BEGIN;

INSERT INTO ReadArticles (subscriberPhone, editionDate, articleNum, readInterval)
SELECT subscriberPhone, editionDate, articleNum, readInterval
FROM NewReadArticles
WHERE NOT EXISTS (
    SELECT 1
    FROM ReadArticles
    WHERE ReadArticles.subscriberPhone = NewReadArticles.subscriberPhone
        AND ReadArticles.editionDate = NewReadArticles.editionDate
        AND ReadArticles.articleNum = NewReadArticles.articleNum
);

UPDATE ReadArticles
SET readInterval = ReadArticles.readInterval + NewReadArticles.readInterval
FROM NewReadArticles
WHERE ReadArticles.subscriberPhone = NewReadArticles.subscriberPhone
    AND ReadArticles.editionDate = NewReadArticles.editionDate
    AND ReadArticles.articleNum = NewReadArticles.articleNum
    AND EXISTS (
        SELECT 1
        FROM ReadArticles
        WHERE ReadArticles.subscriberPhone = NewReadArticles.subscriberPhone
            AND ReadArticles.editionDate = NewReadArticles.editionDate
            AND ReadArticles.articleNum = NewReadArticles.articleNum
    );

COMMIT;