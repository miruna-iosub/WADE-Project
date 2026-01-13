# Pennsylvania Road Network Visualizer

An interactive web-based visualization tool for analyzing the Pennsylvania road network using semantic web technologies (RDF/OWL), SPARQL queries, and D3.js force-directed graphs.

![Network Visualization](https://img.shields.io/badge/Nodes-1%2C088%2C092-blue)
![Edges](https://img.shields.io/badge/Edges-3%2C083%2C796-green)
![Triples](https://img.shields.io/badge/RDF%20Triples-9%2C612%2C407-orange)

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [API Documentation](#api-documentation)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [SPARQL Queries](#sparql-queries)
- [Troubleshooting](#troubleshooting)
- [Technologies Used](#technologies-used)

---

## Demo Video : https://youtu.be/dMxf7h9oj-U

## 🎯 Overview

This project transforms the Stanford SNAP Pennsylvania road network dataset into a semantic web knowledge base using RDF/OWL ontologies and SKOS concept schemes. It provides an interactive visualization interface that allows users to explore network topology, node classifications, and connectivity patterns through SPARQL queries.

**Key Statistics:**
- **Nodes:** 1,088,092 road intersections/endpoints
- **Edges:** 3,083,796 road connections
- **Average Degree:** 5.67 connections per node
- **Max Degree:** 18 connections (super hubs)

---

## ✨ Features

### Data Processing
- ✅ Converts edge list format to RDF/OWL ontology
- ✅ Automatic node classification using SKOS concepts
- ✅ Calculates network statistics (degree, in-degree, out-degree)
- ✅ Generates 9.6M+ semantic triples

### Node Classifications (SKOS)
- **Dead End** - Degree 2 (minimal connectivity)
- **Simple Junction** - Degree 2-4
- **Intersection** - Degree 4-6
- **Major Hub** - Degree 6-10
- **Super Hub** - Degree 10+ (critical intersections)

### Interactive Visualization
- 🗺️ Force-directed network graph (D3.js)
- 🎛️ Dynamic filtering by degree range
- 📊 Real-time network statistics
- 🔍 Node hover tooltips
- 🎨 Color-coded by classification
- 🖱️ Draggable nodes
- 📈 Classification distribution charts

### SPARQL Query Interface
- Query nodes by degree range
- Find major hubs and dead ends
- Extract subgraphs
- Analyze network topology
- Get classification statistics

---

## 🏗️ Architecture

```
┌─────────────────┐
│   Raw Dataset   │
│  roadNet-PA.txt │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Python Converter│  ← Generates RDF/OWL + SKOS
│ convert-to-rdf  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   RDF Triples   │
│   (Turtle TTL)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Apache Jena     │  ← SPARQL Endpoint
│    Fuseki       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Web Client    │  ← D3.js Visualization
│ (HTML/JS/CSS)   │
└─────────────────┘
```

---

## � API Documentation

This project provides a comprehensive **REST API** with an **OpenAPI 3.0 specification** for querying and analyzing the Pennsylvania road network data.

### API Resources

| Resource | Description |
|----------|-------------|
| **[api-spec.yaml](api-spec.yaml)** | Complete OpenAPI 3.0 specification with all endpoints, schemas, and examples |
| **[API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md)** | Comprehensive usage guide with 12 detailed examples and 4 case studies |
| **[API-QUICK-REFERENCE.md](API-QUICK-REFERENCE.md)** | Quick reference guide for common operations and SPARQL queries |
| **[postman-collection.json](postman-collection.json)** | Postman collection for testing all API endpoints |

### Quick Start

#### View API Documentation
```bash
# Using Swagger UI (recommended)
npx @redocly/cli preview-docs api-spec.yaml

# Or use any OpenAPI viewer
# https://editor.swagger.io/ - Paste api-spec.yaml content
```

#### Test API Endpoints
```bash
# Get network statistics
curl http://localhost:3000/api/v1/statistics/network

# Get top 10 most connected nodes
curl "http://localhost:3000/api/v1/nodes?limit=10"

# Find major hubs (degree 6-10)
curl "http://localhost:3000/api/v1/nodes/by-degree?minDegree=6&maxDegree=10"
```

### API Endpoints Overview

#### Nodes
- `GET /nodes` - List all nodes with pagination
- `GET /nodes/by-degree` - Filter nodes by degree range
- `GET /nodes/{nodeId}` - Get specific node details
- `GET /nodes/{nodeId}/subgraph` - Get subgraph around a node

#### Statistics
- `GET /statistics/network` - Overall network statistics
- `GET /statistics/degree-distribution` - Node degree distribution

#### Classifications
- `GET /classifications` - Classification distribution stats
- `GET /classifications/concepts` - SKOS concept hierarchy
- `GET /classifications/dead-ends` - List dead end nodes
- `GET /classifications/hubs` - List major hub nodes

#### SPARQL
- `POST /sparql/query` - Execute custom SPARQL queries

### Real-World Case Studies

The API documentation includes 4 detailed case studies:

1. **Traffic Management System** - Identify critical intersections for monitoring
2. **Road Maintenance Optimization** - Allocate resources based on connectivity
3. **Emergency Response Planning** - Find optimal locations for response stations
4. **Network Visualization Dashboard** - Build interactive React + D3.js app

### Import into Postman

1. Open Postman
2. Click **Import** → **File**
3. Select `postman-collection.json`
4. Update environment variables:
   - `baseUrl`: `http://localhost:3000/api/v1`
   - `sparqlEndpoint`: `http://localhost:3030/roadnet/sparql`

### Example: Get Node Subgraph (JavaScript)

```javascript
async function getNodeSubgraph(nodeId, depth = 2) {
  const response = await fetch(
    `http://localhost:3000/api/v1/nodes/${nodeId}/subgraph?depth=${depth}`
  );
  const data = await response.json();
  
  console.log(`Center node: ${data.centerNode.nodeId}`);
  console.log(`Connected nodes: ${data.meta.nodeCount}`);
  console.log(`Edges: ${data.meta.edgeCount}`);
  
  return data;
}

// Usage
const subgraph = await getNodeSubgraph('0', 2);
```

### Example: Custom SPARQL Query (Python)

```python
import requests

query = """
PREFIX roadonto: <http://example.org/roadnet/ontology#>

SELECT ?nodeId ?degree
WHERE {
  ?node roadonto:hasNodeId ?nodeId ;
        roadonto:hasDegree ?degree .
  FILTER(?degree > 10)
}
ORDER BY DESC(?degree)
LIMIT 10
"""

response = requests.post(
    'http://localhost:3000/api/v1/sparql/query',
    json={'query': query, 'format': 'json'}
)

results = response.json()
for binding in results['results']['bindings']:
    print(f"Node: {binding['nodeId']['value']}, "
          f"Degree: {binding['degree']['value']}")
```

For complete documentation, see **[API-USAGE-EXAMPLES.md](API-USAGE-EXAMPLES.md)**.

---

## �📦 Prerequisites

### Required Software
- **Python 3.8+** (for data conversion)
- **Java 11+** (for Apache Jena Fuseki)
- **Modern web browser** (Chrome, Firefox, Edge)

### Python Packages
```bash
pip install rdflib networkx --break-system-packages
```

### System Requirements
- **RAM:** 4GB minimum (8GB recommended for full dataset)
- **Disk Space:** 500MB for RDF files
- **OS:** Windows (WSL), Linux, or macOS

---

## 🚀 Installation

### Step 1: Clone/Download Project Files

Ensure you have these files:
```
wade/
├── roadNet-PA.txt           # Original dataset
├── convert-to-rdf.py        # RDF conversion script
├── roadnet-visualizer.html  # Web visualization
└── output/                  # Generated RDF files (created by script)
    └── roadnet_complete.ttl
```

### Step 2: Install Dependencies

**On Windows (PowerShell):**
```powershell
pip install rdflib networkx --break-system-packages
```

**On Linux/WSL:**
```bash
pip install rdflib networkx
```

### Step 3: Convert Dataset to RDF

**Option A: Full Dataset (1M+ nodes, ~10 minutes)**
```bash
python convert-to-rdf.py roadNet-PA.txt --output-dir output
```

**Option B: Sample (10%, ~1 minute for testing)**
```bash
python convert-to-rdf.py roadNet-PA.txt --output-dir output --sample-rate 0.1
```

**Output:**
```
✓ Conversion complete!
  Saved complete graph to output/roadnet_complete.ttl
  Total triples: 9612407
```

### Step 4: Install Apache Jena Fuseki

**On Linux/WSL:**
```bash
cd ~
wget https://archive.apache.org/dist/jena/binaries/apache-jena-fuseki-4.10.0.tar.gz
tar -xzf apache-jena-fuseki-4.10.0.tar.gz
cd apache-jena-fuseki-4.10.0
```

**Install Java (if needed):**
```bash
sudo apt update
sudo apt install default-jre default-jdk -y
```

### Step 5: Start Fuseki Server

```bash
cd ~/apache-jena-fuseki-4.10.0
./fuseki-server --mem /roadnet
```

**Expected output:**
```
INFO  Server          :: Apache Jena Fuseki 4.10.0
INFO  Server          :: Fuseki running on http://localhost:3030
```

**Keep this terminal running!**

### Step 6: Load RDF Data into Fuseki

1. Open browser to: **http://localhost:3030**
2. Click **"manage datasets"**
3. Select **"roadnet"** dataset
4. Click **"upload data"**
5. Choose file: `output/roadnet_complete.ttl`
6. Click **"upload"** and wait (~90 seconds for full dataset)

### Step 7: Verify Data Loading

**Test query:**
```bash
curl -X POST -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  --data 'SELECT (COUNT(*) AS ?count) WHERE { ?s ?p ?o }' \
  http://localhost:3030/roadnet/sparql
```

**Expected result:**
```json
{
  "count": { "value": "9612407" }
}
```

✅ If you see ~9.6M triples, data is loaded successfully!

---

## 🎮 Usage

### Opening the Visualization

1. **Open** `roadnet-visualizer.html` in your web browser
2. Wait for statistics to load (should show 1,088,092 nodes)
3. Use the filters and buttons to explore the network

### Recommended Viewing Options

#### Option 1: See Road Segments (Best for Understanding Structure)
- Set **Min Degree: 2**
- Set **Max Degree: 4**
- Set **Nodes to Display: 100**
- Click **"Apply Filters"**

**Result:** Shows typical road segments with clear connections

#### Option 2: Major Intersections
- Click **"Show Major Hubs"**

**Result:** Displays high-traffic intersections (degree ≥ 6)

#### Option 3: Dead Ends
- Click **"Show Dead Ends"**

**Result:** Shows terminal nodes (degree = 2)

#### Option 4: Random Sample
- Click **"Random Sample"**

**Result:** Diverse mix of node types

### Understanding the Visualization

**Elements:**
- **Nodes (circles):** Road intersections/endpoints
- **Edges (lines):** Road connections
- **Colors:** 
  - 🔴 Red: Dead Ends (degree 2)
  - 🟠 Orange: Simple Junctions (2-4)
  - 🔵 Blue: Intersections (4-6)
  - 🟣 Purple: Major Hubs (6-10)
  - 🌸 Pink: Super Hubs (10+)

**Interactions:**
- **Hover:** View node details (ID, degree, classification)
- **Drag:** Move nodes around
- **Auto-layout:** Force-directed physics simulation

---

## 📁 Project Structure

```
pennsylvania-road-network/
│
├── data/
│   ├── roadNet-PA.txt              # Original dataset
│   └── output/
│       └── roadnet_complete.ttl    # Generated RDF file
│
├── scripts/
│   └── convert-to-rdf.py           # Python RDF converter
│
├── web/
│   └── roadnet-visualizer.html     # Interactive visualization
│
├── sparql/
│   └── sample-queries.txt          # Example SPARQL queries
│
└── README.md                        # This file
```

---

## 🔍 SPARQL Queries

### Query 1: Get Network Statistics

```sparql
PREFIX roadonto: <http://example.org/roadnet/ontology#>

SELECT 
    (COUNT(DISTINCT ?node) AS ?totalNodes)
    (AVG(?degree) AS ?avgDegree)
    (MAX(?degree) AS ?maxDegree)
WHERE {
    ?node a roadonto:RoadNode ;
          roadonto:hasDegree ?degree .
}
```

### Query 2: Find Major Hubs

```sparql
PREFIX roadonto: <http://example.org/roadnet/ontology#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?nodeId ?degree ?label
WHERE {
    ?node a roadonto:RoadNode ;
          roadonto:hasNodeId ?nodeId ;
          roadonto:hasDegree ?degree ;
          roadonto:hasClassification ?class .
    
    ?class skos:prefLabel ?label .
    FILTER(?degree >= 6)
}
ORDER BY DESC(?degree)
LIMIT 100
```

### Query 3: Get Classification Counts

```sparql
PREFIX roadonto: <http://example.org/roadnet/ontology#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?label (COUNT(?node) AS ?count)
WHERE {
    ?node a roadonto:RoadNode ;
          roadonto:hasClassification ?class .
    
    ?class skos:prefLabel ?label .
}
GROUP BY ?label
ORDER BY DESC(?count)
```

### Query 4: Filter by Degree Range

```sparql
PREFIX roadonto: <http://example.org/roadnet/ontology#>

SELECT ?nodeId ?degree
WHERE {
    ?node a roadonto:RoadNode ;
          roadonto:hasNodeId ?nodeId ;
          roadonto:hasDegree ?degree .
    
    FILTER(?degree >= 4 && ?degree <= 6)
}
ORDER BY DESC(?degree)
LIMIT 100
```

**Test queries at:** http://localhost:3030 → Click "query" on roadnet dataset

---

## 🐛 Troubleshooting

### Problem: "Could not connect to Fuseki"

**Symptoms:** Visualization shows connection error

**Solutions:**
1. Check Fuseki is running: Visit http://localhost:3030
2. Restart Fuseki:
   ```bash
   cd ~/apache-jena-fuseki-4.10.0
   ./fuseki-server --mem /roadnet
   ```
3. Reload data via web interface

### Problem: "0 triples found"

**Symptoms:** Queries return empty results

**Solutions:**
1. Re-upload data:
   - Go to http://localhost:3030
   - Click "upload data"
   - Select `roadnet_complete.ttl`
   - Wait for completion (~90 seconds)

2. Verify upload:
   ```bash
   curl -X POST -H "Content-Type: application/sparql-query" \
     --data 'SELECT (COUNT(*) AS ?count) WHERE { ?s ?p ?o }' \
     http://localhost:3030/roadnet/sparql
   ```

### Problem: "Nodes visible but no edges"

**Symptoms:** Visualization shows disconnected dots

**Cause:** High-degree nodes are spread far apart and rarely direct neighbors

**Solutions:**
- Use **lower degree filters** (2-6 instead of 6+)
- Click **"Show Dead Ends"** for linear segments
- Set **Max Degree: 4** for connected regions

### Problem: "Java not found"

**Symptoms:** `Cannot find a Java JDK`

**Solution:**
```bash
sudo apt update
sudo apt install default-jre default-jdk -y
java -version  # Verify installation
```

### Problem: "Visualization is slow"

**Solutions:**
1. Reduce **"Nodes to Display"** to 50 or fewer
2. Use narrower degree range filters
3. Close other browser tabs
4. Increase system RAM if possible

### Problem: "Data lost after Fuseki restart"

**Cause:** Using `--mem` flag creates in-memory database

**Solution:** Data must be re-uploaded after each Fuseki restart, or use persistent storage:
```bash
# Create persistent database
mkdir -p run/databases/roadnet
./tdbloader --loc=run/databases/roadnet /path/to/roadnet_complete.ttl
./fuseki-server --loc=run/databases/roadnet /roadnet
```

---

## 🛠️ Technologies Used

### Backend
- **Python 3.10+** - Data processing
- **RDFLib** - RDF graph manipulation
- **NetworkX** - Graph analysis
- **Apache Jena Fuseki 4.10.0** - SPARQL endpoint

### Ontologies
- **OWL** - Web Ontology Language
- **SKOS** - Simple Knowledge Organization System
- **RDF** - Resource Description Framework

### Frontend
- **HTML5/CSS3** - Structure and styling
- **JavaScript (ES6+)** - Application logic
- **D3.js v7** - Force-directed graph visualization
- **Fetch API** - SPARQL query client

### Data Format
- **Turtle (.ttl)** - RDF serialization
- **SPARQL** - Query language
- **JSON** - API responses

---

## 📊 Dataset Information

**Source:** Stanford Network Analysis Project (SNAP)
**Dataset:** roadNet-PA (Pennsylvania Road Network)
**Format:** Edge list (tab-separated)

**Structure:**
```
# FromNodeId    ToNodeId
0               1
0               6309
0               6353
...
```

**Converted to:**
- **Nodes:** `road:node_{id}` instances of `roadonto:RoadNode`
- **Edges:** `roadonto:connectsTo` object properties
- **Properties:** `hasDegree`, `hasInDegree`, `hasOutDegree`, `hasNodeId`
- **Classifications:** SKOS concepts (DeadEnd, SimpleJunction, Intersection, MajorHub, SuperHub)

---

## 📈 Performance Notes

**Conversion Time:**
- 10% sample: ~1 minute
- Full dataset: ~5-10 minutes

**Fuseki Loading:**
- Via web upload: ~90 seconds
- Via tdbloader: ~5-10 minutes

**Query Performance:**
- Simple counts: <1 second
- Filtered queries: 1-10 seconds
- Complex subgraph: 5-15 seconds

**Visualization:**
- 50 nodes: Smooth (60fps)
- 100 nodes: Good (30-60fps)
- 150+ nodes: Slow (<30fps)

---

## 🤝 Contributing

This is a course project for semantic web technologies. Suggestions for improvement:

1. **Add geographic coordinates** for map-based visualization
2. **Implement path-finding algorithms** (shortest path, etc.)
3. **Add temporal dimension** for network evolution
4. **Create 3D visualization** using Three.js
5. **Export subgraphs** to various formats

---

## 📝 License

Educational project - Dataset from Stanford SNAP.

---

## 📧 Contact

For questions about this implementation, refer to course materials or instructor.

---

## 🎓 Academic Context

**Course:** Web Application Development with Semantic Web
**Topic:** RDF/OWL Ontologies, SPARQL, Knowledge Graphs
**Learning Objectives:**
- Transform raw data into semantic web format
- Design OWL ontologies with SKOS vocabularies
- Implement SPARQL endpoints and queries
- Create interactive semantic web applications

---

## ⚡ Quick Start Checklist

- [ ] Install Python dependencies
- [ ] Convert dataset to RDF
- [ ] Install and start Fuseki
- [ ] Upload RDF data to Fuseki
- [ ] Open visualization in browser
- [ ] Test with "Apply Filters" button
- [ ] Explore different degree ranges
- [ ] Try SPARQL queries in Fuseki UI

**Total setup time:** 15-20 minutes

---
