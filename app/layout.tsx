import type { Metadata } from "next";
import "./globals.css";
import { ApolloWrapper } from "@/lib/apollo-provider";
import { ReduxProvider } from "@/lib/redux/provider";
import Header from "@/components/ui/Header";
import Footer from "@/components/ui/Footer";

export const metadata: Metadata = {
  title: "Hasura Blog",
  description: "A blog built with Next.js, Hasura, and TailwindCSS",
  keywords: ["blog", "next.js", "hasura", "graphql", "tailwindcss"],
  authors: [{ name: "Hasura Blog Team" }],
  openGraph: {
    title: "Hasura Blog",
    description: "A blog built with Next.js, Hasura, and TailwindCSS",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased flex flex-col min-h-screen">
        <ReduxProvider>
          <ApolloWrapper>
            <Header />
            <div className="flex-grow">{children}</div>
            <Footer />
          </ApolloWrapper>
        </ReduxProvider>
      </body>
    </html>
  );
}
