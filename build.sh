#!/usr/bin/env bash
# build.sh
set -e
dart pub get
mkdir -p build
dart compile exe bin/main.dart -o build/interpreter