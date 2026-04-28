# frozen_string_literal: true

module Api
  module V1
    class RatingsController < ApplicationController
      def create
        rating = Rating.new(rating_params)

        if rating.save
          average = rating.post.ratings.average(:value).to_f.round(2)
          render json: { rating: rating, average_rating: average }, status: :created
        else
          render json: { errors: rating.errors.full_messages },
                 status: :unprocessable_content
        end
      rescue ActiveRecord::RecordNotUnique
        render json: { errors: ['You have already rated this post'] },
               status: :unprocessable_content
      end

      private

      def rating_params
        params.permit(:post_id, :user_id, :value)
      end
    end
  end
end
