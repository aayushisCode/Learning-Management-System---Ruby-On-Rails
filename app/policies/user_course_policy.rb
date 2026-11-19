class UserCoursePolicy < ApplicationPolicy
  def index?
    admin? || manager? || learner?
  end

  def show?
    admin? ||
      (manager? && record.assigned_by_id == user.id) ||
      (learner? && record.user_id == user.id)
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  def start_quiz?
    learner? && record.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      case user&.role&.name
      when "admin"
        scope.all
      when "manager"
        scope.where(assigned_by_id: user.id)
      when "learner"
        scope.where(user_id: user.id)
      else
        scope.none
      end
    end
  end
end
