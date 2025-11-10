'use client';

import { gql } from '@apollo/client';
import { useQuery } from '@apollo/client/react';
import { useParams } from 'next/navigation';
import Link from 'next/link';
import PostList from '@/components/blog/PostList';
import LoadingSpinner from '@/components/ui/LoadingSpinner';
import ErrorMessage from '@/components/ui/ErrorMessage';

const GET_POSTS_BY_CATEGORY = gql`
  query GetPostsByCategory($categorySlug: String!, $limit: Int = 10) {
    posts(
      where: {
        category: { slug: { _eq: $categorySlug } }
        status: { _eq: "published" }
      }
      limit: $limit
      order_by: { published_at: desc }
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
    categories(where: { slug: { _eq: $categorySlug } }) {
      id
      name
      slug
      description
    }
  }
`;

export default function CategoryPage() {
  const params = useParams();
  const slug = params.slug as string;

  const { loading, error, data } = useQuery(GET_POSTS_BY_CATEGORY, {
    variables: { categorySlug: slug, limit: 12 },
  });

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message="Failed to load posts. Please try again later." />;

  const category = (data as any)?.categories?.[0];
  const posts = (data as any)?.posts || [];

  if (!category) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-12 text-center">
        <h1 className="text-3xl font-bold mb-4">Category Not Found</h1>
        <p className="text-gray-600 dark:text-gray-400 mb-6">
          The category you're looking for doesn't exist.
        </p>
        <Link
          href="/categories"
          className="text-blue-600 dark:text-blue-400 hover:underline"
        >
          View all categories
        </Link>
      </div>
    );
  }

  return (
    <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="mb-8">
        <Link
          href="/categories"
          className="text-blue-600 dark:text-blue-400 hover:underline mb-4 inline-block"
        >
          ← Back to categories
        </Link>
        <h1 className="text-4xl font-bold mb-2">{category.name}</h1>
        {category.description && (
          <p className="text-gray-600 dark:text-gray-400">
            {category.description}
          </p>
        )}
      </div>

      {posts.length === 0 ? (
        <div className="text-center py-12">
          <p className="text-xl text-gray-600 dark:text-gray-400">
            No posts in this category yet.
          </p>
        </div>
      ) : (
        <PostList posts={posts} />
      )}
    </main>
  );
}
