CREATE TABLE SubscriptionKinds (
    subscriptionMode CHAR(1) CHECK (subscriptionMode IN ('D', 'P', 'B')),
    subscriptionInterval INTERVAL,
    rate NUMERIC(6,2),
    stillOffered BOOLEAN,
    PRIMARY KEY (subscriptionMode, subscriptionInterval)
);

CREATE TABLE Editions (
    editionDate DATE,
    numArticles INTEGER,
    numPages INTEGER,
    PRIMARY KEY (editionDate)
);

CREATE TABLE Subscribers (
    subscriberPhone INTEGER,
    subscriberName VARCHAR(30),
    subscriberAddress VARCHAR(60),
    PRIMARY KEY (subscriberPhone)
);

CREATE TABLE Subscriptions (
    subscriberPhone INTEGER,
    subscriptionStartDate DATE,
    subscriptionMode CHAR(1),
    subscriptionInterval INTERVAL,
    paymentReceived BOOLEAN,
    PRIMARY KEY (subscriberPhone, subscriptionStartDate),
    FOREIGN KEY (subscriberPhone) REFERENCES Subscribers(subscriberPhone),
    FOREIGN KEY (subscriptionMode, subscriptionInterval) REFERENCES SubscriptionKinds(subscriptionMode, subscriptionInterval)
);


CREATE TABLE Holds (
    subscriberPhone INTEGER,
    subscriptionStartDate DATE,
    holdStartDate DATE,
    holdEndDate DATE,
    PRIMARY KEY (subscriberPhone, subscriptionStartDate, holdStartDate),
    FOREIGN KEY (subscriberPhone, subscriptionStartDate) REFERENCES Subscriptions(subscriberPhone, subscriptionStartDate)
);


CREATE TABLE Articles (
    editionDate DATE,
    articleNum INTEGER,
    articleAuthor VARCHAR(30),
    articlePage INTEGER,
    PRIMARY KEY (editionDate, articleNum),
    FOREIGN KEY (editionDate) REFERENCES Editions(editionDate)
);


CREATE TABLE ReadArticles (
    subscriberPhone INTEGER,
    editionDate DATE,
    articleNum INTEGER,
    readInterval INTERVAL,
    PRIMARY KEY (subscriberPhone, editionDate, articleNum),
    FOREIGN KEY (subscriberPhone) REFERENCES Subscribers(subscriberPhone),
    FOREIGN KEY (editionDate, articleNum) REFERENCES Articles(editionDate, articleNum)
);
