# frozen_string_literal: true

module Api
  module V1
    class PostsController < ApplicationController
      def create
        result = PostCreationService.call(params)

        if result.success?
          render json: { post: result.data[:post], user: result.data[:user] }, status: :created
        else
          render json: { errors: result.error }, status: :unprocessable_content
        end
      end

      def top
        n = params.fetch(:n, 10).to_i
        posts = Post.top_by_average_rating(n)

        render json: posts.map { |p|
          {
            id: p.id,
            title: p.title,
            body: p.body,
            average_rating: p.average_rating.to_f.round(2)
          }
        }
      end
    end
  end
end
