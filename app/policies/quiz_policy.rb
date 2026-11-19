class QuizPolicy < ApplicationPolicy
  def index?
    admin? || manager? || learner?
  end

  def show?
    admin? ||
      (manager? && manager_has_access?) ||
      (learner? && learner_has_access?)
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
      case user&.role&.name
      when "admin"
        scope.all
      when "manager"
        scope.joins(course: :user_courses)
             .where(user_courses: { assigned_by_id: user.id })
             .distinct
      when "learner"
        scope.joins(course: :user_courses)
             .where(user_courses: { user_id: user.id })
             .distinct
      else
        scope.none
      end
    end
  end

  private

  def manager_has_access?
    UserCourse.exists?(
      course_id: record.course_id,
      assigned_by_id: user.id
    )
  end

  def learner_has_access?
    UserCourse.exists?(
      course_id: record.course_id,
      user_id: user.id
    )
  end
end
