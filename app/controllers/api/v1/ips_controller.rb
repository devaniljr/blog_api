module Api
  module V1
    class IpsController < ApplicationController
      def index
        results = Post.joins(:user)
                      .group("posts.ip")
                      .pluck(Arel.sql("posts.ip, array_agg(DISTINCT users.login) AS logins"))

        render json: results.map { |ip, logins| { ip: ip, logins: logins } }
      end
    end
  end
end
