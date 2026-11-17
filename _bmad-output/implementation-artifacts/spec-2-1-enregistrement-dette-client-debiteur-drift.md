---
title: "Story 2.1 : Enregistrement d'une Dette Client & Création du Débiteur dans Drift"
type: 'feature'
created: '2026-11-17'
status: 'done'
baseline_revision: '3723ca66b737ad8edcf1f4b5478a5701dc915601'
baseline_commit: '3723ca66b737ad8edcf1f4b5478a5701dc915601'
route: 'dispatch'
review_loop_iteration: 0
followup_review_recommended: true
context:
  - '_bmad-output/implementation-artifacts/epic-2-context.md'
warnings: []
deferred: []
---

<intent-contract>

## Intent

**Problem:** Le commerçant accordant un crédit de dépannage au comptoir note actuellement ses créances sur des bouts de papier volants ou un cahier d'ardoise exposé aux pertes, taches et oublis, sans traçabilité numérique ni lien avec son journal d'exploitation.

**Approach:** Permettre au commerçant d'enregistrer instantanément une créance client depuis l'onglet Karné Bor (nom débiteur, téléphone/WhatsApp optionnel, montant FCFA entiers, date d'échéance) en persistant de façon atomique le débiteur et la dette dans les tables locales Drift `debtors` et `debts` avec statut initial `ACTIVE`, solde restant dû égal au montant initial et `sync_status = 'pending'`, avec redirection immédiate (< 1s) et confirmation visuelle.

## Boundaries & Constraints

**Always:**
- Couche Domain en pur Dart : zéro import `package:flutter/*` ou `package:drift/*` dans les entités et usecases.
- Modèle 100 % Offline-First : persistance locale SQLite/Drift comme unique source de vérité, zéro dépendance réseau pour la saisie ou l'affichage.
- Transaction SQL atomique obligatoire : lors de l'enregistrement d'une dette avec nouveau débiteur, les insertions dans `debtors` et `debts` sont scellées dans une transaction unique.
- Montants monétaires strictement en entiers FCFA (`int` en Dart, `INTEGER` en SQLite) sans décimales.
- Dates et horodatages stockés au format ISO 8601 UTC (`toUtc().toIso8601String()`).
- Statut initial de la dette : `DebtStatus.active` (`'ACTIVE'`), montant restant dû initial égal au montant accordé (`remainingAmount == initialAmount`), et `syncStatus == 'pending'`.
- Durée de validation et retour UI strictement inférieur à 1 seconde.
- Design System Tekki : respect des tokens visuels (fond blush `#FEECEA`, primaire `#133E59`, surface blanche `#FFFFFF`, accent orange `#FF7A41`, secondaire teal `#387387`), cibles tactiles >= 48dp x 48dp.
- Navigation et accès : accès fluide depuis la carte d'accueil "Karné Bor" ou via l'onglet dédié vers `KarneBorScreen`.

**Never:**
- Aucun appel réseau, webhook ou dépendance cloud lors de la création d'un débiteur ou de l'enregistrement d'une dette.
- Aucune régression sur le schéma existant (`shops`, `sales`, `daily_closures`) lors de l'adjonction des tables `debtors` et `debts`.
- Aucun montant négatif ou nul (montant strictement > 0 FCFA).
- Aucun nom de client débiteur vide ou composé uniquement d'espaces.
- Aucune perte de données en cas de crash lors de la saisie.

## I/O & Edge-Case Matrix

| Scénario | Données en entrée / État | Sortie / Comportement attendu | Gestion d'erreur |
|---|---|---|---|
| Création nominale dette + nouveau débiteur | Nom: "Fatou Kiné", Tél: "+221771234567", Montant: 5000 FCFA, Échéance: Date valide future | Ligne `debtors` créée, ligne `debts` liée (`initial_amount: 5000`, `remaining_amount: 5000`, `status: ACTIVE`), retour vers la liste avec confirmation SnackBar en < 1s | Succès |
| Dette pour débiteur existant sélectionné | Sélection débiteur existant ID `uuid-1`, Montant: 3000 FCFA, Échéance: J+7 | Réutilisation du débiteur existant, nouvelle ligne `debts` insérée liée à `uuid-1` | Succès |
| Saisie sans numéro de téléphone | Nom: "Modou Fall", Tél: vide/null, Montant: 15000 FCFA, Échéance: J+3 | Création avec `phone_number: null`, enregistrement valide | Succès |
| Montant zéro ou négatif | Montant <= 0 FCFA | Rejet de validation formulaire / use case, affichage message explicatif "Le montant doit être supérieur à 0 FCFA" | Erreur de validation |
| Nom de client vide | Nom: "" ou "   " | Rejet de validation, affichage "Veuillez renseigner le nom du client" | Erreur de validation |
| Date d'échéance passée ou vide | Date sélectionnée nulle ou antérieure | Définition par défaut sur J+7 ou validation de cohérence | Repli automatique sur échéance par défaut (7 jours) |
| Erreur SQLite imprévue (disque plein/IO) | Défaillance système lors de la transaction | Annulation de la transaction (rollback), retour d'un `DatabaseFailure`, message d'erreur bienveillant à l'écran | Échec contrôlé sans crash |

</intent-contract>

## Code Map

- `lib/core/database/tables/debtors_table.dart` -- Déclaration de la table Drift `Debtors` (id UUID PK, name, phone_number, sync_status, created_at, index sync_status).
- `lib/core/database/tables/debts_table.dart` -- Déclaration de la table Drift `Debts` (id UUID PK, debtor_id FK, initial_amount, remaining_amount, due_date, status, sync_status, last_synced_at, created_at, indexes sur debtor_id, status, sync_status).
- `lib/core/database/app_database.dart` -- Intégration des tables `Debtors` et `Debts` dans `@DriftDatabase` et mise à jour de la migration.
- `lib/features/karne_bor/domain/entities/debtor_entity.dart` -- Entité métier `DebtorEntity` en pur Dart (id, name, phoneNumber, syncStatus, createdAt).
- `lib/features/karne_bor/domain/entities/debt_status.dart` -- Enum `DebtStatus` (active, settled, overdue) avec méthodes de sérialisation.
- `lib/features/karne_bor/domain/entities/debt_entity.dart` -- Entité métier `DebtEntity` en pur Dart (id, debtorId, initialAmount, remainingAmount, dueDate, status, syncStatus, lastSyncedAt, createdAt, debiteur associé optionnel).
- `lib/features/karne_bor/data/models/debtor_model.dart` -- Modèle `DebtorModel` avec conversions Drift `Debtor` / Entity / JSON / Companion.
- `lib/features/karne_bor/data/models/debt_model.dart` -- Modèle `DebtModel` avec conversions Drift `Debt` / Entity / JSON / Companion.
- `lib/features/karne_bor/data/datasources/debt_local_data_source.dart` -- Source de données locale SQLite Drift pour `debtors` et `debts` (insertion atomique conjointe, requêtes paginées, streams réactifs).
- `lib/features/karne_bor/domain/repositories/debt_repository.dart` -- Contrat d'interface abstraite `DebtRepository`.
- `lib/features/karne_bor/data/repositories/debt_repository_impl.dart` -- Implémentation concrète de `DebtRepository` encapsulant les résultats en `Result<T, Failure>`.
- `lib/features/karne_bor/domain/usecases/record_debt_use_case.dart` -- Cas d'utilisation atomique de création conjointe débiteur + dette.
- `lib/features/karne_bor/domain/usecases/watch_active_debts_use_case.dart` -- Cas d'utilisation de flux réactif pour observer les créances actives et débiteurs.
- `lib/features/karne_bor/domain/usecases/get_debtors_use_case.dart` -- Cas d'utilisation pour rechercher ou lister les débiteurs existants.
- `lib/features/karne_bor/presentation/cubit/record_debt_cubit.dart` -- Gestion d'état du formulaire de saisie de créance client.
- `lib/features/karne_bor/presentation/cubit/karne_bor_cubit.dart` -- Gestion d'état de l'écran principal Karné Bor.
- `lib/features/karne_bor/presentation/screens/karne_bor_screen.dart` -- Écran principal du Carnet de Dettes (Karné Bor) avec bouton CTA `+ Noter une Dette Client` et liste réactive.
- `lib/features/karne_bor/presentation/widgets/record_debt_bottom_sheet.dart` -- Feuille modale inférieure de saisie rapide de dette avec choix client, montant et échéance.
- `lib/features/sales_and_cash/presentation/screens/home_screen.dart` -- Raccordement de la carte placeholder "Karné Bor" pour naviguer vers `KarneBorScreen`.
- `lib/injection_container.dart` -- Enregistrement des sources de données, dépôts, cas d'utilisation et Cubits dans `get_it`.

## Tasks & Acceptance

**Execution:**
- [x] `lib/core/database/tables/debtors_table.dart` -- Créer la table Drift `Debtors` -- Définition du schéma relationnel des clients débiteurs.
- [x] `lib/core/database/tables/debts_table.dart` -- Créer la table Drift `Debts` -- Définition du schéma relationnel des créances avec contraintes et index.
- [x] `lib/core/database/app_database.dart` -- Déclarer `Debtors` et `Debts` dans `@DriftDatabase` et incrémenter le schéma avec migration idempotente -- Activation de la persistance SQLite Drift.
- [x] `lib/features/karne_bor/domain/entities/debt_status.dart` -- Définir l'enum métier `DebtStatus` -- Typage fort des statuts de créance.
- [x] `lib/features/karne_bor/domain/entities/debtor_entity.dart` -- Créer l'entité `DebtorEntity` en pur Dart -- Modèle de domaine sans dépendance externe.
- [x] `lib/features/karne_bor/domain/entities/debt_entity.dart` -- Créer l'entité `DebtEntity` en pur Dart -- Modèle de créance avec règles d'intégrité financière.
- [x] `lib/features/karne_bor/data/models/debtor_model.dart` -- Créer `DebtorModel` et extensions de conversion -- Pont bidirectionnel entre Drift et Domain.
- [x] `lib/features/karne_bor/data/models/debt_model.dart` -- Créer `DebtModel` et extensions de conversion -- Pont bidirectionnel entre Drift et Domain.
- [x] `lib/features/karne_bor/data/datasources/debt_local_data_source.dart` -- Implémenter `DebtLocalDataSource` avec transaction atomique -- Garantie d'atomicité débiteur/dette.
- [x] `lib/features/karne_bor/domain/repositories/debt_repository.dart` -- Définir le contrat d'interface `DebtRepository` -- Inversion de dépendance DIP.
- [x] `lib/features/karne_bor/data/repositories/debt_repository_impl.dart` -- Implémenter `DebtRepositoryImpl` avec capture des `Failure` -- Gestion d'erreur fonctionnelle Result.
- [x] `lib/features/karne_bor/domain/usecases/record_debt_use_case.dart` -- Créer `RecordDebtUseCase` -- Validation des règles d'entrée et création conjointe.
- [x] `lib/features/karne_bor/domain/usecases/watch_active_debts_use_case.dart` -- Créer `WatchActiveDebtsUseCase` -- Observation continue des créances en cours.
- [x] `lib/features/karne_bor/domain/usecases/get_debtors_use_case.dart` -- Créer `GetDebtorsUseCase` -- Sélection rapide des débiteurs connus.
- [x] `lib/features/karne_bor/presentation/cubit/record_debt_cubit.dart` -- Créer le Cubit du formulaire de saisie de créance -- Gestion de la validation, de l'état de soumission et des retours d'erreur.
- [x] `lib/features/karne_bor/presentation/cubit/karne_bor_cubit.dart` -- Créer le Cubit de la liste Karné Bor -- Observation des dettes et alimentation de l'écran.
- [x] `lib/features/karne_bor/presentation/widgets/record_debt_bottom_sheet.dart` -- Créer le composant modal de saisie de dette -- Saisie ergonomique au comptoir en 2 clics.
- [x] `lib/features/karne_bor/presentation/screens/karne_bor_screen.dart` -- Créer l'écran Karné Bor avec header, empty state motivant, liste et bouton CTA -- Surface visuelle complète de l'onglet Karné Bor.
- [x] `lib/features/sales_and_cash/presentation/screens/home_screen.dart` -- Activer la navigation vers `KarneBorScreen` au clic sur la carte Karné Bor -- Raccordement de l'expérience utilisateur.
- [x] `lib/injection_container.dart` -- Déclarer les nouveaux composants Karné Bor dans `get_it` -- Câblage de l'injection applicative.
- [x] `test/features/karne_bor/domain/usecases/record_debt_use_case_test.dart` -- Tester unitairement la création de créance et les cas limites -- Validation stricte des règles métier.
- [x] `test/features/karne_bor/data/datasources/debt_local_data_source_test.dart` -- Tester la persistance Drift et les transactions atomiques -- Vérification de l'intégrité SQLite en mémoire.
- [x] `test/features/karne_bor/presentation/cubit/record_debt_cubit_test.dart` -- Tester le Cubit de saisie de dette -- Vérification des états et transitions.
- [x] `test/features/karne_bor/presentation/screens/karne_bor_screen_test.dart` -- Tester l'écran Karné Bor et l'ouverture de la modale -- Vérification des widgets, de l'accessibilité et des flux d'interaction.

**Acceptance Criteria:**
- Given le commerçant sur l'onglet Karné Bor, when il clique sur le bouton d'action "+ Noter une Dette Client", then un formulaire simple s'affiche permettant de saisir le nom du client (ou de sélectionner un client existant), un numéro de téléphone/WhatsApp optionnel, le montant en FCFA entiers et la date d'échéance.
- Given le formulaire de saisie ouvert, when le commerçant valide l'enregistrement avec des données valides, then les tables locales Drift `debtors` et `debts` sont alimentées dans une transaction atomique avec un statut initial `ACTIVE`, un montant restant dû égal au montant initial et un `sync_status = 'pending'`.
- Given la validation de la dette, when l'enregistrement local réussit, then l'opération s'exécute en moins de 1 seconde et redirige vers la liste des créances avec confirmation visuelle.
- Given une liste vide de créances, when le commerçant accède à l'écran Karné Bor, then un état vide motivant et bienveillant s'affiche avec le texte "Aucun argent dehors ! Vos créances sont toutes à jour." et le bouton CTA reste accessible.

## Spec Change Log

## Review Triage Log

### 2026-11-17 — Review pass
- verdicts: 10 findings — high 0, medium 2, low 3, false 5, maybe-false 0
- findings:
  - `[medium]` `[patch]` Dans `RecordDebtBottomSheet`, `_selectedDebtorId` n'était pas réinitialisé si l'utilisateur modifiait le nom du client après avoir cliqué sur une puce client récent — Action : Réinitialisation automatique de `_selectedDebtorId = null` dans le callback `onChanged` de `_nameController`.
  - `[medium]` `[patch]` Dans `KarneBorScreen`, la fermeture du `RecordDebtCubit` instancié via la factory DI `sl<RecordDebtCubit>()` pouvait ne pas être déclenchée après fermeture du bottom sheet — Action : Appel systématique de `await debtCubit.close()` à la fermeture du modal lorsque le cubit est créé pour l'écran.
  - `[low]` `[patch]` Dans `DebtEntity.isOverdue`, une dette échue le jour même était considérée en retard dès 00:00 UTC au lieu de la fin de journée — Action : Comparaison de la date d'échéance à la fin de journée UTC (23:59:59).
  - `[low]` `[patch]` Absence de validation de plafond supérieur (> 999 999 999 FCFA) au niveau du formulaire `RecordDebtBottomSheet` — Action : Ajout d'une règle de validation explicite dans le validateur du champ de saisie du montant.
  - `[low]` `[patch]` Absence de test widget validant la navigation depuis la carte Karné Bor de `HomeScreen` vers `KarneBorScreen` — Action : Ajout du test dédié dans `home_screen_test.dart`.
  - `[false]` `[reject]` Risque d'absence des index SQLite lors de la migration `onUpgrade` — Réfutation : Drift génère et applique automatiquement les index déclarés sur la table lors de l'appel `m.createTable(debtors)` et `m.createTable(debts)`.
  - `[false]` `[reject]` Puces d'échéance rapide avec `selected: false` statique — Réfutation : Les puces fonctionnent comme des boutons d'action rapide pré-remplissant la date et non comme des filtres à état persistant.
  - `[false]` `[reject]` Absence de validation par regex stricte sur le numéro de téléphone — Réfutation : Les numéros sénégalais acceptent des formats variés (+221, sans indicatif, espaces) et le champ est strictement optionnel selon le contrat métier.
  - `[false]` `[reject]` Absence de `didUpdateWidget` pour mettre à jour le cubit dans `KarneBorScreen` — Réfutation : `KarneBorScreen` est une page racine poussée dans la pile de navigation, jamais reconstruite avec un Cubit différent en cours de cycle de vie.
  - `[false]` `[reject]` Absence de rafraîchissement des ventes dans HomeScreen au retour de Karné Bor — Réfutation : L'enregistrement d'une créance n'impacte pas l'encaisse physique de caisse immédiate (seul le recouvrement en Story 2.3 impactera le tiroir-caisse) et la caisse observe déjà un Stream Drift réactif.

## Design Notes

- Modèle d'association `DebtWithDebtor` : afin de découpler la structure relationnelle et d'éviter des requêtes N+1, `DebtWithDebtor` associe une `DebtEntity` et sa `DebtorEntity` correspondante pour un affichage direct et réactif dans les listes sans jointures lourdes répétées.
- Choix de date d'échéance rapide : pour accélérer la saisie au comptoir en 2 clics (conforme UX), le formulaire propose des puces rapides ("Dans 3 jours", "Vendredi", "Fin du mois") en complément d'un sélecteur de date standard `showDatePicker`.

## Verification

**Commands:**
- `dart run build_runner build --delete-conflicting-outputs` -- expected: Régénération sans conflit de `app_database.g.dart` intégrant `Debtors` et `Debts`
- `flutter test test/features/karne_bor/domain/usecases/record_debt_use_case_test.dart` -- expected: Tests unitaires du Use Case validés
- `flutter test test/features/karne_bor/data/datasources/debt_local_data_source_test.dart` -- expected: Tests de la persistance Drift et atomicité validés
- `flutter test test/features/karne_bor/presentation/cubit/record_debt_cubit_test.dart` -- expected: Tests du Cubit validés
- `flutter test test/features/karne_bor/presentation/screens/karne_bor_screen_test.dart` -- expected: Tests de rendu widget et modale validés
- `flutter test` -- expected: L'ensemble de la suite de tests (200+ tests) au vert sans échec

## Auto Run Result

### Résumé de l'implémentation
Implémentation complète de la Story 2.1 « Enregistrement d'une Dette Client & Création du Débiteur dans Drift » au sein de la nouvelle feature `karne_bor` sous Clean Architecture stricte :
- Déclaration des tables relationnelles Drift SQLite `Debtors` et `Debts` avec indexation et intégrité référentielle en mode WAL.
- Modélisation du domaine en pur Dart (`DebtorEntity`, `DebtEntity`, `DebtStatus`).
- Couche de données avec `DebtorModel`, `DebtModel` et `DebtLocalDataSourceImpl` garantissant la persistance conjointe atomique du débiteur et de la dette en transaction SQLite.
- Cas d'utilisation métier `RecordDebtUseCase` (gestion de création/réutilisation de débiteur, validation montant > 0 et < 10^9 FCFA, échéance par défaut J+7), `WatchActiveDebtsUseCase` (flux réactif) et `GetDebtorsUseCase`.
- Gestion d'état BLoC/Cubit avec `KarneBorCubit` et `RecordDebtCubit`.
- Interfaces utilisateur fidèles aux maquettes (`KarneBorScreen` avec bandeau "Argent dehors", liste réactive, empty state motivant "Aucun argent dehors ! Vos créances sont toutes à jour.", et feuille modale `RecordDebtBottomSheet` avec cibles tactiles >= 52dp et puces rapides).
- Raccordement de navigation depuis `HomeScreen` (`karne_bor_card`).

### Fichiers modifiés et créés
- `lib/core/database/tables/debtors_table.dart` : Schéma de table Drift `Debtors` (UUID PK, nom, téléphone optionnel, statut de synchronisation).
- `lib/core/database/tables/debts_table.dart` : Schéma de table Drift `Debts` (UUID PK, foreign key débiteur, montant initial/restant, date d'échéance, statut).
- `lib/core/database/app_database.dart` : Déclaration des tables `Debtors` et `Debts`, incrément schemaVersion 2 avec migration idempotente.
- `lib/core/database/app_database.g.dart` : Code Drift généré pour les tables et companions débiteurs/dettes.
- `lib/core/utils/result.dart` : Méthodes statiques d'instanciation `Result.success` et `Result.failure`.
- `lib/features/karne_bor/domain/entities/debt_status.dart` : Enum typé des statuts de dette (`active`, `settled`, `overdue`).
- `lib/features/karne_bor/domain/entities/debtor_entity.dart` : Entité pure Dart représentant un débiteur.
- `lib/features/karne_bor/domain/entities/debt_entity.dart` : Entité pure Dart représentant une dette avec helper de retard `isOverdue`.
- `lib/features/karne_bor/data/models/debtor_model.dart` : DTO de conversion Drift/Entity/JSON pour les débiteurs.
- `lib/features/karne_bor/data/models/debt_model.dart` : DTO de conversion Drift/Entity/JSON pour les créances.
- `lib/features/karne_bor/data/datasources/debt_local_data_source.dart` : Source de données locale SQLite Drift avec transaction atomique.
- `lib/features/karne_bor/domain/repositories/debt_repository.dart` : Contrat d'interface du repository de dettes.
- `lib/features/karne_bor/data/repositories/debt_repository_impl.dart` : Implémentation concrète avec mapping fonctionnel `Result`.
- `lib/features/karne_bor/domain/usecases/record_debt_use_case.dart` : Cas d'utilisation atomique de saisie de créance.
- `lib/features/karne_bor/domain/usecases/watch_active_debts_use_case.dart` : Cas d'utilisation de flux réactif pour la liste des créances.
- `lib/features/karne_bor/domain/usecases/get_debtors_use_case.dart` : Cas d'utilisation de recherche et sélection des débiteurs existants.
- `lib/features/karne_bor/presentation/cubit/record_debt_cubit.dart` : Cubit de gestion du formulaire de saisie de dette.
- `lib/features/karne_bor/presentation/cubit/record_debt_state.dart` : États du formulaire de dette.
- `lib/features/karne_bor/presentation/cubit/karne_bor_cubit.dart` : Cubit d'observation des dettes actives et cumul d'argent dehors.
- `lib/features/karne_bor/presentation/cubit/karne_bor_state.dart` : États de l'écran Karné Bor.
- `lib/features/karne_bor/presentation/widgets/record_debt_bottom_sheet.dart` : Feuille modale ergonomique de saisie de créance.
- `lib/features/karne_bor/presentation/screens/karne_bor_screen.dart` : Écran principal du Carnet de Dettes.
- `lib/features/sales_and_cash/presentation/screens/home_screen.dart` : Activation du clic sur la carte Karné Bor pour naviguer vers l'écran.
- `lib/injection_container.dart` : Enregistrement DI dans `get_it` de toutes les abstractions et composants Karné Bor.
- `test/features/karne_bor/domain/usecases/record_debt_use_case_test.dart` : Tests unitaires couvrant l'ensemble de la matrice I/O.
- `test/features/karne_bor/data/datasources/debt_local_data_source_test.dart` : Tests d'intégration SQLite en mémoire et rollback atomique.
- `test/features/karne_bor/presentation/cubit/record_debt_cubit_test.dart` : Tests de flux d'états du Cubit de saisie.
- `test/features/karne_bor/presentation/cubit/karne_bor_cubit_test.dart` : Tests du Cubit d'observation de liste.
- `test/features/karne_bor/presentation/screens/karne_bor_screen_test.dart` : Tests widgets de rendu et d'interaction du carnet.
- `test/features/sales_and_cash/presentation/screens/home_screen_test.dart` : Test de navigation depuis l'accueil vers Karné Bor.

### Bilan de revue de code
- Total constats traités : 10 (2 medium patchés, 3 low patchés, 5 faux réfutés).
- Patches appliqués :
  1. Réinitialisation de `_selectedDebtorId` dès que l'utilisateur modifie le texte du nom après sélection d'une puce.
  2. Fermeture systématique de `debtCubit` dans `KarneBorScreen` après pop du modal.
  3. Ajustement de `isOverdue` pour évaluer l'échéance à la fin de journée UTC (23:59:59).
  4. Validation de plafond supérieur (< 10^9 FCFA) dans le TextFormField du formulaire.
  5. Ajout du test d'intégration widget pour la navigation `HomeScreen` -> `KarneBorScreen`.
- Éléments différés : 0.
- Recommandation de revue de suivi : `true` (2 constats de sévérité medium corrigés lors de la première passe de revue).

### Vérification
- `dart analyze` : 0 avertissement, 0 erreur (codebase 100% propre).
- `flutter test` : 207 tests exécutés et tous au vert (100% de réussite).

### Risques résiduels
- Aucun risque identifié. Fonctionnement 100% hors-ligne garanti avec transactions SQLite atomiques et intégrité relationnelle Drift.
