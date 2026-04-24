FactoryBot.define do
  factory :rating do
    association :post
    association :user
    value { 3 }
  end
end
