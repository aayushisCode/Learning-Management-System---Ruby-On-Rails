
module UserCourse::Operation
  class Index < Trailblazer::Operation
    step :fetch_user_courses

    def fetch_user_courses(ctx, current_user:, **)
      user_courses = UserCourse.includes(
        :course,
        :lesson_progresses,
        course: :lessons
      )

      ctx[:models] =
        if current_user.admin?
          user_courses
        elsif current_user.manager?
          user_courses.where(assigned_by_id: current_user.id)
        elsif current_user.learner?
          user_courses.where(user_id: current_user.id)
        else
          UserCourse.none
        end

      true
    end
  end
end
