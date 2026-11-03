module UserCourse::Operation
  class Create <Trailblazer::Operation
    step :validate_filter_type
    step :fetch_users
    step :fetch_courses
    # step :create_assignments
    fail :handle_failure

    def validate_filter_type(ctx, user_course_params:, **)
      filter_type = user_course_params[:filter_type]
      unless %w[user role all].include?(filter_type)
        ctx[:error] = "Invalid filter type"
        return false
      end
      true
    end

    def fetch_users(ctx, user_course_params:, **)
      filter_type = user_course_params[:filter_type].to_s
      ctx[:users] =
      case filter_type
      when "user"
        ids = user_course_params[:user_ids]
        return false if ids.blank?
        User.where(id: ids)
      when "role"
        role_ids = user_course_params[:role_ids]
        return false if role_ids.blank?

        User.joins(:roles).where(role_id: role_ids).where(roles: { name: %w[manager learner] })

      when "all"
        User.joins(:role).where(roles: { name: %w[manager learner] })
      end
      return false if ctx[:users].blank?

      true
    end

    def fetch_courses(ctx, user_course_params:, **)
      course_ids = user_course_params[:course_ids]
      if course_ids.blank?
        ctx[:error] = "Please select at least one course"
        return false
      end
      ctx[:courses] = Course.where(id: course_ids, status: "published")
      if ctx[:courses].count != course_ids.uniq.count
        ctx[:error] ="One or more selected courses are invalid or not published"
        return false
      end
      true
    end



    def handle_failure(ctx, **)
      ctx[:error] ||= "Course assignment failed"
    end
  end
end
