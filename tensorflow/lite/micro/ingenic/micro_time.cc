/* Copyright 2020 The TensorFlow Authors. All Rights Reserved.
   Copyright 2024 Ingenic TFLite Micro port.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

// Ingenic MIPS implementation of micro_time for Linux

#include "tensorflow/lite/micro/micro_time.h"

#include <sys/time.h>
#include <stdint.h>

namespace tflite {

// Returns ticks per second (microseconds resolution)
uint32_t ticks_per_second() { return 1000000; }

// Returns current time in microseconds
uint32_t GetCurrentTimeTicks() {
  struct timeval tv;
  gettimeofday(&tv, nullptr);
  return (uint32_t)(tv.tv_sec * 1000000 + tv.tv_usec);
}

}  // namespace tflite
