class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true
  validates :ip, presence: true

  def self.top_by_average_rating(n = 10)
    joins(:ratings)
      .select("posts.*, AVG(ratings.value) AS average_rating")
      .group(:id, :title, :body, :ip, :user_id,
             :created_at, :updated_at)
      .order("average_rating DESC")
      .limit(n)
  end
end
