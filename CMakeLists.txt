cmake_minimum_required(VERSION 3.17)
project(new_p2 C)

set(CMAKE_C_STANDARD 99)
SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -D_DEBUG")
add_executable(new_p2 main.c parser.y parser.tab.c)