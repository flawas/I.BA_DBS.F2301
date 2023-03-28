-- Lokaler Dateiupload erlauben
SET GLOBAL local_infile = true;

-- Movies Daten laden
LOAD DATA LOCAL INFILE '/path/to/movies.csv'
INTO TABLE Movies
FIELDS ENCLOSED BY '"' ESCAPED BY '\\'
IGNORE 1 LINES;

-- In der Tabelle Rating der FK zu MovieID und Rrimary Key löschen
ALTER TABLE Ratings DROP CONSTRAINT MovieID_FK;
ALTER TABLE Ratings DROP PRIMARY KEY;

-- Rating Daten laden
LOAD DATA LOCAL INFILE '/path/to/ratings.csv'
INTO TABLE Ratings
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 LINES
(UserID, MovieID, Rating, @Timestamp)
SET Timestamp = FROM_UNIXTIME(@Timestamp);

-- Primary Keys wieder hinzufügen
ALTER TABLE Ratings ADD CONSTRAINT
PRIMARY KEY (MovieID, UserID);

-- Unnötige Bewertungen löschen, welche nicht vorhanden sind
DELETE FROM Ratings WHERE MovieID NOT IN
(SELECT MovieID from Movies);

-- FK zwischen Ratings und Movies Tabelle neu erstellen
ALTER TABLE Ratings ADD CONSTRAINT MovieID_FK
FOREIGN KEY (MovieID)
REFERENCES Movies(MovieID);

-- Genres aus der Movie Tabelle exportieren und in Genres einfügen
INSERT INTO Genres
SELECT DISTINCT
JSON_EXTRACT(Genres, "$[0].id"),
JSON_UNQUOTE(JSON_EXTRACT(Genres, "$[0].name"))
FROM Movies
WHERE JSON_EXTRACT(Genres, "$[0].id") IS NOT NULL;