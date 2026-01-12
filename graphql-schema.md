# GraphQL API Schema (Alternative Implementation)

This document provides a GraphQL schema as an alternative to the REST API for querying the Pennsylvania Road Network data.

## GraphQL Schema Definition

```graphql
"""
Pennsylvania Road Network GraphQL API
Version: 1.0.0

This API provides access to road network data using semantic web technologies.
Data includes 1,088,092 nodes and 3,083,796 edges from the Pennsylvania road network.
"""

# ==================== Types ====================

"""
A node in the road network representing an intersection or endpoint
"""
type Node {
  """Unique identifier for the node"""
  nodeId: ID!
  
  """Total number of connections (in + out degree)"""
  degree: Int!
  
  """Number of incoming edges"""
  inDegree: Int!
  
  """Number of outgoing edges"""
  outDegree: Int!
  
  """SKOS classification of the node"""
  classification: Classification!
  
  """List of nodes this node connects to"""
  connectedNodes: [Node!]!
  
  """All edges originating from this node"""
  outgoingEdges: [Edge!]!
  
  """All edges pointing to this node"""
  incomingEdges: [Edge!]!
  
  """RDF URI of the node"""
  uri: String!
}

"""
SKOS classification concept for road network nodes
"""
type Classification {
  """Classification label (e.g., "Super Hub", "Dead End")"""
  label: ClassificationLabel!
  
  """Human-readable definition"""
  definition: String!
  
  """Minimum degree for this classification"""
  minDegree: Int
  
  """Maximum degree for this classification (null = no upper limit)"""
  maxDegree: Int
  
  """URI of the SKOS concept"""
  uri: String!
  
  """Broader concept in the hierarchy (if any)"""
  broader: Classification
  
  """Count of nodes with this classification"""
  nodeCount: Int!
}

"""
Classification labels enum
"""
enum ClassificationLabel {
  DEAD_END
  SIMPLE_JUNCTION
  INTERSECTION
  MAJOR_HUB
  SUPER_HUB
}

"""
An edge (connection) between two nodes
"""
type Edge {
  """Source node"""
  from: Node!
  
  """Target node"""
  to: Node!
  
  """Degree of the source node"""
  fromDegree: Int!
  
  """Degree of the target node"""
  toDegree: Int!
}

"""
A subgraph around a central node
"""
type Subgraph {
  """The central node"""
  centerNode: Node!
  
  """All nodes in the subgraph"""
  nodes: [Node!]!
  
  """All edges in the subgraph"""
  edges: [Edge!]!
  
  """Depth of the subgraph"""
  depth: Int!
  
  """Number of nodes"""
  nodeCount: Int!
  
  """Number of edges"""
  edgeCount: Int!
}

"""
Overall network statistics
"""
type NetworkStatistics {
  """Total number of nodes"""
  totalNodes: Int!
  
  """Total number of edges"""
  totalEdges: Int!
  
  """Average node degree"""
  avgDegree: Float!
  
  """Maximum node degree"""
  maxDegree: Int!
  
  """Minimum node degree"""
  minDegree: Int!
  
  """Median node degree"""
  medianDegree: Float!
  
  """Network density"""
  density: Float!
  
  """Timestamp when statistics were generated"""
  generatedAt: String!
}

"""
Degree distribution data point
"""
type DegreeDistribution {
  """Degree value"""
  degree: Int!
  
  """Number of nodes with this degree"""
  count: Int!
  
  """Percentage of total nodes"""
  percentage: Float!
}

"""
Distribution of node classifications
"""
type ClassificationStatistics {
  """List of classifications with counts"""
  statistics: [ClassificationStat!]!
  
  """Total number of nodes"""
  total: Int!
}

"""
Individual classification statistic"""
type ClassificationStat {
  """Classification label"""
  label: ClassificationLabel!
  
  """Number of nodes with this classification"""
  count: Int!
  
  """Percentage of total nodes"""
  percentage: Float!
}

"""
Result of a custom SPARQL query
"""
type SparqlResult {
  """Variable names from SELECT clause"""
  variables: [String!]!
  
  """Query results"""
  bindings: [SparqlBinding!]!
  
  """Number of results"""
  count: Int!
}

"""
A single SPARQL query result binding
"""
type SparqlBinding {
  """Variable name"""
  variable: String!
  
  """Value"""
  value: String!
  
  """Type (uri, literal, bnode)"""
  type: String!
  
  """Datatype (for literals)"""
  datatype: String
}

"""
Pagination information
"""
type PageInfo {
  """Whether there are more results"""
  hasNextPage: Boolean!
  
  """Whether there are previous results"""
  hasPreviousPage: Boolean!
  
  """Total number of items (if available)"""
  totalCount: Int
}

"""
Paginated list of nodes"""
type NodeConnection {
  """List of nodes"""
  nodes: [Node!]!
  
  """Pagination information"""
  pageInfo: PageInfo!
}

# ==================== Inputs ====================

"""
Input for filtering nodes by degree range
"""
input DegreeRangeInput {
  """Minimum degree (inclusive)"""
  minDegree: Int!
  
  """Maximum degree (inclusive)"""
  maxDegree: Int!
}

"""
Sorting order enum
"""
enum SortOrder {
  ASC
  DESC
}

"""
Fields to sort nodes by
"""
enum NodeSortField {
  NODE_ID
  DEGREE
  IN_DEGREE
  OUT_DEGREE
}

"""
Input for sorting nodes
"""
input NodeSortInput {
  """Field to sort by"""
  field: NodeSortField!
  
  """Sort order"""
  order: SortOrder!
}

"""
Input for pagination
"""
input PaginationInput {
  """Number of items per page"""
  limit: Int = 100
  
  """Number of items to skip"""
  offset: Int = 0
}

# ==================== Queries ====================

type Query {
  """
  Get a specific node by ID
  
  Example:
  query {
    node(nodeId: "0") {
      nodeId
      degree
      classification {
        label
        definition
      }
    }
  }
  """
  node(nodeId: ID!): Node
  
  """
  Get a list of nodes with optional filtering and sorting
  
  Example:
  query {
    nodes(pagination: { limit: 10 }, sort: { field: DEGREE, order: DESC }) {
      nodes {
        nodeId
        degree
        classification { label }
      }
      pageInfo {
        hasNextPage
      }
    }
  }
  """
  nodes(
    pagination: PaginationInput
    sort: NodeSortInput
  ): NodeConnection!
  
  """
  Get nodes filtered by degree range
  
  Example:
  query {
    nodesByDegree(degreeRange: { minDegree: 6, maxDegree: 10 }, pagination: { limit: 50 }) {
      nodes {
        nodeId
        degree
        classification { label }
      }
    }
  }
  """
  nodesByDegree(
    degreeRange: DegreeRangeInput!
    pagination: PaginationInput
  ): NodeConnection!
  
  """
  Get nodes by classification
  
  Example:
  query {
    nodesByClassification(classification: SUPER_HUB, pagination: { limit: 20 }) {
      nodes {
        nodeId
        degree
      }
    }
  }
  """
  nodesByClassification(
    classification: ClassificationLabel!
    pagination: PaginationInput
  ): NodeConnection!
  
  """
  Get subgraph around a specific node
  
  Example:
  query {
    subgraph(nodeId: "0", depth: 2) {
      centerNode {
        nodeId
        degree
      }
      nodes {
        nodeId
        degree
      }
      nodeCount
      edgeCount
    }
  }
  """
  subgraph(
    nodeId: ID!
    depth: Int = 1
    limit: Int = 500
  ): Subgraph
  
  """
  Get all edges with optional filtering
  
  Example:
  query {
    edges(nodeIds: ["0", "1"], pagination: { limit: 100 }) {
      from { nodeId }
      to { nodeId }
      fromDegree
      toDegree
    }
  }
  """
  edges(
    nodeIds: [ID!]
    pagination: PaginationInput
  ): [Edge!]!
  
  """
  Get overall network statistics
  
  Example:
  query {
    networkStatistics {
      totalNodes
      totalEdges
      avgDegree
      maxDegree
    }
  }
  """
  networkStatistics: NetworkStatistics!
  
  """
  Get degree distribution
  
  Example:
  query {
    degreeDistribution {
      degree
      count
      percentage
    }
  }
  """
  degreeDistribution: [DegreeDistribution!]!
  
  """
  Get classification statistics
  
  Example:
  query {
    classificationStatistics {
      statistics {
        label
        count
        percentage
      }
      total
    }
  }
  """
  classificationStatistics: ClassificationStatistics!
  
  """
  Get all SKOS classification concepts
  
  Example:
  query {
    classifications {
      label
      definition
      minDegree
      maxDegree
      nodeCount
    }
  }
  """
  classifications: [Classification!]!
  
  """
  Get a specific classification by label
  
  Example:
  query {
    classification(label: SUPER_HUB) {
      label
      definition
      nodeCount
    }
  }
  """
  classification(label: ClassificationLabel!): Classification
  
  """
  Get all dead end nodes (degree = 1)
  
  Example:
  query {
    deadEnds(pagination: { limit: 100 }) {
      nodes {
        nodeId
        connectedNodes { nodeId }
      }
    }
  }
  """
  deadEnds(pagination: PaginationInput): NodeConnection!
  
  """
  Get all major hub nodes (Major Hub + Super Hub)
  
  Example:
  query {
    majorHubs(pagination: { limit: 50 }) {
      nodes {
        nodeId
        degree
        classification { label }
      }
    }
  }
  """
  majorHubs(
    type: ClassificationLabel
    pagination: PaginationInput
  ): NodeConnection!
  
  """
  Execute a custom SPARQL query
  
  Example:
  query {
    sparql(query: "PREFIX roadonto: <http://example.org/roadnet/ontology#> SELECT ?nodeId ?degree WHERE { ?node roadonto:hasNodeId ?nodeId ; roadonto:hasDegree ?degree . FILTER(?degree > 10) } LIMIT 10") {
      variables
      bindings {
        variable
        value
      }
      count
    }
  }
  """
  sparql(query: String!): SparqlResult!
}

# ==================== Mutations ====================

"""
Mutations are not currently supported as this is a read-only dataset.
Future versions may include data ingestion capabilities.
"""
type Mutation {
  """Placeholder - mutations not yet implemented"""
  _placeholder: Boolean
}

# ==================== Subscriptions ====================

"""
Subscriptions for real-time updates (future implementation)
"""
type Subscription {
  """
  Subscribe to network statistics updates
  (Future implementation - would update when data changes)
  """
  networkStatisticsUpdated: NetworkStatistics!
}

# ==================== Schema ====================

schema {
  query: Query
  mutation: Mutation
  subscription: Subscription
}
```

