# Ingenic TFLite Micro

TensorFlow Lite Micro port for Ingenic MIPS32 SoCs (T31, T40, T41, etc.)

This is a port of [TensorFlow Lite Micro](https://github.com/tensorflow/tflite-micro) for embedded Linux systems running on Ingenic MIPS processors, modeled after [esp-tflite-micro](https://github.com/espressif/esp-tflite-micro).

## Features

- Optimized for Ingenic MIPS32r2 architecture (XBurst1)
- Builds as a static library for easy integration
- Includes signal processing library for audio/spectrogram features
- Reference kernel implementations (no hardware acceleration)
- No OS dependencies beyond standard C/C++ libraries

## Building

### With Buildroot (Recommended)

The easiest way to build is as a Buildroot external package:

1. Copy the package files to your Buildroot external tree:
   ```bash
   mkdir -p /path/to/your-external/package/ingenic-tflite-micro
   cp ingenic-tflite-micro.mk Config.in /path/to/your-external/package/ingenic-tflite-micro/
   ```

2. Add to your external tree's `Config.in`:
   ```
   source "$BR2_EXTERNAL_YOUR_NAME_PATH/package/ingenic-tflite-micro/Config.in"
   ```

3. Add to your external tree's `external.mk` (if not already present):
   ```
   include $(sort $(wildcard $(BR2_EXTERNAL_YOUR_NAME_PATH)/package/*/*.mk))
   ```

4. Enable in menuconfig:
   ```bash
   make menuconfig
   # Navigate to: External options -> ingenic-tflite-micro
   ```

5. Build:
   ```bash
   make ingenic-tflite-micro-rebuild
   ```

The library will be installed to `$(STAGING_DIR)/usr/lib/libtflite-micro.a` with headers in `$(STAGING_DIR)/usr/include/`.

### Standalone Cross-compilation

Prerequisites:
- CMake 3.10+
- Ingenic SDK toolchain (mips-linux-gnu-gcc 5.4+)

```bash
# Set toolchain path
export INGENIC_SDK=$HOME/github/Ingenic-SDK-T31-1.1.1-20200508

mkdir build && cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/mips-linux-gnu.cmake ..
make -j$(nproc)
```

### Native build (for testing on x86/ARM host)

```bash
mkdir build && cd build
cmake ..
make -j$(nproc)
```

## Usage

Link against `libtflite-micro.a` and include the headers:

```cpp
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
#include "tensorflow/lite/micro/system_setup.h"

// Initialize the runtime
tflite::InitializeTarget();

// Load model and create interpreter
const tflite::Model* model = tflite::GetModel(model_data);
tflite::MicroMutableOpResolver<10> resolver;
// Add needed ops...

tflite::MicroInterpreter interpreter(
    model, resolver, tensor_arena, kTensorArenaSize);
interpreter.AllocateTensors();

// Run inference
interpreter.Invoke();
```

### Signal Processing for Audio

For wake word detection, use the signal processing library:

```cpp
#include "signal/src/rfft.h"
#include "signal/src/filter_bank.h"
#include "signal/src/log.h"
```

## Supported Ingenic SoCs

- T31 series (T31L, T31N, T31X, T31A, T31AL, T31ZL, T31ZX)
- T21 series (T21L, T21N, T21X, T21Z)
- T23 series (T23N, T23ZN)
- T30 series (T30L, T30N, T30X, T30A)
- T40/T41 series (with appropriate toolchain)

## License

Apache 2.0 (same as TensorFlow)
