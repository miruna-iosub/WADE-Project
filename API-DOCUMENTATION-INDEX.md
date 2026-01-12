# API Documentation Index

## Overview

This directory contains comprehensive API documentation for the Pennsylvania Road Network project, including both REST API (OpenAPI) and GraphQL specifications.

---

## 📚 Documentation Files

### 1. **[api-spec.yaml](api-spec.yaml)**
**Type**: OpenAPI 3.0 Specification  
**Size**: ~900 lines  
**Purpose**: Complete REST API specification

**Contents**:
- 15 REST endpoints with full documentation
- Request/response schemas and examples
- Error handling specifications
- SPARQL query endpoint
- Authentication placeholder (for future use)

**View with**:
```bash
# Swagger UI
npx @redocly/cli preview-docs api-spec.yaml

# Or online at https://editor.swagger.io/
```

---

### 2. **[API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md)**
**Type**: Markdown Documentation  
**Size**: ~1,100 lines  
**Purpose**: Comprehensive usage guide with practical examples

**Contents**:
- **9 Basic Usage Examples** - Common API operations
- **4 Advanced Query Examples** - Custom SPARQL queries
- **4 Real-World Case Studies**:
  - Traffic Management System
  - Road Maintenance Optimization
  - Emergency Response Planning
  - Network Visualization Dashboard
- **3 Integration Examples** (Python, Node.js, React)
- **Performance Best Practices**
- **Error Handling Patterns**

**Best for**: Learning how to use the API in real applications

---

### 3. **[API-QUICK-REFERENCE.md](API-QUICK-REFERENCE.md)**
**Type**: Quick Reference Guide  
**Size**: ~450 lines  
**Purpose**: Fast lookup for common operations

**Contents**:
- Endpoint summary table
- Common query parameters
- Response format examples
- SKOS classifications table
- SPARQL query templates
- curl, JavaScript, and Python code snippets
- Performance tips
- Error code reference

**Best for**: Daily development reference

---

### 4. **[postman-collection.json](postman-collection.json)**
**Type**: Postman Collection v2.1  
**Size**: ~500 lines  
**Purpose**: Pre-configured API test collection

**Contents**:
- 25+ pre-configured requests
- Organized into folders:
  - Nodes (6 requests)
  - Edges (2 requests)
  - Statistics (2 requests)
  - Classifications (5 requests)
  - SPARQL Queries (4 requests)
  - Use Case Examples (4 requests)
- Environment variables
- Automated tests

**Import into Postman**:
1. Open Postman
2. Click **Import** → Select file
3. Choose `postman-collection.json`

---

### 5. **[graphql-schema.md](graphql-schema.md)**
**Type**: GraphQL Schema + Documentation  
**Size**: ~950 lines  
**Purpose**: Alternative GraphQL API design

**Contents**:
- Complete GraphQL schema definition
- 20+ types and enums
- Query examples (7 detailed examples)
- Client implementation (JavaScript, Python, React)
- Server setup guide (Apollo Server)
- REST vs GraphQL comparison
- Implementation roadmap

**Best for**: Understanding GraphQL alternative or planning future GraphQL implementation

**Note**: This is a design specification. Current implementation uses REST/SPARQL.

---

## 🚀 Quick Start

### For API Users (Developers)

1. **Start here**: [API-QUICK-REFERENCE.md](API-QUICK-REFERENCE.md)
2. **Then explore**: [API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md)
3. **For testing**: Import [postman-collection.json](postman-collection.json)

### For API Designers

1. **View spec**: [api-spec.yaml](api-spec.yaml) in Swagger Editor
2. **Design alternative**: [graphql-schema.md](graphql-schema.md)

### For Integration

