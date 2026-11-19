

class UserLessonProgressPolicy < ApplicationPolicy
  def index?
    admin? || manager? || learner?
  end

  def show?
    can_view_progress?
  end

  def navigate_page?
    learner? || own_progress?
  end
  # next_page marks the previous page as completed.
  # Therefore, only the learner can call it.
  # def next_page?
  #   own_progress?
  # end


  # # Previous page navigation does not modify progress.
  # def prev_page?
  #   can_view_progress?
  # end


  private

  def can_view_progress?
    assignment = user_course_record
    return false unless assignment

    UserCoursePolicy.new(user, assignment).show?
  end

  def own_progress?
    assignment = user_course_record

    learner? &&
      assignment.present? &&
      assignment.user_id == user.id
  end

  def user_course_record
    return record if record.is_a?(UserCourse)

    record.user_course if record.respond_to?(:user_course)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if admin?

      if manager?
        scope.joins(:user_course)
             .where(user_courses: { assigned_by_id: user.id })
      elsif learner?
        scope.joins(:user_course)
             .where(user_courses: { user_id: user.id })
      else
        scope.none
      end
    end
  end
end
