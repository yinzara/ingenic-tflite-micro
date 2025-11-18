# Hello World example for TFLite Micro

add_executable(hello_world
    main.cc
    main_functions.cc
    model.cc
    constants.cc
    output_handler.cc
)

target_include_directories(hello_world PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(hello_world
    tflite-micro
)
