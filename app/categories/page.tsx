'use client';

import { gql } from '@apollo/client';
import { useQuery } from '@apollo/client/react';
import Link from 'next/link';
import LoadingSpinner from '@/components/ui/LoadingSpinner';
import ErrorMessage from '@/components/ui/ErrorMessage';

const GET_CATEGORIES = gql`
  query GetCategories {
    categories {
      id
      name
      slug
      description
    }
  }
`;

export default function CategoriesPage() {
  const { loading, error, data } = useQuery(GET_CATEGORIES);

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message="Failed to load categories. Please try again later." />;

  const categories = (data as any)?.categories || [];

  return (
    <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="mb-8">
        <h1 className="text-4xl font-bold mb-2">Categories</h1>
        <p className="text-gray-600 dark:text-gray-400">
          Browse posts by category
        </p>
      </div>

      {categories.length === 0 ? (
        <div className="text-center py-12">
          <p className="text-xl text-gray-600 dark:text-gray-400">
            No categories found.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {categories.map((category: any) => (
            <Link
              key={category.id}
              href={`/categories/${category.slug}`}
              className="block p-6 border rounded-lg hover:shadow-lg transition-shadow"
            >
              <h2 className="text-2xl font-bold mb-2 text-blue-600 dark:text-blue-400">
                {category.name}
              </h2>
              {category.description && (
                <p className="text-gray-600 dark:text-gray-400">
                  {category.description}
                </p>
              )}
            </Link>
          ))}
        </div>
      )}
    </main>
  );
}
