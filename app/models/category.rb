class Category < ApplicationRecord
  has_many :courses
  has_many :question_banks
end
