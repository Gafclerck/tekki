---
title: "Story 2.3: Encaissement de Remboursement & Réconciliation avec le Tiroir-Caisse"
type: 'feature'
created: '2026-11-17'
status: 'done'
baseline_revision: '1ec231563ed1fb7925b21448fe10c7d97dfb8071'
review_loop_iteration: 0
followup_review_recommended: false
context:
  - '_bmad-output/implementation-artifacts/epic-2-context.md'
warnings: []
deferred: []
---

<intent-contract>

## Intent

**Problem:** Lorsqu'un client débiteur vient rembourser tout ou partie de sa dette, le commerçant ne dispose d'aucun moyen in-app pour consigner l'encaissement, mettre à jour le solde restant dû de son ardoise et réconcilier automatiquement ce flux d'espèces avec le tiroir-caisse physique pour la clôture du soir.

**Approach:** Permettre depuis le bouton "✓ Encaisser" de chaque `DebtCard` d'ouvrir un dialogue d'encaissement proposant le règlement complet en 1 clic ou la saisie d'un acompte partiel en espèces, d'enregistrer atomiquement dans Drift l'encaissement dans `debt_payments`, de décrémenter le solde restant dû de la dette (statut `SETTLED` à solde nul), de consigner le montant perçu en espèces comme flux entrant dans le tiroir-caisse (`total_cash_debt_inflow` participant au calcul d'encaisse théorique), et de déclencher un retour sonore de tiroir-caisse et une vibration haptique brève.

## Boundaries & Constraints

**Always:**
- Clean Architecture 3 couches stricte : couche Domain en pur Dart (zéro import `package:flutter/*` ou `package:drift/*`), couche Data assurant la persistance SQLite Drift en mode WAL, couche Presentation observant via Cubit BLoC.
- Modèle 100 % Offline-First : SQLite/Drift comme unique source de vérité locale sans aucune dépendance réseau.
- Atomicité transactionnelle : l'insertion dans `debt_payments` et la mise à jour de la dette (`remaining_amount` et `status`) s'exécutent impérativement dans une seule transaction SQLite Drift via `database.transaction()`.
- Intégration Caisse-Dettes (AD-9) : tout encaissement en espèces consigne un flux entrant participant au calcul d'encaisse théorique (`Encaisse_Theorique = Ventes_Comptant_Especes + Remboursements_Dettes_Especes - Depenses_Especes`) et prérempli dans la clôture journalière via `total_cash_debt_inflow`.
- Respect du Design System Tekki : palette officielle (fond `#FEECEA`, primaire `#133E59`, surface `#FFFFFF`, accent `#FF7A41`, tertiaire `#8CB8C3`, secondaire `#387387`), cibles tactiles >= 48dp x 48dp, contraste WCAG AA.
- Célébration et feed-back sensoriel : retour sonore du tiroir-caisse via `IAudioPlayerService.playCashDrawerSound()` avec dégradation gracieuse en cas d'absence de haut-parleur, et vibration brève via `HapticFeedback.mediumImpact()`.
- Clôture atomique temporelle : lors de la clôture express journalière, les lignes `debt_payments` en espèces orphelines (non encore clôturées) créées avant le cutoff sont scellées avec le `closure_id` de la clôture.

**Never:**
- Aucun encaissement supérieur au solde restant dû (`payment_amount > remaining_amount`) ni montant inférieur ou égal à 0 FCFA.
- Aucun calcul bloquant sur le thread UI ni exclusion de la gestion des erreurs de saisie.
- Aucun blocage ou plantage de l'application si les retours audio ou haptiques échouent (interception silencieuse et tolérance de panne 100 %).
- Aucune dette au statut `SETTLED` ne doit subsister dans le flux des créances actives (`watchActiveDebts`).

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Règlement total en 1 clic | Dette active (solde 5 000 FCFA), clic sur "Régler le solde complet (5 000 FCFA)" | `debt_payments` inséré (5 000 FCFA, ESPECES), dette `remaining_amount = 0` et `status = SETTLED`, son tiroir-caisse + haptique, fermeture dialogue, rafraîchissement réactif | Rejet si transaction échoue, message d'erreur |
| Remboursement partiel (acompte) | Dette active (solde 10 000 FCFA), saisie d'un acompte de 4 000 FCFA | `debt_payments` inséré (4 000 FCFA, ESPECES), dette `remaining_amount = 6 000 FCFA`, statut inchangé (`ACTIVE` ou `OVERDUE`), son + haptique, mise à jour réactive immédiate | Validation en temps réel, désactivation du bouton si invalide |
| Saisie acompte supérieur au solde | Dette active (solde 5 000 FCFA), tentative de saisie 6 000 FCFA | Message d'erreur "Le montant ne peut pas dépasser le solde restant (5 000 FCFA)", bouton de validation désactivé | Garde synchrone UI et validation du use case rejetant avec `ValidationFailure` |
| Saisie acompte négatif ou nul | Saisie 0 FCFA ou vide | Bouton de validation désactivé, indicateur visuel | Désactivation du bouton de soumission |
| Réconciliation tiroir-caisse | Encaissement en espèces consigné | `ClosureLocalDataSource.getPrefillDebtCashInflow` somme les encaissements d'espèces non scellés, `ExpressClosureCubit` préremplit `totalCashDebtInflow`, participant à `theoreticalCash` | Pris en compte lors de l'exécution de la clôture journalière |
| Absence haut-parleur / vibreur | Périphérique sans son/vibreur | L'encaissement réussit parfaitement, l'absence matérielle est interceptée avec tolérance de panne | `try/catch` silencieux sans impact sur le résultat métier |

