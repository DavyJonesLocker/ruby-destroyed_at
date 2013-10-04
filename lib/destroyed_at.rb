require 'destroyed_at/version'
require 'destroyed_at/has_many_association'

module DestroyedAt
  def self.included(klass)
    klass.instance_eval do
      default_scope { where(destroyed_at: nil) }
      after_initialize :_set_destruction_state
      define_model_callbacks :restore
    end
  end

  # Set an object's destroyed_at time.
  def destroy(timestamp = nil)
    timestamp ||= current_time_from_proper_timezone
    raw_write_attribute(:destroyed_at, timestamp)
    run_callbacks(:destroy) do
      destroy_associations
      self.class.unscoped.where(self.class.primary_key => id).update_all(destroyed_at: timestamp)
      @destroyed = true
    end
  end

  # Set an object's destroyed_at time to nil.
  def restore
    state = nil
    run_callbacks(:restore) do
      if state = (self.class.unscoped.where(self.class.primary_key => id).update_all(destroyed_at: nil) == 1)
        _restore_associations
        raw_write_attribute(:destroyed_at, nil)
        @destroyed = false
        true
      end
    end
    state
  end

  def persisted?
    !new_record? && destroyed_at.present? || super
  end

  def delete
    self.destroyed_at = nil
    super
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
      reload_association = false
      if assoc.options[:through] && assoc.options[:dependent] == :destroy
        assoc = association(assoc.options[:through])
      end
      assoc.association_scope.each do |r|
        if r.respond_to?(:restore) && r.destroyed_at == self.destroyed_at
          r.restore
          reload_association = true
        end
      end

      if reload_association
        assoc.reload
      end
    end
  end
end
