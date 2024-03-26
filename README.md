# README for Web Proxy

## Project Overview
This project is a TCP-based proxy server project. It has a blacklist to block prohibited websites that clients try to access. At the same time, the client's HTTP request is sent to the server in encrypted form by establishing an HTTPS connection with the server. Then the response from the server is finally returned to the client in the form of HTTP.

## Notice:
I don't have as many test files as in lab 4 for this project, because this project is not about file transfer. So this time I only have a shell script for testing in src/.