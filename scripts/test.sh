#!/usr/bin/env bash
# Script d'execution optimisee de la suite de tests Tekki (<30s)
set -e

if [ "$1" == "--coverage" ]; then
  flutter test test/all_tests.dart --coverage
else
  flutter test test/all_tests.dart "$@"
fi
