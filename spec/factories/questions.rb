FactoryBot.define do
  factory :question do
    title { FFaker::Lorem.phrase }
    question_type { rand(0..3) } # :short_text, :long_text, :integer, :boolean
    form
  end
end
