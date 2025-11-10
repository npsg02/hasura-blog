'use client';

import { useState } from 'react';
import { gql } from '@apollo/client';
import { useQuery } from '@apollo/client/react';
import PostList from '@/components/blog/PostList';
import LoadingSpinner from '@/components/ui/LoadingSpinner';
import ErrorMessage from '@/components/ui/ErrorMessage';
import Pagination from '@/components/ui/Pagination';

const POSTS_PER_PAGE = 12;

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
    posts_aggregate(where: { status: { _eq: "published" } }) {
      aggregate {
        count
      }
    }
  }
`;

export default function PostsPage() {
  const [currentPage, setCurrentPage] = useState(1);
  
  const { loading, error, data } = useQuery(GET_POSTS, {
    variables: { 
      limit: POSTS_PER_PAGE, 
      offset: (currentPage - 1) * POSTS_PER_PAGE 
    },
  });

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message="Failed to load posts. Please try again later." />;

  const totalCount = (data as any)?.posts_aggregate?.aggregate?.count || 0;
  const totalPages = Math.ceil(totalCount / POSTS_PER_PAGE);

  return (
    <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="mb-8">
        <h1 className="text-4xl font-bold mb-2">All Posts</h1>
        <p className="text-gray-600 dark:text-gray-400">
          Explore our latest articles and stories ({totalCount} posts)
        </p>
      </div>
      <PostList posts={(data as any)?.posts || []} />
      {totalPages > 1 && (
        <Pagination
          currentPage={currentPage}
          totalPages={totalPages}
          onPageChange={setCurrentPage}
        />
      )}
    </main>
  );
}
