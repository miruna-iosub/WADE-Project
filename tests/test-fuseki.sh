#!/bin/bash

# Test script for verifying Fuseki and data are working

echo "================================================"
echo "Pennsylvania Road Network - Fuseki Test"
echo "================================================"
echo ""

# Test 1: Check if Fuseki is running
echo "Test 1: Checking if Fuseki is running..."
if curl -s http://localhost:3030/\$/ping > /dev/null 2>&1; then
    echo "✓ Fuseki is running!"
else
    echo "✗ Fuseki is NOT running. Please start it with:"
    echo "  cd ~/apache-jena-fuseki-4.10.0"
    echo "  ./fuseki-server --mem /roadnet"
    exit 1
fi

echo ""

# Test 2: Check if dataset exists
echo "Test 2: Checking if 'roadnet' dataset exists..."
if curl -s http://localhost:3030/roadnet/sparql > /dev/null 2>&1; then
    echo "✓ Dataset 'roadnet' exists!"
else
    echo "✗ Dataset 'roadnet' not found"
    exit 1
fi

echo ""

# Test 3: Count total triples
echo "Test 3: Counting total triples..."
RESULT=$(curl -s -X POST -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  --data 'SELECT (COUNT(*) AS ?count) WHERE { ?s ?p ?o }' \
  http://localhost:3030/roadnet/sparql)

COUNT=$(echo $RESULT | grep -o '"value":"[0-9]*"' | head -1 | grep -o '[0-9]*')

if [ -n "$COUNT" ] && [ "$COUNT" -gt 0 ]; then
    echo "✓ Found $COUNT triples in the dataset!"
else
    echo "✗ No triples found. Data may not be loaded."
    exit 1
fi

echo ""

# Test 4: Count nodes
echo "Test 4: Counting RoadNode instances..."
RESULT=$(curl -s -X POST -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  --data 'PREFIX roadonto: <http://example.org/roadnet/ontology#> SELECT (COUNT(?node) AS ?total) WHERE { ?node a roadonto:RoadNode . }' \
  http://localhost:3030/roadnet/sparql)

NODES=$(echo $RESULT | grep -o '"value":"[0-9]*"' | head -1 | grep -o '[0-9]*')

if [ -n "$NODES" ] && [ "$NODES" -gt 0 ]; then
    echo "✓ Found $NODES road network nodes!"
else
    echo "✗ No nodes found. There may be an issue with the data."
    exit 1
fi

echo ""

# Test 5: Check classifications
echo "Test 5: Checking node classifications..."
RESULT=$(curl -s -X POST -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  --data 'PREFIX roadonto: <http://example.org/roadnet/ontology#> PREFIX skos: <http://www.w3.org/2004/02/skos/core#> SELECT ?label (COUNT(?node) AS ?count) WHERE { ?node a roadonto:RoadNode ; roadonto:hasClassification ?class . ?class skos:prefLabel ?label . } GROUP BY ?label' \
  http://localhost:3030/roadnet/sparql)

if echo "$RESULT" | grep -q "Dead End"; then
    echo "✓ Classifications are working!"
else
    echo "⚠ Classifications may not be properly loaded"
fi

# Test 6: Check for geographic coordinates
echo "Test 6: Checking for geographic coordinates..."
RESULT=$(curl -s -X POST -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  --data 'PREFIX roadonto: <http://example.org/roadnet/ontology#> SELECT (COUNT(?node) AS ?count) WHERE { ?node roadonto:hasLatitude ?lat ; roadonto:hasLongitude ?lon . }' \
  http://localhost:3030/roadnet/sparql)

COORDS=$(echo $RESULT | grep -o '"value":"[0-9]*"' | head -1 | grep -o '[0-9]*')

if [ -n "$COORDS" ] && [ "$COORDS" -gt 0 ]; then
    echo "✓ Found $COORDS nodes with coordinates!"
else
    echo "✗ No geographic coordinates found."
    exit 1
fi

echo ""

# Test 7: Check road segments (edges)
echo "Test 7: Counting RoadSegment instances..."
RESULT=$(curl -s -X POST -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  --data 'PREFIX roadonto: <http://example.org/roadnet/ontology#> SELECT (COUNT(?segment) AS ?total) WHERE { ?segment a roadonto:RoadSegment . }' \
  http://localhost:3030/roadnet/sparql)

SEGMENTS=$(echo $RESULT | grep -o '"value":"[0-9]*"' | head -1 | grep -o '[0-9]*')

if [ -n "$SEGMENTS" ] && [ "$SEGMENTS" -gt 0 ]; then
    echo "✓ Found $SEGMENTS road segments!"
else
    echo "⚠ No road segments found. This may be expected if only nodes are modeled."
fi

echo ""

# Test 8: Check node connectivity
echo "Test 8: Checking node connectivity (connectsTo relationships)..."
RESULT=$(curl -s -X POST -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  --data 'PREFIX roadonto: <http://example.org/roadnet/ontology#> SELECT (COUNT(*) AS ?count) WHERE { ?node1 roadonto:connectsTo ?node2 . }' \
  http://localhost:3030/roadnet/sparql)

CONNECTIONS=$(echo $RESULT | grep -o '"value":"[0-9]*"' | head -1 | grep -o '[0-9]*')

if [ -n "$CONNECTIONS" ] && [ "$CONNECTIONS" -gt 0 ]; then
    echo "✓ Found $CONNECTIONS connections between nodes!"
else
    echo "✗ No connections found. Network may not be properly linked."
    exit 1
fi

echo ""

# Test 9: Check for node names/labels
echo "Test 9: Checking for node labels/names..."
RESULT=$(curl -s -X POST -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  --data 'PREFIX roadonto: <http://example.org/roadnet/ontology#> PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> SELECT (COUNT(?node) AS ?count) WHERE { ?node a roadonto:RoadNode ; rdfs:label ?label . }' \
  http://localhost:3030/roadnet/sparql)

LABELS=$(echo $RESULT | grep -o '"value":"[0-9]*"' | head -1 | grep -o '[0-9]*')

if [ -n "$LABELS" ] && [ "$LABELS" -gt 0 ]; then
    echo "✓ Found $LABELS nodes with labels!"
else
    echo "⚠ No node labels found. Consider adding rdfs:label properties."
fi

echo ""

# Test 10: Sample query - Most connected nodes
echo "Test 10: Finding most connected nodes (top 5)..."
RESULT=$(curl -s -X POST -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  --data 'PREFIX roadonto: <http://example.org/roadnet/ontology#> SELECT ?node (COUNT(?neighbor) AS ?connections) WHERE { ?node roadonto:connectsTo ?neighbor . } GROUP BY ?node ORDER BY DESC(?connections) LIMIT 5' \
  http://localhost:3030/roadnet/sparql)

if echo "$RESULT" | grep -q "node"; then
    echo "✓ Successfully queried most connected nodes!"
    # Extract and display the top result
    TOP_CONNECTIONS=$(echo $RESULT | grep -o '"connections":{"value":"[0-9]*"' | head -1 | grep -o '[0-9]*')
    if [ -n "$TOP_CONNECTIONS" ]; then
        echo "  Most connected node has $TOP_CONNECTIONS connections"
    fi
else
    echo "⚠ Could not retrieve connection statistics"
fi

echo ""

# Test 11: Check classification distribution
echo "Test 11: Checking classification distribution..."
RESULT=$(curl -s -X POST -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  --data 'PREFIX roadonto: <http://example.org/roadnet/ontology#> PREFIX skos: <http://www.w3.org/2004/02/skos/core#> SELECT ?label (COUNT(?node) AS ?count) WHERE { ?node a roadonto:RoadNode ; roadonto:hasClassification ?class . ?class skos:prefLabel ?label . } GROUP BY ?label ORDER BY DESC(?count)' \
  http://localhost:3030/roadnet/sparql)

if echo "$RESULT" | grep -q "label"; then
    echo "✓ Classification distribution:"
    # Try to extract and display counts (basic parsing)
    echo "$RESULT" | grep -o '"label":{"value":"[^"]*"},"count":{"value":"[0-9]*"}' | while read -r line; do
        LABEL=$(echo $line | grep -o '"label":{"value":"[^"]*"}' | sed 's/"label":{"value":"\([^"]*\)"}/\1/')
        COUNT=$(echo $line | grep -o '"count":{"value":"[0-9]*"}' | sed 's/"count":{"value":"\([0-9]*\)"}/\1/')
        echo "  - $LABEL: $COUNT nodes"
    done
else
    echo "⚠ Could not retrieve classification distribution"
fi

echo ""

# Test 12: Geographic bounds check
echo "Test 12: Checking geographic bounds..."
RESULT=$(curl -s -X POST -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-results+json" \
  --data 'PREFIX roadonto: <http://example.org/roadnet/ontology#> SELECT (MIN(?lat) AS ?minLat) (MAX(?lat) AS ?maxLat) (MIN(?lon) AS ?minLon) (MAX(?lon) AS ?maxLon) WHERE { ?node roadonto:hasLatitude ?lat ; roadonto:hasLongitude ?lon . }' \
  http://localhost:3030/roadnet/sparql)

if echo "$RESULT" | grep -q "minLat"; then
    echo "✓ Geographic bounds calculated successfully!"
    # Extract bounds
    MIN_LAT=$(echo $RESULT | grep -o '"minLat":{"value":"[0-9.-]*"' | grep -o '[0-9.-]*' | tail -1)
    MAX_LAT=$(echo $RESULT | grep -o '"maxLat":{"value":"[0-9.-]*"' | grep -o '[0-9.-]*' | tail -1)
    MIN_LON=$(echo $RESULT | grep -o '"minLon":{"value":"[0-9.-]*"' | grep -o '[0-9.-]*' | tail -1)
    MAX_LON=$(echo $RESULT | grep -o '"maxLon":{"value":"[0-9.-]*"' | grep -o '[0-9.-]*' | tail -1)
    if [ -n "$MIN_LAT" ]; then
        echo "  Latitude range: $MIN_LAT to $MAX_LAT"
        echo "  Longitude range: $MIN_LON to $MAX_LON"
    fi
else
    echo "⚠ Could not retrieve geographic bounds"
fi

echo ""
echo "================================================"
echo "✓ All tests passed!"
echo "================================================"
echo ""
echo "Summary:"
echo "- Total triples: $COUNT"
echo "- Road nodes: $NODES"
echo "- Coordinates: $COORDS"
echo "- Connections: $CONNECTIONS"
if [ -n "$SEGMENTS" ] && [ "$SEGMENTS" -gt 0 ]; then
    echo "- Road segments: $SEGMENTS"
fi
echo ""
echo "You can now open the visualization:"
echo "1. Open roadnet-visualizer.html in your browser"
echo "2. Click 'Apply Filters' or any preset button"
echo "3. Explore the network!"
echo ""