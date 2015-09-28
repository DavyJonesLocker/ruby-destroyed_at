module DestroyedAt
  module BelongsToAssociation
    def handle_dependency
      if load_target && method == :destroy
        DestroyedAt.destroy_target_of_association(owner, target)
      else
        super
      end
    end
  end
end

ActiveRecord::Associations::BelongsToAssociation.send(:prepend, DestroyedAt::BelongsToAssociation)
