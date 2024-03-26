#include "ssl.hh"
#include <openssl/err.h>
#include <iostream>
#include <netdb.h>
#include <unistd.h>

using namespace std;

void init_openssl() {
    SSL_load_error_strings();   
    OpenSSL_add_ssl_algorithms();
}

void cleanup_openssl() {
    EVP_cleanup();
}

SSL_CTX* create_context() {
    const SSL_METHOD* method = SSLv23_client_method();
    SSL_CTX* ctx = SSL_CTX_new(method);
    if (!ctx) {
        perror("Unable to create SSL context");
        ERR_print_errors_fp(stderr);
        exit(EXIT_FAILURE);
    }
    return ctx;
}

void cleanup(int server_fd, SSL_CTX* ctx, SSL* ssl) {
    if (ssl) SSL_free(ssl); // Release SSL object
    if (server_fd != -1) close(server_fd); // close socket
    if (ctx) SSL_CTX_free(ctx); // Release SSL context
}

SSL* connect_to_server(const string& server_ip, int server_port) {
    SSL_CTX* ctx;
    SSL* ssl;
    int server_fd;
    struct addrinfo hints, *res, *p;

    init_openssl();
    ctx = create_context();

    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC; // Support IPv4 and IPv6
    hints.ai_socktype = SOCK_STREAM;

    string port_str = to_string(server_port);

    if (getaddrinfo(server_ip.c_str(), port_str.c_str(), &hints, &res) != 0) {
        cerr << "getaddrinfo failed: " << gai_strerror(errno) << endl;
        SSL_CTX_free(ctx);
        exit(EXIT_FAILURE);
    }

    for (p = res; p != NULL; p = p->ai_next) {
        server_fd = socket(p->ai_family, p->ai_socktype, p->ai_protocol);
        if (server_fd == -1) continue;

        if (connect(server_fd, p->ai_addr, p->ai_addrlen) == 0) {
            break; // Successfully connected
        }

        close(server_fd);
    }

    if (p == NULL) {
        cerr << "Unable to connect" << endl;
        SSL_CTX_free(ctx);
        exit(EXIT_FAILURE);
    }

    freeaddrinfo(res);

    ssl = SSL_new(ctx);
    SSL_set_fd(ssl, server_fd);

    if (SSL_connect(ssl) != 1) {
        ERR_print_errors_fp(stderr);
        cleanup(server_fd, ctx, ssl);
        exit(EXIT_FAILURE);
    }

    return ssl;
}
