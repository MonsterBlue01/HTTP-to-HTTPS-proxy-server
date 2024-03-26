// log.cc
#include "log.hh"
#include <fstream>
#include <chrono>
#include <sstream>
#include <iomanip>
#include <iostream>

using namespace std;

mutex log_mutex;
string access_log_file_path;

// Normalized time format
string current_time_formatted() {
    auto now = chrono::system_clock::now();
    auto in_time_t = chrono::system_clock::to_time_t(now);

    stringstream ss;
    ss << put_time(gmtime(&in_time_t), "%Y-%m-%dT%H:%M:%S") << "Z";
    return ss.str();
}

// Record access log
void log_access(const string& client_ip, const string& request_line, int status_code, size_t response_size) {
    lock_guard<mutex> guard(log_mutex); // Ensure thread safety of log file writing
    
    ofstream log_file(access_log_file_path, ios::app); // Open log file
    if (log_file.is_open()) {
        // Write to log
        log_file << current_time_formatted() << " "
                 << client_ip << " \""
                 << request_line << "\" "
                 << status_code << " "
                 << response_size << endl;
        log_file.close();
    } else {
        cerr << "Unable to open log file." << endl;
    }
}