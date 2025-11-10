import Link from 'next/link';

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

interface PostCardProps {
  post: Post;
}

export default function PostCard({ post }: PostCardProps) {
  const publishDate = new Date(post.published_at).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });

  return (
    <article className="border rounded-lg overflow-hidden hover:shadow-lg transition-shadow">
      {post.featured_image && (
        <div className="aspect-video bg-gray-200 dark:bg-gray-800">
          <img
            src={post.featured_image}
            alt={post.title}
            className="w-full h-full object-cover"
          />
        </div>
      )}
      <div className="p-6">
        {post.category && (
          <Link
            href={`/categories/${post.category.slug}`}
            className="text-sm text-blue-600 dark:text-blue-400 hover:underline"
          >
            {post.category.name}
          </Link>
        )}
        <h2 className="text-2xl font-bold mt-2 mb-3">
          <Link href={`/posts/${post.slug}`} className="hover:text-blue-600 dark:hover:text-blue-400">
            {post.title}
          </Link>
        </h2>
        {post.excerpt && (
          <p className="text-gray-600 dark:text-gray-400 mb-4">
            {post.excerpt}
          </p>
        )}
        <div className="flex items-center text-sm text-gray-500 dark:text-gray-500">
          {post.author.avatar_url && (
            <img
              src={post.author.avatar_url}
              alt={post.author.name}
              className="w-8 h-8 rounded-full mr-2"
            />
          )}
          <span>{post.author.name}</span>
          <span className="mx-2">•</span>
          <time dateTime={post.published_at}>{publishDate}</time>
        </div>
      </div>
    </article>
  );
}
