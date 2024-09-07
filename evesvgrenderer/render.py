import sys
import sqlite3
import evesvgrenderer.queries as q
import graphviz

def dict_factory(cursor, row):
    fields = [column[0] for column in cursor.description]
    return {key: value for key, value in zip(fields, row)}

def getDataForRegion(cursor: sqlite3.Cursor, region_name: str):
    systems = cursor.execute(q.regionCoordinatesAndStatusesStandard, [region_name])
    nodes = systems.fetchall()
    connections = cursor.execute(q.regionConnectionsStandard, [region_name])
    edges = connections.fetchall()
    return nodes, edges

def init(database_path: str) -> sqlite3.Cursor:
    conn = sqlite3.connect(database_path)
    conn.row_factory = dict_factory
    cursor = conn.cursor()
    return cursor

def main(argv):
    database_path = argv[1]
    print(f"Using database {database_path}")
    cursor = init(database_path)
    regions = cursor.execute(q.allRegionNames).fetchall()
    count = len(regions)
    i = 1

    for region in regions:
        region_name = region["regionName"]
        region_id = region["regionID"]
        print(f"{i}/{count}: Rendering {region_name} {region_id}")
        nodes, edges = getDataForRegion(cursor, region_name)

        G = graphviz.Graph(region_name, strict=True, format="svg", engine="sfdp", filename=region_name)
        # Always desirable parameters
        G.graph_attr.update(splines="true")
        G.graph_attr.update(overlap="false")
        G.graph_attr.update(normalize="true")
        # Layout engine specific parameters
        G.graph_attr.update(K="0.1")
        G.graph_attr.update(repulsiveforce="1.25")
        G.graph_attr.update(beautify="true")
        G.graph_attr.update(overlap_scaling="5")



        current_constellation_name = None
        constellation_graph = None

        for node in nodes:
            node_region_id = node["regionID"]
            node_constellation_name = node["constellationName"]

            if(node_constellation_name != current_constellation_name):

                current_constellation_name = node_constellation_name
                constellation_graph = graphviz.Graph(f"{node_constellation_name}")
                constellation_graph.attr(label=node_constellation_name)


            node_name = node["solarSystemName"]
            node_region = node["regionName"]
            node_label = None
            node_shape = None

            # Meaning: it's a system belonging to another region
            if node_region_id != region_id:
                node_shape = "ellipse" 
                node_label = f"<{node_name}<br align=\"center\"/><font point-size=\"10\"><u>{node['regionName']}</u></font><br align=\"center\"/>>"
            else:
                node_label = node_name
                node_shape = "Mrecord" 

            constellation_graph.node(node_name, label=node_label, shape=node_shape, group=node_constellation_name, width="1.5")
            if(constellation_graph is not None):
                G.subgraph(constellation_graph)

        for edge in edges:
            G.edge(edge["fromSystemName"], edge["toSystemName"])

        G.render(directory="output/", cleanup=True)
        i+= 1

    return 0

def start():
    return main(sys.argv)

if __name__ == "__main__":
    start()