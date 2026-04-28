#!/bin/bash

set -e

BASE_URL="http://localhost:3000/api/v1"
TOTAL_POSTS=${TOTAL_POSTS:-200000}
TOTAL_USERS=100
WORKERS=${WORKERS:-20}
TMP_DIR="/tmp/tech_test_seed"

mkdir -p "$TMP_DIR"

# ── Phase 1: create users ──
echo "🌱 Phase 1: creating users..."
for i in $(seq 1 $TOTAL_USERS); do
  IP="192.168.$((i / 256)).$((i % 256))"
  curl -s -X POST "$BASE_URL/posts" \
    -H "Content-Type: application/json" \
    -d "{\"title\":\"Post $i\",\"body\":\"Body $i\",\"login\":\"user_$i\",\"ip\":\"$IP\"}" > /dev/null
done
echo "✅ Phase 1 done."

# ── Phase 2: remaining posts (parallel) ──
REMAINING_POSTS=$((TOTAL_POSTS - TOTAL_USERS))
if [ "$REMAINING_POSTS" -gt 0 ]; then
  echo "📝 Phase 2: creating $REMAINING_POSTS posts..."

  TOTAL_POSTS="$TOTAL_POSTS" TOTAL_USERS="$TOTAL_USERS" ruby -r json << 'RUBY' > "$TMP_DIR/post_payloads.jsonl"
    total_posts = ENV.fetch('TOTAL_POSTS').to_i
    total_users = ENV.fetch('TOTAL_USERS').to_i
    (total_users + 1..total_posts).each do |i|
      user_id = (i % total_users) + 1
      puts({ title: "Post #{i}", body: "Body #{i}", login: "user_#{user_id}", ip: "192.168.1.#{user_id % 50 + 1}" }.to_json)
    end
RUBY

  cat "$TMP_DIR/post_payloads.jsonl" | xargs -d '\n' -P "$WORKERS" -I {} \
    sh -c 'curl -s -X POST "$0/posts" -H "Content-Type: application/json" -d "$1" > /dev/null' "$BASE_URL" {}

  echo "✅ Phase 2 done."
fi

# ── Phase 3: ratings (parallel) ──
TOTAL_RATINGS=$(( (TOTAL_POSTS * 75) / 100 ))
if [ "$TOTAL_RATINGS" -gt 0 ]; then
  echo "⭐ Phase 3: creating $TOTAL_RATINGS ratings..."

  TOTAL_POSTS="$TOTAL_POSTS" TOTAL_USERS="$TOTAL_USERS" ruby -r json << 'RUBY' > "$TMP_DIR/rating_payloads.jsonl"
    total_posts = ENV.fetch('TOTAL_POSTS').to_i
    total_users = ENV.fetch('TOTAL_USERS').to_i
    total_ratings = (total_posts * 75) / 100
    (1..total_ratings).each do |i|
      puts({ post_id: i, user_id: (i % total_users) + 1, value: (i % 5) + 1 }.to_json)
    end
RUBY

  cat "$TMP_DIR/rating_payloads.jsonl" | xargs -d '\n' -P "$WORKERS" -I {} \
    sh -c 'curl -s -X POST "$0/ratings" -H "Content-Type: application/json" -d "$1" > /dev/null' "$BASE_URL" {}

  echo "✅ Phase 3 done."
fi

rm -rf "$TMP_DIR"
echo "🎉 Seed finished!"
