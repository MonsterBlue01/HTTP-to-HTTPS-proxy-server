SELECT P.articleAuthor AS authorName, P.articleCount2021, COUNT(A.articleNum) AS articleCount2022
FROM ProlificIn2021View P
JOIN Articles A ON P.articleAuthor = A.articleAuthor AND EXTRACT(YEAR FROM A.editionDate) = 2022
GROUP BY P.articleAuthor, P.articleCount2021
HAVING COUNT(A.articleNum) > P.articleCount2021;

DELETE FROM Articles WHERE (editionDate, articleNum) IN (('2021-06-13', 10), ('2021-06-13', 1));