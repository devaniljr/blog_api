# frozen_string_literal: true

module Api
  module V1
    class PostsController < ApplicationController
      def create
        ActiveRecord::Base.transaction do
          user = User.find_or_create_by!(login: params[:login])
          post = user.posts.build(title: params[:title],
                                  body: params[:body],
                                  ip: params[:ip])
          post.save!
          render json: { post: post, user: user }, status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages },
               status: :unprocessable_content
      rescue ActiveRecord::RecordNotUnique
        render json: { errors: ['Login has already been taken'] },
               status: :unprocessable_content
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
