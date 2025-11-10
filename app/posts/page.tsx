'use client';

import { gql } from '@apollo/client';
import { useQuery } from '@apollo/client/react';
import PostList from '@/components/blog/PostList';
import LoadingSpinner from '@/components/ui/LoadingSpinner';
import ErrorMessage from '@/components/ui/ErrorMessage';

const GET_POSTS = gql`
  query GetPosts($limit: Int = 10, $offset: Int = 0) {
    posts(
      limit: $limit
      offset: $offset
      order_by: { published_at: desc }
      where: { status: { _eq: "published" } }
    ) {
      id
      title
      slug
      excerpt
      featured_image
      published_at
      author {
        id
        name
        avatar_url
      }
      category {
        id
        name
        slug
      }
    }
  }
`;

export default function PostsPage() {
  const { loading, error, data } = useQuery(GET_POSTS, {
    variables: { limit: 12, offset: 0 },
  });

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message="Failed to load posts. Please try again later." />;

  return (
    <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="mb-8">
        <h1 className="text-4xl font-bold mb-2">All Posts</h1>
        <p className="text-gray-600 dark:text-gray-400">
          Explore our latest articles and stories
        </p>
      </div>
      <PostList posts={(data as any)?.posts || []} />
    </main>
  );
}