1. **JavaScript/Node.js**: See examples in [API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md#example-11-nodejs-express-integration)
2. **Python**: See examples in [API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md#example-10-python-integration)
3. **React**: See examples in [API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md#case-study-4-network-visualization-dashboard)

---

## 📊 API Overview

### REST Endpoints Summary

| Category | Endpoints | Description |
|----------|-----------|-------------|
| **Nodes** | 4 | Query road network nodes |
| **Edges** | 1 | Query road connections |
| **Statistics** | 2 | Network analytics |
| **Classifications** | 4 | SKOS concept queries |
| **SPARQL** | 1 | Custom queries |
| **Total** | **12** | |

### Data Model

```
Road Network (RDF/OWL)
├── 1,088,092 Nodes (RoadNode)
├── 3,083,796 Edges (connectsTo)
└── SKOS Classifications
    ├── Dead End (degree 1)
    ├── Simple Junction (degree 2-3)
    ├── Intersection (degree 4-5)
    ├── Major Hub (degree 6-9)
    └── Super Hub (degree ≥ 10)
```

---

## 🎯 Common Use Cases

### 1. Display Network Statistics on Dashboard
```javascript
// Quick Reference: API-QUICK-REFERENCE.md
// Detailed Example: API-USAGE-EXAMPLES.md - Example 1
fetch('http://localhost:3000/api/v1/statistics/network')
  .then(res => res.json())
  .then(stats => {
    console.log(`Nodes: ${stats.totalNodes}`);
    console.log(`Edges: ${stats.totalEdges}`);
  });
```

### 2. Find Critical Infrastructure Points
```bash
# Quick Reference: API-QUICK-REFERENCE.md
# Detailed Example: API-USAGE-EXAMPLES.md - Case Study 1
curl "http://localhost:3000/api/v1/classifications/hubs?limit=50&type=Super%20Hub"
```

### 3. Visualize Local Network Structure
```javascript
// Quick Reference: API-QUICK-REFERENCE.md
// Detailed Example: API-USAGE-EXAMPLES.md - Example 5
const subgraph = await fetch(
  'http://localhost:3000/api/v1/nodes/0/subgraph?depth=2'
).then(res => res.json());

// Use with D3.js for visualization
```

### 4. Run Custom Analysis
```sparql
# Quick Reference: API-QUICK-REFERENCE.md
# Detailed Example: API-USAGE-EXAMPLES.md - Example 7
PREFIX roadonto: <http://example.org/roadnet/ontology#>

SELECT ?nodeId ?degree
WHERE {
  ?node roadonto:hasNodeId ?nodeId ;
        roadonto:hasDegree ?degree .
  FILTER(?degree > 10)
}
ORDER BY DESC(?degree)
```

---

## 🔧 Implementation Status

### ✅ Completed
- [x] OpenAPI 3.0 specification
- [x] REST endpoint design
- [x] SPARQL query interface specification
- [x] Comprehensive documentation
- [x] Usage examples and case studies
- [x] Postman collection
- [x] GraphQL schema design
- [x] Quick reference guide

### 🚧 To Implement
- [ ] REST API server (Node.js/Express)
- [ ] SPARQL client implementation
- [ ] GraphQL server (optional)
- [ ] API authentication
- [ ] Rate limiting
- [ ] Response caching
- [ ] API monitoring/logging

---

## 📖 Reading Path by Role

### Frontend Developer
1. [API-QUICK-REFERENCE.md](API-QUICK-REFERENCE.md) - Learn endpoints
2. [API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md) - JavaScript examples
3. [postman-collection.json](postman-collection.json) - Test API calls
4. Case Study 4 in [API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md) - React integration

### Backend Developer
1. [api-spec.yaml](api-spec.yaml) - API specification
2. [API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md) - Node.js integration
3. Example 11 in [API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md) - Express server

### Data Scientist
1. [API-QUICK-REFERENCE.md](API-QUICK-REFERENCE.md) - SPARQL queries
2. [API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md) - Python examples
3. Example 10 in [API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md) - Data analysis

### Product Manager / Analyst
1. [API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md) - Case Studies section
2. [API-QUICK-REFERENCE.md](API-QUICK-REFERENCE.md) - Use cases
3. [graphql-schema.md](graphql-schema.md) - Alternative design

### API Designer / Architect
1. [api-spec.yaml](api-spec.yaml) - REST design
2. [graphql-schema.md](graphql-schema.md) - GraphQL design
3. REST vs GraphQL comparison in [graphql-schema.md](graphql-schema.md)

---

## 🧪 Testing the API

### Option 1: Postman (Recommended)
1. Import [postman-collection.json](postman-collection.json)
2. Set environment variables:
   - `baseUrl`: `http://localhost:3000/api/v1`
   - `sparqlEndpoint`: `http://localhost:3030/roadnet/sparql`
3. Run requests in the collection

### Option 2: curl
```bash
# Network statistics
curl http://localhost:3000/api/v1/statistics/network

# Top nodes
curl "http://localhost:3000/api/v1/nodes?limit=10"

# Subgraph
curl "http://localhost:3000/api/v1/nodes/0/subgraph?depth=2"
```

### Option 3: Interactive API Explorer
```bash
# View with Swagger UI
npx @redocly/cli preview-docs api-spec.yaml

# Opens at http://localhost:8080
```

---

## 📝 File Sizes & Statistics

| File | Lines | Size | Type |
|------|-------|------|------|
| api-spec.yaml | ~900 | ~45 KB | OpenAPI 3.0 |
| API-USAGE-EXAMPLES.md | ~1,100 | ~65 KB | Documentation |
| API-QUICK-REFERENCE.md | ~450 | ~22 KB | Reference |
| postman-collection.json | ~500 | ~18 KB | Postman v2.1 |
| graphql-schema.md | ~950 | ~42 KB | GraphQL Schema |
| **Total** | **~3,900** | **~192 KB** | |

---

## 🔗 Related Files

In the project:
- [README.md](../README.md) - Main project documentation
- [src/services/sparql-client.js](../src/services/sparql-client.js) - SPARQL client implementation
- [src/services/sparql-queries.md](../src/services/sparql-queries.md) - SPARQL query examples
- [src/roadnet-visualizer.html](../src/roadnet-visualizer.html) - Web visualization

---

## 💡 Tips & Best Practices

1. **Always use pagination** for large datasets (nodes, edges)
2. **Cache network statistics** - they don't change frequently
3. **Use degree filtering** instead of fetching all nodes
4. **Batch related queries** when possible
5. **Test with Postman** before coding integrations
6. **Refer to case studies** for real-world patterns
7. **Use SPARQL endpoint** for custom analytics

---

## 📧 Support & Contribution

- **Questions**: See examples in [API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md)
- **Issues**: Check error codes in [API-QUICK-REFERENCE.md](API-QUICK-REFERENCE.md)
- **Contributions**: Follow OpenAPI specification in [api-spec.yaml](api-spec.yaml)

---

## 🗂️ Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-12 | Initial API documentation release |
|  |  | - OpenAPI 3.0 specification |
|  |  | - Usage examples and case studies |
|  |  | - Quick reference guide |
|  |  | - Postman collection |
|  |  | - GraphQL schema design |

---

**Last Updated**: January 12, 2026  
**Maintained By**: WADE Project Team  
**License**: MIT
