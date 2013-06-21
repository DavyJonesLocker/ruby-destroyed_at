require "destroyed_at/version"

module DestroyedAt
  def self.included(klass)
    klass.instance_eval { default_scope { where(destroyed_at: nil) } }
  end

  def destroy
    run_callbacks(:destroy) do
      destroy_associations
      self.update_attribute(:destroyed_at, DateTime.current)
    end
  end

  def undestroy
   self.update_attribute(:destroyed_at, nil)
   undestroy_associations
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
