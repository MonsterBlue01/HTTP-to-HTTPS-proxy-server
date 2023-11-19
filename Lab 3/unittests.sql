INSERT INTO Subscriptions (subscriberPhone, subscriptionStartDate, subscriptionMode, subscriptionInterval, paymentReceived)
VALUES (9999999, '2023-01-01', 'D', '1 year', TRUE);

INSERT INTO Subscriptions (subscriberPhone, subscriptionStartDate, subscriptionMode, subscriptionInterval, paymentReceived)
VALUES (8315512, '2023-01-01', 'Z', '1 year', TRUE);

INSERT INTO Holds (subscriberPhone, subscriptionStartDate, holdStartDate, holdEndDate)
VALUES (8315512, '2025-01-01', '2025-01-01', '2025-01-10');

UPDATE SubscriptionKinds SET rate = 1.00 WHERE subscriptionMode = 'D' AND subscriptionInterval = '1 year';

UPDATE SubscriptionKinds SET rate = -1.00 WHERE subscriptionMode = 'D' AND subscriptionInterval = '1 year';

UPDATE Holds SET holdEndDate = '2023-01-20' WHERE subscriberPhone = 8315512 AND subscriptionStartDate = '2023-01-01';

UPDATE Holds SET holdStartDate = '2023-02-01' WHERE subscriberPhone = 8315512 AND subscriptionStartDate = '2023-01-01';

UPDATE Subscribers SET subscriberName = 'Tony Stark', subscriberAddress = NULL WHERE subscriberPhone = 9255556;

UPDATE Subscribers SET subscriberName = NULL WHERE subscriberPhone = 9255556;
