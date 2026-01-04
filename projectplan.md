# Pennsylvania Road Network Visualization Tool - Project Plan

## Overview
Build a modular SPA for visualizing and analyzing the Pennsylvania road network using semantic web technologies.

## Phase 1: Data Transformation & Knowledge Model

### 1.1 Convert Graph to RDF/OWL
Transform the edge list into an OWL ontology:

```turtle
@prefix road: <http://example.org/roadnet#> .
@prefix geo: <http://www.w3.org/2003/01/geo/wgs84_pos#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .

# Define classes
road:RoadNode a owl:Class ;
    rdfs:label "Road Network Node" .

road:RoadEdge a owl:Class ;
    rdfs:label "Road Network Edge" .

# Define properties
road:connectsTo a owl:ObjectProperty ;
    rdfs:domain road:RoadNode ;
    rdfs:range road:RoadNode .

road:hasConnectivity a owl:DatatypeProperty ;
    rdfs:domain road:RoadNode ;
    rdfs:range xsd:integer .

# Example instances
road:node_0 a road:RoadNode ;
    road:connectsTo road:node_1, road:node_6309, road:node_6353 ;
    road:hasConnectivity 3 .
```

### 1.2 Enrich with SKOS Concepts
Create a concept scheme for road network analysis:

```turtle
road:RoadNetworkConcepts a skos:ConceptScheme ;
    skos:prefLabel "Road Network Analysis Concepts" .

road:HighDegreeNode a skos:Concept ;
    skos:inScheme road:RoadNetworkConcepts ;
    skos:prefLabel "High Degree Intersection" ;
    skos:definition "Node with >5 connections" .

road:DeadEnd a skos:Concept ;
    skos:inScheme road:RoadNetworkConcepts ;
    skos:prefLabel "Dead End" ;
    skos:definition "Node with exactly 1 connection" .
```

### 1.3 SPARQL Endpoint Setup
Use Apache Jena Fuseki or GraphDB to host the data with SPARQL endpoint.

## Phase 2: Core Functionalities

### 2.1 SPARQL Queries to Implement

**Query 1: Get Node Connectivity**
```sparql
SELECT ?node (COUNT(?connected) as ?degree)
WHERE {
    ?node road:connectsTo ?connected .
}
GROUP BY ?node
ORDER BY DESC(?degree)
```

**Query 2: Find Dead Ends**
```sparql
SELECT ?node
WHERE {
    ?node road:connectsTo ?connected .
}
GROUP BY ?node
HAVING (COUNT(?connected) = 1)
```

**Query 3: Get Subgraph**
```sparql
SELECT ?from ?to
WHERE {
    ?from road:connectsTo ?to .
    FILTER(?from IN (road:node_0, road:node_1, ...))
}
```

## Phase 3: Visualization Extensions (3+ Required)

### Extension 1: Network Graph Visualization
**Technology:** D3.js force-directed graph
**Features:**
- Interactive node exploration
- Color coding by connectivity degree
- Zoom and pan
- Node clustering

**SPARQL Integration:**
- Query for subgraphs based on region
- Real-time degree calculation
- Filter by connectivity threshold

### Extension 2: Intelligent Filtering Dashboard
**Technology:** React components + Cytoscape.js
**Features:**
- Filter by node degree (slider)
- Geographic region selection (if coordinates added)
- Path finding between two nodes
- Community detection display

**SPARQL Queries:**
```sparql
# Filter by degree range
SELECT ?node ?degree
WHERE {
    {
        SELECT ?node (COUNT(?conn) as ?degree)
        WHERE { ?node road:connectsTo ?conn }
        GROUP BY ?node
    }
    FILTER(?degree >= ?minDegree && ?degree <= ?maxDegree)
}
```

### Extension 3: Layered Hierarchical View
**Technology:** Hierarchical edge bundling or Sankey diagram
**Features:**
- Layer nodes by connectivity tier
- Show flow patterns
- Identify bottlenecks
- Compare different regions

**SKOS Integration:**
- Classify nodes using SKOS concepts
- Visualize concept hierarchy
- Filter by concept categories

