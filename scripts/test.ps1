# Script d'execution optimisee de la suite de tests Tekki (<30s)
param(
    [switch]$Coverage
)

if ($Coverage) {
    flutter test test/all_tests.dart --coverage
} else {
    flutter test test/all_tests.dart
}
