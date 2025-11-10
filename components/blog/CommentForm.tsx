'use client';

import { useState } from 'react';

interface CommentFormProps {
  postId: string;
  onSubmit: (content: string) => Promise<void>;
}

export default function CommentForm({ postId, onSubmit }: CommentFormProps) {
  const [content, setContent] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!content.trim()) {
      setError('Comment cannot be empty');
      return;
    }

    setIsSubmitting(true);
    setError(null);

    try {
      await onSubmit(content);
      setContent('');
    } catch (err) {
      setError('Failed to submit comment. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label htmlFor="comment" className="block text-sm font-medium mb-2">
          Add a comment
        </label>
        <textarea
          id="comment"
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="Share your thoughts..."
          className="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-800 dark:border-gray-700"
          rows={4}
          disabled={isSubmitting}
        />
      </div>
      {error && (
        <p className="text-red-600 dark:text-red-400 text-sm">{error}</p>
      )}
      <button
        type="submit"
        disabled={isSubmitting}
        className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
      >
        {isSubmitting ? 'Submitting...' : 'Submit Comment'}
      </button>
    </form>
  );
}
