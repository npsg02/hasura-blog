import { ApolloClient, InMemoryCache, HttpLink, from } from '@apollo/client';
import { setContext } from '@apollo/client/link/context';

const httpLink = new HttpLink({
  uri: process.env.NEXT_PUBLIC_HASURA_GRAPHQL_URL || 'http://localhost:8080/v1/graphql',
});

const authLink = setContext((_, { headers }) => {
  // Get the authentication token from session storage or other secure place
  // For now, we'll use the admin secret for development
  const token = process.env.HASURA_GRAPHQL_ADMIN_SECRET;
  
  return {
    headers: {
      ...headers,
      ...(token ? { 'x-hasura-admin-secret': token } : {}),
    }
  };
});

const client = new ApolloClient({
  link: from([authLink, httpLink]),
  cache: new InMemoryCache(),
  defaultOptions: {
    watchQuery: {
      fetchPolicy: 'cache-and-network',
    },
  },
});

export default client;
