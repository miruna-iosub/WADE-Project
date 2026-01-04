// src/services/sparqlClient.js
// SPARQL Client for querying the road network

export class SPARQLClient {
    constructor(endpoint = 'http://localhost:3030/roadnet/sparql') {
        this.endpoint = endpoint;
    }

    async query(sparqlQuery) {
        try {
            const response = await fetch(this.endpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/sparql-query',
                    'Accept': 'application/sparql-results+json'
                },
                body: sparqlQuery
            });

            if (!response.ok) {
                throw new Error(`SPARQL query failed: ${response.statusText}`);
            }

            const data = await response.json();
            return this.parseResults(data);
        } catch (error) {
            console.error('SPARQL query error:', error);
            throw error;
        }
    }

    parseResults(data) {
        if (!data.results || !data.results.bindings) {
            return [];
        }

        return data.results.bindings.map(binding => {
            const row = {};
            for (const key in binding) {
                row[key] = binding[key].value;
            }
            return row;
        });
    }

    // Get nodes with their connectivity degree
    async getNodes(limit = 100, offset = 0) {
        const query = `
            PREFIX roadonto: <http://example.org/roadnet/ontology#>
            
            SELECT ?nodeId ?degree ?inDegree ?outDegree
            WHERE {
                ?node a roadonto:RoadNode ;
                      roadonto:hasNodeId ?nodeId ;
                      roadonto:hasDegree ?degree ;
                      roadonto:hasInDegree ?inDegree ;
                      roadonto:hasOutDegree ?outDegree .
            }
            ORDER BY DESC(?degree)
            LIMIT ${limit}
            OFFSET ${offset}
        `;
        
        return this.query(query);
    }

    // Get nodes filtered by degree range
    async getNodesByDegree(minDegree, maxDegree, limit = 100) {
        const query = `
            PREFIX roadonto: <http://example.org/roadnet/ontology#>
            PREFIX road: <http://example.org/roadnet/pa#>
            PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
            
            SELECT ?nodeId ?degree ?classification
            WHERE {
                ?node a roadonto:RoadNode ;
                      roadonto:hasNodeId ?nodeId ;
                      roadonto:hasDegree ?degree .
                
                OPTIONAL {
                    ?node roadonto:hasClassification ?class .
                    ?class skos:prefLabel ?classification .
                }
                
                FILTER(?degree >= ${minDegree} && ?degree <= ${maxDegree})
            }
            ORDER BY DESC(?degree)
            LIMIT ${limit}
        `;
        
        return this.query(query);
    }

    // Get edges for network visualization
    async getEdges(limit = 1000, offset = 0, nodeIds = null) {
        let nodeFilter = '';
        if (nodeIds && nodeIds.length > 0) {
            const nodeList = nodeIds.map(id => `road:node_${id}`).join(' ');
            nodeFilter = `VALUES ?from { ${nodeList} }`;
        }

        const query = `
            PREFIX road: <http://example.org/roadnet/pa#>
            PREFIX roadonto: <http://example.org/roadnet/ontology#>
            
            SELECT ?fromId ?toId ?fromDegree ?toDegree
            WHERE {
                ${nodeFilter}
                
                ?from roadonto:connectsTo ?to ;
                      roadonto:hasNodeId ?fromId ;
                      roadonto:hasDegree ?fromDegree .
                
                ?to roadonto:hasNodeId ?toId ;
                    roadonto:hasDegree ?toDegree .
            }
            LIMIT ${limit}
            OFFSET ${offset}
        `;
        
        return this.query(query);
    }

    // Get subgraph around specific nodes
    async getSubgraph(nodeIds, depth = 1) {
        const nodeList = nodeIds.map(id => `road:node_${id}`).join(' ');
        
        const query = `
            PREFIX road: <http://example.org/roadnet/pa#>
            PREFIX roadonto: <http://example.org/roadnet/ontology#>
            
            SELECT DISTINCT ?fromId ?toId ?degree
            WHERE {
                VALUES ?centerNodes { ${nodeList} }
                
                {
                    ?from roadonto:hasNodeId ?centerNodes ;
                          roadonto:connectsTo ?to ;
                          roadonto:hasDegree ?degree .
                    
                    ?from roadonto:hasNodeId ?fromId .
                    ?to roadonto:hasNodeId ?toId .
                }
                UNION
                {
                    ?from roadonto:connectsTo ?to ;
                          roadonto:hasDegree ?degree .
                    
                    ?to roadonto:hasNodeId ?centerNodes .
                    ?from roadonto:hasNodeId ?fromId .
                    ?to roadonto:hasNodeId ?toId .
                }
            }
            LIMIT 500
        `;
        
        return this.query(query);
    }

    // Get classification statistics
    async getClassificationStats() {
        const query = `
            PREFIX road: <http://example.org/roadnet/pa#>
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
        `;
        
        return this.query(query);
    }

    // Get degree distribution
    async getDegreeDistribution() {
        const query = `
            PREFIX roadonto: <http://example.org/roadnet/ontology#>
            
            SELECT ?degree (COUNT(?node) AS ?count)
            WHERE {
                ?node a roadonto:RoadNode ;
                      roadonto:hasDegree ?degree .
            }
            GROUP BY ?degree
            ORDER BY ?degree
        `;
        
        return this.query(query);
    }

    // Get network statistics
    async getNetworkStats() {
        const query = `
            PREFIX roadonto: <http://example.org/roadnet/ontology#>
            
            SELECT 
                (COUNT(DISTINCT ?node) AS ?totalNodes)
                (AVG(?degree) AS ?avgDegree)
                (MAX(?degree) AS ?maxDegree)
                (MIN(?degree) AS ?minDegree)
            WHERE {
                ?node a roadonto:RoadNode ;
                      roadonto:hasDegree ?degree .
            }
        `;
        
        const results = await this.query(query);
        return results[0] || {};
    }

    // Get SKOS concept hierarchy
    async getConceptHierarchy() {
        const query = `
            PREFIX road: <http://example.org/roadnet/pa#>
            PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
            PREFIX roadonto: <http://example.org/roadnet/ontology#>
            
            SELECT ?concept ?label ?definition ?broader ?minDegree ?maxDegree
            WHERE {
                ?concept a skos:Concept ;
                         skos:inScheme road:ConceptScheme ;
                         skos:prefLabel ?label ;
                         skos:definition ?definition .
                
                OPTIONAL { ?concept skos:broader ?broader }
                OPTIONAL { ?concept roadonto:minDegree ?minDegree }
                OPTIONAL { ?concept roadonto:maxDegree ?maxDegree }
            }
        `;
        
        return this.query(query);
    }

    // Find dead ends
    async getDeadEnds(limit = 100) {
        const query = `
            PREFIX road: <http://example.org/roadnet/pa#>
            PREFIX roadonto: <http://example.org/roadnet/ontology#>
            
            SELECT ?nodeId
            WHERE {
                ?node a roadonto:RoadNode ;
                      roadonto:hasNodeId ?nodeId ;
                      roadonto:hasDegree 1 ;
                      roadonto:hasClassification road:DeadEnd .
            }
            LIMIT ${limit}
        `;
        
        return this.query(query);
    }

    // Find major hubs
    async getMajorHubs(limit = 100) {
        const query = `
            PREFIX road: <http://example.org/roadnet/pa#>
            PREFIX roadonto: <http://example.org/roadnet/ontology#>
            PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
            
            SELECT ?nodeId ?degree ?label
            WHERE {
                ?node a roadonto:RoadNode ;
                      roadonto:hasNodeId ?nodeId ;
                      roadonto:hasDegree ?degree ;
                      roadonto:hasClassification ?class .
                
                ?class skos:prefLabel ?label .
                FILTER(?label IN ("Major Hub", "Super Hub"))
            }
            ORDER BY DESC(?degree)
            LIMIT ${limit}
        `;
        
        return this.query(query);
    }
}

// Export a singleton instance
export default new SPARQLClient();