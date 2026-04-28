# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'validations' do
    it 'is valid with all required fields' do
      expect(build(:post)).to be_valid
    end

    it 'is invalid without a title' do
      post = build(:post, title: nil)
      expect(post).not_to be_valid
      expect(post.errors[:title]).to include("can't be blank")
    end

    it 'is invalid without a body' do
      post = build(:post, body: nil)
      expect(post).not_to be_valid
      expect(post.errors[:body]).to include("can't be blank")
    end

    it 'is invalid without an ip' do
      post = build(:post, ip: nil)
      expect(post).not_to be_valid
      expect(post.errors[:ip]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      user = create(:user)
      post = create(:post, user: user)
      expect(post.user).to eq(user)
    end
  end

  describe 'dependent destroy' do
    it 'destroys associated ratings when post is destroyed' do
      post = create(:post)
      create(:rating, post: post, user: create(:user))
      expect { post.destroy }.to change(Rating, :count).by(-1)
    end
  end
end
