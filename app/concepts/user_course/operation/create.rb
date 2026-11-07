
module UserCourse::Operation
  class Create < Trailblazer::Operation
    step :validate_filter_type
    step :fetch_course
    step :fetch_users
    step :create_assignments

    fail :handle_failure

    # Step 1: Validate selection type
    def validate_filter_type(ctx, user_course_params:, **)
      filter_type = user_course_params[:filter_type].to_s

      unless %w[user role].include?(filter_type)
        ctx[:error] = {
          msg: "Invalid filter type. Select user or role.",
          status: :unprocessable_entity
        }
        return false
      end

      true
    end

    # Step 2: Fetch ONE course
    def fetch_course(ctx, user_course_params:, **)
      category_id = user_course_params[:category_id]
      course_id = user_course_params[:course_id]

      if category_id.blank? || course_id.blank?
        ctx[:error] = {
          msg: "Please select a category and one course.",
          status: :unprocessable_entity
        }
        return false
      end

      category = Category.find_by(id: category_id)

      unless category
        ctx[:error] = {
          msg: "Selected category does not exist.",
          status: :not_found
        }
        return false
      end

      course = Course.includes(:lessons).find_by(
        id: course_id,
        category_id: category.id,
        status: "published"
      )

      unless course
        ctx[:error] = {
          msg: "Selected course is invalid or unpublished.",
          status: :unprocessable_entity
        }
        return false
      end

      ctx[:course] = course
      true
    end

    # Step 3: Fetch multiple users based on selection
    def fetch_users(ctx, user_course_params:, **)
      filter_type = user_course_params[:filter_type].to_s

      case filter_type

      when "user"
        user_ids = Array(user_course_params[:user_ids])
                    .reject(&:blank?)
                    .uniq

        if user_ids.blank?
          ctx[:error] = {
            msg: "Please select at least one user.",
            status: :unprocessable_entity
          }
          return false
        end

        users = User.joins(:role)
                    .where(id: user_ids)
                    .where(roles: { name: %w[manager learner] })

        if users.count != user_ids.count
          ctx[:error] = {
            msg: "One or more selected users are invalid.",
            status: :unprocessable_entity
          }
          return false
        end

        ctx[:users] = users

      when "role"
        role_ids = Array(user_course_params[:role_ids])
                    .reject(&:blank?)
                    .uniq

        if role_ids.blank?
          ctx[:error] = {
            msg: "Please select at least one role.",
            status: :unprocessable_entity
          }
          return false
        end

        roles = Role.where(
          id: role_ids,
          name: %w[manager learner]
        )

        if roles.count != role_ids.count
          ctx[:error] = {
            msg: "One or more selected roles are invalid.",
            status: :unprocessable_entity
          }
          return false
        end

        users = User.where(role_id: roles.select(:id))

        if users.blank?
          ctx[:error] = {
            msg: "No users found for the selected roles.",
            status: :unprocessable_entity
          }
          return false
        end

        ctx[:users] = users
      end

      true
    end

    # Step 4: Assign ONE course to MULTIPLE users
    def create_assignments(ctx, **)
      assignments = []
      course = ctx[:course]

      UserCourse.transaction do
        ctx[:users].each do |user|
          assignment = UserCourse.create!(
            user: user,
            course: course,
            assigned_by: ctx[:current_user]
          )

          course.lessons.each do |lesson|
            assignment.lesson_progresses.create!(
              lesson: lesson,
              completed_pages: 0,
              total_pages: Array(lesson.pages).size,
              progress_percentage: 0,
              status: "not_started"
            )
          end

          assignments << assignment
        end
      end

      ctx[:assignments] = assignments
      true

    rescue ActiveRecord::RecordInvalid => e
      ctx[:errors] = e.record.errors.full_messages

      ctx[:error] = {
        msg: "Unable to create course assignments.",
        status: :unprocessable_entity
      }

      false
    end

    # Failure handling
    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "Course assignment failed.",
        status: :unprocessable_entity
      }
    end
  end
end
