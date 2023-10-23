SELECT s.subscriberName AS theSubscriberName, 
       s.subscriberAddress AS theSubscriberAddress, 
       a.editionDate AS theEditionDate
FROM Subscribers s
JOIN Articles a ON s.subscriberName = a.articleAuthor
GROUP BY s.subscriberName, s.subscriberAddress, a.editionDate
HAVING COUNT(*) > 1;
