<!-- bmad:context -->
<!-- Verified 2026-11-17 against c5b7ccf. Managed by bmad-project-context; edits inside this block are replaced on refresh. Keep anything you want preserved outside the markers. -->

## tekki

Application mobile Flutter de gestion commerciale, carnet de dettes (Karné Bor) et passeport financier pour commerçants d'Afrique de l'Ouest. Clean Architecture feature-first, Offline-First Outbox, Drift SQLite locale (WAL).

## Policy

- Branches : `develop` pour l'intégration, `feat/*` pour les fonctionnalités, PR obligatoire vers `develop`.
- Commits : Conventional Commits stricts (`feat:`, `fix:`, `refactor:`, `test:`, `chore:`).
- Zéro dépendance vers Flutter, Drift ou réseau dans la couche `domain/` (Dart pur uniquement).
- Pas de nombres flottants pour l'argent : montants toujours en entiers FCFA (`int amount`), jamais de `double`.

## Where things are

- Modules métier sous `lib/features/` : `sales_and_cash/`, `karne_bor/`, `financial_passport/`, `advisor/`, `sync/`.
- Fondations transverses sous `lib/core/` : `database/` (Drift), `theme/`, `utils/` (formattage FCFA, Result), `services/` (Audio, Location, WhatsApp).
- Injection de dépendances GetIt sous `lib/injection_container.dart`.
- Helpers de tests partagés sous `test/helpers/` : `mocks.dart`, `fixtures.dart`, `pump_helpers.dart`.
- Suite complète de tests sous `test/all_tests.dart`.

## Running and verifying

- **RÈGLE OBLIGATOIRE DE TESTS** : TOUJOURS exécuter `flutter test test/all_tests.dart` au lieu de `flutter test` brut.
  - Justification : `flutter test` sans argument compile et démarre 37 VM indépendantes (~3 min 30s). `flutter test test/all_tests.dart` exécute tous les 268 tests en un seul isolate en ~18 à 30 secondes (gain de 90%).
- **Ajout de nouveaux tests** : Dès qu'un nouveau fichier `*_test.dart` est créé, il DOIT obligatoirement être importé et invoqué dans `test/all_tests.dart`.
- **Test unitaire ciblé** : Pendant le développement d'une fonctionnalité spécifique, tester uniquement son fichier : `flutter test test/chemin/vers/fichier_test.dart`.
- **Analyse statique et formatage** : `flutter analyze` et `dart format --output=none --set-exit-if-changed .` doivent être strictement à 0 erreur avant tout commit.

## Conventions that differ from defaults

- Réutiliser les Mocks partagés de `test/helpers/mocks.dart` et les fixtures de `test/helpers/fixtures.dart` au lieu de redéclarer des mocks dupliqués.
- Toujours isoler `GetIt` dans les tests de widgets en ajoutant `addTearDown(() async => await sl.reset());` dans `setUp()`.
- Utiliser `tester.pumpTekkiWidget(myWidget)` de `test/helpers/pump_helpers.dart` pour injecter automatiquement le thème officiel `AppTheme.lightTheme` et le Scaffold.

## Known pitfalls

- Ne jamais lancer `flutter test` sans cible sous peine de bloquer la boucle de feedback pendant plus de 3 minutes.
- `registerFallbackValue` de Mocktail ne doit être appelé qu'une seule fois par type, idéalement dans `setUpAll()`.
- En cas de merge, toujours vérifier l'absence totale de marqueurs de conflit (`git grep -n "<<<<<<<"`) et exécuter `flutter test test/all_tests.dart` avant de pousser.

<!-- /bmad:context -->
