//author creation
MATCH (n) WHERE n.author IS NOT NULL
UNWIND n.author as authorname
MERGE (author:person:author{name:authorname})
CREATE (author)-[r:WROTE]->(n)
SET r.year = n.year

//IS_EDITOR creation
MATCH (n:proceedings) WHERE n.editor IS NOT NULL
UNWIND n.editor as editorname
MERGE (editor:person{name:editorname})
SET editor:editor
CREATE (editor)-[:IS_EDITOR]->(n)

//BELONGS_TO_BOOK creation
MATCH (n:incollection) where n.crossref is not null
WITH n.crossref AS book,n.pages as pages n as n
MATCH (b:book {key:book})
CREATE (n)-[:BELONGS_TO_BOOK{pages:pages}]->(b)

//journal nodes and PUBLISHED_IN_JOURNAL creation
MATCH(n:article) WHERE n.journal IS NOT NULL
WITH n.journal as jourName, n.volume AS volume,
n.number AS number, n.pages as pages, n AS n
MERGE (j:journal{name:jourName})
CREATE (n)-[r:PUBLISHED_IN_JOURNAL{volume:volume,number:number,pages:pages}]->(j)

// school nodes creation
MATCH (n)
WHERE n.school IS NOT NULL
MERGE (:school{name:n.school})

// CITES relation
MATCH (citing) WHERE citing.cite IS NOT NULL
UNWIND citing.cite as cited_key
MATCH (cited {key:cited_key})
CREATE (citing)-[:CITES]->(cited)

// *******************
// QUERIES
// *******************

// list of publications that cite one of your coauthors
MATCH (n:author{name:"David Maier 0001"})-[:WROTE]->(p),
(p)<-[:WROTE]-(coauthor:author)
MATCH (coauthor)-[:WROTE]->(byCo)
WHERE NOT "David Maier 0001" IN byCo.author
MATCH (citesCo)-[:CITES]->(byCo)
RETURN citesCo, byCo, coauthor

// Find persons who wrote together at least one article and were editors together for at least one proceedings.
MATCH (p1:person)-[:IS_EDITOR]->(pro:proceedings),
(p2:person)-[:IS_EDITOR]->(pro),
(p1)-[:WROTE]->(a:article),
(p2)-[:WROTE]->(a)
RETURN a AS article, pro AS proceeding, collect(DISTINCT p1)

// Find the author with the greatest number of cocoauthors
MATCH (f:person)-[:WROTE]->(a:article)<-[:WROTE]-(coauthor:person),
(coauthor)-[:WROTE]->(a2:article)<-[:WROTE]-(cocoauthor:person)
WHERE (NOT (f)-[:WROTE]->(:article)<-[:WROTE]-(cocoauthor))
RETURN f AS author, count(*) AS cocoCount
ORDER BY cocoCount DESC
LIMIT 1

// Find persons that wrote an article citing one master Thesis and one Phd Thesis written in the same school
MATCH (p:person)-[:WROTE]->(a:article),
(a)-[:CITES]->(mt:mastersthesis),
(a)-[:CITES]->(phdt:phdthesis),
(mt)-[:WRITTEN_IN]->(:school)<-[:WRITTEN_IN]-(phdt)
RETURN DISTINCT p AS Author

// A query that returns the name, the webpage and the phd thesis publication year of the most recent author who made both master thesis and phd thesis in the same school
MATCH (phd:phdthesis)-[wphd:WRITTEN_IN_SCHOOL]->(s1:school),
    (master:mastersthesis)-[wmas:WRITTEN_IN_SCHOOL]->(s2:school),
    (a: author)-[hw:HAS_WEBPAGE]->(w:www),
WHERE phd.author = master.author
AND s1.name = s2.name
AND a.name = phd.author
WITH phd, s1, master, s2, a, w
ORDER BY phd.year DESC
LIMIT 1
RETURN phd.author AS authorName,
    w.key AS webpage,
    s1.name AS schoolName,
    master.year AS masterYear,
    phd.year AS phdYear

// Filtering cited articles on the same inproceeding by last modification date
MATCH (citing:inproceedings)-[r:CITES]->(cited: article),
(inPro:inproceedings)-[:BELONGS_TO_PROCEEDING]->(pro:proceedings)
WHERE cited.mdate < "2022" and cited.mdate > "2017"
AND citing.title = inPro.title
WITH citing, cited, inPro, pro
ORDER BY cited.mdate DESC
RETURN cited.author AS ArticleAuthor,
citing.title AS InproceedingTitle,
cited.mdate AS ArticleLastModification,
pro.title AS Proceeding

// Find the number of articles written and proceedings edited by persons that have done both activities in 2022 (=both numbers must be at least 1)
MATCH (p:person)-[:WROTE]->(a:article),
(p)-[:IS_EDITOR]->(pro:proceedings)
WHERE a.year = 2022 and p.year = 2022
RETURN p.name, count(DISTINCT a), count(DISTINCT pro)

// Returns all editors that a determined author has worked with and the percentage of working with each one of them with respect to the number of inproceedings of that author
MATCH (a:author)-[r:WROTE]->(i:inproceedings)
-[b:BELONGS_TO_PROCEEDING]->(p:proceedings)
<-[o:IS_EDITOR]-(e:editor)
WHERE a.name = "Cristiano Tolomei"
WITH collect(distinct e) AS ed, count(e) AS numEdit
UNWIND ed AS edit
RETURN distinct(edit.name) AS EditorName,
count(edit.name) AS NumOfInproceeding,
toString(round((1.0 * (count(edit.name)) / numEdit) * 100, 1))
+ "%" AS Percentage
ORDER BY Percentage DESC

// Returns all phdthesis that have been modified in the same school in the
same year
MATCH (t:phdthesis)-[r:WRITTEN_IN_SCHOOL]->(s)
WITH [item IN split(t.mdate, "/") | toInteger(item)] AS parts,
t AS thesis,
s AS school
WHERE "University of Siegen" IN school.name
AND toString(date({day: parts[0], month: parts[1],year: parts[2]}).year)
= "2021"
RETURN thesis.title AS Title, thesis.mdate AS ModDate

// Find shortest path between two persons
match (p1:person {name: "Hideo Saito"}),
(p2:person {name: "Yuguang Fang"}),
p = shortestPath((p1)-[*]-(p2))
return p