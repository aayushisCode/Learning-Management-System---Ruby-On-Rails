
module UserCourse::Operation
  class Create < ApplicationOperation
    step :authorize_create
    step :validate_filter_type
    step :fetch_course
    step :fetch_users
    step :create_assignments
    step :set_response

    fail :handle_failure

    # Step 1: Validate selection type
    def authorize_create(ctx, **)
      authorize_record(ctx, UserCourse, :create?)
    end

    def validate_filter_type(ctx, params:, **)
      source = params[:user_course].presence || params
      ctx[:params] = source.permit(
        :filter_type, :category_id, :course_id, user_ids: [], role_ids: []
      ).to_h.with_indifferent_access
      params = ctx[:params]
      filter_type = params[:filter_type].to_s

      unless %w[user role].include?(filter_type)
        ctx[:error] = {
          msg: "Invalid filter type. Select user or role.",
          status: :unprocessable_entity
        }
        return false
      end

      true
    end

    # Step 2: Fetch ONE published course
    def fetch_course(ctx, params:, **)
      category_id = params[:category_id]
      course_id = params[:course_id]

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

      course = Course.includes(lessons: :lesson_pages).find_by(
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
    def fetch_users(ctx, params:, **)
      filter_type = params[:filter_type].to_s

      case filter_type
      when "user"
        user_ids = Array(params[:user_ids])
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
        role_ids = Array(params[:role_ids])
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
    # Create ONE UserLessonProgress record per lesson
    def create_assignments(ctx, **)
      assignments = []
      course = ctx[:course]

      UserCourse.transaction do
        ctx[:users].each do |user|
          assignment = UserCourse.create!(
            user: user,
            course: course,
            assigned_by: ctx[:current_user],
            status: "assigned",
            assigned_at: Time.current,
            due_date: 30.days.from_now.to_date,
            progress_percentage: 0,
            completed_lessons: 0,
            total_lessons: course.lessons.size
          )

          course.lessons.each do |lesson|
            assignment.user_lesson_progresses.create!(
              lesson: lesson,
              status: "not_started",
              metadata: {
                "pages" => lesson.lesson_pages.each_with_object({}) do |page, pages|
                  pages[page.id.to_s] = {
                    "completed" => false
                  }
                end,
                "completed_pages" => 0,
                "total_pages" => lesson.lesson_pages.size,
                "progress_percentage" => 0
              }
            )
          end

          assignments << assignment
        end
      end

      ctx[:assignments] = assignments
      true

    rescue ActiveRecord::RecordInvalid => e
      error_messages = e.record.errors.full_messages

      Rails.logger.error(
        "UserCourse assignment failed: " \
        "#{e.record.class} - #{error_messages.join(', ')}"
      )

      ctx[:errors] = error_messages

      ctx[:error] = {
        msg: "Unable to create course assignments: #{error_messages.join(', ')}",
        status: :unprocessable_entity
      }

      false

    rescue ActiveRecord::RecordNotUnique => e
      Rails.logger.error(
        "Duplicate course assignment: #{e.message}"
      )

      ctx[:error] = {
        msg: "One or more users are already assigned to this course.",
        status: :unprocessable_entity
      }

      false

    rescue StandardError => e
      Rails.logger.error(
        "Unexpected course assignment error: #{e.class} - #{e.message}"
      )

      ctx[:error] = {
        msg: "An unexpected error occurred while creating course assignments.",
        status: :internal_server_error
      }

      false
    end

    # Failure handling
    def set_response(ctx, **)
      ctx[:response_data] = {
        message: "Course assigned successfully",
        data: ctx[:assignments].map do |assignment|
          {
            id: assignment.id,
            user_id: assignment.user_id,
            course_id: assignment.course_id,
            status: assignment.status,
            assigned_at: assignment.assigned_at,
            due_date: assignment.due_date
          }
        end
      }
      ctx[:status] = :created
    end

    def handle_failure(ctx, **)
      ctx[:error] ||= {
        msg: "Course assignment failed.",
        status: :unprocessable_entity
      }
    end
  end
end
