SELECT s.subscriberPhone, s.subscriberName
FROM Subscribers s
JOIN Subscriptions sub ON s.subscriberPhone = sub.subscriberPhone
JOIN SubscriptionKinds sk ON sub.subscriptionMode = sk.subscriptionMode 
                            AND sub.subscriptionInterval = sk.subscriptionInterval
WHERE sk.rate > 137.25 AND sub.paymentReceived = FALSE
ORDER BY s.subscriberName ASC, s.subscriberPhone DESC;