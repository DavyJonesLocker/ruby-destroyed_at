require 'action_dispatch'

module DestroyedAt::Mapper
  module Routes
    def set_member_mappings_for_resource
      member do
        put :restore if parent_resource.actions.include?(:restore)
      end
      super
    end
  end

  module Resource
    def default_actions
      actions = super
      if self.name.camelcase.singularize.constantize.included_modules.include?(DestroyedAt)
        actions << :restore
      end

      actions
    end
  end
end

ActionDispatch::Routing::Mapper.send(:prepend, DestroyedAt::Mapper::Routes)
ActionDispatch::Routing::Mapper::Resource.send(:prepend, DestroyedAt::Mapper::Resource)
