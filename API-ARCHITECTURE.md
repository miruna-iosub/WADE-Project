# API Architecture Overview

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          CLIENT APPLICATIONS                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐│
│  │  Web Browser │  │ Mobile Apps  │  │   Python     │  │   React     ││
│  │  (Fetch API) │  │   (REST)     │  │  (requests)  │  │   (Apollo)  ││
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬──────┘│
│         │                 │                 │                 │        │
│         └─────────────────┴─────────────────┴─────────────────┘        │
│                                    │                                    │
└────────────────────────────────────┼────────────────────────────────────┘
                                     │
                           HTTP/HTTPS Requests
                                     │
┌────────────────────────────────────▼────────────────────────────────────┐
│                         REST API LAYER                                  │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │         Node.js + Express Server (Port 3000)                    │   │
│  │                                                                  │   │
│  │  Endpoints:                                                      │   │
│  │  • GET  /api/v1/nodes                                          │   │
│  │  • GET  /api/v1/nodes/{id}                                     │   │
│  │  • GET  /api/v1/nodes/{id}/subgraph                            │   │
│  │  • GET  /api/v1/edges                                          │   │
│  │  • GET  /api/v1/statistics/*                                   │   │
│  │  • GET  /api/v1/classifications/*                              │   │
│  │  • POST /api/v1/sparql/query                                   │   │
│  │                                                                  │   │
│  │  Features:                                                       │   │
│  │  ✓ Request validation                                           │   │
│  │  ✓ Response formatting                                          │   │
│  │  ✓ Error handling                                               │   │
│  │  ✓ Pagination                                                   │   │
│  │  ✓ Caching (optional)                                           │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                            SPARQL Queries
                                     │
┌────────────────────────────────────▼────────────────────────────────────┐
│                      SPARQL CLIENT LAYER                                │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │              SPARQLClient (JavaScript Class)                     │   │
│  │                                                                  │   │
│  │  Methods:                                                        │   │
│  │  • query(sparqlQuery)           - Execute raw SPARQL           │   │
│  │  • getNodes(limit, offset)      - Fetch nodes                  │   │
│  │  • getNodesByDegree(min, max)   - Filter by degree             │   │
│  │  • getSubgraph(nodeIds, depth)  - Get subgraph                 │   │
│  │  • getEdges(limit, nodeIds)     - Fetch edges                  │   │
│  │  • getNetworkStats()            - Network statistics           │   │
│  │  • getDegreeDistribution()      - Degree distribution          │   │
│  │  • getClassificationStats()     - Classification stats         │   │
│  │  • getDeadEnds(limit)           - Find dead ends               │   │
│  │  • getMajorHubs(limit)          - Find hubs                    │   │
│  │                                                                  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                      HTTP POST (application/sparql-query)
                                     │
┌────────────────────────────────────▼────────────────────────────────────┐
│                    APACHE JENA FUSEKI (Port 3030)                       │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                   SPARQL Endpoint                                │   │
│  │              /roadnet/sparql (Query)                             │   │
│  │              /roadnet/update (Update - disabled)                 │   │
│  │                                                                  │   │
│  │  Query Types Supported:                                          │   │
│  │  • SELECT  - Retrieve specific data                             │   │
│  │  • CONSTRUCT - Build RDF graphs                                 │   │
│  │  • ASK - Boolean queries                                        │   │
│  │  • DESCRIBE - Describe resources                                │   │
│  │                                                                  │   │
│  │  Query Optimizations:                                            │   │
│  │  ✓ TDB2 storage engine                                          │   │
│  │  ✓ Query caching                                                │   │
│  │  ✓ Result streaming                                             │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                               Query Engine
                                     │
┌────────────────────────────────────▼────────────────────────────────────┐
│                        RDF TRIPLE STORE (TDB2)                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                   Knowledge Base                                 │   │
│  │                                                                  │   │
│  │  Dataset: roadnet                                                │   │
│  │  Format: Turtle (TTL)                                            │   │
│  │  Size: ~500MB                                                    │   │
│  │                                                                  │   │
│  │  Statistics:                                                     │   │
│  │  • 9,612,407 RDF triples                                        │   │
│  │  • 1,088,092 nodes (roadonto:RoadNode)                          │   │
│  │  • 3,083,796 edges (roadonto:connectsTo)                        │   │
│  │  • 5 SKOS concepts (classifications)                            │   │
│  │                                                                  │   │
│  │  Ontology Structure:                                             │   │
│  │  @prefix road: <http://example.org/roadnet/pa#>                │   │
│  │  @prefix roadonto: <http://example.org/roadnet/ontology#>      │   │
│  │  @prefix skos: <http://www.w3.org/2004/02/skos/core#>          │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Diagrams

### 1. Simple Query Flow (GET /nodes)

```
Client Request
    │
    ├─→ GET /api/v1/nodes?limit=10
    │
    ▼
REST API Layer
    │
    ├─→ Validate parameters (limit, offset)
    ├─→ Call SPARQLClient.getNodes(10, 0)
    │
    ▼
SPARQL Client
    │
    ├─→ Build SPARQL query:
    │   PREFIX roadonto: <...ontology#>
    │   SELECT ?nodeId ?degree ?inDegree ?outDegree
    │   WHERE { ... }
    │   LIMIT 10
    │
    ├─→ POST to http://localhost:3030/roadnet/sparql
    │
    ▼
Fuseki SPARQL Endpoint
    │
    ├─→ Parse SPARQL query
    ├─→ Query TDB2 triple store
    ├─→ Return JSON results
    │
    ▼
SPARQL Client
    │
    ├─→ Parse SPARQL results
    ├─→ Transform to simple objects
    │
    ▼
REST API Layer
    │
    ├─→ Add pagination metadata
    ├─→ Format response
    │
    ▼
Client Response
    │
    └─→ { data: [...], pagination: {...} }
```

### 2. Complex Query Flow (GET /nodes/{id}/subgraph)

```
Client Request
    │
    ├─→ GET /api/v1/nodes/0/subgraph?depth=2
    │
    ▼
REST API Layer
    │
    ├─→ Validate nodeId and depth
    ├─→ Call SPARQLClient.getSubgraph(['0'], 2)
    │
    ▼
SPARQL Client
    │
    ├─→ Build complex SPARQL query with UNION:
    │   • Find all direct connections (depth 1)
    │   • Find connections of connections (depth 2)
    │   • Collect all unique nodes and edges
    │
    ├─→ POST to Fuseki endpoint
    │
    ▼
Fuseki SPARQL Endpoint
    │
    ├─→ Execute multi-part query
    ├─→ Traverse graph structure
    ├─→ Return all matching triples
    │
    ▼
SPARQL Client
    │
    ├─→ Parse results
    ├─→ Build graph structure:
    │   • centerNode
    │   • nodes[]
    │   • edges[]
    │
    ▼
REST API Layer
    │
    ├─→ Add metadata (nodeCount, edgeCount)
    ├─→ Format response
    │
    ▼
Client Response
    │
    └─→ { centerNode: {...}, nodes: [...], edges: [...], meta: {...} }
```

### 3. Custom SPARQL Query Flow

```
Client Request
    │
    ├─→ POST /api/v1/sparql/query
    │   Body: { query: "SELECT ...", format: "json" }
    │
    ▼
REST API Layer
    │
    ├─→ Validate SPARQL syntax
    ├─→ Check query safety (no DELETE/INSERT)
    ├─→ Forward to Fuseki
    │
    ▼
Fuseki SPARQL Endpoint
    │
    ├─→ Execute custom query
    ├─→ Return raw SPARQL results
    │
    ▼
REST API Layer
    │
    ├─→ Pass through results
    │   (minimal transformation)
    │
    ▼
Client Response
    │
    └─→ { head: {...}, results: { bindings: [...] } }
```

---

## Component Responsibilities

### Client Layer
**Responsibilities:**
- User interface
- HTTP request construction
- Response handling
- Error display
- Data visualization (D3.js, charts)

**Technologies:**
- JavaScript (Fetch API)
- React / Vue / Angular
- Python (requests library)
- Apollo Client (GraphQL alternative)

---

### REST API Layer
**Responsibilities:**
- Endpoint routing
- Request validation
- Authentication (future)
- Rate limiting (future)
- Response formatting
- Error handling
- Pagination logic
- Caching (optional)

**Technologies:**
- Node.js
- Express.js
- Middleware (validation, auth)

**Files:**
- `api-spec.yaml` - OpenAPI specification
- `server.js` - Express server (to be implemented)

---

### SPARQL Client Layer
**Responsibilities:**
- SPARQL query construction
- Query parameterization
- Result parsing
- Result transformation
- Connection management

**Technologies:**
- JavaScript ES6 classes
- Fetch API / axios

**Files:**
- `src/services/sparql-client.js` - Implementation
- `src/services/sparql-queries.md` - Query examples

---

### SPARQL Endpoint (Fuseki)
**Responsibilities:**
- SPARQL query execution
- Graph traversal
- Result formatting (JSON, XML, CSV)
- Query optimization
- Concurrency management

**Technologies:**
- Apache Jena Fuseki 4.x
- TDB2 storage engine
- Java 11+

**Configuration:**
- Dataset: `roadnet`
- Endpoint: `http://localhost:3030/roadnet/sparql`

---

### RDF Triple Store (TDB2)
**Responsibilities:**
- Persistent RDF storage
- Index management
- Triple retrieval
- Graph pattern matching

**Technologies:**
- Apache Jena TDB2
- Turtle (TTL) format

**Data:**
- Input: `output/roadnet_complete.ttl`
- Size: ~500MB
- Triples: 9,612,407

---

## API Design Patterns

### 1. Resource-Based URLs
```
/api/v1/nodes              - Collection
/api/v1/nodes/{id}         - Single resource
/api/v1/nodes/{id}/subgraph - Sub-resource
```

### 2. Query Parameters for Filtering
```
/api/v1/nodes?limit=10&offset=0
/api/v1/nodes/by-degree?minDegree=6&maxDegree=10
```

### 3. Consistent Response Format
```json
{
  "data": [...],           // Main content
  "pagination": {...},     // Pagination info
  "meta": {...}           // Additional metadata
}
```

### 4. Standard Error Format
```json
{
  "error": {
    "code": "INVALID_PARAMETER",
    "message": "...",
    "timestamp": "..."
  }
}
```

---

## Security Considerations

### Current State (Development)
- ✗ No authentication
- ✗ No rate limiting
- ✗ No HTTPS
- ✓ Read-only SPARQL endpoint

### Production Recommendations
- ✓ API key authentication
- ✓ OAuth 2.0 for user authentication
- ✓ Rate limiting (e.g., 1000 requests/hour)
- ✓ HTTPS/TLS encryption
- ✓ CORS configuration
- ✓ Input validation and sanitization
- ✓ SPARQL query restrictions (no UPDATE/DELETE)
- ✓ Request logging and monitoring

---

## Scalability Considerations

### Current Architecture
- Single Fuseki instance
- In-memory query execution
- No caching layer
- Direct client-to-server connections

### Scaling Strategies

#### Horizontal Scaling
```
                  ┌──────────────┐
                  │ Load Balancer│
                  └──────┬───────┘
                         │
           ┌─────────────┼─────────────┐
           │             │             │
    ┌──────▼──────┐ ┌───▼────────┐ ┌─▼──────────┐
    │ API Server 1│ │API Server 2│ │API Server 3│
    └──────┬──────┘ └───┬────────┘ └─┬──────────┘
           │             │             │
           └─────────────┼─────────────┘
                         │
                  ┌──────▼───────┐
                  │    Fuseki    │
                  │  (Primary)   │
                  └──────────────┘
```

#### Caching Layer
```
Client → CDN → Redis Cache → API Server → Fuseki → TDB2
         (static)  (queries)
```

#### Recommendations
1. **Cache network statistics** (rarely change)
2. **Cache popular queries** (top nodes, classifications)
3. **Use CDN** for static content
4. **Connection pooling** for SPARQL endpoint
5. **Async processing** for expensive queries
6. **Query result pagination** (already implemented)

---

## Monitoring & Observability

### Metrics to Track
- Request rate (requests/second)
- Response time (p50, p95, p99)
- Error rate (%)
- Cache hit rate (%)
- SPARQL query time
- Memory usage
- TDB2 disk usage

### Tools
- **Logging**: Winston, Bunyan
- **Monitoring**: Prometheus + Grafana
- **APM**: New Relic, DataDog
- **Tracing**: OpenTelemetry

---

## Development Workflow

```
1. Design
   └─→ api-spec.yaml (OpenAPI)

2. Documentation
   ├─→ API-USAGE-EXAMPLES.md
   ├─→ API-QUICK-REFERENCE.md
   └─→ graphql-schema.md

3. Testing
   └─→ postman-collection.json

4. Implementation
   ├─→ Server: server.js (Express)
   ├─→ Client: sparql-client.js
   └─→ Tests: test suite

5. Deployment
   ├─→ Docker containers
   ├─→ Kubernetes (optional)
   └─→ CI/CD pipeline
```

---

## Future Enhancements

### Phase 1: Core API
- [x] API design and documentation
- [ ] REST API implementation
- [ ] Authentication system
- [ ] Rate limiting
- [ ] Basic monitoring

### Phase 2: Performance
- [ ] Response caching
- [ ] Query optimization
- [ ] Load balancing
- [ ] CDN integration

### Phase 3: Features
- [ ] GraphQL endpoint
- [ ] WebSocket subscriptions
- [ ] Batch operations
- [ ] Export to various formats

### Phase 4: Analytics
- [ ] Real-time analytics
- [ ] Query usage statistics
- [ ] Performance dashboards
- [ ] Predictive caching

---

## References

- **OpenAPI Specification**: [api-spec.yaml](api-spec.yaml)
- **Usage Examples**: [API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md)
- **Quick Reference**: [API-QUICK-REFERENCE.md](API-QUICK-REFERENCE.md)
- **GraphQL Alternative**: [graphql-schema.md](graphql-schema.md)
- **SPARQL Client**: [src/services/sparql-client.js](../src/services/sparql-client.js)

---

**Version**: 1.0.0  
**Last Updated**: January 12, 2026
