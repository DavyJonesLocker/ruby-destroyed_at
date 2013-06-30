require "destroyed_at/version"

module DestroyedAt
  def self.included(klass)
    klass.instance_eval do
      default_scope { where(destroyed_at: nil) }
      after_initialize :_set_destruction_state
      define_model_callbacks :undestroy
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
  def undestroy
    state = nil
    run_callbacks(:undestroy) do
      if state = self.update_attribute(:destroyed_at, nil)
        @destroyed = false
        _undestroy_associations
      end
    end
    state
  end

  private

  def _set_destruction_state
    @destroyed = destroyed_at.present?
  end

  def _undestroy_associations
    reflections.select { |key, value| value.options[:dependent] == :destroy }.keys.each do |key|
      assoc = association(key)
      if assoc.options[:through] && assoc.options[:dependent] == :destroy
        assoc = association(assoc.options[:through])
      end
      assoc.scoped.unscoped.each { |r| r.undestroy if r.respond_to? :undestroy }
    end
  end
end
