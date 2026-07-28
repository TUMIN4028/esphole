#!/usr/bin/env bash
# Tests de host de los módulos puros (research.md R3).
#
# IMPORTANTE (local): NO ejecutar con el entorno de ESP-IDF activado — su PATH
# antepone binutils cruzados sin prefijo (xtensa/riscv) y rompen al gcc del host
# ("as: unrecognized option '--64'"). En local usamos cmake/ninja/ctest de la
# instalación de IDF por ruta absoluta, con el PATH del sistema intacto.
#
# En CI (contenedor espressif/idf) esas rutas absolutas no existen: si no están,
# caemos a cmake/ninja/ctest del PATH — que ahí SÍ es el correcto (gcc del host,
# con IDF_PATH exportado para tomar Unity del árbol de ESP-IDF).
set -euo pipefail

IDF_ROOT="${HOME}/.espressif"
VENV_BIN="${IDF_ROOT}/tools/python/v6.0.1/venv/bin"
NINJA_IDF="${IDF_ROOT}/tools/ninja/1.12.1/ninja"
export IDF_PATH="${IDF_PATH:-${IDF_ROOT}/v6.0.1/esp-idf}"

# cmake/ctest: los del venv de IDF si están (local), si no los del PATH (CI).
if [ -x "${VENV_BIN}/cmake" ]; then
    CMAKE="${VENV_BIN}/cmake"
    CTEST="${VENV_BIN}/ctest"
else
    CMAKE="$(command -v cmake)"
    CTEST="$(command -v ctest)"
fi
# ninja: el binario dedicado de IDF si está (local), si no el del PATH (CI).
if [ -x "${NINJA_IDF}" ]; then
    NINJA="${NINJA_IDF}"
else
    NINJA="$(command -v ninja)"
fi

HERE="$(cd "$(dirname "$0")" && pwd)"
BUILD="${HERE}/build"

"${CMAKE}" -S "${HERE}" -B "${BUILD}" -G Ninja \
    -DCMAKE_MAKE_PROGRAM="${NINJA}" -DCMAKE_BUILD_TYPE=Debug
"${CMAKE}" --build "${BUILD}"
"${CTEST}" --test-dir "${BUILD}" --output-on-failure "$@"