---

## Example Queries

### 1. Get Top 10 Most Connected Nodes

```graphql
query GetTopNodes {
  nodes(
    pagination: { limit: 10 }
    sort: { field: DEGREE, order: DESC }
  ) {
    nodes {
      nodeId
      degree
      inDegree
      outDegree
      classification {
        label
        definition
      }
    }
    pageInfo {
      hasNextPage
      totalCount
    }
  }
}
```

**Response:**
```json
{
  "data": {
    "nodes": {
      "nodes": [
        {
          "nodeId": "0",
          "degree": 18,
          "inDegree": 9,
          "outDegree": 9,
          "classification": {
            "label": "SUPER_HUB",
            "definition": "Critical intersection with 10 or more connections"
          }
        },
        {
          "nodeId": "42156",
          "degree": 15,
          "inDegree": 7,
          "outDegree": 8,
          "classification": {
            "label": "SUPER_HUB",
            "definition": "Critical intersection with 10 or more connections"
          }
        }
        // ... 8 more nodes
      ],
      "pageInfo": {
        "hasNextPage": true,
        "totalCount": 1088092
      }
    }
  }
}
```

---

### 2. Get Specific Node with Subgraph

```graphql
query GetNodeWithSubgraph {
  node(nodeId: "0") {
    nodeId
    degree
    classification {
      label
      definition
    }
    connectedNodes {
      nodeId
      degree
      classification {
        label
      }
    }
  }
  
  subgraph(nodeId: "0", depth: 1, limit: 100) {
    centerNode {
      nodeId
      degree
    }
    nodeCount
    edgeCount
    edges {
      from { nodeId }
      to { nodeId }
    }
  }
}
```

