module DestroyedAt
  module HasOneAssociation
    def delete(method = options[:dependent])
      if load_target && method == :destroy
        DestroyedAt.destroy_target_of_association(target, owner)
      else
        super
      end
    end
  end
end

ActiveRecord::Associations::HasOneAssociation.send(:prepend, DestroyedAt::HasOneAssociation)
