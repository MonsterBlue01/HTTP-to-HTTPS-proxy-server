#include <unistd.h>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <thread>
#include <unordered_set>
#include <signal.h>
#include <map>
#include <arpa/inet.h>
#include <netdb.h>
#include <regex>

#include "log.hh"
#include "acl.hh"
#include "ssl.hh"

#define MAX_REQUEST_SIZE 16384

using namespace std;

bool is_valid_ip(const string& ip) {
    struct sockaddr_in sa;
    return inet_pton(AF_INET, ip.c_str(), &(sa.sin_addr)) != 0;
}

pair<string, int> extract_domain_and_port_from_url(const string& url) {
    regex url_regex("^(?:http[s]?://)?([^/:]+)(?::(\\d+))?");
    smatch url_match_result;

    if (regex_search(url, url_match_result, url_regex)) {
        string domain = url_match_result[1].str();
        int port = 443; // Default HTTPS port
        if (url_match_result.size() == 3 && url_match_result[2].matched) {
            // If a port is matched, the extracted port is used
            port = stoi(url_match_result[2].str());
        }
        return {domain, port};
    } else {
        return {"", 443}; // Not a valid URL, return the default value
    }
}

bool is_valid_domain_name(const string& domain_name) {
    if (domain_name.length() > 253) {
        return false;
    }

    regex label_regex("^([a-z0-9]|[a-z0-9][a-z0-9\\-]*[a-z0-9])$");
    regex domain_regex("^([a-z0-9\\-]+\\.)*[a-z0-9\\-]+$");

    if (!regex_match(domain_name, domain_regex)) {
        return false;
    }

    auto start = domain_name.begin();
    auto end = domain_name.end();
    while (start < end) {
        end = find(start, end, '.');
        string label(start, end);
        if (!regex_match(label, label_regex)) {
            return false;
        }
        if (end != domain_name.end()) ++end; // Skip the dot
        start = end;
    }

    return true;
}
// Parse HTTP request
void parse_http_request(const string& http_request, string& method, string& url, map<string, string>& headers) {
    stringstream request_stream(http_request);
    string line;
    // Read the request line
    if (getline(request_stream, line)) {
        stringstream request_line_stream(line);
        request_line_stream >> method; // Read method
        request_line_stream >> url;    // Read URL
        // Read request header
        while (getline(request_stream, line) && line != "\r") {
            auto colon_pos = line.find(':');
            if (colon_pos != string::npos) {
                string header_name = line.substr(0, colon_pos);
                string header_value = line.substr(colon_pos + 2, line.length() - colon_pos - 3); // Remove the \r at the end
                headers[header_name] = header_value;
            }
        }
    }
}

string resolve_domain_name_to_ip(const string& domain_name) {
    struct addrinfo hints, *res, *p;
    int status;
    char ipstr[INET6_ADDRSTRLEN];

    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC; // AF_INET or AF_INET6 to force version
    hints.ai_socktype = SOCK_STREAM;

    if ((status = getaddrinfo(domain_name.c_str(), NULL, &hints, &res)) != 0) {
        cerr << "getaddrinfo error: " << gai_strerror(status) << endl;
        return "";
    }

    for(p = res; p != NULL; p = p->ai_next) {
        void *addr;
        if (p->ai_family == AF_INET) { // IPv4
            struct sockaddr_in *ipv4 = (struct sockaddr_in *)p->ai_addr;
            addr = &(ipv4->sin_addr);
        } else { // IPv6
            struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *)p->ai_addr;
            addr = &(ipv6->sin6_addr);
        }
        // Convert the IP to a string and break
        inet_ntop(p->ai_family, addr, ipstr, sizeof ipstr);
        break;
    }

    freeaddrinfo(res); // Free the linked list
    return string(ipstr);
}

