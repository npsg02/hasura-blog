export default function Home() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-8">
      <main className="max-w-4xl mx-auto text-center">
        <h1 className="text-5xl font-bold mb-4">
          Welcome to Hasura Blog
        </h1>
        <p className="text-xl text-gray-600 dark:text-gray-400 mb-8">
          A modern blog built with Next.js 14, Hasura GraphQL, and TailwindCSS
        </p>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-12">
          <div className="p-6 border rounded-lg">
            <h2 className="text-2xl font-semibold mb-2">Next.js 14</h2>
            <p className="text-gray-600 dark:text-gray-400">
              Server-side rendering and App Router
            </p>
          </div>
          <div className="p-6 border rounded-lg">
            <h2 className="text-2xl font-semibold mb-2">Hasura</h2>
            <p className="text-gray-600 dark:text-gray-400">
              GraphQL API with PostgreSQL
            </p>
          </div>
          <div className="p-6 border rounded-lg">
            <h2 className="text-2xl font-semibold mb-2">TailwindCSS</h2>
            <p className="text-gray-600 dark:text-gray-400">
              Utility-first CSS framework
            </p>
          </div>
        </div>
      </main>
    </div>
  );
}
