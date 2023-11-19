COPY SubscriptionKinds FROM stdin USING DELIMITERS '|';
D|1 years|70.00|TRUE
P|1 years|90.00|FALSE
B|1 years|160.00|TRUE
D|4 weeks|16.00|TRUE
P|4 weeks|18.00|TRUE
D|8 years|399.99|TRUE
B|8 years|1099.99|TRUE
B|3 years|450.00|FALSE
P|3 years|250.00|TRUE
\.

-- Editions(editionDate, numArticles, numPages)
COPY Editions FROM stdin USING DELIMITERS '|';
2022-12-01|3|5
2022-06-01|10|15
2022-03-01|5|23
2022-01-01|13|67
2021-02-15|3|10
2021-04-01|3|3
2021-06-13|25|25
2023-08-30|2|30
2021-06-15|20|40
2021-10-15|10|34
\.

-- Subscribers(subscriberPhone, subscriberName, subscriberAddress)
COPY Subscribers FROM stdin USING DELIMITERS '|';
8315512|Steve Rogers|569A Leaman Place, Santa Barbara, CA, 93103
6505523|Cersei Lannister|\N
4155534|Doctor Strange|300D Quincy Street, New York, NY, 10213
5105545|Carol Danvers|230C Randyll Street, Trenton, NJ, 08406
9255556|Tony Stark|\N
8315567|Bruce Banner|3428A Lombard St, Tahoe City, CA, 96142
6502123|Doctor Strange|13 Bleecker St, New York, NY, 10021
8313293|Thor Odinson|100 Asgard St, Asgard, AG, 00001
\.

-- Subscriptions(subscriberPhone, subscriptionStartDate, subscriptionMode, subscriptionInterval, paymentReceived)
COPY Subscriptions FROM stdin USING DELIMITERS '|';
8315512|2023-01-01|D|1 years|FALSE
6505523|2022-12-15|P|4 weeks|TRUE
6505523|2022-12-27|D|8 years|FALSE
4155534|2021-02-15|B|1 years|FALSE
5105545|2022-04-01|D|8 years|TRUE
8315567|2023-03-01|D|8 years|TRUE
8315567|2023-09-01|P|1 years|TRUE
6502123|2022-12-06|B|3 years|FALSE
6502123|2022-12-10|D|1 years|FALSE
6502123|2023-04-15|B|1 years|FALSE
8313293|2022-10-01|D|8 years|TRUE
\.

-- Holds(subscriberPhone, subscriptionStartDate, holdStartDate, holdEndDate)
COPY Holds FROM stdin USING DELIMITERS '|';
6502123|2022-12-06|2023-01-01|2023-11-01
6505523|2022-12-27|2023-01-31|2023-02-28
6505523|2022-12-27|2023-03-31|2023-04-30
5105545|2022-04-01|2022-10-01|2022-12-01
5105545|2022-04-01|2023-01-21|2023-01-21
5105545|2022-04-01|2022-04-01|2023-05-10
8313293|2022-10-01|2022-10-01|2022-10-01
\.

-- Articles(editionDate, articleNum, articleAuthor, articlePage)
COPY Articles FROM stdin USING DELIMITERS '|';
2022-12-01|4|Green Goblin|10
2022-12-01|6|Doctor Strange|7
2022-12-01|1|Doctor Strange|4
2021-02-15|1|Cersei Lannister|1
2021-02-15|2|Cersei Lannister|12
2021-02-15|3|Cersei Lannister|15
2021-04-01|1|Ragnar Lothbrok|1
2021-04-01|2|Ragnar Lothbrok|2
2021-02-15|5|Ragnar Lothbrok|4
2021-06-13|1|Ragnar Lothbrok|1
2021-06-13|2|Ragnar Lothbrok|1
2022-12-01|2|Ragnar Lothbrok|2
2022-06-01|1|Ragnar Lothbrok|10
2022-03-01|1|Ragnar Lothbrok|4
2022-01-01|1|Ragnar Lothbrok|3
2022-01-01|4|Ragnar Lothbrok|3
2022-01-01|5|Ragnar Lothbrok|3
2021-04-01|3|Judith|4
2021-02-15|6|Judith|3
2021-06-13|3|Judith|4
2021-06-13|4|Judith|3
2021-06-15|1|Judith|1
2022-06-01|2|Lucius Malfoy|11
2022-06-01|3|Lucius Malfoy|11
2022-06-01|4|Lucius Malfoy|11
2022-03-01|2|Lucius Malfoy|13
2022-01-01|3|Lucius Malfoy|2
2022-03-01|3|Lucius Malfoy|2
2021-02-15|9|Lucius Malfoy|1
2021-06-13|10|Lucius Malfoy|3
2021-04-01|4|Lucius Malfoy|10
2023-08-30|1|Lucius Malfoy|1
2023-08-30|2|Barty Crouch Jr.|3
2023-08-30|3|Gregor Clegane|5
2023-08-30|4|Bellatrix Lestrange|10
\.

-- ReadArticles(subscriberPhone, editionDate, articleNum, readInterval)
COPY ReadArticles FROM stdin USING DELIMITERS '|';
8315512|2021-02-15|1|00:15:00
8315512|2021-04-01|1|00:25:36
8315512|2023-08-30|3|00:00:01
5105545|2023-08-30|3|00:19:03
6505523|2022-12-01|4|01:45:02
6505523|2022-12-01|6|00:00:05
6505523|2023-08-30|2|00:14:32
6505523|2023-08-30|1|22:20:32
8315567|2021-02-15|1|10:32:30
8315567|2021-02-15|2|00:03:23
8315567|2021-02-15|5|00:10:32
8315567|2023-08-30|1|00:12:34
6502123|2022-12-01|4|00:07:30
6502123|2022-12-01|1|00:08:45
6502123|2021-02-15|1|00:09:31
6502123|2021-02-15|2|00:06:53
6502123|2021-02-15|5|10:07:11
6502123|2021-04-01|1|00:14:37
6502123|2023-08-30|1|00:23:25
6502123|2023-08-30|2|00:06:41
6502123|2023-08-30|3|08:08:08
8313293|2023-08-30|3|00:01:00
\.

-- NewReadArticles(subscriberPhone, editionDate, articleNum, readInterval)
COPY NewReadArticles FROM stdin USING DELIMITERS '|';
8315512|2021-02-15|1|00:35:00
5105545|2023-08-30|3|00:10:30
4155534|2021-04-01|3|00:12:12
8313293|2023-08-30|4|00:23:12
8315567|2022-12-01|1|00:00:50
6502123|2023-08-30|3|00:21:12
8313293|2023-08-30|3|00:02:00
\.