// Handle client connections and forward requests
void handle_connection(int client_fd) {
    char buffer[MAX_REQUEST_SIZE];
    memset(buffer, 0, MAX_REQUEST_SIZE);

    //Receive HTTP request from client
    ssize_t request_size = recv(client_fd, buffer, MAX_REQUEST_SIZE, 0);
    if (request_size < 0) {
        perror("Unable to read from socket");
        close(client_fd);
        return;
    }

    // Make sure the buffer is null terminated
    buffer[request_size] = '\0';
    string http_request(buffer);

    // Get the client IP address
    struct sockaddr_in client_addr;
    socklen_t client_addr_len = sizeof(client_addr);
    char client_ip_str[INET_ADDRSTRLEN];

    if (getpeername(client_fd, (struct sockaddr*)&client_addr, &client_addr_len) == 0) {
        inet_ntop(AF_INET, &client_addr.sin_addr, client_ip_str, INET_ADDRSTRLEN);
    } else {
        strcpy(client_ip_str, "Unknown");
    }

    string method, url;
    map<string, string> headers;
    parse_http_request(http_request, method, url, headers);

    auto domain_and_port = extract_domain_and_port_from_url(url);
    string domain_name_or_ip = domain_and_port.first;
    int server_port = domain_and_port.second;

    // debug output
    // cout << "Received request: " << method << " " << url << endl;
    // cout << "Headers:" << endl;
    // for (const auto& header : headers) {
    //     cout << header.first << ": " << header.second << endl;
    // }

    // Check if URL is in ACL
    if (is_acl_blocked(url)) {
        string response = "HTTP/1.1 403 Forbidden\r\n\r\n";
        cout << "Blocked URL: " << url << endl;
        log_access(client_ip_str, method + " " + url, 403, response.size());
        send(client_fd, response.c_str(), response.size(), 0);
        close(client_fd);
        return;
    }

    // Check if the method is supported
    if (method != "GET" && method != "HEAD") {
        string response = "HTTP/1.1 501 Not Implemented\r\n\r\n";        
        cout << "Unsupported method: " << method << endl;
        log_access(client_ip_str, method + " " + url, 501, response.size());
        send(client_fd, response.c_str(), response.size(), 0);
        close(client_fd);
        return;
    }

    string server_ip;

    // Check if the URL is valid
    if (domain_name_or_ip.empty()) {
        string response = "HTTP/1.1 400 Bad Request\r\n\r\n";
        cout << "Invalid URL: " << url << endl;
        log_access(client_ip_str, method + " " + url, 400, response.size());
        send(client_fd, response.c_str(), response.size(), 0);
        close(client_fd);
        return;
    }

    // Check if it is an IP address
    if (is_valid_ip(domain_name_or_ip)) {
        // If it is an IP address, connect directly to the target server
        cout << "Connecting to IP: " << domain_name_or_ip << endl;
    } else {
        // If it is a domain name, resolve the domain name and connect to the target server
        if (!is_valid_domain_name(domain_name_or_ip)) {
            string response = "HTTP/1.1 400 Bad Request\r\n\r\n";
            cout << "Invalid domain name: " << domain_name_or_ip << endl;
            log_access(client_ip_str, method + " " + url, 400, response.size());
            cout << "Writing log entry" << endl;
            send(client_fd, response.c_str(), response.size(), 0);
            close(client_fd);
            return;
        }
        server_ip = resolve_domain_name_to_ip(domain_name_or_ip);
        if (server_ip.empty()) {
            string response = "HTTP/1.1 502 Bad Gateway\r\n\r\n";
            cout << "Unable to resolve domain name: " << domain_name_or_ip << endl;
            log_access(client_ip_str, method + " " + url, 502, response.size());
            cout << "Writing log entry" << endl;
            send(client_fd, response.c_str(), response.size(), 0);
            close(client_fd);
            return;
        }
        cout << "Ready to connect to domain: " << domain_name_or_ip << " (" << server_ip << ")" << endl;
    }

    if (is_acl_blocked(server_ip)) {
        string response = "HTTP/1.1 403 Forbidden\r\n\r\n";
        cout << "Blocked IP: " << server_ip << endl;
        log_access(client_ip_str, method + " " + url, 403, response.size());
        send(client_fd, response.c_str(), response.size(), 0);
        close(client_fd);
        return;
    }

    // Connect to target server
    SSL* ssl = connect_to_server(server_ip, server_port);
    if (!ssl) {
        // Connection failed, handling error
        string response = "HTTP/1.1 504 Gateway Timeout\r\n\r\n";
        cerr << "Failed to connect to " << server_ip << ":" << server_port << endl;
        log_access(client_ip_str, method + " " + url, 502, response.size());
        send(client_fd, response.c_str(), response.size(), 0);
        close(client_fd);
        return;
    }

    int server_fd = SSL_get_fd(ssl);
    if (server_fd < 0) {
        // Failed to obtain file descriptor, processing error
        SSL_free(ssl); // Release SSL resources
        string response = "HTTP/1.1 502 Bad Gateway\r\n\r\n";
        cerr << "Failed to get file descriptor from SSL for " << server_ip << endl;
        log_access(client_ip_str, method + " " + url, 502, response.size());
        send(client_fd, response.c_str(), response.size(), 0);
        close(client_fd);
        return;
    }

    // Forward the client's HTTP request to the server
    ssize_t sent = SSL_write(ssl, http_request.c_str(), http_request.length());
    if (sent <= 0) {
        // Handle SSL write error
        SSL_shutdown(ssl);
        SSL_free(ssl);
        close(client_fd);
        close(server_fd);
        return;
    }

    // Initialize the set of active sockets
    fd_set read_fds;
    int max_fd = max(client_fd, server_fd) + 1; // Assuming server_fd is the socket descriptor for the server connection

    char client_buffer[MAX_REQUEST_SIZE];
    char server_buffer[MAX_REQUEST_SIZE];

    // Define a timeout before the while loop starts
    struct timeval timeout;
    timeout.tv_sec = 30; // 30 seconds
    timeout.tv_usec = 0;  // 0 microseconds

    size_t total_response_size = 0;

    // Ready to enter the loop
    // cout << "Entering select loop" << endl;
    while (true) {
        FD_ZERO(&read_fds);
        FD_SET(client_fd, &read_fds);
        FD_SET(server_fd, &read_fds);

        // Call select with timeout setting
        int activity = select(max_fd, &read_fds, NULL, NULL, &timeout);

        if (activity < 0) {
            perror("select error");
            break; // Exit the loop on select error
        } else if (activity == 0) {
            // timeout occurs
            cout << "Timeout occurred. No data in 30 seconds." << endl;
            break; // Timeout, end loop
        }

        if (FD_ISSET(client_fd, &read_fds)) {
            // Data coming from the client, read it
            int bytes_read = read(client_fd, client_buffer, MAX_REQUEST_SIZE);
            // cout << "Read " << bytes_read << " bytes from client" << endl;
            if (bytes_read > 0) {
                // Write the data to the server using SSL
                int write_ret = SSL_write(ssl, client_buffer, bytes_read);
                if (write_ret <= 0) {
                    // Handle SSL write error or close
                    break;
                }
            } else if (bytes_read == 0 || (bytes_read < 0 && errno != EINTR && errno != EWOULDBLOCK)) {
                // Handle client disconnection or error
                break;
            }
        }

        if (FD_ISSET(server_fd, &read_fds)) {
            // Data coming from the server, read it using SSL
            int bytes_read = SSL_read(ssl, server_buffer, MAX_REQUEST_SIZE);
            // cout << "Read " << bytes_read << " bytes from server" << endl;
            if (bytes_read > 0) {
                // Write the data to the client
                int write_ret = write(client_fd, server_buffer, bytes_read);
                if (write_ret <= 0) {
                    // Handle write error or close
                    break;
                } else {
                    total_response_size += write_ret;
                }
            } else if (bytes_read <= 0) {
                // Handle SSL read error, close, or need for SSL renegotiation
                break;
            }
        }
    }

    // Record access log
    if (total_response_size > 0) {
        log_access(client_ip_str, method + " " + url, 200, total_response_size);
        // cout << "Writing log entry" << endl;
    }

    // Gracefully close SSL connections
    SSL_shutdown(ssl);
    SSL_free(ssl);

    // close socket
    close(client_fd);
    close(server_fd);
}

