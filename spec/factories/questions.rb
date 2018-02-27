FactoryBot.define do
  factory :question do
    title { FFaker::Lorem.phrase }
    question_type { [ "short_text", "long_text", "integer", "boolean" ].sample }
    form
  end
end