</intent-contract>

## Code Map

- `lib/core/database/tables/debt_payments_table.dart` -- Définition Drift de la table `debt_payments` (`id`, `debt_id`, `payment_amount`, `payment_method`, `closure_id`, `sync_status`, `last_synced_at`, `paid_at`) avec index SQLite.
- `lib/core/database/app_database.dart` -- Enregistrement de `DebtPayments`, migration `schemaVersion` vers 3 avec création de table `debt_payments`.
- `lib/features/karne_bor/domain/entities/debt_payment_entity.dart` -- Entité métier Dart pure représentant un paiement/remboursement de dette avec validations d'intégrité.
- `lib/features/karne_bor/data/models/debt_payment_model.dart` -- Modèle Data assurant la sérialisation bidirectionnelle entre `DebtPaymentEntity` et `DebtPayment` Drift.
- `lib/features/karne_bor/domain/repositories/debt_repository.dart` -- Déclaration de `recordDebtPayment(...)` et `getPaymentsByDebt(...)`.
- `lib/features/karne_bor/data/datasources/debt_local_data_source.dart` -- Transaction atomique SQLite : insertion `debt_payments`, décrément du solde `remaining_amount` de la dette, transition vers `SETTLED` à solde nul.
- `lib/features/karne_bor/data/repositories/debt_repository_impl.dart` -- Implémentation du repository encapsulant la datasource et traduisant les exceptions en `Failure`.
- `lib/features/karne_bor/domain/usecases/record_debt_payment_use_case.dart` -- Use case métier avec validation du montant (> 0, <= remainingAmount) et coordination de l'encaissement.
- `lib/features/sales_and_cash/data/datasources/closure_local_data_source.dart` -- Ajout du calcul de préremplissage des encaissements espèces de dettes orphelines et scellement lors de `executeDailyClosure`.
- `lib/features/sales_and_cash/domain/repositories/closure_repository.dart` & `closure_repository_impl.dart` -- Exposition du flux d'encaissements de dettes pour la clôture.
- `lib/features/sales_and_cash/presentation/cubit/express_closure_cubit.dart` -- Récupération et prise en compte de `totalCashDebtInflow` dans la clôture de caisse.
- `lib/features/karne_bor/presentation/cubit/collect_debt_payment_cubit.dart` & `collect_debt_payment_state.dart` -- Cubit BLoC gérant l'état du dialogue d'encaissement (solde complet, acompte, validation, feedback audio/haptique).
- `lib/features/karne_bor/presentation/widgets/collect_debt_payment_dialog.dart` -- Dialogue modal conforme au Design System avec choix solde complet 1-clic ou acompte, champs lisibles et boutons >= 48dp.
- `lib/features/karne_bor/presentation/widgets/debt_card.dart` -- Connexion du bouton "✓ Encaisser" au callback `onCollect`.
- `lib/features/karne_bor/presentation/screens/karne_bor_screen.dart` -- Intégration de l'ouverture du dialogue d'encaissement au tap sur "✓ Encaisser".
- `lib/injection_container.dart` -- Enregistrement de `RecordDebtPaymentUseCase` et `CollectDebtPaymentCubit` dans le conteneur de dépendances GetIt.

## Tasks & Acceptance

