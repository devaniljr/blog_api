require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with a login' do
      expect(build(:user)).to be_valid
    end

    it 'is invalid without a login' do
      user = build(:user, login: nil)
      expect(user).not_to be_valid
      expect(user.errors[:login]).to include("can't be blank")
    end

    it 'is invalid with a duplicate login' do
      create(:user, login: 'joao')
      user = build(:user, login: 'joao')
      expect(user).not_to be_valid
      expect(user.errors[:login]).to include('has already been taken')
    end
  end

  describe 'dependent destroy' do
    it 'destroys associated posts when user is destroyed' do
      user = create(:user)
      create(:post, user: user)
      expect { user.destroy }.to change { Post.count }.by(-1)
    end

    it 'destroys associated ratings when user is destroyed' do
      user = create(:user)
      post = create(:post, user: user)
      create(:rating, post: post, user: user)
      expect { user.destroy }.to change { Rating.count }.by(-1)
    end
  end
end
