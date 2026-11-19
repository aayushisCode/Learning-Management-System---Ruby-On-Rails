class CoursePolicy < ApplicationPolicy
  def index?
    admin? || manager? || learner?
  end

  def show?
    return true if admin?

    if manager?
      record.user_courses.exists?(assigned_by_id: user.id)
    elsif learner?
      record.user_courses.exists?(user_id: user.id)
    else
      false
    end
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

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if admin?

      if manager?
        scope.joins(:user_courses)
             .where(user_courses: { assigned_by_id: user.id })
             .distinct
      elsif learner?
        scope.joins(:user_courses)
             .where(user_courses: { user_id: user.id })
             .distinct
      else
        scope.none
      end
    end
  end
end
