-- Insert sample users
INSERT INTO users (id, email, name, role, bio) VALUES
('11111111-1111-1111-1111-111111111111', 'admin@example.com', 'Admin User', 'admin', 'Blog administrator'),
('22222222-2222-2222-2222-222222222222', 'john@example.com', 'John Doe', 'author', 'Tech enthusiast and blogger'),
('33333333-3333-3333-3333-333333333333', 'jane@example.com', 'Jane Smith', 'author', 'Software developer and writer');

-- Insert sample categories
INSERT INTO categories (id, name, slug, description) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Technology', 'technology', 'Posts about technology and software development'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Web Development', 'web-development', 'Web development tutorials and tips'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'DevOps', 'devops', 'DevOps practices and tools');

-- Insert sample tags
INSERT INTO tags (id, name, slug) VALUES
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Next.js', 'nextjs'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'React', 'react'),
('ffffffff-ffff-ffff-ffff-ffffffffffff', 'GraphQL', 'graphql'),
('10101010-1010-1010-1010-101010101010', 'Hasura', 'hasura'),
('20202020-2020-2020-2020-202020202020', 'TailwindCSS', 'tailwindcss'),
('30303030-3030-3030-3030-303030303030', 'Docker', 'docker');

-- Insert sample posts
INSERT INTO posts (id, title, slug, excerpt, content, author_id, category_id, status, published_at) VALUES
(
    '11111111-aaaa-bbbb-cccc-111111111111',
    'Getting Started with Next.js 14',
    'getting-started-with-nextjs-14',
    'Learn how to build modern web applications with Next.js 14 and the App Router.',
    '# Getting Started with Next.js 14\n\nNext.js 14 introduces powerful features for building modern web applications. In this post, we''ll explore the new App Router and Server Components.\n\n## Key Features\n\n- Server Components by default\n- Improved performance\n- Better developer experience\n\n## Installation\n\n```bash\nnpx create-next-app@latest my-app\n```\n\nLet''s dive in!',
    '22222222-2222-2222-2222-222222222222',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'published',
    NOW() - INTERVAL '5 days'
),
(
    '22222222-aaaa-bbbb-cccc-222222222222',
    'Building GraphQL APIs with Hasura',
    'building-graphql-apis-with-hasura',
    'Discover how to quickly build production-ready GraphQL APIs using Hasura.',
    '# Building GraphQL APIs with Hasura\n\nHasura is a powerful GraphQL engine that gives you instant GraphQL APIs on your databases.\n\n## Why Hasura?\n\n- Instant GraphQL APIs\n- Real-time subscriptions\n- Role-based access control\n- Database migrations\n\n## Setup\n\nUsing Docker Compose, you can have Hasura running in minutes.\n\nStay tuned for more!',
    '22222222-2222-2222-2222-222222222222',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'published',
    NOW() - INTERVAL '3 days'
),
(
    '33333333-aaaa-bbbb-cccc-333333333333',
    'Styling with TailwindCSS',
    'styling-with-tailwindcss',
    'Learn how to create beautiful, responsive designs with TailwindCSS utility classes.',
    '# Styling with TailwindCSS\n\nTailwindCSS is a utility-first CSS framework that makes styling your applications a breeze.\n\n## Benefits\n\n- Utility-first approach\n- Highly customizable\n- No context switching\n- Responsive design made easy\n\n## Getting Started\n\nInstall TailwindCSS in your project and start building beautiful interfaces.',
    '33333333-3333-3333-3333-333333333333',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'published',
    NOW() - INTERVAL '1 day'
);

-- Associate posts with tags
INSERT INTO post_tags (post_id, tag_id) VALUES
('11111111-aaaa-bbbb-cccc-111111111111', 'dddddddd-dddd-dddd-dddd-dddddddddddd'),
('11111111-aaaa-bbbb-cccc-111111111111', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'),
('22222222-aaaa-bbbb-cccc-222222222222', 'ffffffff-ffff-ffff-ffff-ffffffffffff'),
('22222222-aaaa-bbbb-cccc-222222222222', '10101010-1010-1010-1010-101010101010'),
('33333333-aaaa-bbbb-cccc-333333333333', '20202020-2020-2020-2020-202020202020');

-- Insert sample comments
INSERT INTO comments (content, post_id, author_id, status) VALUES
('Great article! Very helpful for beginners.', '11111111-aaaa-bbbb-cccc-111111111111', '33333333-3333-3333-3333-333333333333', 'approved'),
('Thanks for sharing this information!', '22222222-aaaa-bbbb-cccc-222222222222', '33333333-3333-3333-3333-333333333333', 'approved'),
('Looking forward to more tutorials like this.', '33333333-aaaa-bbbb-cccc-333333333333', '22222222-2222-2222-2222-222222222222', 'approved');
