cmake_minimum_required(VERSION 4.1)
project(liblnm3 C)

set(CMAKE_C_STANDARD 23)

add_library(liblnm3 STATIC library.c)