**Execution:**
- `lib/core/database/tables/debt_payments_table.dart` -- Create table -- Définir la table Drift `debt_payments` avec contraintes FK vers `debts`, colonne nullable `closure_id` et index SQLite.
- `lib/core/database/app_database.dart` -- Update schema -- Ajouter `DebtPayments` à `@DriftDatabase`, passer `schemaVersion` à 3 et migrer `onUpgrade`.
- `lib/features/karne_bor/domain/entities/debt_payment_entity.dart` -- Create entity -- Entité Dart pure représentant un paiement de dette avec validations strictes.
- `lib/features/karne_bor/data/models/debt_payment_model.dart` -- Create model -- Mappings `toEntity()`, `toCompanion()`, `fromJson()`, `toJson()`.
- `lib/features/karne_bor/domain/repositories/debt_repository.dart` -- Update contract -- Déclarer `recordDebtPayment` et `getPaymentsByDebt`.
- `lib/features/karne_bor/data/datasources/debt_local_data_source.dart` -- Implement payment data source -- Exécuter la transaction SQLite atomique (insertion paiement, mise à jour solde dette et statut).
- `lib/features/karne_bor/data/repositories/debt_repository_impl.dart` -- Implement repository method -- Encapsuler l'appel datasource et gérer les exceptions Drift.
- `lib/features/karne_bor/domain/usecases/record_debt_payment_use_case.dart` -- Create use case -- Valider l'acompte/solde, générer UUID v4, appeler le repository.
- `lib/features/sales_and_cash/data/datasources/closure_local_data_source.dart` -- Integrate debt inflows -- Ajouter `getPrefillDebtCashInflow` et sceller les remboursements espèces dans `executeDailyClosure`.
- `lib/features/sales_and_cash/domain/repositories/closure_repository.dart` & `closure_repository_impl.dart` -- Expose prefill -- Fournir `getPrefillDebtCashInflow` au domaine de clôture.
- `lib/features/sales_and_cash/presentation/cubit/express_closure_cubit.dart` -- Update closure cubit -- Intégrer les encaissements de dettes préremplis dans `totalCashDebtInflow`.
- `lib/features/karne_bor/presentation/cubit/collect_debt_payment_cubit.dart` & `collect_debt_payment_state.dart` -- Create cubit -- Gérer la sélection du mode, validation du montant, retour sonore et haptique.
- `lib/features/karne_bor/presentation/widgets/collect_debt_payment_dialog.dart` -- Create dialog -- Interface utilisateur ergonomique proposant solde complet en 1 clic ou saisie d'acompte avec boutons >= 48dp.
- `lib/features/karne_bor/presentation/widgets/debt_card.dart` -- Wire onCollect -- Déclencher `onCollect?.call()` sans afficher le SnackBar temporaire obsolète.
- `lib/features/karne_bor/presentation/screens/karne_bor_screen.dart` -- Wire screen dialog -- Afficher `CollectDebtPaymentDialog` sur tap du bouton "✓ Encaisser".
- `lib/injection_container.dart` -- Register DI -- Enregistrer `RecordDebtPaymentUseCase` et `CollectDebtPaymentCubit`.
- `test/features/karne_bor/data/datasources/debt_local_data_source_test.dart` -- Unit tests -- Valider la transaction atomique de paiement, le décrément du solde et la transition `SETTLED`.
- `test/features/karne_bor/domain/usecases/record_debt_payment_use_case_test.dart` -- Unit tests -- Valider les règles métier, montants négatifs/supérieurs au solde et génération UUID.
- `test/features/karne_bor/presentation/cubit/collect_debt_payment_cubit_test.dart` -- Unit tests cubit -- Valider les émissions d'états, le calcul du solde, l'appel audio et la vibration.
- `test/features/karne_bor/presentation/widgets/collect_debt_payment_dialog_test.dart` -- Widget tests -- Valider le rendu du dialogue, le bouton 1-clic solde complet, la saisie acompte et l'interaction.
- `test/features/sales_and_cash/closure_cash_reconciliation_test.dart` -- Integration tests -- Valider la réconciliation caisse : flux espèces consigné et intégré dans l'encaisse théorique.

