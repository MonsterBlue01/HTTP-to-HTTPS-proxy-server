#!/bin/bash

make

echo "Test 1: (Simple test for the proxy server)"

# Start proxy server
./bin/myproxy 8080 ./forbidden.txt ./access.log &
proxy_pid=$!

# Use curl to access www.google.com through the proxy server and save the response headers
response=$(curl -i -x http://localhost:8080 http://www.google.com --silent)

# Extract HTTP status code from response
curl_status=$(echo "$response" | grep HTTP/ | awk '{print $2}')

# Check whether the curl request is successful (return code is 200)
if [ "$curl_status" == "200" ]; then
    echo -e "\033[0;32mTest 1 passed.\033[0m"
else
    echo -e "\033[0;31mTest 1 failed. Expected: 200. Received: $curl_status\033[0m"
    # Turn off proxy server
    kill $proxy_pid
    make clean
    exit 1
fi

echo "Test 2: (Multithreading test for the proxy server)"

declare -a curl_pids

perform_test() {
    local method=$1
    local url=$2
    local expected_status=$3
    local test_name=$4

    # Use curl to make requests through a proxy server, running in the background for concurrency
    if [ "$method" == "GET" ]; then
        curl -i -x http://localhost:8080 "$url" --silent > "/tmp/${test_name}_response.txt" &
    elif [ "$method" == "HEAD" ]; then
        curl -I -x http://localhost:8080 "$url" --silent > "/tmp/${test_name}_response.txt" &
    fi
    curl_pids+=($!)
}

# Start all tests at the same time
perform_test "GET" "http://www.google.com" "200" "Test_1_Simple_GET_for_www_google_com"
perform_test "HEAD" "http://www.google.com" "200" "Test_2_Simple_HEAD_for_www_google_com"
perform_test "GET" "http://www.ucsc.edu" "200" "Test_3_Simple_GET_for_www_ucsc_edu"
perform_test "HEAD" "http://www.ucsc.edu" "200" "Test_4_Simple_HEAD_for_www_ucsc_edu"

# Wait for all curl commands to complete
for pid in "${curl_pids[@]}"; do
    wait $pid
done

# Check the output file of the curl command to verify the status code
failed=0
for test_name in "Test_1_Simple_GET_for_www_google_com" "Test_2_Simple_HEAD_for_www_google_com" "Test_3_Simple_GET_for_www_ucsc_edu" "Test_4_Simple_HEAD_for_www_ucsc_edu"; do
    curl_status=$(grep HTTP/ "/tmp/${test_name}_response.txt" | awk '{print $2}')
    if [ "$curl_status" == "200" ]; then
        echo -e "\033[0;32m${test_name} passed.\033[0m"
    else
        echo -e "\033[0;31m${test_name} failed. Expected: 200. Received: $curl_status\033[0m"
        failed=1
    fi
done

# Check if any tests failed
if [ "$failed" != "1" ]; then
    echo -e "\033[0;32mAll tests passed.\033[0m"
else
    echo -e "\033[0;31mOne or more tests failed.\033[0m"
fi

echo "Test 3: Server is not able to connect to the requested URL."

# Use curl to access an invalid URL through a proxy server, saving response headers
response=$(curl -i -x http://localhost:8080 http://wwww. --silent)

# Extract HTTP status code from response
curl_status=$(echo "$response" | grep HTTP/ | awk '{print $2}')

# Check if the curl request was successful (expected return code is 502)
if [ "$curl_status" == "400" ]; then
    echo -e "\033[0;32mTest 3 passed.\033[0m"
else
    echo -e "\033[0;31mTest 3 failed. Expected: 502. Received: $curl_status\033[0m"
    # Turn off proxy server
    kill $proxy_pid
    make clean
    exit 1
fi

echo "Test 4: Testing for expected 501 Not Implemented response with unsupported HTTP method"

# Use curl to access www.google.com with the POST method through the proxy server, saving the response headers
# NOTE: We use the -X option to specify the POST method to use
response=$(curl -i -X POST -x http://localhost:8080 http://www.google.com --silent)

# Extract HTTP status code from response
curl_status=$(echo "$response" | grep HTTP/ | awk '{print $2}')

# Check if curl request is successful (expected return code is 501)
if [ "$curl_status" == "501" ]; then
    echo -e "\033[0;32mTest 4 passed. Unsupported HTTP method correctly resulted in 501 Not Implemented.\033[0m"
else
    echo -e "\033[0;31mTest 4 failed. Expected: 501. Received: $curl_status\033[0m"
fi

# To test for completeness, it is also possible to add checks for other non-supported methods such as PUT, DELETE, etc.
# Here is an additional example, using the PUT method
response=$(curl -i -X PUT -x http://localhost:8080 http://www.google.com --silent)
curl_status=$(echo "$response" | grep HTTP/ | awk '{print $2}')
if [ "$curl_status" == "501" ]; then
    echo -e "\033[0;32mAdditional Test with PUT method passed. Unsupported HTTP method correctly resulted in 501 Not Implemented.\033[0m"
else
    echo -e "\033[0;31mAdditional Test with PUT method failed. Expected: 501. Received: $curl_status\033[0m"
fi

echo "Test 5: (ACL test for the proxy server)"

# Use curl to access www.google.com through the proxy server and save the response headers
response=$(curl -i -x http://localhost:8080 http://www.google.com --silent)

# Extract HTTP status code from response
curl_status=$(echo "$response" | grep HTTP/ | awk '{print $2}')

# Check whether the curl request is successful (return code is 200)
if [ "$curl_status" == "200" ]; then
    echo -e "\033[0;32mTest 5 Part 1 passed.\033[0m"
else
    echo -e "\033[0;31mTest 5 Part 1 failed. Expected: 200. Received: $curl_status\033[0m"
    # Turn off proxy server
    kill $proxy_pid
    make clean
    exit 1
fi

# Save the contents of forbidden.txt to a temporary file
mv ./forbidden.txt ./forbidden.txt.bak

# Create a new forbidden.txt file
echo "http://www.google.com" > ./forbidden.txt
echo "https://www.google.com" >> ./forbidden.txt
echo "http://www.google.com/" >> ./forbidden.txt
echo "https://www.google.com/" >> ./forbidden.txt

# Type the contents of forbidden.txt file
echo "forbidden.txt:"
cat ./forbidden.txt

# End the original proxy server
kill $proxy_pid
wait $proxy_pid 2>/dev/null

# Restart proxy server
./bin/myproxy 8080 ./forbidden.txt ./access.log &
proxy_pid=$!

# Use the same curl command again as above
response=$(curl -i -x http://localhost:8080 http://www.google.com --silent)

# Check whether the curl request is successful (return code is 403)
curl_status=$(echo "$response" | grep HTTP/ | awk '{print $2}')

if [ "$curl_status" == "403" ]; then
    echo -e "\033[0;32mTest 5 Part 2 passed.\033[0m"
else
    echo -e "\033[0;31mTest 5 Part 2 failed. Expected: 403. Received: $curl_status\033[0m"
    # Restore the original forbidden.txt file
    mv ./forbidden.txt.bak ./forbidden.txt
    # Turn off proxy server
    kill $proxy_pid
    make clean
    exit 1
fi

# Restore the original forbidden.txt file
mv ./forbidden.txt.bak ./forbidden.txt

# Close proxy server
kill $proxy_pid
wait $proxy_pid 2>/dev/null

make clean
