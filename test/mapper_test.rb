require 'test_helper'
require 'action_dispatch'
require 'action_dispatch/routing/route_set'
require 'action_controller'

class CommentsController < ActionController::Base; end

class MapperTest < ActiveSupport::TestCase
  setup do
    @set = ActionDispatch::Routing::RouteSet.new
  end

  test 'adds restore route for DestroyedAt model plural resource' do
    draw do
      resources :comments
    end

    params = @set.recognize_path('/comments/:id/restore', method: 'put')
    assert_equal params[:controller], 'comments'
    assert_equal params[:action], 'restore'
  end

  test 'adds restore route for DestroyedAt model singular resource' do
    draw do
      resource :comment
    end

    params = @set.recognize_path('/comment/restore', method: 'put')
    assert_equal params[:controller], 'comments'
    assert_equal params[:action], 'restore'
  end

  test 'does not add restore route for non DestroyedAt plural resource' do
    draw do
      resources :authors
    end

    begin
      params = @set.recognize_path('/authors/:id/restore', method: 'put')
      assert false, 'this should not be reached'
    rescue ActionController::RoutingError
      assert true, 'path not recognized'
    end
  end

  test 'does not add restore route for non DestroyedAt singular resource' do
    draw do
      resource :author
    end

    begin
      params = @set.recognize_path('/author/restore', method: 'put')
      assert false, 'this should not be reached'
    rescue ActionController::RoutingError
      assert true, 'path not recognized'
    end
  end

  private

  def draw(&block)
    @set.draw(&block)
  end

  def url_helpers
    @set.url_helpers
  end

  def clear!
    @set.clear!
  end
end
