CREATE VIEW ProlificIn2021View AS
SELECT articleAuthor, COUNT(*) AS articleCount2021, COUNT(DISTINCT editionDate) AS differentEditionCount2021
FROM Articles
WHERE EXTRACT(YEAR FROM editionDate) = 2021
GROUP BY articleAuthor
HAVING COUNT(*) >= 3 AND COUNT(DISTINCT editionDate) >= 2;