// acl.hh
#pragma once
#ifndef ACL_H
#define ACL_H

#include <string>
#include <unordered_set>
#include <mutex>

void load_acl(const std::string& acl_file_path);
bool is_acl_blocked(const std::string& url);
void signal_handler(int signum);

extern std::mutex acl_mutex;
extern std::unordered_set<std::string> acl;
extern std::string forbidden_sites_file_path;

#endif // ACL_H
