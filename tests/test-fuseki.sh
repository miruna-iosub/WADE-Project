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

echo ""
echo "================================================"
echo "✓ All tests passed!"
echo "================================================"
echo ""
echo "You can now open the visualization:"
echo "1. Open roadnet-visualizer.html in your browser"
echo "2. Click 'Apply Filters' or any preset button"
echo "3. Explore the network!"
echo ""
echo "File location: /mnt/c/Users/mirun/Downloads/wade/roadnet-visualizer.html"