// log.h
#ifndef LOG_H
#define LOG_H

#include <string>
#include <mutex>

extern std::string access_log_file_path;
extern std::mutex log_mutex;

void log_access(const std::string& client_ip, const std::string& request_line, int status_code, size_t response_size);
std::string current_time_formatted();

#endif // LOG_H