require 'rails_helper'

RSpec.describe Rating, type: :model do
  describe 'validations' do
    it 'is valid with all required fields' do
      expect(build(:rating)).to be_valid
    end

    it 'is invalid without a value' do
      rating = build(:rating, value: nil)
      expect(rating).not_to be_valid
      expect(rating.errors[:value]).to include('is not included in the list')
    end

    [0, 6, -1, 100].each do |invalid_value|
      it "is invalid with value #{invalid_value}" do
        rating = build(:rating, value: invalid_value)
        expect(rating).not_to be_valid
        expect(rating.errors[:value]).to include('is not included in the list')
      end
    end

    [1, 2, 3, 4, 5].each do |valid_value|
      it "is valid with value #{valid_value}" do
        rating = build(:rating, value: valid_value)
        expect(rating).to be_valid
      end
    end

    it 'is invalid when a user rates the same post twice' do
      post = create(:post)
      user = create(:user)
      create(:rating, post: post, user: user, value: 3)
      duplicate = build(:rating, post: post, user: user, value: 5)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include('has already been taken')
    end
  end

  describe 'associations' do
    it 'belongs to a post' do
      post = create(:post)
      rating = create(:rating, post: post)
      expect(rating.post).to eq(post)
    end

    it 'belongs to a user' do
      user = create(:user)
      rating = create(:rating, user: user)
      expect(rating.user).to eq(user)
    end
  end
end
