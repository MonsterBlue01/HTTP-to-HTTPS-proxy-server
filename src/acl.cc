// acl.cc
#include "acl.hh"
#include <fstream>
#include <iostream>

using namespace std;

mutex acl_mutex;
unordered_set<string> acl;
string forbidden_sites_file_path;

void load_acl(const string& acl_file_path) {
    ifstream acl_file(acl_file_path);
    unordered_set<string> new_acl;
    string line;

    if (acl_file.is_open()) {
        while (getline(acl_file, line)) {
            new_acl.insert(line);
        }
        acl_file.close();

        lock_guard<mutex> guard(acl_mutex);
        acl.swap(new_acl);
    } else {
        cerr << "Unable to open ACL file: " << acl_file_path << endl;
    }
}

bool is_acl_blocked(const string& url) {
    lock_guard<mutex> guard(acl_mutex);
    return acl.find(url) != acl.end();
}

void signal_handler(int signum) {
    // Implementation for signal handling
    cout << "Reloading ACL file..." << endl;
    load_acl(forbidden_sites_file_path);
    cout << "ACL file reloaded." << endl;
}
