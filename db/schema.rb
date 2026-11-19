# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_19_143000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "category_name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((category_name)::text)", name: "index_categories_on_lower_category_name", unique: true
  end

  create_table "courses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "category_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "status", default: "draft", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "category_id, lower((title)::text)", name: "index_courses_on_category_and_lower_title", unique: true
    t.index ["category_id"], name: "index_courses_on_category_id"
    t.index ["status"], name: "index_courses_on_status"
    t.check_constraint "status::text = ANY (ARRAY['draft'::character varying, 'published'::character varying, 'archived'::character varying]::text[])", name: "courses_valid_status"
  end

  create_table "lesson_pages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "lesson_id", null: false
    t.string "title", null: false
    t.string "topic"
    t.text "content"
    t.jsonb "metadata", default: {}, null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id", "position"], name: "index_lesson_page_num", unique: true
    t.index ["lesson_id"], name: "index_lesson_pages_on_lesson_id"
    t.check_constraint "\"position\" > 0", name: "lesson_pages_valid_position"
  end

  create_table "lessons", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "course_id", null: false
    t.string "title", null: false
    t.string "content_type"
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "position"], name: "index_lessons_on_course_and_position", unique: true
    t.index ["course_id"], name: "index_lessons_on_course_id"
    t.check_constraint "\"position\" > 0", name: "lessons_valid_position"
  end

  create_table "options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "question_id", null: false
    t.string "option_text", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "position"], name: "index_options_on_question_and_position", unique: true
    t.index ["question_id"], name: "index_options_on_question_id"
    t.check_constraint "\"position\" > 0", name: "options_valid_position"
  end

  create_table "questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "category_id", null: false
    t.uuid "course_id", null: false
    t.uuid "quiz_id", null: false
    t.text "question_text", null: false
    t.string "question_type", null: false
    t.uuid "correct_option_id"
    t.float "marks", null: false
    t.integer "position", null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_questions_on_category_id"
    t.index ["correct_option_id"], name: "index_questions_on_correct_option_id"
    t.index ["course_id"], name: "index_questions_on_course_id"
    t.index ["quiz_id", "position"], name: "index_questions_on_quiz_id_and_position", unique: true
    t.index ["quiz_id"], name: "index_questions_on_quiz_id"
    t.check_constraint "\"position\" > 0", name: "questions_valid_position"
    t.check_constraint "marks > 0::double precision", name: "questions_valid_marks"
    t.check_constraint "question_type::text = ANY (ARRAY['mcq'::character varying, 'true_false'::character varying]::text[])", name: "questions_valid_type"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying]::text[])", name: "questions_valid_status"
  end

  create_table "quizzes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "course_id", null: false
    t.uuid "lesson_id"
    t.string "title", null: false
    t.text "description"
    t.string "quiz_type", null: false
    t.float "pass_marks", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_one_final_quiz_per_course", unique: true, where: "((quiz_type)::text = 'final'::text)"
    t.index ["course_id"], name: "index_quizzes_on_course_id"
    t.index ["lesson_id"], name: "index_one_lesson_quiz_per_lesson", unique: true, where: "((quiz_type)::text = 'lesson'::text)"
    t.index ["lesson_id"], name: "index_quizzes_on_lesson_id"
    t.check_constraint "pass_marks >= 0::double precision", name: "quizzes_valid_pass_marks"
    t.check_constraint "quiz_type::text = 'lesson'::text AND lesson_id IS NOT NULL OR quiz_type::text = 'final'::text AND lesson_id IS NULL", name: "quizzes_lesson_or_final_reference"
    t.check_constraint "quiz_type::text = ANY (ARRAY['final'::character varying, 'lesson'::character varying]::text[])", name: "quizzes_valid_quiz_type"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_roles_on_lower_name", unique: true
  end

  create_table "user_courses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "course_id", null: false
    t.uuid "assigned_by_id", null: false
    t.string "status", default: "assigned", null: false
    t.datetime "assigned_at"
    t.date "due_date"
    t.datetime "completed_at"
    t.float "progress_percentage", default: 0.0, null: false
    t.integer "completed_lessons", default: 0, null: false
    t.integer "total_lessons", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "current_lesson_id"
    t.integer "current_page_number"
    t.index ["assigned_by_id"], name: "index_user_courses_on_assigned_by_id"
    t.index ["course_id"], name: "index_user_courses_on_course_id"
    t.index ["current_lesson_id"], name: "index_user_courses_on_current_lesson_id"
    t.index ["status"], name: "index_user_courses_on_status"
    t.index ["user_id", "course_id"], name: "index_user_courses_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_user_courses_on_user_id"
    t.check_constraint "completed_lessons <= total_lessons", name: "user_courses_completed_lessons_limit"
    t.check_constraint "completed_lessons >= 0 AND total_lessons >= 0", name: "user_courses_valid_lesson_counts"
    t.check_constraint "progress_percentage >= 0::double precision AND progress_percentage <= 100::double precision", name: "user_courses_valid_progress"
    t.check_constraint "status::text = ANY (ARRAY['assigned'::character varying, 'in_progress'::character varying, 'completed'::character varying]::text[])", name: "user_courses_valid_status"
  end

  create_table "user_lesson_progresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_course_id", null: false
    t.uuid "lesson_id", null: false
    t.string "status", default: "not_started", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.float "progress_percentage", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_user_lesson_progresses_on_lesson_id"
    t.index ["status"], name: "index_user_lesson_progresses_on_status"
    t.index ["user_course_id", "lesson_id"], name: "index_user_lesson_progresses_on_course_and_lesson", unique: true
    t.index ["user_course_id"], name: "index_user_lesson_progresses_on_user_course_id"
    t.check_constraint "progress_percentage >= 0::double precision AND progress_percentage <= 100::double precision", name: "user_lesson_progresses_valid_percentage"
    t.check_constraint "status::text = ANY (ARRAY['not_started'::character varying, 'in_progress'::character varying, 'completed'::character varying]::text[])", name: "user_lesson_progresses_valid_status"
  end

  create_table "user_options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_quiz_id", null: false
    t.uuid "question_id", null: false
    t.uuid "option_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_user_options_on_option_id"
    t.index ["question_id"], name: "index_user_options_on_question_id"
    t.index ["user_quiz_id", "question_id"], name: "index_user_options_on_quiz_and_question", unique: true
    t.index ["user_quiz_id"], name: "index_user_options_on_user_quiz_id"
  end

  create_table "user_quizzes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_course_id", null: false
    t.uuid "quiz_id", null: false
    t.integer "attempt_number", default: 1, null: false
    t.float "score"
    t.float "total_marks"
    t.float "pass_marks"
    t.float "percentage"
    t.string "status", default: "in_progress", null: false
    t.string "result"
    t.datetime "started_at"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_user_quizzes_on_quiz_id"
    t.index ["user_course_id", "quiz_id", "attempt_number"], name: "index_user_quizzes_on_assignment_quiz_attempt", unique: true
    t.index ["user_course_id"], name: "index_user_quizzes_on_user_course_id"
    t.check_constraint "attempt_number > 0", name: "user_quizzes_valid_attempt_number"
    t.check_constraint "percentage IS NULL OR percentage >= 0::double precision AND percentage <= 100::double precision", name: "user_quizzes_valid_percentage"
    t.check_constraint "result IS NULL OR (result::text = ANY (ARRAY['pass'::character varying, 'fail'::character varying]::text[]))", name: "user_quizzes_valid_result"
    t.check_constraint "score IS NULL OR score >= 0::double precision", name: "user_quizzes_valid_score"
    t.check_constraint "status::text = 'submitted'::text OR result IS NULL", name: "user_quizzes_result_requires_submission"
    t.check_constraint "status::text = ANY (ARRAY['in_progress'::character varying, 'submitted'::character varying]::text[])", name: "user_quizzes_valid_status"
    t.check_constraint "total_marks IS NULL OR total_marks >= 0::double precision", name: "user_quizzes_valid_total_marks"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "role_id", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.text "address", null: false
    t.string "contact", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "jti", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "courses", "categories"
  add_foreign_key "lesson_pages", "lessons"
  add_foreign_key "lessons", "courses"
  add_foreign_key "options", "questions"
  add_foreign_key "questions", "categories"
  add_foreign_key "questions", "courses"
  add_foreign_key "questions", "options", column: "correct_option_id"
  add_foreign_key "questions", "quizzes"
  add_foreign_key "quizzes", "courses"
  add_foreign_key "quizzes", "lessons"
  add_foreign_key "user_courses", "courses"
  add_foreign_key "user_courses", "lessons", column: "current_lesson_id"
  add_foreign_key "user_courses", "users"
  add_foreign_key "user_courses", "users", column: "assigned_by_id"
  add_foreign_key "user_lesson_progresses", "lessons"
  add_foreign_key "user_lesson_progresses", "user_courses"
  add_foreign_key "user_options", "options"
  add_foreign_key "user_options", "questions"
  add_foreign_key "user_options", "user_quizzes"
  add_foreign_key "user_quizzes", "quizzes"
  add_foreign_key "user_quizzes", "user_courses"
  add_foreign_key "users", "roles"
end
