class Question < ApplicationRecord
  belongs_to :form
  has_many :questions_answers, dependent: :destroy
  
  validates :title, :type, :form, presence: true
  
  enum type: [ :short_text, :long_text, :integer, :boolean ]
end
