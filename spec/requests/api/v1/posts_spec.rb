# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Posts', type: :request do
  describe 'POST /api/v1/posts' do
    context 'with valid params' do
      let(:params) do
        { title: 'My post', body: 'My body', login: 'joao', ip: '192.168.1.1' }
      end

      it 'creates a new post' do
        expect { post '/api/v1/posts', params: params }.to change(Post, :count).by(1)
      end

      it 'creates a new user when login does not exist' do
        expect { post '/api/v1/posts', params: params }.to change(User, :count).by(1)
      end

      it 'returns status 201' do
        post '/api/v1/posts', params: params
        expect(response).to have_http_status(:created)
      end

      it 'returns the post and user in the response' do
        post '/api/v1/posts', params: params
        json = response.parsed_body

        expect(json['post']['title']).to eq('My post')
        expect(json['post']['body']).to eq('My body')
        expect(json['post']['ip']).to eq('192.168.1.1')
        expect(json['user']['login']).to eq('joao')
      end

      it 'reuses existing user when login already exists' do
        create(:user, login: 'joao')
        expect { post '/api/v1/posts', params: params }.not_to(change(User, :count))
      end
    end

    context 'with invalid params' do
      let(:params) do
        { title: '', body: 'My body', login: 'joao', ip: '192.168.1.1' }
      end

      it 'does not create a post' do
        expect { post '/api/v1/posts', params: params }.not_to(change(Post, :count))
      end

      it 'returns status 422' do
        post '/api/v1/posts', params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors' do
        post '/api/v1/posts', params: params
        json = response.parsed_body
        expect(json['errors']).to include("Title can't be blank")
      end
    end
  end

  describe 'GET /api/v1/posts/top' do
    before do
      rated_post_a = create(:post, title: 'Post A')
      rated_post_b = create(:post, title: 'Post B')
      rated_post_c = create(:post, title: 'Post C')

      # Post A: ratings [3, 5] → média 4.0
      create(:rating, post: rated_post_a, user: create(:user), value: 3)
      create(:rating, post: rated_post_a, user: create(:user), value: 5)

      # Post B: rating [2] → média 2.0
      create(:rating, post: rated_post_b, user: create(:user), value: 2)

      # Post C: rating [5] → média 5.0
      create(:rating, post: rated_post_c, user: create(:user), value: 5)

      # Post D: SEM ratings → não aparece no resultado
      create(:post, title: 'Post D')
    end

    it 'returns posts ordered by average rating' do
      get '/api/v1/posts/top'
      json = response.parsed_body

      expect(json[0]['title']).to eq('Post C')
      expect(json[1]['title']).to eq('Post A')
      expect(json[2]['title']).to eq('Post B')
    end

    it 'excludes posts without ratings' do
      get '/api/v1/posts/top'
      json = response.parsed_body

      titles = json.pluck('title')
      expect(titles).not_to include('Post D')
    end

    it 'respects the n parameter' do
      get '/api/v1/posts/top', params: { n: 2 }
      json = response.parsed_body

      expect(json.size).to eq(2)
    end

    it 'returns id, title, body and average_rating' do
      get '/api/v1/posts/top'
      json = response.parsed_body

      expect(json[0].keys).to contain_exactly(
        'id', 'title', 'body', 'average_rating'
      )
    end
  end
end