**Acceptance Criteria:**
- Given une créance client active affichée sur une `DebtCard`, when le commerçant appuie sur le bouton "✓ Encaisser", then un dialogue d'encaissement modal s'affiche avec le nom du débiteur, le montant total restant dû, un bouton d'action 1-clic "Régler le solde complet (X FCFA)" et une option de saisie d'acompte partiel.
- Given le dialogue d'encaissement ouvert pour une créance de 5 000 FCFA, when le commerçant valide le règlement complet en 1 clic, then une ligne `debt_payments` de 5 000 FCFA est insérée, le solde restant dû de la créance passe à 0 FCFA, son statut devient `SETTLED`, un son de tiroir-caisse et une vibration haptique sont émis, le dialogue se ferme et la créance n'apparaît plus dans la liste des dettes actives du Karné Bor.
- Given le dialogue d'encaissement ouvert pour une créance de 10 000 FCFA, when le commerçant saisit un acompte partiel de 4 000 FCFA en espèces et valide, then une ligne `debt_payments` de 4 000 FCFA est insérée, le solde restant dû passe immédiatement à 6 000 FCFA, le statut reste actif/échue, le montant "Argent dehors" du carnet est réduit de 4 000 FCFA, et les retours sonore et haptique sont déclenchés.
- Given un ou plusieurs remboursements de créance encaissés en espèces durant la journée, when le commerçant ouvre l'écran de clôture express de caisse, then la somme perçue en espèces est préremplie dans `total_cash_debt_inflow` et s'additionne aux ventes au comptant dans le calcul de l'Encaisse Théorique (`totalSalesAmount + totalCashDebtInflow - totalExpensesAmount`), garantissant la concordance exacte du tiroir-caisse physique le soir.

## Spec Change Log

<!-- Append-only. Populated during review loops. -->

## Review Triage Log

### 2026-11-17 — Review pass
- verdicts: 14 findings — high 0, medium 0, low 5, false 9, maybe-false 0
- findings:
  - `[low]` `[reject]` BH-1: Absence de garde explicite si remainingAmount est nul à l'ouverture du dialogue — Le dialogue n'est accessible que depuis les dettes actives (non réglées) et `canSubmit` bloque tout montant <= 0.
  - `[low]` `[reject]` BH-2: Double-tap potentiel sur le bouton de règlement complet — `isSubmitting` désactive immédiatement les boutons et l'interaction.
  - `[low]` `[reject]` BH-3: Dimensionnement tactile des boutons du dialogue — Conforme aux directives WCAG avec des cibles >= 48dp et 52dp.
  - `[low]` `[reject]` BH-4: Configuration du clavier de saisie numérique d'acompte — `TextInputType.number` est correctement assigné.
  - `[false]` `[reject]` BH-5: Exceptions SQLite non interceptées lors de l'encaissement — Toutes les méthodes retournent un `Result` typé avec mapping explicite en `DatabaseFailure`.
  - `[false]` `[reject]` BH-6: Défaillance matérielle audio ou vibreur bloquant la transaction — Les retours audio et haptiques sont encapsulés dans des blocs try/catch avec dégradation gracieuse.
  - `[false]` `[reject]` BH-7: Somme SQL nulle sur table debt_payments vide — `result.read(sumColumn) ?? 0` renvoie 0 en l'absence de ligne.
  - `[false]` `[reject]` BH-8: Fuite temporelle de paiements après cutoff — Le filtrage SQL `paidAt <= cutoffIso` garantit une étanchéité temporelle stricte.
  - `[false]` `[reject]` BH-9: Null safety sur repository lors de l'init de clôture — Les appels sur `closureRepository` sont conditionnés par une garde non-null `if (closureRepository != null)`.
  - `[low]` `[reject]` BH-10: Sémantique d'accessibilité sur le CTA 1-clic — Un label `Semantics` explicite avec le montant et le nom est présent.
  - `[false]` `[reject]` ECH-1: Acompte saisi égal au solde exact restant — Le cas `amount == remainingAmount` est accepté et déclenche la transition vers `DebtStatus.settled`.
  - `[false]` `[reject]` ECH-2: Encaissements multiples successifs sur une même dette — Chaque paiement génère un UUID v4 unique et décrémente `remainingAmount`.
  - `[false]` `[reject]` ECH-3: Concurrence entre paiement et clôture — Les deux flux s'exécutent dans des transactions atomiques SQLite en mode WAL.
  - `[false]` `[reject]` ECH-4: Paiements hors espèces comptabilisés dans le tiroir-caisse — La requête SQL filtre strictement sur `payment_method = 'ESPECES'`.

## Auto Run Result

