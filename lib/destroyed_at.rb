require "destroyed_at/version"

module DestroyedAt
  def self.included(klass)
    klass.instance_eval { default_scope { where(destroyed_at: nil) } }
  end

  def destroy
    run_callbacks(:destroy) { self.update_attribute(:destroyed_at, DateTime.current) }
  end

  def undestroy
   self.update_attribute(:destroyed_at, nil)
  end
end
