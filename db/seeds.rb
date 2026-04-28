require "json"

TOTAL_POSTS = 200_000
TOTAL_USERS = 100

Rails.logger.level = Logger::WARN

def api_post(path, payload)
  env = Rack::MockRequest.env_for(path,
    method: "POST",
    input: JSON.generate(payload),
    "CONTENT_TYPE" => "application/json",
    "HTTP_HOST" => "localhost"
  )
  Rails.application.call(env)
end

def timed(label)
  start = Time.now
  yield
  puts "#{label}: #{(Time.now - start).round(1)}s"
end

timed("🌱 Phase 1: creating users") do
  (1..TOTAL_USERS).each do |i|
    api_post("/api/v1/posts", {
      title: "Post #{i}",
      body: "Body #{i}",
      login: "user_#{i}",
      ip: "192.168.1.#{i % 50 + 1}"
    })
  end
end

timed("📝 Phase 2: creating posts") do
  ((TOTAL_USERS + 1)..TOTAL_POSTS).each do |i|
    api_post("/api/v1/posts", {
      title: "Post #{i}",
      body: "Body #{i}",
      login: "user_#{(i % TOTAL_USERS) + 1}",
      ip: "192.168.1.#{(i % TOTAL_USERS) % 50 + 1}"
    })
  end
end

timed("⭐ Phase 3: creating ratings") do
  ((TOTAL_POSTS * 75) / 100).times do |i|
    api_post("/api/v1/ratings", {
      post_id: i + 1,
      user_id: (i % TOTAL_USERS) + 1,
      value: (i % 5) + 1
    })
  end
end
