## NYPL Labs Map Polygon fixer

Authors: [Mauricio Giraldo Arteaga] / NYPL Labs

- [Data ingest](#ingest)
- [API querying](#api)

### <a name="ingest"></a>Data ingest

This project works with GeoJSON files generated by the [NYPL Map Vectorizer]. The specific files for the NYPL use case are found in the [/public/files](public/files/) folder.

#### First ingest

After downloading, and running the proper `rake db:migrate` you need to do a base ingest of data using the included rake task.

####All sheet data ingest

`rake data_import:ingest_bulk id=LAYERID force=true`

This assumes the presence of `public/files/config-ingest-LAYERID.json` with a list of IDs and bounding boxes to import for the layer `LAYERID`. This **erases all sheet/polygon/flag data** for those IDs in the config file.

####About centroids

Polygon centroids are used in some tasks to determine where to put markers in case the flag value is none/blank/etc. There is an included Python script -- `ingestor_config_builder.py` -- to easily calculate centroids for the sheets to be used in the inspector. It assumes a folder full of GeoTIFF files.

Usage:

`python ingestor_config_builder.py /path/to/folder/with/geotiffs`

It creates a config file in the application root folder with the name `config-ingest-FOLDERNAME` where `FOLDERNAME` is the name of the folder where the GeoTIFFs were found.

####Add bulk centroids

The original GeoJSON files do not have centroids (they were added and processed later). To create the centroids of the polygons in the database you need to run:

`rake data_import:ingest_centroid_bulk id=LAYERID force=true`

####Single sheet data ingest

`rake data_import:ingest_geojson id=SOMEID layer_id=SOMELAYERID bbox=SOMEBOUNDINGBOX force=true`

This imports polygons from a file `public/files/SOMEID-traced.json` into the database **replacing** any polygons (and its corresponding flags) that are associated to ID `SOMEID`.

**NOTE:** So far only layers 859 and 860 are provided. Layer 859 has separate GeoJSON for centroids and polygons. Layer 860 sheets have a single file with both fields. Ingesting 859 requires a separate `data_import:ingest_centroid_bulk` process for centroids.

####Single sheet centroid updating

`rake data_import:ingest_centroids_for_sheet id=SOMEID force=true`

This updates the polygon centroids for a given `sheet_id` from a file `public/files/SOMEID-traced.json` **replacing** any existing polygon centroids (not the polygons themselves).

### <a name="api"></a>API querying

The following API endpoints have been added to export the inspection consensus process (paginated by groups of 500). Consensus is defined by **agreement of 75% or more of three or more votes**:

#### Polygon export → /api/polygons/…

Active endpoints:
````
/api/polygons/:task/page/:page
/api/polygons/:task/:consensus/page/:page
````

Accept tasks:
`geometry`, `color`, `polygonfix`, `address` with numeric paging (500 records per page).

`consensus` values depend on the task and perhaps only useful in the `geometry` and `color` tasks.

- `/api/polygons/geometry/page/PAGENUMBER` returns all polygons in `PAGENUMBER` regardless of their consensus value.
- `/api/polygons/geometry/yes/page/PAGENUMBER` returns all polygons in `PAGENUMBER` that have been marked as *correct*.
- `/api/polygons/geometry/no/page/PAGENUMBER` returns all polygons in `PAGENUMBER` that have been marked as *not buildings*.
- `/api/polygons/geometry/fix/page/PAGENUMBER` returns all polygons in `PAGENUMBER` that need to be *fixed*.

### Version notes

- 2.0 Second release with `address`, `polygonfix` and `color` tasks. Refactored and improved code. New API endpoints.
- 1.1 Added API endpoints
- 1.0 First release with single `geometry` task

### Copyright 2013-2014 The New York Public Library

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


[Mauricio Giraldo Arteaga]: https://twitter.com/mgiraldo
[NYPL Map Vectorizer]: https://github.com/NYPL/map-vectorizer
