require "destroyed_at/version"

module DestroyedAt
  def self.included(klass)
    klass.instance_eval do
      default_scope { where(destroyed_at: nil) }
      after_initialize :_set_destruction_state
      define_model_callbacks :restore
    end
  end

  # Set an object's destroyed_at time.
  def destroy
    run_callbacks(:destroy) do
      destroy_associations
      self.update_attribute(:destroyed_at, DateTime.current)
      @destroyed = true
    end
  end

  # Set an object's destroyed_at time to nil.
  def restore
    state = nil
    run_callbacks(:restore) do
      if state = self.update_attribute(:destroyed_at, nil)
        @destroyed = false
        _restore_associations
      end
    end
    state
  end

  private

  def _set_destruction_state
    @destroyed = destroyed_at.present? if has_attribute?(:destroyed_at)
    # Don't stop the other callbacks from running
    true
  end

  def _restore_associations
    reflections.select { |key, value| value.options[:dependent] == :destroy }.keys.each do |key|
      assoc = association(key)
      if assoc.options[:through] && assoc.options[:dependent] == :destroy
        assoc = association(assoc.options[:through])
      end
      relation = assoc.respond_to?(:scope) ? assoc.scope : assoc.scoped
      relation.unscoped.each { |r| r.restore if r.respond_to? :restore }
    end
  end
end
