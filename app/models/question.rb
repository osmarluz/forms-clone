class Question < ApplicationRecord
  belongs_to :form
  has_many :questions_answers, dependent: :destroy
  
  validates :title, :question_type, :form, presence: true
  
  enum question_type: [ :short_text, :long_text, :integer, :boolean ]
end
