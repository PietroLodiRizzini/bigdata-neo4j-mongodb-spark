# Big data project
This project aims at comparing different NoSQL large scale technological solutions for efficient data management. This is achieved by implementing a bibliographic dataset with Neo4j, MongoDB and Apache Spark.

The full report can be found [here](project_report.pdf)

## Data preprocessing
The very first step consisted in a pre-processing of the [DBLP XML data dump](https://dblp.org/xml/).
A conversion to multiple csv files was performed by exploiting an existing [python script](https://github.com/ThomHurks/dblp-to-csv). The csv files can bo found in the [neo4j directory](/neo4j)
The number of records han also been reduced in order to deploy the databases on regular PCs.
Additional details about this phase can be found in the report.

## Part 1: Neo4J
The first part consists in a graph database implementation with Neo4j. After some additional processing of the data, the graph DB has been created and some queries were executed. The import commands and queries can be found in the [neo4j directory](/neo4j).

## Part 2: MongoDB
In this part we replicated the same use case scenario leveraging a documental database, MongoDB.
In this case the data ahs been generated with a tool available at [mockaroo.com](https://www.mockaroo.com/901f0eb0).
The import commands and queries performed can be found in the [mongodb directory](/mongodb)

## Part 3: Apache Spark
Lastly we performed the same task with the Apache Spark framework.

## Authors

- BRUNETTI Enrico
- LODI RIZZINI Pietro
- PAESANO Emanuele
- PIZZUTI Gianluca
- SIMONIN Mélissande