### Summary of Implemented Change
- **Database Layer:** Ajout de la table Drift `DebtPayments` (`id`, `debt_id`, `payment_amount`, `payment_method`, `closure_id`, `sync_status`, `last_synced_at`, `paid_at`) avec index SQLite dédiés et migration `schemaVersion: 3`.
- **Domain Layer:** Création de `DebtPaymentEntity` et `RecordDebtPaymentUseCase` validant les montants (> 0, <= solde restant), calculant le nouveau solde et passant le statut à `SETTLED` à solde nul.
- **Data Layer:** Implémentation atomique de `recordDebtPayment` dans `DebtLocalDataSourceImpl` et `DebtRepositoryImpl` assurant l'insertion du paiement et la mise à jour de la dette dans la même transaction SQLite.
- **Cash Reconciliation:** Intégration dans `ClosureLocalDataSourceImpl` du calcul des encaissements d'espèces orphelins via `getPrefillDebtCashInflow` et scellement atomique des paiements d'espèces avec `closure_id` lors de `executeDailyClosure`.
- **Closure State & Cubit:** Prise en compte de `totalCashDebtInflow` dans `ExpressClosureState` pour l'Encaisse Théorique (`totalSalesAmount + totalCashDebtInflow - totalExpensesAmount`) et soumission de clôture.
- **Presentation Layer:**
  - Création de `CollectDebtPaymentCubit` et `CollectDebtPaymentState` orchestrant le choix de règlement (1-clic solde complet vs acompte partiel), les retours sensoriels (son tiroir-caisse et vibration haptique) et la gestion d'erreur.
  - Création du widget `CollectDebtPaymentDialog` conforme au Design System Tekki avec cibles tactiles >= 48dp.
  - Raccordement du bouton "✓ Encaisser" de `DebtCard` et intégration de l'ouverture du dialogue d'encaissement dans `KarneBorScreen`.
- **Dependency Injection:** Enregistrement de `RecordDebtPaymentUseCase` et de la factory `CollectDebtPaymentCubit` dans `injection_container.dart`.
- **Comprehensive Testing:** Création et exécution de tests unitaires, BLoC/Cubit, widgets et réconciliation de caisse Drift couvrant l'ensemble des scénarios nominaux et aux limites.

### Files Changed
- `_bmad-output/implementation-artifacts/spec-2-3-encaissement-remboursement-reconciliation-tiroir-caisse.md`: Spécification de la Story 2.3 et résultats d'exécution.
- `lib/core/database/app_database.dart`: Enregistrement de `DebtPayments`, migration `schemaVersion: 3`.
- `lib/core/database/app_database.g.dart`: Génération du code Drift pour la table `DebtPayments`.
- `lib/core/database/tables/debt_payments_table.dart`: Définition de la table `DebtPayments` avec clés et index.
- `lib/features/karne_bor/data/datasources/debt_local_data_source.dart`: Méthodes `recordDebtPayment` et `getPaymentsByDebt`.
- `lib/features/karne_bor/data/models/debt_payment_model.dart`: Modèle de mapping bidirectionnel pour `DebtPayment`.
- `lib/features/karne_bor/data/repositories/debt_repository_impl.dart`: Implémentation de `recordDebtPayment` et `getPaymentsByDebt`.
- `lib/features/karne_bor/domain/entities/debt_payment_entity.dart`: Entité métier pure représentant un paiement de dette.
- `lib/features/karne_bor/domain/repositories/debt_repository.dart`: Contrat pour l'enregistrement et la lecture des paiements.
- `lib/features/karne_bor/domain/usecases/record_debt_payment_use_case.dart`: Cas d'utilisation d'encaissement avec validation et transition de statut.
- `lib/features/karne_bor/presentation/cubit/collect_debt_payment_cubit.dart`: Cubit gérant l'état du dialogue d'encaissement et le feedback sensoriel.
- `lib/features/karne_bor/presentation/cubit/collect_debt_payment_state.dart`: États immuables du processus d'encaissement.
- `lib/features/karne_bor/presentation/screens/karne_bor_screen.dart`: Câblage de l'ouverture du dialogue au tap sur "✓ Encaisser".
- `lib/features/karne_bor/presentation/widgets/collect_debt_payment_dialog.dart`: Dialogue modal ergonomique avec solde complet 1-clic et acompte.
- `lib/features/sales_and_cash/data/datasources/closure_local_data_source.dart`: Agrégation des remboursements espèces et scellement sur clôture.
- `lib/features/sales_and_cash/data/repositories/closure_repository_impl.dart`: Exposition de `getPrefillDebtCashInflow`.
- `lib/features/sales_and_cash/domain/repositories/closure_repository.dart`: Contrat pour `getPrefillDebtCashInflow`.
- `lib/features/sales_and_cash/presentation/cubit/express_closure_cubit.dart`: Intégration de `totalCashDebtInflow` dans la clôture.
- `lib/features/sales_and_cash/presentation/cubit/express_closure_state.dart`: Encaisse Théorique réconciliée avec les encaissements de dettes.
- `lib/injection_container.dart`: Enregistrement DI GetIt pour use case et cubit.
- `test/core/database/app_database_test.dart`: Vérification de l'enregistrement DI des nouveaux composants.
- `test/features/karne_bor/data/datasources/debt_local_data_source_test.dart`: Tests de la transaction atomique de paiement et transition `SETTLED`.
- `test/features/karne_bor/domain/usecases/record_debt_payment_use_case_test.dart`: Tests des règles de validation de montant et statuts.
- `test/features/karne_bor/presentation/cubit/collect_debt_payment_cubit_test.dart`: Tests unitaires du cubit, feedback sonore et haptique.
- `test/features/karne_bor/presentation/screens/karne_bor_screen_test.dart`: Test d'intégration de l'ouverture du dialogue d'encaissement.
- `test/features/karne_bor/presentation/widgets/collect_debt_payment_dialog_test.dart`: Tests widgets du dialogue (1-clic, acompte, validation).
- `test/features/sales_and_cash/closure_cash_reconciliation_test.dart`: Test d'intégration de réconciliation caisse-dettes en SQLite Drift.
- `test/features/sales_and_cash/presentation/cubit/express_closure_cubit_test.dart`: Test de la prise en compte du préremplissage d'encaissements dettes.

