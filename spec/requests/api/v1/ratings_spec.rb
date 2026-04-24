require 'rails_helper'

RSpec.describe 'Api::V1::Ratings', type: :request do
  describe 'POST /api/v1/ratings' do
    context 'with valid params' do
      let(:rated_post) { create(:post) }
      let(:user) { create(:user) }
      let(:payload) do
        { post_id: rated_post.id, user_id: user.id, value: 4 }
      end

      it 'creates a new rating' do
        expect { post '/api/v1/ratings', params: payload }.to change { Rating.count }.by(1)
      end

      it 'returns status 201' do
        post '/api/v1/ratings', params: payload
        expect(response).to have_http_status(:created)
      end

      it 'returns the average rating of the post' do
        create(:rating, post: rated_post, user: create(:user), value: 2)
        post '/api/v1/ratings', params: payload
        json = JSON.parse(response.body)

        # existing: 2, new: 4 → average: 3.0
        expect(json['average_rating']).to eq(3.0)
      end
    end

    context 'with invalid params' do
      let(:rated_post) { create(:post) }
      let(:user) { create(:user) }
      let(:payload) do
        { post_id: rated_post.id, user_id: user.id, value: 0 }
      end

      it 'does not create a rating' do
        expect { post '/api/v1/ratings', params: payload }.not_to change { Rating.count }
      end

      it 'returns status 422' do
        post '/api/v1/ratings', params: payload
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors' do
        post '/api/v1/ratings', params: payload
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Value is not included in the list')
      end
    end

    context 'when user already rated the post' do
      let(:rated_post) { create(:post) }
      let(:user) { create(:user) }

      before { create(:rating, post: rated_post, user: user, value: 3) }

      it 'does not create a duplicate rating' do
        payload = { post_id: rated_post.id, user_id: user.id, value: 5 }
        expect { post '/api/v1/ratings', params: payload }.not_to change { Rating.count }
      end

      it 'returns status 422' do
        payload = { post_id: rated_post.id, user_id: user.id, value: 5 }
        post '/api/v1/ratings', params: payload
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns an error message' do
        payload = { post_id: rated_post.id, user_id: user.id, value: 5 }
        post '/api/v1/ratings', params: payload
        json = JSON.parse(response.body)
        expect(json['errors']).to include('User has already been taken')
      end
    end
  end
end
