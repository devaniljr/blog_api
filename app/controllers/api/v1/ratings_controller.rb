# frozen_string_literal: true

module Api
  module V1
    class RatingsController < ApplicationController
      def create
        result = RatingCreationService.call(params)

        if result.success?
          render json: { rating: result.data[:rating], average_rating: result.data[:average_rating] },
                 status: :created
        else
          render json: { errors: result.error },
                 status: :unprocessable_content
        end
      end
    end
  end
end
