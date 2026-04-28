# frozen_string_literal: true

class RatingCreationService < ApplicationService
  def initialize(params)
    @params = params
  end

  def call
    rating = Rating.new(
      post_id: @params[:post_id],
      user_id: @params[:user_id],
      value: @params[:value]
    )

    if rating.save
      average = rating.post.ratings.average(:value).to_f.round(2)
      success(rating: rating, average_rating: average)
    else
      failure(rating.errors.full_messages)
    end
  rescue ActiveRecord::RecordNotUnique
    failure('You have already rated this post')
  end
end
