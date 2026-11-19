class CategoryPolicy < ApplicationPolicy
  def index?
    admin? || manager? || learner?
  end

  def show?
    return true if admin?

    if manager?
      record.courses.joins(:user_courses)
            .where(user_courses: { assigned_by_id: user.id })
            .exists?
    elsif learner?
      record.courses.joins(:user_courses)
            .where(user_courses: { user_id: user.id })
            .exists?
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
        scope.joins(courses: :user_courses)
             .where(user_courses: { assigned_by_id: user.id })
             .distinct
      elsif learner?
        scope.joins(courses: :user_courses)
             .where(user_courses: { user_id: user.id })
             .distinct
      else
        scope.none
      end
    end
  end
end
