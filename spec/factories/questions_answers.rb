FactoryBot.define do
  factory :questions_answer do
    content { FFaker::Lorem.phrase }
    answer
    question
  end
end