// Thread pool task function
void thread_pool_task(int client_fd) {
    // Call handle_connection to handle each client connection
    handle_connection(client_fd);
}

// Main function: initialize select, listen to port, handle connection
int main(int argc, char* argv[]) {
    if (argc != 4) {
        cerr << "Usage: " << argv[0] << " <listen_port> <forbidden_sites_file_path> <access_log_file_path>" << endl;
        return 1;
    }

    int port = atoi(argv[1]);
    forbidden_sites_file_path = argv[2];
    access_log_file_path = argv[3];

    // Try to open the log file
    ofstream log_file(access_log_file_path, ios::app);
    if (!log_file.is_open()) {
        cerr << "Unable to open log file: " << access_log_file_path << endl;
        return 1;
    } else {
        log_file.close();
    }

    int server_fd;
    struct sockaddr_in address;
    int opt = 1;
    socklen_t addrlen = sizeof(address);

    // Register signal handler for SIGINT
    signal(SIGINT, signal_handler);

    // Load ACL file
    load_acl(forbidden_sites_file_path);

    // Creating socket file descriptor
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("socket failed");
        exit(EXIT_FAILURE);
    }

    // Forcefully attaching socket to the port
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &opt, sizeof(opt))) {
        perror("setsockopt");
        exit(EXIT_FAILURE);
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(port);

    // Bind the socket to the port
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }

    // Listen for incoming connections
    if (listen(server_fd, 10) < 0) {
        perror("listen");
        exit(EXIT_FAILURE);
    }

    cout << "Server listening on port " << port << endl;

    while (true) {
        int new_socket;
        if ((new_socket = accept(server_fd, (struct sockaddr *)&address, &addrlen))<0) {
            perror("accept");
            exit(EXIT_FAILURE);
        }

        cout << "Connection accepted" << endl;

        // Use a thread to handle the connection
        thread(handle_connection, new_socket).detach(); // Detach the thread to handle independently
    }

    return 0;
}
