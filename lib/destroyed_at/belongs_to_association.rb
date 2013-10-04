module DestroyedAt
  module BelongsToAssociation
    def handle_dependency
      if load_target
        if options[:dependent] == :destroy && target.respond_to?(:destroyed_at)
          target.destroy(owner.destroyed_at)
        else
          super
        end
      end
    end
  end
end

ActiveRecord::Associations::BelongsToAssociation.send(:prepend, DestroyedAt::BelongsToAssociation)
