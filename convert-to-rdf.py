#!/usr/bin/env python3
"""
Convert Pennsylvania road network dataset to RDF/OWL format with SKOS concepts
"""

from rdflib import Graph, Namespace, Literal, URIRef
from rdflib.namespace import RDF, RDFS, OWL, SKOS, XSD
import networkx as nx
from collections import Counter
import sys

# Define namespaces
ROAD = Namespace("http://example.org/roadnet/pa#")
ROAD_ONTO = Namespace("http://example.org/roadnet/ontology#")

class RoadNetworkConverter:
    def __init__(self):
        self.graph = Graph()
        self.network = nx.DiGraph()
        
        # Bind namespaces
        self.graph.bind("road", ROAD)
        self.graph.bind("roadonto", ROAD_ONTO)
        self.graph.bind("skos", SKOS)
        self.graph.bind("owl", OWL)
        
    def create_ontology(self):
        """Create the OWL ontology structure"""
        print("Creating ontology...")
        
        # Define ontology
        ontology = ROAD_ONTO[""]
        self.graph.add((ontology, RDF.type, OWL.Ontology))
        self.graph.add((ontology, RDFS.label, Literal("Pennsylvania Road Network Ontology")))
        
        # Define classes
        node_class = ROAD_ONTO.RoadNode
        self.graph.add((node_class, RDF.type, OWL.Class))
        self.graph.add((node_class, RDFS.label, Literal("Road Network Node")))
        self.graph.add((node_class, RDFS.comment, Literal("Represents an intersection or endpoint in the road network")))
        
        edge_class = ROAD_ONTO.RoadEdge
        self.graph.add((edge_class, RDF.type, OWL.Class))
        self.graph.add((edge_class, RDFS.label, Literal("Road Connection")))
        
        # Define object properties
        connects_to = ROAD_ONTO.connectsTo
        self.graph.add((connects_to, RDF.type, OWL.ObjectProperty))
        self.graph.add((connects_to, RDFS.domain, node_class))
        self.graph.add((connects_to, RDFS.range, node_class))
        self.graph.add((connects_to, RDFS.label, Literal("connects to")))
        
        # Define datatype properties
        has_id = ROAD_ONTO.hasNodeId
        self.graph.add((has_id, RDF.type, OWL.DatatypeProperty))
        self.graph.add((has_id, RDFS.domain, node_class))
        self.graph.add((has_id, RDFS.range, XSD.integer))
        
        has_degree = ROAD_ONTO.hasDegree
        self.graph.add((has_degree, RDF.type, OWL.DatatypeProperty))
        self.graph.add((has_degree, RDFS.domain, node_class))
        self.graph.add((has_degree, RDFS.range, XSD.integer))
        self.graph.add((has_degree, RDFS.label, Literal("connectivity degree")))
        
        has_in_degree = ROAD_ONTO.hasInDegree
        self.graph.add((has_in_degree, RDF.type, OWL.DatatypeProperty))
        self.graph.add((has_in_degree, RDFS.domain, node_class))
        self.graph.add((has_in_degree, RDFS.range, XSD.integer))
        
        has_out_degree = ROAD_ONTO.hasOutDegree
        self.graph.add((has_out_degree, RDF.type, OWL.DatatypeProperty))
        self.graph.add((has_out_degree, RDFS.domain, node_class))
        self.graph.add((has_out_degree, RDFS.range, XSD.integer))
        
    def create_skos_concepts(self):
        """Create SKOS concept scheme for road network classification"""
        print("Creating SKOS concepts...")
        
        # Create concept scheme
        scheme = ROAD.ConceptScheme
        self.graph.add((scheme, RDF.type, SKOS.ConceptScheme))
        self.graph.add((scheme, SKOS.prefLabel, Literal("Road Network Node Classification", lang="en")))
        
        # Define concepts based on connectivity
        concepts = {
            "DeadEnd": ("Dead End", "Node with only one connection", 1, 1),
            "SimpleJunction": ("Simple Junction", "Node with 2-3 connections", 2, 3),
            "Intersection": ("Intersection", "Node with 4-5 connections", 4, 5),
            "MajorHub": ("Major Hub", "Node with 6-10 connections", 6, 10),
            "SuperHub": ("Super Hub", "Node with more than 10 connections", 11, float('inf'))
        }
        
        for concept_id, (label, definition, min_deg, max_deg) in concepts.items():
            concept = ROAD[concept_id]
            self.graph.add((concept, RDF.type, SKOS.Concept))
            self.graph.add((concept, SKOS.inScheme, scheme))
            self.graph.add((concept, SKOS.prefLabel, Literal(label, lang="en")))
            self.graph.add((concept, SKOS.definition, Literal(definition, lang="en")))
            self.graph.add((concept, ROAD_ONTO.minDegree, Literal(min_deg, datatype=XSD.integer)))
            if max_deg != float('inf'):
                self.graph.add((concept, ROAD_ONTO.maxDegree, Literal(max_deg, datatype=XSD.integer)))
        
        # Create hierarchical relationships
        self.graph.add((ROAD.SimpleJunction, SKOS.broader, ROAD.DeadEnd))
        self.graph.add((ROAD.Intersection, SKOS.broader, ROAD.SimpleJunction))
        self.graph.add((ROAD.MajorHub, SKOS.broader, ROAD.Intersection))
        self.graph.add((ROAD.SuperHub, SKOS.broader, ROAD.MajorHub))
        
    def load_dataset(self, filepath, max_edges=None, sample_rate=1.0):
        """Load the road network dataset"""
        print(f"Loading dataset from {filepath}...")
        
        edges_count = 0
        with open(filepath, 'r') as f:
            for line in f:
                # Skip comments
                if line.startswith('#'):
                    continue
                    
                parts = line.strip().split()
                if len(parts) != 2:
                    continue
                
                # Optional sampling for testing
                if sample_rate < 1.0:
                    import random
                    if random.random() > sample_rate:
                        continue
                
                try:
                    from_node = int(parts[0])
                    to_node = int(parts[1])
                    
                    self.network.add_edge(from_node, to_node)
                    edges_count += 1
                    
                    if max_edges and edges_count >= max_edges:
                        break
                        
                    if edges_count % 100000 == 0:
                        print(f"  Loaded {edges_count} edges...")
                        
                except ValueError:
                    continue
        
        print(f"Loaded {edges_count} edges, {self.network.number_of_nodes()} nodes")
        
    def convert_network_to_rdf(self, batch_size=10000):
        """Convert NetworkX graph to RDF triples"""
        print("Converting network to RDF...")
        
        # Calculate node statistics
        in_degrees = dict(self.network.in_degree())
        out_degrees = dict(self.network.out_degree())
        
        node_count = 0
        for node in self.network.nodes():
            node_uri = ROAD[f"node_{node}"]
            
            # Add node instance
            self.graph.add((node_uri, RDF.type, ROAD_ONTO.RoadNode))
            self.graph.add((node_uri, ROAD_ONTO.hasNodeId, Literal(node, datatype=XSD.integer)))
            
            # Add degree information
            in_deg = in_degrees.get(node, 0)
            out_deg = out_degrees.get(node, 0)
            total_deg = in_deg + out_deg
            
            self.graph.add((node_uri, ROAD_ONTO.hasInDegree, Literal(in_deg, datatype=XSD.integer)))
            self.graph.add((node_uri, ROAD_ONTO.hasOutDegree, Literal(out_deg, datatype=XSD.integer)))
            self.graph.add((node_uri, ROAD_ONTO.hasDegree, Literal(total_deg, datatype=XSD.integer)))
            
            # Classify node using SKOS concepts
            concept = self._classify_node(total_deg)
            if concept:
                self.graph.add((node_uri, ROAD_ONTO.hasClassification, concept))
            
            node_count += 1
            if node_count % batch_size == 0:
                print(f"  Processed {node_count} nodes...")
        
        # Add edges
        edge_count = 0
        for from_node, to_node in self.network.edges():
            from_uri = ROAD[f"node_{from_node}"]
            to_uri = ROAD[f"node_{to_node}"]
            
            self.graph.add((from_uri, ROAD_ONTO.connectsTo, to_uri))
            
            edge_count += 1
            if edge_count % batch_size == 0:
                print(f"  Processed {edge_count} edges...")
        
        print(f"Converted {node_count} nodes and {edge_count} edges to RDF")
        
    def _classify_node(self, degree):
        """Classify node based on degree"""
        if degree == 1:
            return ROAD.DeadEnd
        elif 2 <= degree <= 3:
            return ROAD.SimpleJunction
        elif 4 <= degree <= 5:
            return ROAD.Intersection
        elif 6 <= degree <= 10:
            return ROAD.MajorHub
        elif degree > 10:
            return ROAD.SuperHub
        return None
    
    def generate_statistics(self):
        """Generate statistical summary"""
        print("\n=== Network Statistics ===")
        print(f"Nodes: {self.network.number_of_nodes()}")
        print(f"Edges: {self.network.number_of_edges()}")
        
        degrees = [d for n, d in self.network.degree()]
        print(f"Average degree: {sum(degrees)/len(degrees):.2f}")
        print(f"Max degree: {max(degrees)}")
        
        degree_dist = Counter(degrees)
        print("\nDegree Distribution:")
        for deg in sorted(degree_dist.keys())[:10]:
            print(f"  Degree {deg}: {degree_dist[deg]} nodes")
        
    def save(self, output_dir="output"):
        """Save RDF graphs to files"""
        import os
        os.makedirs(output_dir, exist_ok=True)
        
        print(f"\nSaving RDF data to {output_dir}/...")
        
        # Save complete graph
        output_file = os.path.join(output_dir, "roadnet_complete.ttl")
        self.graph.serialize(destination=output_file, format='turtle')
        print(f"  Saved complete graph to {output_file}")
        print(f"  Total triples: {len(self.graph)}")
        
        # Also save as N-Triples for easier loading
        nt_file = os.path.join(output_dir, "roadnet_complete.nt")
        self.graph.serialize(destination=nt_file, format='nt')
        print(f"  Saved N-Triples to {nt_file}")

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Convert road network to RDF/OWL')
    parser.add_argument('input_file', help='Input road network file')
    parser.add_argument('--output-dir', default='output', help='Output directory')
    parser.add_argument('--max-edges', type=int, help='Maximum edges to process (for testing)')
    parser.add_argument('--sample-rate', type=float, default=1.0, help='Sampling rate (0-1)')
    
    args = parser.parse_args()
    
    converter = RoadNetworkConverter()
    
    # Create ontology and concepts
    converter.create_ontology()
    converter.create_skos_concepts()
    
    # Load and convert data
    converter.load_dataset(args.input_file, args.max_edges, args.sample_rate)
    converter.convert_network_to_rdf()
    
    # Generate statistics
    converter.generate_statistics()
    
    # Save output
    converter.save(args.output_dir)
    
    print("\n✓ Conversion complete!")
    print(f"\nNext steps:")
    print(f"1. Load {args.output_dir}/roadnet_complete.ttl into Apache Jena Fuseki")
    print(f"2. Test SPARQL queries against the endpoint")
    print(f"3. Build the web application to visualize the data")

if __name__ == "__main__":
    main()