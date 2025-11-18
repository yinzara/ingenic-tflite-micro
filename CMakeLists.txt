cmake_minimum_required(VERSION 3.10)

project(ingenic-tflite-micro
    VERSION 1.0.0
    LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Options
option(BUILD_EXAMPLES "Build example applications" ON)
option(BUILD_TESTS "Build unit tests" OFF)

# TFLite Micro source directories
set(TFLITE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/tensorflow/lite")
set(TFMICRO_DIR "${TFLITE_DIR}/micro")
set(TFMICRO_KERNELS_DIR "${TFMICRO_DIR}/kernels")
set(TFMICRO_FRONTEND_DIR "${TFLITE_DIR}/experimental/microfrontend/lib")
set(SIGNAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/signal")
set(COMPILER_MLIR_DIR "${CMAKE_CURRENT_SOURCE_DIR}/tensorflow/compiler/mlir")

# Core TFLite Micro sources
set(SRCS_MICRO
    "${TFMICRO_DIR}/debug_log.cc"
    "${TFMICRO_DIR}/flatbuffer_utils.cc"
    "${TFMICRO_DIR}/memory_helpers.cc"
    "${TFMICRO_DIR}/micro_allocation_info.cc"
    "${TFMICRO_DIR}/micro_allocator.cc"
    "${TFMICRO_DIR}/micro_context.cc"
    "${TFMICRO_DIR}/micro_interpreter_context.cc"
    "${TFMICRO_DIR}/micro_interpreter_graph.cc"
    "${TFMICRO_DIR}/micro_interpreter.cc"
    "${TFMICRO_DIR}/micro_log.cc"
    "${TFMICRO_DIR}/micro_op_resolver.cc"
    "${TFMICRO_DIR}/micro_profiler.cc"
    "${TFMICRO_DIR}/micro_resource_variable.cc"
    "${TFMICRO_DIR}/micro_utils.cc"
    "${TFMICRO_DIR}/recording_micro_allocator.cc"
    "${TFMICRO_DIR}/system_setup.cc"
)

# Use Ingenic-specific micro_time implementation
list(APPEND SRCS_MICRO "${TFMICRO_DIR}/ingenic/micro_time.cc")

# TFLite bridge sources
file(GLOB SRCS_TFLITE_BRIDGE
    "${TFMICRO_DIR}/tflite_bridge/*.c"
    "${TFMICRO_DIR}/tflite_bridge/*.cc"
)

# Kernel sources (use reference implementations, not ESP NN)
file(GLOB SRCS_KERNELS
    "${TFMICRO_KERNELS_DIR}/*.c"
    "${TFMICRO_KERNELS_DIR}/*.cc"
)

# Remove ESP NN optimized kernels (we use reference implementations for MIPS)
file(GLOB ESP_NN_KERNELS "${TFMICRO_KERNELS_DIR}/esp_nn/*.cc")
list(LENGTH ESP_NN_KERNELS ESP_NN_COUNT)
if(ESP_NN_COUNT GREATER 0)
    list(REMOVE_ITEM SRCS_KERNELS ${ESP_NN_KERNELS})
endif()

# Micro frontend sources (for audio feature extraction)
file(GLOB SRCS_MICRO_FRONTEND
    "${TFMICRO_FRONTEND_DIR}/*.c"
    "${TFMICRO_FRONTEND_DIR}/*.cc"
)

# Signal processing sources
file(GLOB SIGNAL_MICRO_KERNELS
    "${SIGNAL_DIR}/micro/kernels/*.c"
    "${SIGNAL_DIR}/micro/kernels/*.cc"
)

file(GLOB SIGNAL_SRC
    "${SIGNAL_DIR}/src/*.c"
    "${SIGNAL_DIR}/src/*.cc"
)

set(SIGNAL_SRCS
    ${SIGNAL_MICRO_KERNELS}
    ${SIGNAL_SRC}
    "${SIGNAL_DIR}/src/kiss_fft_wrappers/kiss_fft_float.cc"
    "${SIGNAL_DIR}/src/kiss_fft_wrappers/kiss_fft_int16.cc"
    "${SIGNAL_DIR}/src/kiss_fft_wrappers/kiss_fft_int32.cc"
)

# Additional TFLite sources
set(SRCS_TFLITE_ADDITIONAL
    "${TFLITE_DIR}/kernels/kernel_util.cc"
    "${TFLITE_DIR}/micro/memory_planner/greedy_memory_planner.cc"
    "${TFLITE_DIR}/micro/memory_planner/linear_memory_planner.cc"
    "${TFLITE_DIR}/micro/arena_allocator/non_persistent_arena_buffer_allocator.cc"
    "${TFLITE_DIR}/micro/arena_allocator/persistent_arena_buffer_allocator.cc"
    "${TFLITE_DIR}/micro/arena_allocator/recording_single_arena_buffer_allocator.cc"
    "${TFLITE_DIR}/micro/arena_allocator/single_arena_buffer_allocator.cc"
    "${TFLITE_DIR}/core/c/common.cc"
    "${TFLITE_DIR}/core/api/flatbuffer_conversions.cc"
    "${TFLITE_DIR}/core/api/tensor_utils.cc"
    "${TFLITE_DIR}/kernels/internal/common.cc"
    "${TFLITE_DIR}/kernels/internal/quantization_util.cc"
    "${TFLITE_DIR}/kernels/internal/portable_tensor_utils.cc"
    "${TFLITE_DIR}/kernels/internal/tensor_utils.cc"
    "${TFLITE_DIR}/kernels/internal/tensor_ctypes.cc"
    "${TFLITE_DIR}/kernels/internal/reference/portable_tensor_utils.cc"
    "${TFLITE_DIR}/kernels/internal/reference/comparisons.cc"
    "${COMPILER_MLIR_DIR}/lite/core/api/error_reporter.cc"
    "${COMPILER_MLIR_DIR}/lite/schema/schema_utils.cc"
)

# Combine all sources
set(LIB_SRCS
    ${SRCS_MICRO}
    ${SRCS_KERNELS}
    ${SRCS_TFLITE_BRIDGE}
    ${SRCS_MICRO_FRONTEND}
    ${SIGNAL_SRCS}
    ${SRCS_TFLITE_ADDITIONAL}
)

# Create static library
add_library(tflite-micro STATIC ${LIB_SRCS})

# Include directories
target_include_directories(tflite-micro PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gemmlowp
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/flatbuffers/include
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/ruy
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/kissfft
)

# Compile definitions
target_compile_definitions(tflite-micro PUBLIC
    TF_LITE_STATIC_MEMORY
    TF_LITE_DISABLE_X86_NEON
)

# Common compile flags
set(COMMON_FLAGS
    -Wstrict-aliasing
    -Wno-unused-parameter
    -Wall
    -Wextra
    -Wvla
    -Wsign-compare
    -Wdouble-promotion
    -Wswitch
    -Wunused-function
    -Wmissing-field-initializers
    -ffunction-sections
    -fdata-sections
    -Wshadow
    -Wunused-variable
    -fno-unwind-tables
    -fmessage-length=0
)

# Apply compile options
target_compile_options(tflite-micro PRIVATE
    ${COMMON_FLAGS}
    -Wno-error=attributes
    -Wno-error=shadow
    -Wno-missing-field-initializers
    -Wno-error=sign-compare
    -Wno-error=double-promotion
    -Wno-type-limits
    -Wno-nonnull
    $<$<COMPILE_LANGUAGE:CXX>:
        -fno-rtti
        -fno-exceptions
        -fno-threadsafe-statics
        -Wno-return-type
        -Wno-strict-aliasing
    >
)

# Release optimization
target_compile_options(tflite-micro PRIVATE
    $<$<CONFIG:Release>:-O3>
)

# Link math library
target_link_libraries(tflite-micro PUBLIC m)

# Install
install(TARGETS tflite-micro
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(DIRECTORY tensorflow/
    DESTINATION include/tensorflow
    FILES_MATCHING PATTERN "*.h"
)

install(DIRECTORY third_party/
    DESTINATION include/third_party
    FILES_MATCHING PATTERN "*.h"
)

# Examples
if(BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

# Print configuration
message(STATUS "Ingenic TFLite Micro Configuration:")
message(STATUS "  Version: ${PROJECT_VERSION}")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "  CXX Compiler: ${CMAKE_CXX_COMPILER}")
