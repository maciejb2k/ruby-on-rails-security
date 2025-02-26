class TaskPolicy < ApplicationPolicy
  def show?
    task.user == user
  end

  def edit?
    task.user == user
  end

  def update?
    task.user == user
  end

  def destroy?
    task.user == user
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.where(user: user)
    end
  end
end
