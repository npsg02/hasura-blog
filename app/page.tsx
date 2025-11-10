'use client';

import { gql } from '@apollo/client';
import { useQuery } from '@apollo/client/react';
import Link from 'next/link';
import PostList from '@/components/blog/PostList';
import LoadingSpinner from '@/components/ui/LoadingSpinner';
import ErrorMessage from '@/components/ui/ErrorMessage';

const GET_RECENT_POSTS = gql`
  query GetRecentPosts($limit: Int = 6) {
    posts(
      limit: $limit
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

export default function Home() {
  const { loading, error, data } = useQuery(GET_RECENT_POSTS, {
    variables: { limit: 6 },
  });

  return (
    <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      {/* Hero Section */}
      <div className="text-center mb-16">
        <h1 className="text-5xl md:text-6xl font-bold mb-4">
          Welcome to Hasura Blog
        </h1>
        <p className="text-xl text-gray-600 dark:text-gray-400 mb-8 max-w-3xl mx-auto">
          A modern blog built with Next.js 14, Hasura GraphQL, and TailwindCSS
        </p>
        <div className="flex justify-center gap-4">
          <Link
            href="/posts"
            className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            Browse Posts
          </Link>
          <Link
            href="/categories"
            className="px-6 py-3 border border-gray-300 dark:border-gray-700 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
          >
            View Categories
          </Link>
        </div>
      </div>

      {/* Recent Posts Section */}
      <div className="mb-12">
        <div className="flex justify-between items-center mb-8">
          <h2 className="text-3xl font-bold">Latest Posts</h2>
          <Link
            href="/posts"
            className="text-blue-600 dark:text-blue-400 hover:underline"
          >
            View all →
          </Link>
        </div>

        {loading ? (
          <LoadingSpinner />
        ) : error ? (
          <ErrorMessage message="Failed to load posts. Please try again later." />
        ) : (
          <PostList posts={(data as any)?.posts || []} />
        )}
      </div>

      {/* Features Section */}
      <div className="mt-20 pt-12 border-t">
        <h2 className="text-3xl font-bold text-center mb-12">Built With Modern Technologies</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="p-6 border rounded-lg">
            <h3 className="text-2xl font-semibold mb-3">Next.js 14</h3>
            <p className="text-gray-600 dark:text-gray-400">
              Server-side rendering, App Router, and optimal performance out of the box
            </p>
          </div>
          <div className="p-6 border rounded-lg">
            <h3 className="text-2xl font-semibold mb-3">Hasura GraphQL</h3>
            <p className="text-gray-600 dark:text-gray-400">
              Instant GraphQL APIs over PostgreSQL with real-time capabilities
            </p>
          </div>
          <div className="p-6 border rounded-lg">
            <h3 className="text-2xl font-semibold mb-3">TailwindCSS</h3>
            <p className="text-gray-600 dark:text-gray-400">
              Utility-first CSS framework for rapid UI development
            </p>
          </div>
        </div>
      </div>
    </main>
  );
}
