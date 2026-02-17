cmake_minimum_required(VERSION 3.16)
project(MyApp)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ==============================
# WebAssembly config
# ==============================
if(EMSCRIPTEN)

    message(STATUS "Building for WebAssembly")

    set(CMAKE_EXECUTABLE_SUFFIX ".html")

    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}
        -O2
        -sUSE_SDL=2
        -sUSE_SDL_IMAGE=2
        -sALLOW_MEMORY_GROWTH=1
        -sWASM=1
        -sASSERTIONS=1
    ")

endif()

# ==============================
# Tìm toàn bộ source
# ==============================
file(GLOB_RECURSE APP_SOURCES
    ${CMAKE_SOURCE_DIR}/*.cpp
    ${CMAKE_SOURCE_DIR}/*.c
)

# Debug xem có tìm thấy file không
message(STATUS "Sources found: ${APP_SOURCES}")

if(NOT APP_SOURCES)
    message(FATAL_ERROR "❌ Không tìm thấy file source (.cpp / .c)")
endif()

# ==============================
# Build executable
# ==============================
add_executable(MyApp ${APP_SOURCES})

# Web chỉ cần SDL builtin
if(EMSCRIPTEN)
    target_link_libraries(MyApp PRIVATE SDL2)
endif()
