
require "securerandom"

puts "LMS seed process started..."

# ----------------------------------------
# 1. ROLES (3)
# ----------------------------------------

roles = %w[admin manager learner].index_with do |name|
  Role.find_or_create_by!(name: name)
end

puts "Roles created"

# ----------------------------------------
# 2. CATEGORIES (3)
# ----------------------------------------

category_data = {
  "Motor Insurance" => "Training for motor insurance products, premiums and claims",
  "Health Insurance" => "Training for health insurance products and claims",
  "Life Insurance" => "Training for life insurance products and operations"
}

categories = {}

category_data.each do |name, description|
  category = Category.find_or_initialize_by(category_name: name)
  category.description = description
  category.save!

  categories[name] = category
end

puts "Categories created"

# ----------------------------------------
# 3. COURSES (5)
# ----------------------------------------

course_data = {
  "Motor Insurance" => [
    {
      title: "Motor Insurance Fundamentals",
      description: "Learn OD, TP, CPA, vehicle types and insurance basics."
    },
    {
      title: "Motor Claims and Renewals",
      description: "Learn motor claims, policy renewal and endorsements."
    }
  ],

  "Health Insurance" => [
    {
      title: "Health Insurance Fundamentals",
      description: "Learn coverage, exclusions, underwriting and portability."
    },
    {
      title: "Health Claims Management",
      description: "Learn cashless claims, reimbursement and TPA processes."
    }
  ],

  "Life Insurance" => [
    {
      title: "Life Insurance Fundamentals",
      description: "Learn policy types, premiums, benefits and claims."
    }
  ]
}

courses = []

course_data.each do |category_name, course_list|
  course_list.each do |course_info|
    course = Course.find_or_initialize_by(title: course_info[:title])

    course.category = categories.fetch(category_name)
    course.description = course_info[:description]
    course.status = "published"

    course.save!
    courses << course
  end
end

puts "Courses created"

# ----------------------------------------
# 4. USERS (5)
# 1 admin, 1 manager, 3 learners
# ----------------------------------------

user_data = {
  "admin" => 1,
  "manager" => 1,
  "learner" => 3
}

users = []

user_data.each do |role_name, count|
  count.times do |index|
    email = "#{role_name}#{index + 1}@company.example"

    user = User.find_or_initialize_by(email: email)

    user.role = roles.fetch(role_name)
    user.name = "#{role_name.capitalize} #{index + 1}"
    user.address = "Mumbai, Maharashtra"
    user.contact = "900000#{format('%04d', index + 1)}"

    user.password = "Test@123"
    user.password_confirmation = "Test@123"
    user.jti ||= SecureRandom.uuid

    user.save!
    users << user
  end
end

puts "Users created"

# ----------------------------------------
# 5. LESSONS (5)
# One lesson per course
# ----------------------------------------

lessons = []

courses.each do |course|
  lesson = Lesson.find_or_initialize_by(
    course_id: course.id,
    position: 1
  )

  lesson.title = "#{course.title} - Introduction"
  lesson.content_type = "document"
  lesson.save!
  lessons << lesson
end

puts "Lessons created"

# ----------------------------------------
# 6. LESSON PAGES (5)
# ----------------------------------------

lesson_pages = []

lessons.each do |lesson|
  page = LessonPage.find_or_initialize_by(
    lesson_id: lesson.id,
    position: 1
  )

  page.title = "Introduction"
  page.topic = "Fundamentals"
  page.content = "Introduction to #{lesson.course.title}."
  page.metadata = { "page_type" => "reading" }

  page.save!
  lesson_pages << page
end

puts "Lesson pages created"

# ----------------------------------------
# 7. QUIZZES (5)
# 3 lesson quizzes + 2 final quizzes
# ----------------------------------------

quizzes = []

courses.each_with_index do |course, index|
  quiz_type = index < 3 ? "lesson" : "final"

  quiz = Quiz.find_or_initialize_by(
    course_id: course.id,
    quiz_type: quiz_type,
    title: "#{course.title} #{quiz_type.capitalize} Quiz"
  )

  quiz.lesson = index < 3 ? lessons[index] : nil
  quiz.description = "Assessment for #{course.title}."
  quiz.pass_marks = 1

  quiz.save!
  quizzes << quiz
