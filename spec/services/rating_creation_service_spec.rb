# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RatingCreationService do
  describe '.call' do
    let(:post) { create(:post) }
    let(:user) { create(:user) }

    context 'with valid params' do
      let(:params) { { post_id: post.id, user_id: user.id, value: 4 } }

      it 'creates a rating' do
        result = described_class.call(params)

        expect(result.success?).to be true
        expect(result.data[:rating].value).to eq(4)
        expect(result.data[:rating].post).to eq(post)
      end

      it 'returns the average rating' do
        create(:rating, post: post, user: create(:user), value: 2)
        result = described_class.call(params)

        # (2 + 4) / 2 = 3.0
        expect(result.data[:average_rating]).to eq(3.0)
      end
    end

    context 'with invalid value' do
      let(:params) { { post_id: post.id, user_id: user.id, value: 0 } }

      it 'returns failure with errors' do
        result = described_class.call(params)

        expect(result.success?).to be false
        expect(result.error).to include('Value is not included in the list')
      end
    end

    context 'when user already rated the post' do
      before { create(:rating, post: post, user: user, value: 3) }

      let(:params) { { post_id: post.id, user_id: user.id, value: 5 } }

      it 'returns failure with errors' do
        result = described_class.call(params)

        expect(result.success?).to be false
        expect(result.error).to include('User has already been taken')
      end
    end
  end
end
