import Link from 'next/link';

interface CategoryBadgeProps {
  name: string;
  slug: string;
}

export default function CategoryBadge({ name, slug }: CategoryBadgeProps) {
  return (
    <Link
      href={`/categories/${slug}`}
      className="inline-block px-3 py-1 text-sm bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 rounded-full hover:bg-blue-200 dark:hover:bg-blue-800 transition-colors"
    >
      {name}
    </Link>
  );
}
