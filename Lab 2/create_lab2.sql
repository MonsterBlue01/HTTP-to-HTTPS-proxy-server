-- CSE 180 Fall 2023 create file which students need to modify.

-- This file is based on our create file solution for Lab1, but most comments have been deleted,
-- and the schema used is now Lab2.

-- But you may use your own Lab1 create file as a basis for Lab2 instead of ours, if
-- your Lab1 solution is correct.

-- The following two lines are not needed in your solution, but they're useful.
DROP SCHEMA lab2 CASCADE;
CREATE SCHEMA lab2;


CREATE TABLE SubscriptionKinds(
    subscriptionMode CHAR(1),
    subscriptionInterval INTERVAL,
    rate NUMERIC(6,2) NOT NULL,
    stillOffered BOOLEAN,
    PRIMARY KEY (subscriptionMode, subscriptionInterval)
    );


CREATE TABLE Editions(
    editionDate DATE PRIMARY KEY,
    numArticles INT,
    numPages INT
    );


CREATE TABLE Subscribers(
    subscriberPhone INT PRIMARY KEY,
    subscriberName VARCHAR(30) NOT NULL,
    subscriberAddress VARCHAR(60),
    UNIQUE(subscriberName, subscriberAddress)
    );


CREATE TABLE Subscriptions(
    subscriberPhone INT REFERENCES Subscribers ON DELETE CASCADE,
    subscriptionStartDate DATE,
    subscriptionMode CHAR(1),
    subscriptionInterval INTERVAL,
    paymentReceived BOOLEAN,
    PRIMARY KEY (subscriberPhone, subscriptionStartDate),
    FOREIGN KEY (subscriptionMode, subscriptionInterval) REFERENCES SubscriptionKinds ON DELETE CASCADE
);


CREATE TABLE Holds(
    subscriberPhone INT,
    subscriptionStartDate DATE,
    holdStartDate DATE,
    holdEndDate DATE,
    PRIMARY KEY (subscriberPhone, subscriptionStartDate, holdStartDate),
    FOREIGN KEY (subscriberPhone, subscriptionStartDate) REFERENCES Subscriptions,
    UNIQUE(subscriberPhone, subscriptionStartDate, holdEndDate)
    );


CREATE TABLE Articles(
    editionDate DATE REFERENCES Editions ON DELETE CASCADE,
    articleNum INT,
    articleAuthor VARCHAR(30) NOT NULL,
    articlePage INT,
    PRIMARY KEY (editionDate, articleNum),
    UNIQUE(editionDate, articleAuthor, articlePage)
);


CREATE TABLE ReadArticles(
    subscriberPhone INT REFERENCES Subscribers ON DELETE CASCADE,
    editionDate DATE,
    articleNum INT,
    readInterval INTERVAL,
    PRIMARY KEY (subscriberPhone, editionDate, articleNum),
    FOREIGN KEY (editionDate, articleNum) REFERENCES Articles ON DELETE CASCADE
);