### Review Findings Breakdown
- **Patches Applied:** 0 findings nécessitant un patch (conception initiale rigoureuse et conforme).
- **Deferred:** 0 findings différés.
- **Rejected / False-Positive:** 14 findings (5 low sans impact fonctionnel, 9 false-positives réfutés par des preuves factuelles).
- **Follow-up Review Recommended:** `false`.

### Verification Outcomes
- `flutter test test/features/karne_bor/`: 54/54 tests passés avec succès.
- `flutter test test/features/sales_and_cash/`: 114/114 tests passés avec succès.
- `flutter test`: 238/238 tests passés avec succès (0 régression).
- `dart analyze`: Aucune erreur ni avertissement (`No issues found!`).

## Design Notes

- **Composant `CollectDebtPaymentDialog` :**
  - Modale au design épuré, surface blanche `#FFFFFF` avec coins arrondis 20px et fond d'assombrissement.
  - En-tête : "Encaisser un remboursement", avec nom du débiteur en gras (`AppColors.primary`) et solde actuel lisible en typographie display (`CurrencyFormatter.format(debt.remainingAmount)`).
  - Bouton 1-clic Prioritaire : Grand bouton mis en avant `AppColors.accent` avec libellé clair "Régler le solde complet (${CurrencyFormatter.format(debt.remainingAmount)})", hauteur >= 52dp.
  - Option Acompte Partiel : Séparateur "OU VERSER UN ACOMPTE", champ de saisie numérique formaté avec clavier adapté, contrôles de bornes dynamiques (erreur immédiate si montant > solde).
  - Bouton de validation d'acompte : Cible tactile >= 48dp, désactivé tant que la saisie est invalide.
- **Réconciliation Caisse-Dettes (AD-9) :**
  - La table `debt_payments` intègre une colonne `closure_id` nullable indexée.
  - Lors du préremplissage de clôture, les encaissements d'espèces dont `closure_id IS NULL` et `paid_at <= cutoffTimestamp` sont agrégés dans `totalCashDebtInflow`.
  - Lors de l'exécution de `executeDailyClosure`, ces encaissements sont scellés atomiquement avec l'identifiant de la clôture, exactement comme les ventes orphelines.

## Verification

**Commands:**
- `dart run build_runner build --delete-conflicting-outputs` -- expected: Génération propre des tables et requêtes Drift sans conflit.
- `flutter test test/features/karne_bor/` -- expected: L'ensemble des tests unitaires et widgets du carnet de dettes passent avec succès.
- `flutter test test/features/sales_and_cash/` -- expected: La suite de tests de vente et clôture de caisse passe sans régression avec la réconciliation des dettes.
- `flutter test` -- expected: Tous les tests du projet passent avec succès (zéro régression).
- `dart analyze` -- expected: Analyse statique propre sans aucun warning ni erreur.
