SELECT DISTINCT e.editionDate AS theEditionDate
FROM Edition e
JOIN Articles a ON e.editionDate = a.editionDate
WHERE a.articleNum > e.numArticles AND a.articlePage > e.numPages;