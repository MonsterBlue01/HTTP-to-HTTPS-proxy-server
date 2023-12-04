CREATE OR REPLACE FUNCTION increaseSomeRatesFunction(maxTotalRateIncrease int)
RETURNS int AS $$
DECLARE
    totalIncrease int := 0;
    rateIncrease int;
    row record;
BEGIN
    IF maxTotalRateIncrease <= 0 THEN
        RETURN -1;
    END IF;

    FOR row IN SELECT subscriptionKindId, COUNT(*) as popularity
               FROM Subscriptions
               GROUP BY subscriptionKindId
               ORDER BY popularity DESC
    LOOP
        rateIncrease := CASE
            WHEN row.popularity >= 5 THEN 10
            WHEN row.popularity BETWEEN 3 AND 4 THEN 5
            WHEN row.popularity = 2 THEN 3
            ELSE 0
        END;

        IF totalIncrease + rateIncrease <= maxTotalRateIncrease THEN
            totalIncrease := totalIncrease + rateIncrease;
            -- 更新 SubscriptionKinds 表中的费率
            UPDATE SubscriptionKinds SET rate = rate + rateIncrease
            WHERE subscriptionKindId = row.subscriptionKindId;
        ELSE
            EXIT;
        END IF;
    END LOOP;

    RETURN totalIncrease;
END;
$$ LANGUAGE plpgsql;
