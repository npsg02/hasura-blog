'use client';

import { gql } from '@apollo/client';
import { useQuery } from '@apollo/client/react';
import { useParams } from 'next/navigation';
import Link from 'next/link';
import CategoryBadge from '@/components/blog/CategoryBadge';
import CommentList from '@/components/blog/CommentList';
import LoadingSpinner from '@/components/ui/LoadingSpinner';
import ErrorMessage from '@/components/ui/ErrorMessage';

const GET_POST_BY_SLUG = gql`
  query GetPostBySlug($slug: String!) {
    posts(where: { slug: { _eq: $slug } }) {
      id
      title
      slug
      excerpt
      content
      featured_image
      published_at
      created_at
      updated_at
      author {
        id
        name
        bio
        avatar_url
      }
      category {
        id
        name
        slug
        description
      }
      post_tags {
        tag {
          id
          name
          slug
        }
      }
      comments(where: { status: { _eq: "approved" } }, order_by: { created_at: asc }) {
        id
        content
        created_at
        author {
          id
          name
          avatar_url
        }
      }
    }
  }
`;

export default function PostPage() {
  const params = useParams();
  const slug = params.slug as string;

  const { loading, error, data } = useQuery(GET_POST_BY_SLUG, {
    variables: { slug },
  });

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message="Failed to load post. Please try again later." />;

  const post = (data as any)?.posts?.[0];

  if (!post) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-12 text-center">
        <h1 className="text-3xl font-bold mb-4">Post Not Found</h1>
        <p className="text-gray-600 dark:text-gray-400 mb-6">
          The post you're looking for doesn't exist or has been removed.
        </p>
        <Link
          href="/posts"
          className="text-blue-600 dark:text-blue-400 hover:underline"
        >
          Back to all posts
        </Link>
      </div>
    );
  }

  const publishDate = new Date(post.published_at).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });

  return (
    <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <article>
        {/* Header */}
        <header className="mb-8">
          {post.category && (
            <div className="mb-4">
              <CategoryBadge name={post.category.name} slug={post.category.slug} />
            </div>
          )}
          <h1 className="text-4xl md:text-5xl font-bold mb-4">{post.title}</h1>
          {post.excerpt && (
            <p className="text-xl text-gray-600 dark:text-gray-400 mb-6">
              {post.excerpt}
            </p>
          )}
          <div className="flex items-center gap-4">
            {post.author.avatar_url ? (
              <img
                src={post.author.avatar_url}
                alt={post.author.name}
                className="w-12 h-12 rounded-full"
              />
            ) : (
              <div className="w-12 h-12 rounded-full bg-gray-300 dark:bg-gray-700 flex items-center justify-center">
                <span className="text-gray-600 dark:text-gray-300 font-semibold text-lg">
                  {post.author.name.charAt(0).toUpperCase()}
                </span>
              </div>
            )}
            <div>
              <div className="font-semibold">{post.author.name}</div>
              <div className="text-sm text-gray-500 dark:text-gray-500">
                <time dateTime={post.published_at}>{publishDate}</time>
              </div>
            </div>
          </div>
        </header>

        {/* Featured Image */}
        {post.featured_image && (
          <div className="mb-8 rounded-lg overflow-hidden">
            <img
              src={post.featured_image}
              alt={post.title}
              className="w-full h-auto"
            />
          </div>
        )}

        {/* Content */}
        <div
          className="prose dark:prose-invert max-w-none mb-12"
          dangerouslySetInnerHTML={{ __html: post.content }}
        />

        {/* Tags */}
        {post.post_tags && post.post_tags.length > 0 && (
          <div className="mb-12 pb-8 border-b">
            <h3 className="text-sm font-semibold mb-3 text-gray-700 dark:text-gray-300">
              Tags:
            </h3>
            <div className="flex flex-wrap gap-2">
              {post.post_tags.map(({ tag }: any) => (
                <span
                  key={tag.id}
                  className="px-3 py-1 text-sm bg-gray-100 dark:bg-gray-800 rounded-full"
                >
                  {tag.name}
                </span>
              ))}
            </div>
          </div>
        )}

        {/* Author Bio */}
        {post.author.bio && (
          <div className="mb-12 p-6 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <h3 className="text-lg font-semibold mb-3">About the Author</h3>
            <div className="flex gap-4">
              {post.author.avatar_url && (
                <img
                  src={post.author.avatar_url}
                  alt={post.author.name}
                  className="w-16 h-16 rounded-full"
                />
              )}
              <div>
                <div className="font-semibold mb-2">{post.author.name}</div>
                <p className="text-gray-600 dark:text-gray-400">{post.author.bio}</p>
              </div>
            </div>
          </div>
        )}

        {/* Comments Section */}
        <div className="mt-12">
          <h2 className="text-2xl font-bold mb-6">
            Comments ({post.comments.length})
          </h2>
          <CommentList comments={post.comments} />
        </div>
      </article>
    </main>
  );
}
