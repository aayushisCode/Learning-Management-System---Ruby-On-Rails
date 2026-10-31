# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "LMS seed process.."

# 1. Create roles
roles = %w[admin manager learner].index_with { |role_name| Role.find_or_create_by!(name: role_name) }
puts "Roles Created"

# 2. Create 3 insurance categories

category_data = {
  "Motor Insurance"=>"Training for motor insurance products, premiums and claims",
  "Health Insurance"=> "Training for health insurance products and claims",
  "Life Insurance"=> "raining for life insurance products and operations."
}
categories={}

category_data.each { |name, description| categories[name] = Category.find_or_create_by!(category_name: name) { |category| category.description = description } }

puts "3 Categories created"
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

course_data.each do |category_name, courses|
  courses.each do |course_info|
    course = Course.find_or_initialize_by(
      title: course_info[:title]
    )

    course.category = categories.fetch(category_name)
    course.description = course_info[:description]
    course.status = "published"
    course.save!
  end
end

puts "5 courses created."

# -----------------------------------
# 4. Create 10 users
# 2 admins, 3 managers, 5 learners
# -----------------------------------

user_data = {
  "admin" => 2,
  "manager" => 3,
  "learner" => 5
}

user_data.each do |role_name, count|
  count.times do |index|
    email = "#{role_name}#{index + 1}@company.example"

    user = User.find_or_initialize_by(email: email)
    user.role = roles.fetch(role_name)

    # Used for initial development/testing only.
    user.password = "Test@123"
    user.password_confirmation = "Test@123"

    user.save!
  end
end

puts "10 users created or updated."
puts "LMS seed process completed!"
