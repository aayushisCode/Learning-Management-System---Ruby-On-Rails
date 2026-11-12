
module UserCourse::Operation
  class Show < Trailblazer::Operation
    step :find_user_course

    def find_user_course(ctx, params:, current_user:, **)
      user_course = UserCourse.includes(
        :lesson_progresses,
        :user_quizzes,
        course: :lessons
      ).find_by(id: params[:id])

      return false unless user_course

      # Admin can see all assignments
      return ctx[:model] = user_course if current_user.admin?

      # Manager can see assignments created by them
      if current_user.manager? &&
         user_course.assigned_by_id == current_user.id
        ctx[:model] = user_course
        return true
      end

      # Learner can see their own assignment
      if current_user.learner? &&
         user_course.user_id == current_user.id
        ctx[:model] = user_course
        return true
      end

      ctx[:errors] = {
        msg: "User course not found",
        status: :not_found
      }

      false
    end
  end
end
