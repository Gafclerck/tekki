---
title: 'Story 1.1 : Socle Applicatif, Thème Visuel Tekki & Persistance Locale Drift'
type: 'feature'
created: '2026-11-17'
status: 'done'
baseline_commit: '16682092be491149cce7b388fade9f88eedc88b7'
route: 'dispatch'
review_loop_iteration: 0
context:
  - '_bmad-output/implementation-artifacts/epic-1-context.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** L'application Tekki a besoin d'un socle technique robuste 100 % hors-ligne, comprenant l'identité visuelle officielle Tekki (thème blush chaleureux sans mode sombre), la structure Clean Architecture avec injection de dépendances découplée, et la persistance locale Drift SQLite configurée en mode WAL avec les tables initiales `shops` et `sales`.

**Approach:** Implémenter la base Drift `AppDatabase` avec les tables `shops` et `sales` indexées et les pragmas SQLite WAL/NORMAL, exposer les entités et modèles du domaine en pur Dart sans fuite de framework, enregistrer la persistance dans `get_it`, et verrouiller le thème visuel officiel sur `ThemeMode.light`.

## Boundaries & Constraints

**Always:**
- Couche `domain` en pur Dart : zéro import `package:flutter/*` et zéro import `package:drift/*`.
- Persistance locale SQLite/Drift comme unique source de vérité, configurée avec `PRAGMA journal_mode = WAL;` et `PRAGMA synchronous = NORMAL;`.
- Montants monétaires représentés en entiers stricts FCFA (`int` en Dart, `INTEGER` en SQLite) sans virgule flottante.
- Identifiants uniques universels au format UUID v4 (`String`) générés côté client.
- Index SQLite explicites sur les colonnes `closure_id` et `sync_status` de la table `sales`.
- Thème visuel verrouillé en permanence en mode clair (`ThemeMode.light`), fond blush `#FEECEA`, primaire `#133E59`, surface `#FFFFFF`, accent `#FF7A41`, tertiaire `#8CB8C3`.
- Cibles tactiles minimales de 48dp x 48dp (bouton primaire >= 52dp) et conformité WCAG AA sur fond blush.

**Never:**
- Aucun mode sombre : l'application ignore le réglage sombre du système d'exploitation.
- Aucun appel réseau ou dépendance externe requise pour le démarrage, la persistance locale ou la lecture des données.
- Aucune logique métier ou requête Drift directe au sein des widgets de présentation.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Ouverture initiale de la DB | Premier démarrage de l'app sur Android (API 26+) | Création des tables `shops` et `sales` avec pragmas WAL et NORMAL appliqués | Échec d'accès SQLite levé en `DatabaseFailure` typé via `Result` |
| Insertion d'une boutique | `ShopEntity` avec UUID v4, nom, ref_lat, ref_lng, cle_publique | Enregistrement persisté dans `shops` avec `sync_status = 'pending'` | Levée d'erreur si UUID dupliqué ou champ obligatoire manquant |
| Insertion d'une vente rapide | `SaleEntity` avec UUID v4, montant 5000 FCFA, mode `ESPECES`, recordedAt UTC | Ligne créée dans `sales` avec `closure_id = null` et `sync_status = 'pending'` | Montant négatif ou invalide rejeté au niveau de l'entité |
| Filtrage ventes orphelines par index | Requête sur `closure_id IS NULL` | Résultat instantané < 50ms utilisant l'index SQLite `sales_closure_id_idx` | Retourne liste vide si aucune vente non clôturée |
| Démarrage sous OS en Dark Mode | Terminal avec Dark Mode système activé | `MaterialApp` applique strictement `AppTheme.lightTheme` sans altération des couleurs | Aucun impact : `ThemeMode.light` forcé |

</frozen-after-approval>

## Code Map

- `lib/core/database/app_database.dart` -- Base de données centrale Drift (`AppDatabase`), configuration de connexion via `drift_flutter`, migration `onCreate`, pragmas `journal_mode = WAL` et `synchronous = NORMAL`.
- `lib/core/database/tables/shops_table.dart` -- Définition Drift de la table `shops` (`id`, `name`, `ref_latitude`, `ref_longitude`, `public_key`, `sync_status`, `created_at`).
- `lib/core/database/tables/sales_table.dart` -- Définition Drift de la table `sales` (`id`, `amount`, `payment_method`, `recorded_at`, `closure_id`, `sync_status`, `last_synced_at`) avec index sur `closure_id` et `sync_status`.
- `lib/core/database/connection/open_connection.dart` -- Factory de connexion Drift isolant la logique plateforme/tests (`drift_flutter` pour mobile, `NativeDatabase.memory()` pour tests unitaires).
- `lib/features/sales_and_cash/domain/entities/payment_method.dart` -- Enum pur Dart `PaymentMethod` (`especes`, `mobileMoney`, `creditClient`) avec conversion string normalisée.
- `lib/features/sales_and_cash/domain/entities/sale_entity.dart` -- Entité métier pure Dart `SaleEntity` (immutable avec `props` / equality).
- `lib/features/sales_and_cash/domain/entities/shop_entity.dart` -- Entité métier pure Dart `ShopEntity` (immutable avec `props` / equality).
- `lib/features/sales_and_cash/data/models/sale_model.dart` -- DTO / Mapper entre la classe générée Drift `Sale` et l'entité métier `SaleEntity`.
- `lib/features/sales_and_cash/data/models/shop_model.dart` -- DTO / Mapper entre la classe générée Drift `Shop` et l'entité métier `ShopEntity`.
- `lib/features/sales_and_cash/data/datasources/sales_local_data_source.dart` -- Contrat et implémentation de la source de données locale Drift pour les ventes et la boutique.
- `lib/injection_container.dart` -- Enregistrement de `AppDatabase` et des data sources dans le conteneur `get_it`.
- `lib/app.dart` -- Application du thème clair exclusif (`themeMode: ThemeMode.light`).
- `test/core/database/app_database_test.dart` -- Tests unitaires en mémoire de la base Drift (création tables, index, pragmas, opérations CRUD).
- `test/core/theme/app_theme_test.dart` -- Tests unitaires vérifiant les tokens de couleurs, les contrastes, la typographie et le verrouillage clair.

