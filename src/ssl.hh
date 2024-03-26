#ifndef SSL_H
#define SSL_H

#include <openssl/ssl.h>
#include <openssl/err.h>
#include <string>

void init_openssl();
void cleanup_openssl();
SSL_CTX* create_context();
void cleanup(int server_fd, SSL_CTX* ctx, SSL* ssl);
SSL* connect_to_server(const std::string& server_ip, int server_port);

#endif // SSL_H
