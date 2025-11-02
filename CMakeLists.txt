cmake_minimum_required(VERSION 3.15)
project(DEXTradingEngine VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Compiler flags
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -pedantic")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -march=native")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -O0")
endif()

# Include directories
include_directories(${PROJECT_SOURCE_DIR}/cpp/include)

# Source files
set(SOURCES
    cpp/src/OrderBook.cpp
    cpp/src/MatchingEngine.cpp
)

# Create library
add_library(dex_engine STATIC ${SOURCES})

# Main executable
add_executable(dex_demo cpp/src/main.cpp)
target_link_libraries(dex_demo dex_engine pthread)

# Install targets
install(TARGETS dex_engine dex_demo
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY cpp/include/
    DESTINATION include/dex
    FILES_MATCHING PATTERN "*.hpp"
)

# Print build information
message(STATUS "=== DEX Trading Engine Build Configuration ===")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ Compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "Install prefix: ${CMAKE_INSTALL_PREFIX}")
