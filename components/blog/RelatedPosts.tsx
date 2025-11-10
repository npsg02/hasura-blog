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

interface RelatedPostsProps {
  posts: Post[];
  title?: string;
}

export default function RelatedPosts({ posts, title = "Related Posts" }: RelatedPostsProps) {
  if (posts.length === 0) {
    return null;
  }

  return (
    <div className="mt-16 pt-12 border-t">
      <h2 className="text-3xl font-bold mb-8">{title}</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {posts.map((post) => (
          <PostCard key={post.id} post={post} />
        ))}
      </div>
    </div>
  );
}
