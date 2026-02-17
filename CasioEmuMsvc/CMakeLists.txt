cmake_minimum_required(VERSION 3.16)
project(MyApp)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ==========================================
# Nếu build bằng Emscripten (WebAssembly)
# ==========================================
if(EMSCRIPTEN)

    message(STATUS "Building for WebAssembly")

    # Tắt shared library hoàn toàn
    set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
    set(SDL_SHARED OFF CACHE BOOL "" FORCE)
    set(SDL_STATIC ON CACHE BOOL "" FORCE)
    set(SDL2IMAGE_SDL2_SHARED OFF CACHE BOOL "" FORCE)
    set(SDL2IMAGE_SDL2_STATIC ON CACHE BOOL "" FORCE)

    # Flags cho Web
    set(CMAKE_EXECUTABLE_SUFFIX ".html")

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}
        -sUSE_SDL=2
        -sUSE_SDL_IMAGE=2
        -sALLOW_MEMORY_GROWTH=1
        -sWASM=1
        -sFULL_ES2=1
    ")

endif()

# ==========================================
# Thêm source của bạn
# ==========================================
file(GLOB_RECURSE APP_SOURCES
    src/*.cpp
    src/*.c
)

add_executable(MyApp ${APP_SOURCES})

# ==========================================
# Link SDL (Web dùng builtin SDL của emscripten)
# ==========================================
if(EMSCRIPTEN)

    target_link_libraries(MyApp PRIVATE
        SDL2
    )

endif()
