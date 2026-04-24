FactoryBot.define do
  sequence(:login) { |n| "user_#{n}" }

  factory :user do
    login { generate(:login) }
  end
end
