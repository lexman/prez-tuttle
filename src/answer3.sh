#!/usr/bin/env sh
set -e
if [ ! -e depts2015.txt ]; then
    curl -O "http://www.insee.fr/fr/methodes/nomenclatures/cog/telechargement/2015/txt/depts2015.txt"
fi
if [ ! -f comsimp2015.zip ]; then
    curl -O "http://www.insee.fr/fr/methodes/nomenclatures/cog/telechargement/2015/txt/comsimp2015.zip"
fi

if ! echo "SELECT * FROM city LIMIT 0;" | sqlite3 cities.sqlite
then 
    sqlite3 cities.sqlite <<$script$
.mode tabs
.import comsimp2015.txt city
CREATE INDEX idx_city on city (DEP, COM);
$script$
fi

if ! echo "SELECT * FROM departement LIMIT 0;" | sqlite3 cities.sqlite; then 
    sqlite3 cities.sqlite <<$script$
.mode tabs
.import depts2015.txt departement
CREATE INDEX idx_dept on departement (DEP);
$script$
fi

if [ ! -f result.csv ]; then
    sqlite3 cities.sqlite <<$script$
.mode csv
.output result.csv
SELECT departement.DEP, departement.NCCENR, COUNT(*) 
    FROM departement
    JOIN city ON city.DEP = departement.DEP
    GROUP BY departement.DEP, departement.NCCENR;
$script$
fi