---

### 3. Get Network Statistics and Classification Distribution

```graphql
query GetNetworkOverview {
  networkStatistics {
    totalNodes
    totalEdges
    avgDegree
    maxDegree
    minDegree
    density
  }
  
  classificationStatistics {
    statistics {
      label
      count
      percentage
    }
    total
  }
  
  degreeDistribution {
    degree
    count
    percentage
  }
}
```

---

### 4. Find Major Hubs in Specific Degree Range

```graphql
query FindMajorHubs {
  nodesByDegree(
    degreeRange: { minDegree: 6, maxDegree: 10 }
    pagination: { limit: 50 }
  ) {
    nodes {
      nodeId
      degree
      classification {
        label
        definition
      }
      connectedNodes {
        nodeId
      }
    }
    pageInfo {
      hasNextPage
    }
  }
}
```

---

### 5. Get All Dead Ends (Rural Areas)

```graphql
query GetDeadEnds {
  deadEnds(pagination: { limit: 100 }) {
    nodes {
      nodeId
      degree
      connectedNodes {
        nodeId
        degree
      }
    }
    pageInfo {
      hasNextPage
      totalCount
    }
  }
}
```

---

### 6. Get Classification Details

```graphql
query GetClassifications {
  classifications {
    label
    definition
    minDegree
    maxDegree
    nodeCount
    broader {
      label
    }
  }
}
```

