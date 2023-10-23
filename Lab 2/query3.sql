SELECT DISTINCT a.articleNum, a.articleAuthor, a.articlePage
FROM Articles a
WHERE NOT EXISTS (
    SELECT 1
    FROM ReadArticles ra
    JOIN Subscribers s ON ra.subscriberPhone = s.subscriberPhone
    WHERE a.editionDate = ra.editionDate AND a.articleNum = ra.articleNum
        AND s.subscriberName LIKE '%er%' AND ra.readInterval > interval '20 minutes'
);