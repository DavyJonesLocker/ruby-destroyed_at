require 'destroyed_at/version'
require 'destroyed_at/belongs_to_association'
require 'destroyed_at/has_many_association'
require 'destroyed_at/has_one_association'
require 'destroyed_at/mapper'

module DestroyedAt
  def self.included(klass)
    klass.instance_eval do
      default_scope { where(destroyed_at: nil) }
      after_initialize :_set_destruction_state
      define_model_callbacks :restore
      extend ClassMethods
    end
  end

  def self.destroy_target_of_association(owner, target)
    if target.respond_to?(:destroyed_at) && owner.respond_to?(:destroyed_at)
      target.destroy(owner.destroyed_at)
    else
      # this will delete the target if DestroyedAt is not included.
      target.destroy
    end
  end

  def self.has_destroy_at?(object)
    object.class.included_modules.include?(DestroyedAt)
  end

  module ClassMethods
    def destroyed(time = nil)
      query = where.not(destroyed_at: nil)
      query.where_values.reject! do |node|
        Arel::Nodes::Equality === node && node.left.name == 'destroyed_at' && node.right.nil?
      end
      time ? query.where(destroyed_at: time) : query.where.not(destroyed_at: nil)
    end
  end

  # Set an object's destroyed_at time.
  def destroy(timestamp = nil)
    transaction do
      timestamp ||= @marked_for_destruction_at || current_time_from_proper_timezone
      raw_write_attribute(:destroyed_at, timestamp)

      run_callbacks(:destroy) do
        destroy_associations
        self.class.unscoped.where(self.class.primary_key => id).update_all(destroyed_at: timestamp)
        @destroyed = true

        next unless ActiveRecord::VERSION::STRING >= '4.2'
        each_counter_cached_associations do |association|
          foreign_key = association.reflection.foreign_key.to_sym
          next if destroyed_by_association && destroyed_by_association.foreign_key.to_sym == foreign_key
          next unless send(association.reflection.name)
          association.decrement_counters
        end

        @destroyed
      end
    end
  end

  def mark_for_destruction(timestamp = nil)
    @marked_for_destruction_at = timestamp

    super()
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
    _reflections.select { |key, value| value.options[:dependent] == :destroy }.keys.each do |key|
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