---

### 7. Custom SPARQL Query

```graphql
query CustomSparqlQuery {
  sparql(
    query: """
      PREFIX roadonto: <http://example.org/roadnet/ontology#>
      
      SELECT ?nodeId ?inDegree ?outDegree 
             (ABS(?inDegree - ?outDegree) AS ?diff)
      WHERE {
        ?node roadonto:hasNodeId ?nodeId ;
              roadonto:hasInDegree ?inDegree ;
              roadonto:hasOutDegree ?outDegree .
        FILTER(?inDegree != ?outDegree)
        FILTER(?inDegree > 5 || ?outDegree > 5)
      }
      ORDER BY DESC(?diff)
      LIMIT 20
    """
  ) {
    variables
    bindings {
      variable
      value
      type
    }
    count
  }
}
```

---

## Client Implementation Examples

### JavaScript (Apollo Client)

```javascript
import { ApolloClient, InMemoryCache, gql } from '@apollo/client';

// Initialize Apollo Client
const client = new ApolloClient({
  uri: 'http://localhost:4000/graphql',
  cache: new InMemoryCache()
});

// Query top nodes
async function getTopNodes(limit = 10) {
  const { data } = await client.query({
    query: gql`
      query GetTopNodes($limit: Int!) {
        nodes(
          pagination: { limit: $limit }
          sort: { field: DEGREE, order: DESC }
        ) {
          nodes {
            nodeId
            degree
            classification {
              label
            }
          }
        }
      }
    `,
    variables: { limit }
  });
  
  return data.nodes.nodes;
}

// Get node subgraph
async function getSubgraph(nodeId, depth = 2) {
  const { data } = await client.query({
    query: gql`
      query GetSubgraph($nodeId: ID!, $depth: Int!) {
        subgraph(nodeId: $nodeId, depth: $depth) {
          centerNode {
            nodeId
            degree
          }
          nodes {
            nodeId
            degree
          }
          nodeCount
          edgeCount
        }
      }
    `,
    variables: { nodeId, depth }
  });
  
  return data.subgraph;
}

// Usage
const topNodes = await getTopNodes(20);
const subgraph = await getSubgraph('0', 2);
```

---

### Python (gql)

```python
from gql import gql, Client
from gql.transport.requests import RequestsHTTPTransport

# Initialize client
transport = RequestsHTTPTransport(url='http://localhost:4000/graphql')
client = Client(transport=transport, fetch_schema_from_transport=True)

# Query network statistics
query = gql('''
    query {
        networkStatistics {
            totalNodes
            totalEdges
            avgDegree
            maxDegree
        }
        classificationStatistics {
            statistics {
                label
                count
                percentage
            }
        }
    }
''')

result = client.execute(query)
print(f"Total nodes: {result['networkStatistics']['totalNodes']}")
print(f"Average degree: {result['networkStatistics']['avgDegree']}")

# Query nodes by degree
query_by_degree = gql('''
    query NodesByDegree($minDegree: Int!, $maxDegree: Int!, $limit: Int!) {
        nodesByDegree(
            degreeRange: { minDegree: $minDegree, maxDegree: $maxDegree }
            pagination: { limit: $limit }
        ) {
            nodes {
                nodeId
                degree
                classification {
                    label
                }
            }
        }
    }
''')

result = client.execute(
    query_by_degree,
    variable_values={'minDegree': 6, 'maxDegree': 10, 'limit': 50}
)

for node in result['nodesByDegree']['nodes']:
    print(f"Node {node['nodeId']}: degree {node['degree']}")
```

---

### React Component Example

```jsx
import React from 'react';
import { useQuery, gql } from '@apollo/client';

const GET_NETWORK_STATS = gql`
  query GetNetworkStats {
    networkStatistics {
      totalNodes
      totalEdges
      avgDegree
      maxDegree
    }
    classificationStatistics {
      statistics {
        label
        count
        percentage
      }
    }
  }
