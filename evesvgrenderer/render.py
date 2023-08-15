import sys
import sqlite3
import evesvgrenderer.queries as q
import pygraphviz as pgv

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

        G = pgv.AGraph(strict=False, directed=False, overlap=False, splines=True)
        G.graph_attr.update(normalize=True)
        G.graph_attr.update(mode="ipsep")
        G.graph_attr.update(center="true")

        for node in nodes:
            node_region = node["regionID"]
            node_name = node["solarSystemName"] if not node["solarSystemName"][0].isdigit() else "_" + node["solarSystemName"]
            node_data = {"id": node_name}
            if node_region != region_id:
                node_data = node_data | {"shape": "box"}
            else:
                node_data = node_data | {"shape": "ellipse"}

            G.add_node(node["solarSystemName"], **node_data)

        for edge in edges:
            G.add_edge(edge["fromSystemName"], edge["toSystemName"])

        G.layout(prog='neato')
        G.draw(f"output/{region_name}.svg")
        i+= 1

    return 0

def start():
    return main(sys.argv)

if __name__ == "__main__":
    start()