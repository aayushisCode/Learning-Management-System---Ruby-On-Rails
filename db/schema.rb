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

ActiveRecord::Schema[8.1].define(version: 2026_11_03_115621) do
  create_table "categories", force: :cascade do |t|
    t.string "category_name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "courses", force: :cascade do |t|
    t.integer "category_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "status", default: "draft"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_courses_on_category_id"
  end

  create_table "lesson_progresses", force: :cascade do |t|
    t.integer "user_course_id", null: false
    t.integer "lesson_id", null: false
    t.string "status", default: "not_started", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "completed_pages", default: 0, null: false
    t.integer "total_pages", default: 0, null: false
    t.decimal "progress_percentage", precision: 5, scale: 2, default: "0.0", null: false
    t.index ["lesson_id"], name: "index_lesson_progresses_on_lesson_id"
    t.index ["user_course_id", "lesson_id"], name: "index_lesson_progresses_on_user_course_id_and_lesson_id", unique: true
    t.index ["user_course_id"], name: "index_lesson_progresses_on_user_course_id"
  end

  create_table "lessons", force: :cascade do |t|
    t.integer "course_id", null: false
    t.string "title", null: false
    t.string "content_type"
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "position"], name: "index_lessons_on_course_id_and_position", unique: true
    t.index ["course_id"], name: "index_lessons_on_course_id"
  end

  create_table "options", force: :cascade do |t|
    t.integer "question_id", null: false
    t.string "option_text", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "position"], name: "index_options_on_question_id_and_position", unique: true
    t.index ["question_id"], name: "index_options_on_question_id"
  end

  create_table "question_banks", force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "course_id", null: false
    t.integer "quiz_id", null: false
    t.text "question_text", null: false
    t.string "question_type", null: false
    t.bigint "correct_option_id"
    t.decimal "marks", precision: 6, scale: 2, default: "1.0", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "active", null: false
    t.index ["category_id"], name: "index_question_banks_on_category_id"
    t.index ["course_id"], name: "index_question_banks_on_course_id"
    t.index ["quiz_id"], name: "index_question_banks_on_quiz_id"
    t.check_constraint "question_type IN ('mcq', 'true_false')", name: "questions_valid_type"
    t.check_constraint "status IN ('active', 'inactive')", name: "questions_valid_status"
  end

  create_table "quizzes", force: :cascade do |t|
    t.integer "course_id", null: false
    t.integer "lesson_id"
    t.string "title", null: false
    t.text "description"
    t.string "quiz_type", null: false
    t.integer "pass_marks", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_quizzes_on_course_id"
    t.index ["lesson_id"], name: "index_quizzes_on_lesson_id"
    t.check_constraint "(quiz_type = 'lesson' AND lesson_id IS NOT NULL) OR (quiz_type = 'final' AND lesson_id IS NULL)", name: "quizzes_lesson_or_final_reference"
    t.check_constraint "quiz_type IN ('final', 'lesson')", name: "quizzes_valid_quize_type"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "user_courses", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "course_id", null: false
    t.integer "assigned_by_id"
    t.string "status", default: "assigned", null: false
    t.datetime "assigned_at"
    t.date "due_date"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "progress_percentage", precision: 5, scale: 2, default: "0.0", null: false
    t.integer "completed_lessons", default: 0, null: false
    t.integer "total_lessons", default: 0, null: false
    t.index ["assigned_by_id"], name: "index_user_courses_on_assigned_by_id"
    t.index ["course_id"], name: "index_user_courses_on_course_id"
    t.index ["user_id", "course_id"], name: "index_user_courses_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_user_courses_on_user_id"
  end

  create_table "user_options", force: :cascade do |t|
    t.integer "question_id", null: false
    t.integer "option_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_quiz_id", null: false
    t.index ["option_id"], name: "index_user_options_on_option_id"
    t.index ["question_id"], name: "index_user_options_on_question_id"
    t.index ["user_quiz_id", "question_id"], name: "index_user_options_on_quiz_and_question", unique: true
    t.index ["user_quiz_id"], name: "index_user_options_on_user_quiz_id"
  end

  create_table "user_quizzes", force: :cascade do |t|
    t.integer "user_course_id", null: false
    t.integer "quiz_id", null: false
    t.integer "attempt_number", default: 1, null: false
    t.decimal "score", precision: 8, scale: 2
    t.decimal "total_marks", precision: 8, scale: 2
    t.decimal "percentage", precision: 5, scale: 2
    t.string "status", default: "in_progress", null: false
    t.string "result"
    t.datetime "started_at"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_user_quizzes_on_quiz_id"
    t.index ["user_course_id", "quiz_id", "attempt_number"], name: "index_user_quizzes_on_course_quiz_attempt", unique: true
    t.index ["user_course_id"], name: "index_user_quizzes_on_user_course_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role_id"
    t.string "password_digest"
    t.string "name"
    t.text "address"
    t.string "contact"
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "courses", "categories"
  add_foreign_key "lesson_progresses", "lessons"
  add_foreign_key "lesson_progresses", "user_courses"
  add_foreign_key "lessons", "courses"
  add_foreign_key "options", "question_banks", column: "question_id"
  add_foreign_key "question_banks", "categories"
  add_foreign_key "question_banks", "courses"
  add_foreign_key "question_banks", "options", column: "correct_option_id"
  add_foreign_key "question_banks", "quizzes"
  add_foreign_key "quizzes", "courses"
  add_foreign_key "quizzes", "lessons"
  add_foreign_key "user_courses", "courses"
  add_foreign_key "user_courses", "users"
  add_foreign_key "user_courses", "users", column: "assigned_by_id"
  add_foreign_key "user_options", "options"
  add_foreign_key "user_options", "question_banks", column: "question_id"
  add_foreign_key "user_options", "user_quizzes"
  add_foreign_key "user_quizzes", "quizzes"
  add_foreign_key "user_quizzes", "user_courses"
  add_foreign_key "users", "roles"
end
