-- Drop triggers
DROP TRIGGER IF EXISTS set_timestamp_comments ON comments;
DROP TRIGGER IF EXISTS set_timestamp_posts ON posts;
DROP TRIGGER IF EXISTS set_timestamp_categories ON categories;
DROP TRIGGER IF EXISTS set_timestamp_users ON users;

-- Drop trigger function
DROP FUNCTION IF EXISTS trigger_set_timestamp();

-- Drop indexes
DROP INDEX IF EXISTS idx_comments_parent_id;
DROP INDEX IF EXISTS idx_comments_author_id;
DROP INDEX IF EXISTS idx_comments_post_id;
DROP INDEX IF EXISTS idx_posts_published_at;
DROP INDEX IF EXISTS idx_posts_status;
DROP INDEX IF EXISTS idx_posts_category_id;
DROP INDEX IF EXISTS idx_posts_author_id;

-- Drop tables
DROP TABLE IF EXISTS post_tags;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;
