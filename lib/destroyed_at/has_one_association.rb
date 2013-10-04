module DestroyedAt
  module HasOneAssociation
    def delete(method = options[:dependent])
      if load_target
        if method == :destroy && target.respond_to?(:destroyed_at)
          target.destroy(owner.destroyed_at)
        else
          super
        end
      end
    end
  end
end

ActiveRecord::Associations::HasOneAssociation.send(:prepend, DestroyedAt::HasOneAssociation)
