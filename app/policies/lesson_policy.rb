class LessonPolicy < ApplicationPolicy
  def index?
    admin? || manager? || learner?
  end

  def show?
    return true if admin?

    if manager?
      record.course.user_courses.exists?(assigned_by_id: user.id)
    elsif learner?
      record.course.user_courses.exists?(user_id: user.id)
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
        scope.joins(course: :user_courses)
             .where(user_courses: { assigned_by_id: user.id })
             .distinct
      elsif learner?
        scope.joins(course: :user_courses)
             .where(user_courses: { user_id: user.id })
             .distinct
      else
        scope.none
      end
    end
  end
end
