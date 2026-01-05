# SPARQL Queries for Pennsylvania Road Network

## Setup
```
PREFIX road: <http://example.org/roadnet/pa#>
PREFIX roadonto: <http://example.org/roadnet/ontology#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
```

## Query 1: Get All Nodes with Their Degree

```sparql
PREFIX road: <http://example.org/roadnet/pa#>
PREFIX roadonto: <http://example.org/roadnet/ontology#>

SELECT ?node ?nodeId ?degree ?classification
WHERE {
    ?node a roadonto:RoadNode ;
          roadonto:hasNodeId ?nodeId ;
          roadonto:hasDegree ?degree .
    OPTIONAL { ?node roadonto:hasClassification ?classification }
}
ORDER BY DESC(?degree)
LIMIT 100
```

## Query 2: Find Major Hubs (High Connectivity Nodes)

```sparql
PREFIX road: <http://example.org/roadnet/pa#>
PREFIX roadonto: <http://example.org/roadnet/ontology#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?node ?nodeId ?degree
WHERE {
    ?node a roadonto:RoadNode ;
          roadonto:hasNodeId ?nodeId ;
          roadonto:hasDegree ?degree ;
          roadonto:hasClassification ?classification .
    
    ?classification skos:prefLabel ?label .
    FILTER(?label IN ("Major Hub", "Super Hub"))
}
ORDER BY DESC(?degree)
```

## Query 3: Get Subgraph Around a Node

```sparql
PREFIX road: <http://example.org/roadnet/pa#>
PREFIX roadonto: <http://example.org/roadnet/ontology#>

SELECT ?fromNode ?toNode ?fromId ?toId
WHERE {
    VALUES ?centerNode { road:node_0 }
    
    {
        ?centerNode roadonto:connectsTo ?toNode .
        ?centerNode roadonto:hasNodeId ?fromId .
        ?toNode roadonto:hasNodeId ?toId .
        BIND(?centerNode AS ?fromNode)
    }
    UNION
    {
        ?fromNode roadonto:connectsTo ?centerNode .
        ?fromNode roadonto:hasNodeId ?fromId .
        ?centerNode roadonto:hasNodeId ?toId .
        BIND(?centerNode AS ?toNode)
    }
}
LIMIT 50
```

## Query 4: Find Dead Ends

```sparql
PREFIX road: <http://example.org/roadnet/pa#>
PREFIX roadonto: <http://example.org/roadnet/ontology#>

SELECT ?node ?nodeId
WHERE {
    ?node a roadonto:RoadNode ;
          roadonto:hasNodeId ?nodeId ;
          roadonto:hasDegree 1 ;
          roadonto:hasClassification road:DeadEnd .
}
LIMIT 100
```

## Query 5: Degree Distribution

```sparql
PREFIX roadonto: <http://example.org/roadnet/ontology#>

SELECT ?degree (COUNT(?node) AS ?count)
WHERE {
    ?node a roadonto:RoadNode ;
          roadonto:hasDegree ?degree .
}
GROUP BY ?degree
ORDER BY ?degree
```

## Query 6: Get Nodes by Degree Range (For Filtering)

```sparql
PREFIX roadonto: <http://example.org/roadnet/ontology#>

SELECT ?node ?nodeId ?degree
WHERE {
    ?node a roadonto:RoadNode ;
          roadonto:hasNodeId ?nodeId ;
          roadonto:hasDegree ?degree .
    
    FILTER(?degree >= 5 && ?degree <= 10)
}
ORDER BY DESC(?degree)
LIMIT 100
```

## Query 7: Get SKOS Concept Hierarchy

```sparql
PREFIX road: <http://example.org/roadnet/pa#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?concept ?label ?broader ?definition
WHERE {
    ?concept a skos:Concept ;
             skos:inScheme road:ConceptScheme ;
             skos:prefLabel ?label ;
             skos:definition ?definition .
    
    OPTIONAL { ?concept skos:broader ?broader }
}
```

## Query 8: Count Nodes by Classification

```sparql
PREFIX road: <http://example.org/roadnet/pa#>
PREFIX roadonto: <http://example.org/roadnet/ontology#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?classLabel (COUNT(?node) AS ?nodeCount)
WHERE {
    ?node a roadonto:RoadNode ;
          roadonto:hasClassification ?classification .
    
    ?classification skos:prefLabel ?classLabel .
}
GROUP BY ?classLabel
ORDER BY DESC(?nodeCount)
```

## Query 9: Find Paths Between Two Nodes (Two Hops)

```sparql
PREFIX road: <http://example.org/roadnet/pa#>
PREFIX roadonto: <http://example.org/roadnet/ontology#>

SELECT ?intermediate ?startId ?intId ?endId
WHERE {
    VALUES ?start { road:node_0 }
    VALUES ?end { road:node_7 }
    
    ?start roadonto:connectsTo ?intermediate .
    ?intermediate roadonto:connectsTo ?end .
    
    ?start roadonto:hasNodeId ?startId .
    ?intermediate roadonto:hasNodeId ?intId .
    ?end roadonto:hasNodeId ?endId .
}
LIMIT 10
```