`;

function NetworkDashboard() {
  const { loading, error, data } = useQuery(GET_NETWORK_STATS);

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error: {error.message}</p>;

  const stats = data.networkStatistics;
  const classifications = data.classificationStatistics.statistics;

  return (
    <div className="dashboard">
      <h1>Pennsylvania Road Network</h1>
      
      <div className="stats-grid">
        <div className="stat-card">
          <h3>{stats.totalNodes.toLocaleString()}</h3>
          <p>Total Nodes</p>
        </div>
        <div className="stat-card">
          <h3>{stats.totalEdges.toLocaleString()}</h3>
          <p>Total Edges</p>
        </div>
        <div className="stat-card">
          <h3>{stats.avgDegree.toFixed(2)}</h3>
          <p>Average Degree</p>
        </div>
        <div className="stat-card">
          <h3>{stats.maxDegree}</h3>
          <p>Max Degree</p>
        </div>
      </div>
      
      <div className="classifications">
        <h2>Node Classifications</h2>
        <ul>
          {classifications.map(c => (
            <li key={c.label}>
              <strong>{c.label.replace('_', ' ')}</strong>: {' '}
              {c.count.toLocaleString()} nodes ({c.percentage.toFixed(1)}%)
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}

export default NetworkDashboard;
```

---

## Implementation Guide

### Server Setup (Node.js + Apollo Server)

```javascript
const { ApolloServer } = require('apollo-server');
const { readFileSync } = require('fs');
const SPARQLClient = require('./sparql-client');

// Load schema
const typeDefs = readFileSync('./schema.graphql', 'utf8');

// Resolvers
const resolvers = {
  Query: {
    node: async (_, { nodeId }) => {
      // Implement node fetching logic
      return await SPARQLClient.getNodeById(nodeId);
    },
    
    nodes: async (_, { pagination, sort }) => {
      const { limit, offset } = pagination || { limit: 100, offset: 0 };
      const nodes = await SPARQLClient.getNodes(limit, offset);
      
      return {
        nodes,
        pageInfo: {
          hasNextPage: nodes.length === limit,
          totalCount: 1088092
        }
      };
    },
    
    networkStatistics: async () => {
      return await SPARQLClient.getNetworkStats();
    },
    
    // ... other resolvers
  },
  
  Node: {
    connectedNodes: async (parent) => {
      return await SPARQLClient.getConnectedNodes(parent.nodeId);
    },
    
    classification: async (parent) => {
      return await SPARQLClient.getClassification(parent.nodeId);
    }
  }
};

// Create server
const server = new ApolloServer({
  typeDefs,
  resolvers,
  introspection: true,
  playground: true
});

// Start server
server.listen({ port: 4000 }).then(({ url }) => {
  console.log(`🚀 GraphQL server ready at ${url}`);
});
```

---

## Comparison: REST vs GraphQL

| Feature | REST API | GraphQL API |
|---------|----------|-------------|
| **Data Fetching** | Multiple endpoints | Single endpoint |
| **Over-fetching** | May return unused fields | Request only needed fields |
| **Under-fetching** | May need multiple requests | Get related data in one query |
| **Versioning** | URL versioning (v1, v2) | Schema evolution |
| **Caching** | HTTP caching | Requires custom logic |
| **Learning Curve** | Easier for beginners | Requires GraphQL knowledge |
| **Tooling** | OpenAPI, Postman | GraphiQL, Apollo DevTools |

### When to Use REST
- Simple CRUD operations
- HTTP caching is important
- Public API with broad audience
- Straightforward resource-based access

### When to Use GraphQL
- Complex nested data requirements
- Mobile apps (reduce data transfer)
- Need precise control over data shape
- Multiple client types with different needs

---

## Resources

- **GraphQL Specification**: https://spec.graphql.org/
- **Apollo Server**: https://www.apollographql.com/docs/apollo-server/
- **GraphiQL**: https://github.com/graphql/graphiql
- **Schema Design Best Practices**: https://graphql.org/learn/best-practices/

---

**Note**: This GraphQL schema is provided as an alternative design. The current implementation uses REST/SPARQL. To implement GraphQL, you would need to:

1. Set up Apollo Server or similar GraphQL server
2. Implement resolvers that query the SPARQL endpoint
3. Configure GraphQL playground for testing
4. Update client applications to use GraphQL queries

For the REST API implementation, see [api-spec.yaml](api-spec.yaml) and [API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md).
