cmake_minimum_required(VERSION 3.15)
project(DeveloperReputationSystem VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Compiler flags
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -pedantic")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")
endif()

# Include directories
include_directories(${PROJECT_SOURCE_DIR}/cpp/include)

# Source files
set(SOURCES
    cpp/src/ReputationCalculator.cpp
)

# Create library
add_library(reputation_lib STATIC ${SOURCES})

# Demo executable
add_executable(reputation_demo cpp/src/demo.cpp)
target_link_libraries(reputation_demo reputation_lib)

# Install
install(TARGETS reputation_lib reputation_demo
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

message(STATUS "=== Developer Reputation System ===")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ Standard: ${CMAKE_CXX_STANDARD}")
