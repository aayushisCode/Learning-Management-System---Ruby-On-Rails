
module UserCourse::Operation
  class Create < Trailblazer::Operation
    step :validate_filter_type
    step :fetch_courses
    step :fetch_users
    step :create_assignments

    fail :handle_failure

    def validate_filter_type(ctx, user_course_params:, **)
      filter_type = user_course_params[:filter_type].to_s

      unless %w[user role].include?(filter_type)
        ctx[:error] = "Invalid filter type. Select user or role."
        return false
      end

      true
    end

    def fetch_courses(ctx, user_course_params:, **)
      category_id = user_course_params[:category_id]
      course_ids = Array(user_course_params[:course_ids]).reject(&:blank?)

      if category_id.blank?
        ctx[:error] = "Please select a category"
        return false
      end

      category = Category.find_by(id: category_id)

      unless category
        ctx[:error] = "Selected category does not exist"
        return false
      end

      if course_ids.blank?
        ctx[:error] = "Please select at least one course"
        return false
      end

      ctx[:courses] = Course.where(
        id: course_ids,
        category_id: category.id,
        status: "published"
      )

      if ctx[:courses].count != course_ids.uniq.count
        ctx[:error] = "One or more courses are invalid, unpublished, or do not belong to the selected category"
        return false
      end

      true
    end

    def fetch_users(ctx, user_course_params:, **)
      filter_type = user_course_params[:filter_type].to_s

      case filter_type

      when "user"
        user_ids = Array(user_course_params[:user_ids]).reject(&:blank?)

        if user_ids.blank?
          ctx[:error] = "Please select at least one user"
          return false
        end

        ctx[:users] = User.joins(:role)
                          .where(id: user_ids)
                          .where(roles: { name: %w[manager learner] })

        if ctx[:users].count != user_ids.uniq.count
          ctx[:error] = "One or more selected users are invalid"
          return false
        end

      when "role"
        role_ids = Array(user_course_params[:role_ids]).reject(&:blank?)

        if role_ids.blank?
          ctx[:error] = "Please select at least one role"
          return false
        end

        valid_roles = Role.where(
          id: role_ids,
          name: %w[manager learner]
        )

        if valid_roles.count != role_ids.uniq.count
          ctx[:error] = "One or more selected roles are invalid"
          return false
        end

        ctx[:users] = User.where(role_id: valid_roles.select(:id))

        if ctx[:users].blank?
          ctx[:error] = "No users found for the selected roles"
          return false
        end
      end

      true
    end

    def create_assignments(ctx, **)
      assignments = []

      UserCourse.transaction do
        ctx[:users].each do |user|
          ctx[:courses].each do |course|
            assignment = UserCourse.create!(
              user: user,
              course: course,
              assigned_by: ctx[:current_user]
            )

            # Initialize progress for every lesson
            course.lessons.each do |lesson|
              assignment.lesson_progresses.create!(
                lesson: lesson,
                completed_pages: 0,
                total_pages: lesson.pages.size,
                progress_percentage: 0,
                status: "not_started"
              )
            end

            assignments << assignment
          end
        end
      end

      ctx[:assignments] = assignments
      true

    rescue ActiveRecord::RecordInvalid => e
      ctx[:error] = e.record.errors.full_messages
      false
    end


    def handle_failure(ctx, **)
      ctx[:error] ||= "Course assignment failed"
    end
  end
end