## Tasks & Acceptance

**Execution:**
- [x] `lib/core/database/tables/shops_table.dart` -- Création de la table Drift `shops` -- Permet de persister les métadonnées et coordonnées de référence du point de vente.
- [x] `lib/core/database/tables/sales_table.dart` -- Création de la table Drift `sales` avec index sur `closure_id` et `sync_status` -- Permet d'enregistrer les ventes unitaires avec performance d'agrégation garantie.
- [x] `lib/core/database/connection/open_connection.dart` -- Création de la stratégie d'ouverture Drift -- Fournit la connexion mobile WAL via `drift_flutter` et permet l'injection de DB en mémoire pour les tests.
- [x] `lib/core/database/app_database.dart` -- Implémentation de `AppDatabase` étendant `_$AppDatabase` -- Configure les pragmas WAL/NORMAL et regroupe les tables de l'Epic 1.
- [x] `lib/features/sales_and_cash/domain/entities/payment_method.dart` -- Définition de l'enum pur Dart `PaymentMethod` -- Spécifie les modes de paiement sans dépendance externe.
- [x] `lib/features/sales_and_cash/domain/entities/sale_entity.dart` -- Implémentation de l'entité pure Dart `SaleEntity` -- Modèle immuable pour la manipulation des ventes dans le Domain.
- [x] `lib/features/sales_and_cash/domain/entities/shop_entity.dart` -- Implémentation de l'entité pure Dart `ShopEntity` -- Modèle immuable pour la boutique dans le Domain.
- [x] `lib/features/sales_and_cash/data/models/sale_model.dart` -- Création du modèle et des extensions de mapping `Sale` <-> `SaleEntity` -- Isole la persistance Drift du domaine.
- [x] `lib/features/sales_and_cash/data/models/shop_model.dart` -- Création du modèle et des extensions de mapping `Shop` <-> `ShopEntity` -- Isole la table `shops` du domaine.
- [x] `lib/features/sales_and_cash/data/datasources/sales_local_data_source.dart` -- Implémentation de `SalesLocalDataSource` -- Encapsule les requêtes Drift pour les ventes et la boutique.
- [x] `lib/injection_container.dart` -- Enregistrement de `AppDatabase` et `SalesLocalDataSource` dans `get_it` -- Assure la disponibilité des services au démarrage.
- [x] `lib/app.dart` -- Ajout explicite de `themeMode: ThemeMode.light` -- Empêche l'application de basculer en mode sombre selon l'OS.
- [x] `test/core/database/app_database_test.dart` -- Tests unitaires complets de la base de données Drift -- Valide les contraintes d'intégrité, index, WAL et CRUD.
- [x] `test/core/theme/app_theme_test.dart` -- Tests unitaires du thème et des tokens -- Valide la conformité visuelle et l'absence de mode sombre.

**Acceptance Criteria:**
- Given une installation fraîche de l'application sur un terminal Android (API 26+), when l'application démarre pour la première fois, then le socle Clean Architecture s'initialise via get_it avec zéro dépendance Flutter dans la couche domain.
- Given le démarrage de l'application, when le thème est appliqué, then les tokens officiels Tekki (fond blush #FEECEA, primaire #133E59, surface #FFFFFF, accent #FF7A41) sont appliqués et l'application reste en mode clair même si le système est en mode sombre.
- Given l'ouverture de la base de données SQLite locale, when la connexion est établie, then les pragmas journal_mode = WAL et synchronous = NORMAL sont activés.
- Given la base de données locale, when le schéma est initialisé, then les tables `shops` et `sales` existent, et la table `sales` possède des index sur `closure_id` et `sync_status`.

## Implementation Notes

