ALTER TABLE Subscriptions
ADD CONSTRAINT fk_subscriptions_subscribers
FOREIGN KEY (subscriberPhone)
REFERENCES Subscribers (subscriberPhone)
ON DELETE NO ACTION
ON UPDATE CASCADE;

ALTER TABLE Subscriptions
ADD CONSTRAINT fk_subscriptions_subscriptionkinds
FOREIGN KEY (subscriptionMode, subscriptionInterval)
REFERENCES SubscriptionKinds (subscriptionMode, subscriptionInterval)
ON DELETE SET NULL
ON UPDATE CASCADE;

ALTER TABLE Holds
ADD CONSTRAINT fk_holds_subscriptions
FOREIGN KEY (subscriberPhone, subscriptionStartDate)
REFERENCES Subscriptions (subscriberPhone, subscriptionStartDate)
ON DELETE NO ACTION
ON UPDATE NO ACTION;