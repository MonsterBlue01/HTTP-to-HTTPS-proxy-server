SELECT s.subscriberPhone, 
       sub.subscriptionStartDate, 
       (sub.subscriptionStartDate + sk.subscriptionInterval)::DATE AS subscriptionEndDate, 
       s.subscriberName, 
       sk.rate AS subscriptionRate
FROM Subscribers s
JOIN Subscriptions sub ON s.subscriberPhone = sub.subscriberPhone
JOIN SubscriptionKinds sk ON sub.subscriptionMode = sk.subscriptionMode 
                            AND sub.subscriptionInterval = sk.subscriptionInterval
JOIN Holds h ON sub.subscriberPhone = h.subscriberPhone 
              AND sub.subscriptionStartDate = h.subscriptionStartDate
WHERE sub.subscriptionStartDate <= '2022-12-17'
      AND (sub.subscriptionStartDate + sk.subscriptionInterval)::DATE >= '2023-10-03'
      AND s.subscriberAddress IS NOT NULL
      AND sk.stillOffered = TRUE
GROUP BY s.subscriberPhone, sub.subscriptionStartDate, s.subscriberName, sk.rate;
