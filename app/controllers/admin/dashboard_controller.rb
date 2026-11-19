module Admin
  class DashboardController < BaseController
    def index
      render json: {
        data: {
          overview: {
            total_users: User.count,
            total_managers: Role.find_by(name: "manager")&.users&.count || 0,
            total_learners: Role.find_by(name: "learner")&.users&.count || 0,
            total_categories: Category.count,
            total_courses: Course.count,
            total_lessons: Lesson.count,
            total_quizzes: Quiz.count,
            total_questions: Question.count,
            total_assignments: UserCourse.count
          }
        }
      }, status: :ok
    end
  end
end