## Query 10: Get Network Statistics

```sparql
PREFIX roadonto: <http://example.org/roadnet/ontology#>

SELECT 
    (COUNT(DISTINCT ?node) AS ?totalNodes)
    (COUNT(?connection) AS ?totalEdges)
    (AVG(?degree) AS ?avgDegree)
    (MAX(?degree) AS ?maxDegree)
WHERE {
    ?node a roadonto:RoadNode ;
          roadonto:hasDegree ?degree .
    
    OPTIONAL { ?node roadonto:connectsTo ?connection }
}
```

## Query 11: Get Edges for Visualization (Paginated)

```sparql
PREFIX road: <http://example.org/roadnet/pa#>
PREFIX roadonto: <http://example.org/roadnet/ontology#>

SELECT ?fromId ?toId ?fromDegree ?toDegree
WHERE {
    ?from roadonto:connectsTo ?to ;
          roadonto:hasNodeId ?fromId ;
          roadonto:hasDegree ?fromDegree .
    
    ?to roadonto:hasNodeId ?toId ;
        roadonto:hasDegree ?toDegree .
}
LIMIT 1000
OFFSET 0
```

## Query 12: Find Nodes in Specific Degree Range with Classifications

```sparql
PREFIX road: <http://example.org/roadnet/pa#>
PREFIX roadonto: <http://example.org/roadnet/ontology#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

SELECT ?nodeId ?degree ?classLabel
WHERE {
    ?node a roadonto:RoadNode ;
          roadonto:hasNodeId ?nodeId ;
          roadonto:hasDegree ?degree ;
          roadonto:hasClassification ?classification .
    
    ?classification skos:prefLabel ?classLabel .
    
    FILTER(?degree >= ?minDegree && ?degree <= ?maxDegree)
}
ORDER BY DESC(?degree)
LIMIT 100
```

## Query 13: Get Neighborhood for Network Visualization

```sparql
PREFIX road: <http://example.org/roadnet/pa#>
PREFIX roadonto: <http://example.org/roadnet/ontology#>

SELECT DISTINCT ?fromId ?toId ?degree
WHERE {
    VALUES ?centerIds { 0 1 2 3 4 5 }
    
    {
        # Get connections from center nodes
        ?from roadonto:hasNodeId ?centerIds ;
              roadonto:connectsTo ?to ;
              roadonto:hasDegree ?degree .
        
        ?from roadonto:hasNodeId ?fromId .
        ?to roadonto:hasNodeId ?toId .
    }
    UNION
    {
        # Get connections to center nodes
        ?from roadonto:connectsTo ?to ;
              roadonto:hasDegree ?degree .
        
        ?to roadonto:hasNodeId ?centerIds .
        ?from roadonto:hasNodeId ?fromId .
        ?to roadonto:hasNodeId ?toId .
    }
}
```

## Query 14: Get In/Out Degree Asymmetry

```sparql
PREFIX roadonto: <http://example.org/roadnet/ontology#>

SELECT ?nodeId ?inDegree ?outDegree (?inDegree - ?outDegree AS ?asymmetry)
WHERE {
    ?node a roadonto:RoadNode ;
          roadonto:hasNodeId ?nodeId ;
          roadonto:hasInDegree ?inDegree ;
          roadonto:hasOutDegree ?outDegree .
    
    FILTER(?inDegree != ?outDegree)
}
ORDER BY DESC(ABS(?inDegree - ?outDegree))
LIMIT 100
```

## Usage in JavaScript/React

```javascript
// Example SPARQL client
class SPARQLClient {
    constructor(endpoint) {
        this.endpoint = endpoint;
    }
    
    async query(sparqlQuery) {
        const response = await fetch(this.endpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/sparql-query',
                'Accept': 'application/sparql-results+json'
            },
            body: sparqlQuery
        });
        
        return await response.json();
    }
    
    async getHighDegreeNodes(minDegree = 5) {
        const query = `
            PREFIX roadonto: <http://example.org/roadnet/ontology#>
            
            SELECT ?nodeId ?degree
            WHERE {
                ?node roadonto:hasNodeId ?nodeId ;
                      roadonto:hasDegree ?degree .
                FILTER(?degree >= ${minDegree})
            }
            ORDER BY DESC(?degree)
            LIMIT 100
        `;
        
        return this.query(query);
    }
    
    async getSubgraph(nodeIds, depth = 1) {
        const nodeList = nodeIds.map(id => `road:node_${id}`).join(' ');
        
        const query = `
            PREFIX road: <http://example.org/roadnet/pa#>
            PREFIX roadonto: <http://example.org/roadnet/ontology#>
            
            SELECT ?fromId ?toId
            WHERE {
                VALUES ?nodes { ${nodeList} }
                
                ?nodes roadonto:connectsTo ?to ;
                       roadonto:hasNodeId ?fromId .
                ?to roadonto:hasNodeId ?toId .
            }
        `;
        
        return this.query(query);
    }
}
```