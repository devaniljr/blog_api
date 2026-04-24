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
               status: :unprocessable_entity
      rescue ActiveRecord::RecordNotUnique
        render json: { errors: ["Login has already been taken"] },
               status: :unprocessable_entity
      end
    end
  end
end
