{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Node.js and npm
    nodejs_20
    
    # Docker and Docker Compose
    docker
    docker-compose
    
    # Hasura CLI
    hasura-cli
    
    # PostgreSQL client (for database management)
    postgresql_15
    
    # Git
    git
    
    # Optional: useful development tools
    gnumake
    curl
    jq
  ];

  shellHook = ''
    echo "🚀 Hasura Blog Development Environment"
    echo ""
    echo "Available tools:"
    echo "  - Node.js $(node --version)"
    echo "  - npm $(npm --version)"
    echo "  - Docker $(docker --version)"
    echo "  - Docker Compose $(docker-compose --version)"
    echo "  - Hasura CLI $(hasura version)"
    echo "  - PostgreSQL client $(psql --version)"
    echo ""
    echo "Quick start:"
    echo "  1. cp .env.example .env"
    echo "  2. npm install"
    echo "  3. docker-compose -f docker-compose.dev.yml up -d"
    echo "  4. npm run dev"
    echo ""
  '';

  # Set environment variables
  DATABASE_URL = "postgresql://postgres:postgrespassword@localhost:5432/hasura";
  NEXT_PUBLIC_HASURA_GRAPHQL_URL = "http://localhost:8080/v1/graphql";
}
