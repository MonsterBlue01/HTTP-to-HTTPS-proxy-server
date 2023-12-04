/**
 * runHighwayApplication skeleton, to be modified by students
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "libpq-fe.h"

/* These constants would normally be in a header file */
/* Maximum length of string used to submit a connection */
#define MAXCONNECTIONSTRINGSIZE 501
/* Maximum length of string used to submit a SQL statement */
#define MAXSQLSTATEMENTSTRINGSIZE 2001
/* Maximum length of string version of integer; you don't have to use a value this big */
#define  MAXNUMBERSTRINGSIZE        20


/* Exit with success after closing connection to the server
 *  and freeing memory that was used by the PGconn object.
 */
static void good_exit(PGconn *conn) {
    PQfinish(conn);
    exit(EXIT_SUCCESS);
}

/* Exit with failure after closing connection to the server
 *  and freeing memory that was used by the PGconn object.
 */
static void bad_exit(PGconn *conn) {
    PQfinish(conn);
    exit(EXIT_FAILURE);
}

/* The three C functions that for Lab4 should appear below.
 * Write those functions, as described in Lab4 Section 4 (and Section 5,
 * which describes the Stored Function used by the third C function).
 *
 * Write the tests of those function in main, as described in Section 6
 * of Lab4.
 *
 * You may use "helper" functions to avoid having to duplicate calls and
 * printing, if you'd like, but if Lab4 says do things in a function, do them
 * in that function, and if Lab4 says do things in main, do them in main,
 * possibly using a helper function, if you'd like.
 */

/* Function: countCoincidentSubscriptions:
 * -------------------------------------
 * Parameters:  connection, and theSubscriberPhone, which should be the ID of a subscriber.
 * Counts the number of coincident subscriptions for that subscriber, if there is a
 * subscriber corresponding to theSubscriberPhone.
 * Return 0 if normal execution, -1 if no such subscriber.
 * bad_exit if SQL statement execution fails.
 */


int countCoincidentSubscriptions(PGconn *conn, int theSubscriberPhone) {
    PGresult *res;
    char sql[MAXSQLSTATEMENTSTRINGSIZE];
    int coincidentCount = 0;

    snprintf(sql, sizeof(sql), "SELECT COUNT(*) FROM Subscriptions s1, Subscriptions s2 "
             "WHERE s1.subscriberPhone = %d AND s2.subscriberPhone = %d "
             "AND s1.subscriptionId != s2.subscriptionId "
             "AND s1.subscriptionStartDate <= s2.subscriptionStartDate "
             "AND DATE(s1.subscriptionStartDate + INTERVAL '1 month' * s1.subscriptionInterval) >= s2.subscriptionStartDate",
             theSubscriberPhone, theSubscriberPhone);

    res = PQexec(conn, sql);

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        printf("Query failed: %s\n", PQerrorMessage(conn));
        PQclear(res);
        return -1;
    }

    if (PQntuples(res) > 0) {
        coincidentCount = atoi(PQgetvalue(res, 0, 0));
    }

    PQclear(res);
    return coincidentCount;
}


/* Function: changeAddresses:
 * ----------------------------
 * Parameters:  connection, and character strings oldAddress and newAddress
 
 * Updates all subscriberAddress values in Subscribers which had value oldAddress to newAddress,
 * and returns the number of addresses updates.
 * If no addresses are updated (because no subscribers have oldAddress as their subscriberAddress,
 * return 0; that's not an error.
 */

int changeAddresses(PGconn *conn, char *oldAddress, char *newAddress) {
    PGresult *res;
    char sql[MAXSQLSTATEMENTSTRINGSIZE];
    int updatedRows = 0;

    snprintf(sql, sizeof(sql), "UPDATE Subscribers SET subscriberAddress = '%s' WHERE subscriberAddress = '%s'",
             newAddress, oldAddress);

    res = PQexec(conn, sql);

    if (PQresultStatus(res) != PGRES_COMMAND_OK) {
        fprintf(stderr, "Update command failed: %s", PQerrorMessage(conn));
        PQclear(res);
        return -1;
    }

    updatedRows = atoi(PQcmdTuples(res));

    PQclear(res);
    return updatedRows;
}


/* Function: increaseSomeRates:
 * -------------------------------
 * Parameters:  connection, and an integer maxTotalRateIncrease, the maximum total
 * rate increase that should be applied based on increasing rates for some subscription kinds
 * in SubscriptionKinds, aa described in Section 5 of the Lab4 pdf.
 *
 * Executes by invoking a Stored Function, increaseSomeRatesFunction, which does all of the work.
 *
 * Returns a negative value if there is an error, and otherwise returns the total rate increase
 * that's been applied to subscriptions that have certain subscription kinds.
 */

int increaseSomeRates(PGconn *conn, int maxTotalRateIncrease) {
    PGresult *res;
    char sql[MAXSQLSTATEMENTSTRINGSIZE];
    int rateIncrease = 0;

    snprintf(sql, sizeof(sql), "SELECT increaseSomeRatesFunction(%d)", maxTotalRateIncrease);

    res = PQexec(conn, sql);

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Stored function call failed: %s", PQerrorMessage(conn));
        PQclear(res);
        return -1;
    }

    if (PQntuples(res) > 0) {
        rateIncrease = atoi(PQgetvalue(res, 0, 0));
    }

    PQclear(res);
    return rateIncrease;
}


int main(int argc, char **argv) {
    PGconn *conn;
    int theResult;

    if (argc != 3) {
        fprintf(stderr, "Usage: ./runHighwayApplication <username> <password>\n");
        exit(EXIT_FAILURE);
    }

    char *userID = argv[1];
    char *pwd = argv[2];

    char conninfo[MAXCONNECTIONSTRINGSIZE] = "host=cse180-db.lt.ucsc.edu user=";
    strcat(conninfo, userID);
    strcat(conninfo, " password=");
    strcat(conninfo, pwd);

    /* Make a connection to the database */
    conn = PQconnectdb(conninfo);

    /* Check to see if the database connection was successfully made. */
    if (PQstatus(conn) != CONNECTION_OK) {
        fprintf(stderr, "Connection to database failed: %s\n",
                PQerrorMessage(conn));
        bad_exit(conn);
    }
    
    /* Perform the calls to countCoincidentSubscriptions listed in Section 6 of Lab4,
     * and print messages as described.
     */
    
    
    /* Extra newline for readability */
    printf("\n");

    
    /* Perform the calls to changeAddresses listed in Section 6 of Lab4,
     * and print messages as described.
     */
    
    /* Extra newline for readability */
    printf("\n");

    
    /* Perform the calls to increaseSomeRates listed in Section
     * 6 of Lab4, and print messages as described.
     * You may use helper functions to do this, if you want.
     */


    good_exit(conn);
    return 0;
}
