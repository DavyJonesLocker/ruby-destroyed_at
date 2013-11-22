require 'action_dispatch'

module DestroyedAt::Routes
  def set_member_mappings_for_resource
    member do
      put :restore if parent_resource.actions.include?(:restore)
    end
    super
  end
end

ActionDispatch::Routing::Mapper.send(:prepend, DestroyedAt::Routes)

module DestroyedAt::Resource
  def default_actions
    actions = super
    if self.name.camelcase.singularize.constantize.included_modules.include?(DestroyedAt)
      actions << :restore
    end

    actions
  end
end

ActionDispatch::Routing::Mapper::Resources::SingletonResource.send(:prepend, DestroyedAt::Resource)
ActionDispatch::Routing::Mapper::Resource.send(:prepend, DestroyedAt::Resource)
