# Index
1. [Introduction](#introduction)
1. [TL;DR](#tldr)
1. [Long Version](#long-version)
    1. [Brief description](#brief-description)

## Introduction
This app takes the geometry data from a SQLite database containing EvE Online's data dump and produces an SVG of the game's regions.

## TL;DR
Build and run with:
```
docker-compose run renderer
```

Output will be placed in `output_docker/`

## Long Version
A full description of what's required to create the SVG ouptut can be inferred by inspecting the multiple stages in the [dockerfile](./dockerfile).

### Brief description
The first stage sets up the common environment for all subsequent stages.

The second stage downloads a universe dump in SQLite format from [Fuzzwork](https://www.fuzzwork.co.uk/), extracts only the relevant topography and deletes the rest.

The final stage extracts the topography data from the database from the second stage, organized by region. Note the particulars as specified in [the queries](./evesvgrenderer/queries/__init__.py) - systems with a connection to the region being rendered are included.

Details on the rendering can be seen [here](./evesvgrenderer/render.py).