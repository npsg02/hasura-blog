import PostCard from './PostCard';

interface Post {
  id: string;
  title: string;
  slug: string;
  excerpt: string | null;
  featured_image: string | null;
  published_at: string;
  author: {
    name: string;
    avatar_url: string | null;
  };
  category: {
    name: string;
    slug: string;
  } | null;
}

interface PostListProps {
  posts: Post[];
}

export default function PostList({ posts }: PostListProps) {
  if (posts.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-xl text-gray-600 dark:text-gray-400">
          No posts found.
        </p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {posts.map((post) => (
        <PostCard key={post.id} post={post} />
      ))}
    </div>
  );
}
