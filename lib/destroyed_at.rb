require "destroyed_at/version"

module DestroyedAt
  def self.included(klass)
    klass.instance_eval { default_scope { where(destroyed_at: nil) } }
  end

  # Set an object's destroyed_at time.
  def destroy
    run_callbacks(:destroy) do
      destroy_associations
      self.update_attribute(:destroyed_at, DateTime.current)
    end
  end

  # Set an object's destroyed at time to nil.
  def undestroy
   if state = self.update_attribute(:destroyed_at, nil)
     undestroy_associations
   end
   state
  end

  private

  def undestroy_associations
    association_cache.select { |key, value| value.options[:dependent] == :destroy }.keys.each do |key|
      assoc = association(key)
      if assoc.options[:through] && assoc.options[:dependent] == :destroy
        assoc = association(assoc.options[:through])
      end
      assoc.scoped.unscoped.each { |r| r.undestroy }
    end
  end
end
