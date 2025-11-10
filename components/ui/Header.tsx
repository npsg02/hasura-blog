import Link from 'next/link';

export default function Header() {
  return (
    <header className="border-b">
      <nav className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <div className="flex items-center gap-8">
            <Link href="/" className="text-2xl font-bold text-blue-600 dark:text-blue-400">
              Hasura Blog
            </Link>
            <div className="hidden md:flex gap-6">
              <Link
                href="/posts"
                className="text-gray-700 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400 transition-colors"
              >
                Posts
              </Link>
              <Link
                href="/categories"
                className="text-gray-700 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400 transition-colors"
              >
                Categories
              </Link>
            </div>
          </div>
        </div>
      </nav>
    </header>
  );
}
