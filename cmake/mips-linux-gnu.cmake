# CMake toolchain file for Ingenic MIPS32 cross-compilation
# Usage: cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/mips-linux-gnu.cmake ..

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR mips)

# Ingenic SDK toolchain path - adjust this to your installation
# Can be set via -DINGENIC_TOOLCHAIN_PATH=... or INGENIC_TOOLCHAIN_PATH env var
if(NOT DEFINED INGENIC_TOOLCHAIN_PATH)
    if(DEFINED ENV{INGENIC_TOOLCHAIN_PATH})
        set(INGENIC_TOOLCHAIN_PATH "$ENV{INGENIC_TOOLCHAIN_PATH}")
    else()
        # Default path for Ingenic SDK T31
        set(INGENIC_TOOLCHAIN_PATH "$ENV{PWD}/../Ingenic-SDK-T31-1.1.1-20200508/toolchain/mips-gcc540-glibc222-64bit-r3.3.0")
    endif()
endif()

set(TOOLCHAIN_PREFIX "mips-linux-gnu-")

# Cross compiler
set(CMAKE_C_COMPILER "${INGENIC_TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}gcc")
set(CMAKE_CXX_COMPILER "${INGENIC_TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}g++")
set(CMAKE_AR "${INGENIC_TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}ar")
set(CMAKE_RANLIB "${INGENIC_TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}ranlib")
set(CMAKE_STRIP "${INGENIC_TOOLCHAIN_PATH}/bin/${TOOLCHAIN_PREFIX}strip")

# Sysroot - use little-endian variant for -EL flag
set(CMAKE_SYSROOT "${INGENIC_TOOLCHAIN_PATH}/mips-linux-gnu/libc/el")
set(CMAKE_FIND_ROOT_PATH "${CMAKE_SYSROOT}")

# Search paths
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# MIPS32 specific flags for Ingenic T31 (XBurst1)
# -march=mips32r2: Target MIPS32 Release 2 instruction set
# -mtune=mips32r2: Optimize for MIPS32R2
# -msoft-float: Use software floating point (optional, depends on FPU availability)
set(CMAKE_C_FLAGS_INIT "-march=mips32r2 -mtune=mips32r2 -EL")
set(CMAKE_CXX_FLAGS_INIT "-march=mips32r2 -mtune=mips32r2 -EL")

# Additional optimization flags
set(CMAKE_C_FLAGS_RELEASE_INIT "-O3 -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "-O3 -DNDEBUG")
