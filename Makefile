# Define compiler
CXX=clang++

# Define compilation options
# -Isrc includes the src directory for header file search
CXXFLAGS=-std=c++17 -Wall -Isrc -pthread

# OpenSSL linking options
LDFLAGS=-lssl -lcrypto -pthread

# Target executable file
TARGET=bin/myproxy

# Source files
# Update the paths to reflect the new src directory location
SOURCES=src/myproxy.cc src/acl.cc src/log.cc src/ssl.cc

# Default target
all: $(TARGET)

# Make sure the bin directory exists
$(shell mkdir -p bin)

# Build rules
$(TARGET): $(SOURCES)
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS)

# Cleanup rules
clean:
	rm -f $(TARGET)
