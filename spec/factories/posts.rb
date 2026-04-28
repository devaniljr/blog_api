# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    association :user
    title { 'My title' }
    body { 'My body text' }
    ip { '192.168.1.1' }
  end
end
