# frozen_string_literal: true

class PostCreationService < ApplicationService
  def initialize(params)
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      user = User.find_or_create_by!(login: @params[:login])
      post = user.posts.build(
        title: @params[:title],
        body: @params[:body],
        ip: @params[:ip]
      )
      post.save!
      success(post: post, user: user)
    end
  rescue ActiveRecord::RecordInvalid => e
    failure(e.record.errors.full_messages)
  rescue ActiveRecord::RecordNotUnique
    failure('Login has already been taken')
  end
end