end

puts "Quizzes created"

# ----------------------------------------
# 8. QUESTIONS (5)
# ----------------------------------------

questions = []

courses.each_with_index do |course, index|
  question = Question.find_or_initialize_by(
    quiz_id: quizzes[index].id,
    position: 1
  )

  question.category = course.category
  question.course = course
  question.question_text =
    "Question #{index + 1}: Is understanding #{course.title} important?"

  question.question_type = index.even? ? "mcq" : "true_false"
  question.marks = 1
  question.status = "active"
  question.position = 1
  question.correct_option_id = nil

  question.save!
  questions << question
end

puts "Questions created"

# ----------------------------------------
# 9. OPTIONS
# 2 options per question
# ----------------------------------------

options = []

questions.each do |question|
  option_texts =
    if question.question_type == "true_false"
      ["True", "False"]
    else
      ["Yes, it is important", "No, it is not important"]
    end

  question_options = []

  option_texts.each_with_index do |option_text, position|
    option = Option.find_or_initialize_by(
      question_id: question.id,
      position: position + 1
    )

    option.option_text = option_text
    option.save!

    question_options << option
    options << option
  end

  question.update!(
    correct_option_id: question_options.first.id
  )
end

puts "Options created"

# ----------------------------------------
# 10. USER COURSE ASSIGNMENTS
# Assign only to learners
# ----------------------------------------

learner_users = users.select do |user|
  user.role.name == "learner"
end

admin_user = users.find do |user|
  user.role.name == "admin"
end

user_courses = []

courses.each_with_index do |course, index|
  user = learner_users[index % learner_users.length]

  user_course = UserCourse.find_or_initialize_by(
    user_id: user.id,
    course_id: course.id
  )

  user_course.assigned_by = admin_user
  user_course.status = "assigned"
  user_course.assigned_at = Time.current
  user_course.due_date = Date.current + 30.days
  user_course.progress_percentage = 0
  user_course.completed_lessons = 0
  user_course.total_lessons = 1

  user_course.save!
  user_courses << user_course
end

puts "User courses created"

# ----------------------------------------
# 11. USER LESSON PROGRESSES
# ----------------------------------------

user_courses.each_with_index do |user_course, index|
  progress = UserLessonProgress.find_or_initialize_by(
    user_course_id: user_course.id,
    lesson_id: lessons[index].id
  )

  progress.status = "not_started"
  progress.progress_percentage = 0
  progress.metadata = {}

  progress.save!
end

puts "User lesson progresses created"

# ----------------------------------------
# 12. USER QUIZZES
# ----------------------------------------

user_quizzes = []

user_courses.each_with_index do |user_course, index|
  user_quiz = UserQuiz.find_or_initialize_by(
    user_course_id: user_course.id,
    quiz_id: quizzes[index].id,
    attempt_number: 1
  )

  user_quiz.status = "submitted"
  user_quiz.score = 1
  user_quiz.total_marks = 1
  user_quiz.percentage = 100
  user_quiz.result = "pass"
  user_quiz.started_at ||= Time.current
  user_quiz.submitted_at ||= Time.current

  user_quiz.save!
  user_quizzes << user_quiz
end

puts "User quizzes created"

# ----------------------------------------
# 14. USER OPTIONS (5)
# ----------------------------------------

user_quizzes.each_with_index do |user_quiz, index|
  user_option = UserOption.find_or_initialize_by(
    user_quiz_id: user_quiz.id,
    question_id: questions[index].id
  )

  user_option.option_id = options[index * 2].id
  user_option.save!
end

puts "User options created"

# ----------------------------------------
# FINAL SUMMARY
# ----------------------------------------

puts "--------------------------------"
puts "LMS seed completed successfully!"

{
  roles: Role.count,
  categories: Category.count,
  courses: Course.count,
  users: User.count,
  lessons: Lesson.count,
  lesson_pages: LessonPage.count,
  quizzes: Quiz.count,
  questions: Question.count,
  options: Option.count,
  user_courses: UserCourse.count,
  user_lesson_progresses: UserLessonProgress.count,
  user_quizzes: UserQuiz.count,
  user_options: UserOption.count
}.each do |table, count|
  puts "#{table}: #{count}"
end

puts "--------------------------------"
