# goertzel

[![CI](https://github.com/pbosetti/goertzel/actions/workflows/ci.yml/badge.svg)](https://github.com/pbosetti/goertzel/actions/workflows/ci.yml)

`goertzel` is a small multi-language package around the Goertzel algorithm.

The project keeps the original R package entry point and now also exposes:

- a general-purpose header-only C++ analyzer in `inst/include/goertzel/goertzel.hpp`
- a C wrapper in `inst/include/goertzel/goertzel_c.h`
- a Python extension module
- a CMake build with a noisy DTMF key `6` regression test

## R

The R package interface is unchanged.

Install from a checkout with:

```r
install.packages(".", repos = NULL, type = "source")
```

Or from GitHub with:

```r
devtools::install_github("pbosetti/goertzel")
```

Use it exactly as before:

```r
library(goertzel)

signal <- sin(2 * pi * 6 * (0:127) / 128)
goertzel(signal, 6)
```

## C++

The reusable core is header-only. With CMake, either add this repository with `add_subdirectory(...)`
or `FetchContent_MakeAvailable(...)`, then link `goertzel::goertzel`.

```cmake
FetchContent_Declare(
  goertzel
  GIT_REPOSITORY https://github.com/ktrask/goertzel.git
  GIT_TAG main
)
FetchContent_MakeAvailable(goertzel)

target_link_libraries(your_target PRIVATE goertzel::goertzel)
```

Example:

```cpp
#include "goertzel/goertzel.hpp"

#include <vector>

int main() {
  std::vector<double> signal = {1.0, 0.0, -1.0, 0.0};
  Goertzel::Analyzer analyzer({Goertzel::Analyzer::alpha_from_bin(1.0, signal.size())});
  analyzer.process(signal);
  const auto value = analyzer.dft_term_from_bin(0, 1.0, signal.size());
  return value.real() != 0.0;
}
```

## Python

Build the extension with CMake:

```sh
cmake -S . -B build -DGOERTZEL_BUILD_PYTHON=ON
cmake --build build
```

The resulting module is named `goertzel`. Import it from the build directory that contains the
compiled module:

```python
import goertzel

samples = [0.0, 1.0, 0.0, -1.0] * 32
values = goertzel.goertzel_frequencies(samples, [770.0, 1477.0], 8000.0)
print(values)
```

## C

Link against `goertzel::goertzel_c` and include `goertzel/goertzel_c.h`.

```c
#include "goertzel/goertzel_c.h"

int main(void) {
  double alpha[1] = {goertzel_alpha_from_bin(6.0, 128)};
  goertzel_analyzer_t *analyzer = goertzel_analyzer_create(alpha, 1);
  double samples[128] = {0.0};
  goertzel_analyzer_process_buffer(analyzer, samples, 128);
  goertzel_analyzer_destroy(analyzer);
  return 0;
}
```

## CMake Build And Test

Configure and build:

```sh
cmake -S . -B build
cmake --build build
```

Run the C++ test suite:

```sh
ctest --test-dir build --output-on-failure
```

The test executable checks that a noisy DTMF signal is classified as key `6` by detecting the
`770 Hz` and `1477 Hz` tones.
