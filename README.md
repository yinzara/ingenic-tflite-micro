# Ingenic TFLite Micro

TensorFlow Lite Micro port for Ingenic MIPS32 SoCs (T31, T40, etc.)

This is a port of [TensorFlow Lite Micro](https://github.com/tensorflow/tflite-micro) for embedded Linux systems running on Ingenic MIPS processors, modeled after [esp-tflite-micro](https://github.com/espressif/esp-tflite-micro).

## Features

- Optimized for Ingenic MIPS32 architecture
- Builds as a static library for easy integration
- Includes audio frontend for speech features (from ESPMicroSpeechFeatures)
- No OS dependencies beyond standard C/C++ libraries

## Building

### Prerequisites

- CMake 3.10+
- Ingenic SDK toolchain (mips-linux-gnu-gcc)

### Cross-compilation

```bash
mkdir build && cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/mips-linux-gnu.cmake ..
make -j$(nproc)
```

### Native build (for testing)

```bash
mkdir build && cd build
cmake ..
make -j$(nproc)
```

## Usage

Link against `libtflite-micro.a` and include the headers:

```c
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
```

## License

Apache 2.0 (same as TensorFlow)
