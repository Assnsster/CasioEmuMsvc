cmake_minimum_required(VERSION 3.10)
project(CasioEmuMsvc)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# =========================
# Detect WebAssembly
# =========================
if(EMSCRIPTEN)
    message(STATUS "Building for WebAssembly")
    set(CMAKE_EXECUTABLE_SUFFIX ".html")
    add_definitions(-DWEB_BUILD)
    add_definitions(-DDISABLE_JIT)
endif()

# =========================
# asmjit (disable for web)
# =========================
if(NOT EMSCRIPTEN)
    set(ASMJIT_STATIC ON CACHE BOOL "" FORCE)
    set(ASMJIT_BUILD_TEST OFF CACHE BOOL "" FORCE)
    set(ASMJIT_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)

    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/asmjit/CMakeLists.txt")
        add_subdirectory(asmjit)
    endif()
endif()

# =========================
# Include directories
# =========================
include_directories(
    ${CMAKE_SOURCE_DIR}/CasioEmuMsvc
    ${CMAKE_SOURCE_DIR}/CasioEmuMsvc/Ext
    ${CMAKE_SOURCE_DIR}/CasioEmuMsvc/Dcl
    ${CMAKE_SOURCE_DIR}/CasioEmuMsvc/Chipset
    ${CMAKE_SOURCE_DIR}/CasioEmuMsvc/Containers
    ${CMAKE_SOURCE_DIR}/CasioEmuMsvc/Gui
    ${CMAKE_SOURCE_DIR}/CasioEmuMsvc/Gui/imgui
    ${CMAKE_SOURCE_DIR}/CasioEmuMsvc/GDB
    ${CMAKE_SOURCE_DIR}/CasioEmuMsvc/Peripheral
    ${CMAKE_SOURCE_DIR}/CasioEmuMsvc/StartupUi
)

# =========================
# Collect sources
# =========================
file(GLOB_RECURSE MAIN_SOURCES
    ${CMAKE_SOURCE_DIR}/CasioEmuMsvc/*.cpp
)

add_executable(CasioEmuMsvc ${MAIN_SOURCES})

# =========================
# Linking
# =========================

if(EMSCRIPTEN)

    target_link_libraries(CasioEmuMsvc PRIVATE
        SDL2::SDL2
        SDL2::image
    )

    target_link_options(CasioEmuMsvc PRIVATE
        "-sUSE_SDL=2"
        "-sUSE_SDL_IMAGE=2"
        "-sFULL_ES2=1"
        "-sFORCE_FILESYSTEM=1"
        "-sALLOW_MEMORY_GROWTH=1"
    )

else()

    find_package(SDL2 REQUIRED)
    find_package(SDL2_image REQUIRED)

    target_link_libraries(CasioEmuMsvc PRIVATE
        SDL2::SDL2
        SDL2::image
        asmjit::asmjit
        -lpthread
        -ldl
        -lrt
        -lm
    )

endif()