### Extension 4 (BONUS): 3D Network Globe
**Technology:** Three.js + WebGL/WebXR
**Features:**
- 3D force-directed layout
- VR/AR exploration (WebXR)
- Geographic mapping if lat/lon added
- Time-based evolution simulation

## Phase 4: Architecture

### 4.1 Tech Stack
```
Frontend:
- React.js (SPA framework)
- D3.js (2D visualizations)
- Three.js (3D visualizations)
- Cytoscape.js (network graphs)
- TailwindCSS (styling)

Backend:
- Apache Jena Fuseki (SPARQL endpoint)
- Python/Node.js (data transformation)

Data Processing:
- RDFLib (Python) for RDF generation
- NetworkX for graph analysis
```

### 4.2 Project Structure
```
roadnet-visualizer/
├── data/
│   ├── raw/
│   │   └── roadNet-PA.txt
│   ├── rdf/
│   │   ├── ontology.ttl
│   │   ├── nodes.ttl
│   │   └── skos-concepts.ttl
│   └── processed/
├── src/
│   ├── components/
│   │   ├── NetworkGraph/
│   │   ├── FilterDashboard/
│   │   ├── LayeredView/
│   │   └── Globe3D/
│   ├── services/
│   │   └── sparqlClient.js
│   ├── utils/
│   │   └── dataTransform.js
│   └── App.jsx
├── sparql/
│   └── queries/
└── scripts/
    └── convert_to_rdf.py
```

## Phase 5: Implementation Steps

### Step 1: Data Preparation (Week 1)
1. Write Python script to convert edge list to RDF
2. Calculate node statistics (degree, centrality)
3. Create OWL ontology
4. Define SKOS concept scheme
5. Generate turtle files

### Step 2: SPARQL Setup (Week 1)
1. Install Fuseki/GraphDB
2. Load RDF data
3. Test SPARQL queries
4. Document query patterns

### Step 3: Core Application (Week 2)
1. Set up React SPA
2. Implement SPARQL client
3. Create basic layout
4. Add routing

### Step 4: Extension Development (Week 2-3)
1. Build Extension 1: Network Graph
2. Build Extension 2: Filtering Dashboard
3. Build Extension 3: Layered Visualization
4. (Optional) Build Extension 4: 3D Globe

### Step 5: Integration & Polish (Week 3-4)
1. Connect all extensions
2. Add loading states
3. Optimize performance
4. Documentation
5. Demo preparation

## Key Features to Highlight

### Intelligent Filtering
- Degree-based filtering
- Path finding algorithms
- Community detection
- Anomaly identification

### Layered Visualizations
- Hierarchical network layout
- Temporal evolution (if you add timestamp data)
- Multi-level zoom
- Concept-based grouping

### Trend Computations
- Connectivity distribution over time
- Growth patterns
- Bottleneck analysis
- Traffic flow simulation

### Comparison Tasks
- Different regions of PA
- Before/after scenarios
- Multiple filtering criteria
- Concept scheme comparisons

## Bonus: 3D/WebXR Ideas

1. **Geographic 3D Globe**
   - Map nodes to actual PA geography
   - Height represents connectivity
   - WebXR for immersive exploration

2. **Force-Directed 3D**
   - Physics-based layout
   - Interactive manipulation
   - VR walkthrough

3. **Temporal 3D Animation**
   - Show network evolution
   - Path tracing visualization
   - Traffic simulation

## Data Enrichment Ideas

To make the project more impressive, consider adding:

1. **Geographic coordinates** (scrape or approximate)
2. **Road classifications** (highway, street, etc.)
3. **Traffic estimates** (synthetic data)
4. **Time dimensions** (historical changes)
5. **Community labels** (cities, counties)

## Deliverables

1. Working SPA with 3+ visualization extensions
2. RDF/OWL ontology files
3. SPARQL endpoint (can be local)
4. Documentation
5. Demo video/presentation
6. Source code repository

## Evaluation Criteria

✓ Proper SKOS/OWL knowledge model
✓ Functional SPARQL endpoint integration
✓ 3+ distinct visualization extensions
✓ Modular architecture
✓ Intelligent filtering capabilities
✓ Performance with large dataset
✓ (Bonus) WebGL/WebXR implementation