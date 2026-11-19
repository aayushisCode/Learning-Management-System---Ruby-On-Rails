class UserQuizPolicy < ApplicationPolicy
  def show?
    admin? ||
      (manager? && manager_has_access?) ||
      (learner? && learner_owns?)
  end

  def create?
    learner? &&
      learner_owns? &&
      record.quiz.course_id == record.user_course.course_id
  end

  def answer?
    learner? && learner_owns? && record.status == "in_progress"
  end

  def submit?
    learner? && learner_owns? && record.status == "in_progress"
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      case user&.role&.name
      when "admin"
        scope.all
      when "manager"
        scope.joins(:user_course)
             .where(user_courses: { assigned_by_id: user.id })
      when "learner"
        scope.joins(:user_course)
             .where(user_courses: { user_id: user.id })
      else
        scope.none
      end
    end
  end

  private

  def learner_owns?
    record.user_course.user_id == user.id
  end

  def manager_has_access?
    record.user_course.assigned_by_id == user.id
  end
end