- Socle Clean Architecture initialisé avec persistance Drift SQLite (mode WAL et synchronous NORMAL) et thème officiel Tekki (mode clair exclusif).
- Tables Drift `shops` et `sales` créées avec index sur `closure_id` et `sync_status`.
- Entités pures Dart `ShopEntity`, `SaleEntity` et `PaymentMethod` sans import Flutter ni Drift.
- Correctifs de révision appliqués : séparation stricte de type entre DTOs et entités, validation des bornes géographiques, rejet des closureId vides, activation de `PRAGMA foreign_keys = ON`, pagination avec offset et tests unitaires étendus (34 tests au vert).

## Spec Change Log

## Review Triage Log

| Finding | Verdict | Evidence / Resolution |
| :--- | :--- | :--- |
| `SaleModel.toEntity() / ShopModel.toEntity()` retournent `this` | medium | Corrigé par patch : instanciation d'entités réelles `SaleEntity` et `ShopEntity` évitant le mismatch `runtimeType` dans Equatable. |
| Validation des coordonnées géographiques `ShopEntity` ([-90, 90] / [-180, 180] et NaN) | low | Corrigé par patch : contrôles stricts ajoutés dans le constructeur avec levée d'ArgumentError. |
| Validation de `closureId` dans `SaleEntity` (chaîne vide / whitespace) | low | Corrigé par patch : rejet des chaînes non-nulles vides pour préserver la détection SQLite `IS NULL`. |
| Normalisation systématique en UTC pour `ShopEntity` et `SaleEntity` | low | Corrigé par patch : appel de `.toUtc()` sur tous les horodatages à l'instanciation des entités. |
| Validation `limit <= 0` et support `offset` dans `SalesLocalDataSource` | low | Corrigé par patch : validation stricte `limit > 0` et ajout de `offset` optionnel. |
| Ajout de `PRAGMA foreign_keys = ON;` dans `AppDatabase.beforeOpen` | low | Corrigé par patch : intégrité référentielle SQLite activée pour toutes les connexions. |
| Index dupliqués dans `onCreate` de `AppDatabase` | low | Corrigé par patch : suppression des customStatement redondants déjà pris en charge par `m.createAll()`. |
| Robustesse de typage `json['amount']` dans `SaleModel.fromJson` | low | Corrigé par patch : cast `(json['amount'] as num).toInt()`. |
| Test tautologique de pragma dans `app_database_test.dart` | low | Corrigé par patch : assertion directe sur les pragmas de la connexion sans re-exécution manuelle. |
| Tests unitaires d'égalité et de conformité DTO / entité | low | Corrigé par patch : tests unitaires ajoutés et validés dans la suite de tests (34 tests au vert). |
| Contraste WCAG AA sur `button-primary-cta` (`#FF7A41` sur `#FFFFFF`) | false | Rejeté : conforme à la spécification normative DESIGN.md qui prescrit expressément background: {colors.accent} et color: #FFFFFF. |
| Index sur `recorded_at` ou composite `(closure_id, recorded_at)` | false | Rejeté : hors périmètre Story 1.1; les index de clôture relèvent de la Story 1.4. |
| Méthodes de mutation et batch dans `SalesLocalDataSource` | false | Rejeté : hors périmètre Story 1.1; les opérations de clôture consolidée relèvent de la Story 1.4. |
| `syncStatus` modélisé en String libre | false | Rejeté : conforme aux critères d'acceptation de la Story 1.1 et à l'architecture spine; Outbox détaillée en Epic 4. |
| `PaymentMethod.displayName` dans le domaine | false | Rejeté : getter utilitaire inoffensif sans dépendance externe. |
| Couverture Material 3 incomplète (`bottomSheetTheme`, etc.) | false | Rejeté : hors périmètre Story 1.1; les composants de formulaire et pavé numérique relèvent de la Story 1.2. |

## Design Notes

La configuration des pragmas SQLite sur Drift s'effectue dans le callback `beforeOpen` de `MigrationStrategy` :
```dart
beforeOpen: (details) async {
  await customStatement('PRAGMA journal_mode = WAL;');
  await customStatement('PRAGMA synchronous = NORMAL;');
}
```
Les index sur `sales` sont déclarés dans la classe de table Drift :
```dart
@override
List<Set<Column>> get uniqueKeys => [];

@override
List<Index> get indexes => [
  Index('sales_closure_id_idx', 'CREATE INDEX IF NOT EXISTS sales_closure_id_idx ON sales (closure_id);'),
  Index('sales_sync_status_idx', 'CREATE INDEX IF NOT EXISTS sales_sync_status_idx ON sales (sync_status);'),
];
```

## Verification

**Commands:**
- `dart run build_runner build --delete-conflicting-outputs` -- expected: Génération sans erreur des classes Drift `app_database.g.dart`.
- `flutter test test/core/database/app_database_test.dart` -- expected: Tous les tests de persistance Drift passent (WAL, CRUD, index).
- `flutter test test/core/theme/app_theme_test.dart` -- expected: Tous les tests de thème passent.
- `flutter test` -- expected: Ensemble de la suite de tests au vert (0 failure).
- `flutter analyze` -- expected: 0 warnings, 0 errors.
