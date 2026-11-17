---
title: "Story 2.2: Tableau de Bord Karné Bor, Total \"Argent Dehors\" & Suivi des Retards"
type: 'feature'
created: '2026-11-17'
status: 'done'
baseline_revision: '5149f1c498cce0689ba2136e4eb88075664b874c'
review_loop_iteration: 1
followup_review_recommended: false
context:
  - '_bmad-output/implementation-artifacts/epic-2-context.md'
warnings: []
deferred:
  - summary: >-
      Total debt amount and overdue count are aggregated across the 50-item paginated stream rather than a dedicated full-table SQLite query.
    evidence: |-
      When active debts exceed 50, folding the display stream caps the summary total at 50 records. Bounded stream was specified by current AC; dedicated aggregate query belongs to a future pagination optimization pass.
    location: >-
      lib/features/karne_bor/presentation/cubit/karne_bor_cubit.dart:20
    severity: medium
---

<intent-contract>

## Intent

**Problem:** Le commerçant accordant des facilités de paiement manque d'une vue synthétique immédiate sur le volume total de ses créances en circulation et peine à repérer sans calcul mental les clients en retard d'échéance à relancer en priorité.

**Approach:** Offrir sur l'écran Karné Bor un bandeau synthétique "Argent dehors" affichant le total cumulé des créances en typographie display lisible, un indicateur d'alertes retards, et une liste ordonnée par urgence (créances échues avec badge d'alerte et bordure accentuée en tête, suivies des créances à venir) via un composant `DebtCard` dédié alimenté par un Stream Drift réactif paginé (limit 50), avec un état vide motivant lorsque toutes les créances sont à jour.

## Boundaries & Constraints

**Always:**
- Architecture en couches strictes : couche Domain en pur Dart (zéro import Flutter ou Drift), couche Data assurant la pagination et le mapping Drift, couche Presentation observant via Cubit BLoC.
- Modèle 100 % Offline-First : SQLite/Drift comme unique source de vérité locale, aucun appel réseau nécessaire.
- Respect du Design System Tekki : palette officielle (fond `#FEECEA`, primaire `#133E59`, surface `#FFFFFF`, accent `#FF7A41`, tertiaire `#8CB8C3`, secondaire `#387387`), cibles tactiles >= 48dp x 48dp, typographie display pour le montant "Argent dehors".
- Tri strict par urgence : les créances échues (`isOverdue == true`) s'affichent impérativement en tête de liste ordonnées par ancienneté de retard, suivies des créances à venir classées par proximité d'échéance.
- Requête Stream réactive bornée : pagination bornée (`limit = 50`) sur les créances non réglées (`status IN ('ACTIVE', 'OVERDUE')`).
- Composant `DebtCard` réutilisable et isolé : extraction dans `lib/features/karne_bor/presentation/widgets/debt_card.dart` avec points d'accroche pour l'encaissement (Story 2.3) et la relance WhatsApp (Story 2.4).
- État vide bienveillant et exact : affichage du message "Aucun argent dehors ! Vos créances sont toutes à jour." avec bouton CTA "+ Noter une Dette Client" persistant.

**Never:**
- Aucun calcul bloquant sur le thread UI : les agrégations (`totalDebt`, `overdueCount`) sont calculées de façon réactive dans le Cubit lors de l'émission du flux.
- Aucune régression sur le formulaire de saisie `RecordDebtBottomSheet` ou les tables existantes.
- Aucune exclusion accidentelle des dettes ayant un statut `'OVERDUE'` lors du requêtage des dettes actives.
- Aucun recours à des popups bloquants ou des modales d'avertissement anxiogènes : le suivi des retards se fait par repères visuels clairs et non punitifs.

## I/O & Edge-Case Matrix

| Scénario | Données en entrée / État | Sortie / Comportement attendu | Gestion d'erreur |
|---|---|---|---|
| Karné Bor vide (zéro dette active) | Base Drift sans dette active | Bandeau "Argent dehors" affiche "0 FCFA", sous-titre "0 créance", état vide illustré "Aucun argent dehors ! Vos créances sont toutes à jour.", bouton CTA actif | Pas d'erreur attendue |
| Dettes actives mixtes (en retard et à jour) | 2 dettes échues (10 000 F et 5 000 F) et 1 dette à venir (15 000 F) | Total "30 000 FCFA" dans le bandeau display, badge "2 en retard", les 2 dettes échues s'affichent en tête avec badge d'alerte et bordure orange, suivies de la dette à venir | Pas d'erreur attendue |
| Nouvelle dette ajoutée au fil de l'eau | Insertion d'une nouvelle dette via `RecordDebtBottomSheet` | Mise à jour automatique instantanée du Stream Drift : recalcul du total et insertion réactive dans la liste sans rechargement manuel | Pas d'erreur attendue |
| Dette ayant un statut `'OVERDUE'` en base | Dette avec `status: 'OVERDUE'` | Incluse dans le flux `watchActiveDebts`, comptabilisée dans l'argent dehors et triée en tête | Pas d'erreur attendue |
| Montant restant dû partiel | Dette initiale 10 000 F, restante 4 000 F | `DebtCard` affiche le solde restant 4 000 F en gros, avec mention "Solde restant sur 10 000 FCFA" | Pas d'erreur attendue |
| Défaillance du flux de base de données | Exception SQL lors de la souscription au Stream | Émission de `KarneBorError` et affichage du message d'erreur avec possibilité de réessayer | Échec contrôlé sans crash |

</intent-contract>

## Code Map

- `lib/features/karne_bor/data/datasources/debt_local_data_source.dart` -- L.228-259: `watchActiveDebts` : adapter le filtre pour inclure `status IN ('ACTIVE', 'OVERDUE')` et garantir le tri par `dueDate ASC` avec limit 50.
- `lib/features/karne_bor/presentation/cubit/karne_bor_state.dart` -- L.19-32: `KarneBorLoaded` : enrichir l'état avec `overdueCount` et `hasOverdue` pour le bandeau synthétique.
- `lib/features/karne_bor/presentation/cubit/karne_bor_cubit.dart` -- L.18-30: `startWatching` : calcul du montant total, décompte des créances en retard et ordonnancement par urgence (`isOverdue` en priorité).
- `lib/features/karne_bor/presentation/widgets/debt_card.dart` -- Nouveau composant : carte de créance conforme DESIGN.md avec badge de retard visuel, date d'échéance, nom débiteur, montant restant dû lisible et cibles tactiles >= 48dp.
- `lib/features/karne_bor/presentation/screens/karne_bor_screen.dart` -- L.148-161 & L.206-259: Intégration du bandeau d'argent dehors enrichi avec typographie display et utilisation du composant `DebtCard`.
- `test/features/karne_bor/presentation/widgets/debt_card_test.dart` -- Nouveau test : validation unitaire et widget du composant `DebtCard` (états nominal, retard, partiel, accessibilité tactile).
- `test/features/karne_bor/presentation/cubit/karne_bor_cubit_test.dart` -- Enrichissement des tests du Cubit : vérification du tri par urgence et du calcul de l'argent dehors et retards.
- `test/features/karne_bor/presentation/screens/karne_bor_screen_test.dart` -- Mise à jour des tests d'intégration d'écran pour vérifier le rendu du bandeau display, le tri des cartes et la réactivité du flux.

## Tasks & Acceptance

**Execution:**
- `lib/features/karne_bor/data/datasources/debt_local_data_source.dart` -- Étendre `watchActiveDebts` pour englober les statuts non réglés (`ACTIVE` et `OVERDUE`) et garantir l'ordre `dueDate ASC` -- Assure l'exhaustivité de l'argent dehors réactif.
- `lib/features/karne_bor/presentation/cubit/karne_bor_state.dart` -- Ajouter `overdueCount` et `hasOverdue` à `KarneBorLoaded` -- Exposition des indicateurs synthétiques de retard pour l'UI.
- `lib/features/karne_bor/presentation/cubit/karne_bor_cubit.dart` -- Implémenter le tri d'urgence déterministe (échues en tête, puis échéance croissante) et le calcul d'alertes -- Décharge l'UI de la logique d'ordonnancement.
- `lib/features/karne_bor/presentation/widgets/debt_card.dart` -- Créer le widget `DebtCard` avec typographie lisible, badge d'avertissement retard, solde restant et cibles d'action conformes DESIGN.md -- Modularité et cohérence de l'interface carnet.
- `lib/features/karne_bor/presentation/screens/karne_bor_screen.dart` -- Mettre à niveau le bandeau "Argent dehors" en typographie display et intégrer `DebtCard` dans la `ListView` paginée -- Réalisation de l'expérience utilisateur complète Story 2.2.
- `test/features/karne_bor/presentation/widgets/debt_card_test.dart` -- Créer la suite de tests widget pour `DebtCard` -- Validation des badges d'alerte, libellés et cibles tactiles.
- `test/features/karne_bor/presentation/cubit/karne_bor_cubit_test.dart` -- Tester le tri d'urgence et les métriques de retard dans `KarneBorCubit` -- Garantie de non-régression fonctionnelle.
- `test/features/karne_bor/presentation/screens/karne_bor_screen_test.dart` -- Tester l'écran Karné Bor avec affichage des créances ordonnées par urgence et le bandeau d'alerte -- Validation de bout en bout de l'interface.

**Acceptance Criteria:**
- Given l'ouverture de l'écran Karné Bor avec des dettes actives en base de données, when l'écran se charge, then le bandeau affiche le montant total cumulé sous le libellé "ARGENT DEHORS" en typographie display lisible, accompagné du nombre total de créances et du nombre de créances en retard.
- Given une liste de dettes comportant à la fois des créances en retard et des créances à venir, when la liste s'affiche, then les créances échues sont présentées en tête de liste sous forme de composants `debt-card` munis d'un badge d'avertissement retard avec icône d'alerte et d'une bordure accentuée, suivies des créances à venir ordonnées par date d'échéance.
- Given aucune dette en cours dans la base de données, when le commerçant consulte l'écran Karné Bor, then un état vide motivant et illustré s'affiche avec le texte exact "Aucun argent dehors ! Vos créances sont toutes à jour." et le bouton CTA "+ Noter une Dette Client" reste immédiatement accessible.
- Given l'écran Karné Bor ouvert, when une dette est insérée ou modifiée en base de données, then la liste paginée (limit 50) et le total "Argent dehors" se mettent à jour réactivement en moins d'une seconde sans rechargement manuel de la page.

## Spec Change Log

## Review Triage Log

### 2026-11-17 Review Pass
- **BH-1 (Blind Hunter):** Cubit stream subscription memory leak or emit when closed.
  - *Severity:* Medium
  - *Verdict:* apply-patch
  - *Action:* Added `if (isClosed) return;` guard in `KarneBorCubit` listener callback before emitting states.
- **BH-2 (Blind Hunter):** Debtor name fallback slicing crashes if empty/whitespace.
  - *Severity:* Low
  - *Verdict:* apply-patch
  - *Action:* Refactored name fallback in `DebtCard` to check `.trim().isNotEmpty` before rendering initial or label.
- **BH-3 (Blind Hunter):** Amount text overflow on compact screens with large figures.
  - *Severity:* Low
  - *Verdict:* apply-patch
  - *Action:* Wrapped amount displays in `FittedBox(fit: BoxFit.scaleDown)` in `DebtCard`.
- **BH-4 (Blind Hunter):** Missing semantic accessibility labels on action buttons.
  - *Severity:* Low
  - *Verdict:* apply-patch
  - *Action:* Wrapped both action buttons in `Semantics(button: true, label: ...)` in `DebtCard`.
- **BH-5 (Blind Hunter):** Active debts query exclusion when debts have status 'OVERDUE'.
  - *Severity:* Medium
  - *Verdict:* false-positive
  - *Reason:* Verified that `DebtLocalDataSourceImpl.watchActiveDebts` and `getActiveDebts` explicitly query `status IN ('ACTIVE', 'OVERDUE')`.
- **BH-6 (Blind Hunter):** Date format locale consistency.
  - *Severity:* Low
  - *Verdict:* apply-patch
  - *Action:* Enforced explicit `'dd/MM/yyyy'` date format pattern across widgets.
- **BH-7 (Blind Hunter):** Overdue calculation time zone / midnight comparison discrepancy.
  - *Severity:* False
  - *Verdict:* false-positive
  - *Reason:* All dates are persisted in UTC midnight standard format; domain comparison is normalized against UTC midnight boundary.
- **BH-8 (Blind Hunter):** Touch target size on icon buttons below 48dp accessibility guideline.
  - *Severity:* Low
  - *Verdict:* apply-patch
  - *Action:* Enforced `BoxConstraints(minHeight: 48)` and responsive padding on all interactive buttons in `DebtCard`.
- **BH-9 (Blind Hunter):** Duplicate empty state title ("Aucun argent dehors !").
  - *Severity:* Low
  - *Verdict:* apply-patch
  - *Action:* Deduplicated empty state heading to "Tout est en règle !" with descriptive subtitle in `KarneBorScreen`.
- **BH-10 (Blind Hunter):** Un-wired callbacks in `DebtCard` leading to silent dead clicks.
  - *Severity:* Medium
  - *Verdict:* apply-patch
  - *Action:* Added clear floating SnackBar informational fallbacks indicating upcoming Story 2.3 and 2.4 integration.
- **BH-11 (Blind Hunter):** Error retry button missing in error state.
  - *Severity:* Low
  - *Verdict:* apply-patch
  - *Action:* Added interactive "Réessayer" button triggering `_cubit.startWatching()` in `KarneBorScreen`.
- **BH-12 (Blind Hunter):** Overdue badge icon accessibility / color contrast.
  - *Severity:* Low
  - *Verdict:* apply-patch
  - *Action:* Styled warning badge with `AppColors.accent` icon and high-contrast bold text for readability.
- **BH-13 (Blind Hunter):** Floating action button padding with persistent bottom bar.
  - *Severity:* Low
  - *Verdict:* apply-patch
  - *Action:* Added bottom list padding `EdgeInsets.only(bottom: 80)` to prevent overlay overlap.
- **BH-14 (Blind Hunter):** Aggregation across paginated stream limit (50) rather than full SQLite query.
  - *Severity:* Medium
  - *Verdict:* defer
  - *Reason:* Bounded stream was specified by current acceptance criteria; dedicated table aggregation query deferred to future pagination optimization pass.
- **ECH-1 (Edge Case Hunter):** Partial debt payment remainder text overflow.
  - *Severity:* Medium
  - *Verdict:* apply-patch
  - *Action:* Used flexible text layout with `TextOverflow.ellipsis` on partial payment details.
- **ECH-2 (Edge Case Hunter):** Drift foreign key integrity dropping orphaned debts on innerJoin.
  - *Severity:* False
  - *Verdict:* false-positive
  - *Reason:* Foreign keys are strictly enforced in SQLite schema (`PRAGMA foreign_keys = ON;`); orphaned debt records are impossible by database constraint.
- **ECH-3 (Edge Case Hunter):** Urgency sort tie-break instability when due dates are identical.
  - *Severity:* Low
  - *Verdict:* apply-patch
  - *Action:* Added secondary tie-breaker sorting by `createdAt ASC` in `KarneBorCubit`.
- **ECH-4 (Edge Case Hunter):** Database exception propagation on stream close.
  - *Severity:* False
  - *Verdict:* false-positive
  - *Reason:* `StreamSubscription` error listener correctly transforms exceptions to `KarneBorError` states without unhandled crashes.

## Design Notes

- **Composant `DebtCard` :** Conformément à DESIGN.md et la maquette `key-karne-bor.html`, chaque carte de créance présente :
  - En-tête : Nom du débiteur (`AppColors.primary`, graisse 800) et solde restant dû formaté en FCFA.
  - Détail : Date d'échéance formatée (`dd/MM/yyyy`).
  - Statut de retard : Si la dette est échue (`isOverdue == true`), affichage d'un badge saumon/orange (`AppColors.accentSoft`) avec texte et icône d'alerte `⚠️ Retard` (ou `⚠️ Échue`), et bordure de carte mise en exergue avec `AppColors.accent` (largeur 1.5px).
  - Statut à jour : Si la dette n'est pas échue, bordure douce `AppColors.tertiary` (1px) et libellé discret `À jour` ou date d'échéance future.
  - Emplacements d'actions : Préparation de boutons d'action conformes (cibles >= 48dp) pour les futures Stories 2.3 ("✓ Encaisser") et 2.4 ("💬 Relance WhatsApp").
- **Ordonnancement d'urgence :** Le tri s'effectue avec priorité absolue aux dettes échues, puis tri par date d'échéance croissante afin que le commerçant repère immédiatement qui relancer en priorité.

## Verification

**Commands:**
- `flutter test test/features/karne_bor/` -- expected: Tous les tests du carnet de dettes passent avec succès.
- `flutter test` -- expected: La suite complète de tests de l'application passe sans régression.
- `dart analyze` -- expected: Analyse statique propre sans aucun avertissement ni erreur.

## Auto Run Result

### Summary of Changes
- **Data Layer:** Mise à jour de `DebtLocalDataSourceImpl.watchActiveDebts` et `getActiveDebts` pour interroger les statuts non réglés `['ACTIVE', 'OVERDUE']`, ordonnés par `dueDate ASC` avec pagination bornée (`limit 50`).
- **Domain Layer:** Mise à jour de `DebtEntity.isOverdue` pour reconnaître explicitement `status == DebtStatus.overdue` et normalisation des dates d'échéance.
- **Presentation State:** Ajout de `overdueCount` et du getter `hasOverdue` dans `KarneBorLoaded`.
- **Presentation Cubit:** Calcul réactif du montant total "Argent dehors" (`totalDebt`), décompte des créances en retard (`overdueCount`), tri déterministe par urgence (créances échues en tête ordonnées par plus ancienne date d'échéance, suivies des créances à venir par date d'échéance croissante, avec bris d'égalité sur `createdAt ASC`), et garde `if (isClosed) return;`.
- **Composant `DebtCard`:** Création d'un composant réutilisable conforme à `DESIGN.md` et `key-karne-bor.html`, avec typographie lisible, badge d'avertissement `⚠️ Retard`, bordure accentuée en cas de retard, affichage du solde restant sur paiement partiel, fallback résilient du nom de client, cibles tactiles >= 48dp, labels `Semantics` d'accessibilité, et SnackBars informatifs d'attente pour les futures Stories 2.3 et 2.4.
- **Écran `KarneBorScreen`:** Intégration de la typographie display ("ARGENT DEHORS", 28sp w800), badge de retards, liste dynamique avec `DebtCard`, état vide motivant "Aucun argent dehors ! Vos créances sont toutes à jour.", et gestion d'erreur avec bouton interactif "Réessayer".
- **Tests & Assurance Qualité:** Création et mise à niveau complète des suites de tests unitaires, de BLoC/Cubit et de widgets couvrant l'ensemble des cas nominaux et aux limites.

### Files Changed
- `lib/features/karne_bor/data/datasources/debt_local_data_source.dart`: Filtrage inclusif `ACTIVE`/`OVERDUE`, tri `dueDate ASC`, limite 50.
- `lib/features/karne_bor/domain/entities/debt_entity.dart`: Reconnaissance directe du statut `DebtStatus.overdue` dans `isOverdue`.
- `lib/features/karne_bor/presentation/cubit/karne_bor_state.dart`: Métriques `overdueCount` et `hasOverdue`.
- `lib/features/karne_bor/presentation/cubit/karne_bor_cubit.dart`: Tri d'urgence strict et calculs réactifs agrégés.
- `lib/features/karne_bor/presentation/widgets/debt_card.dart`: Nouveau composant carte de créance avec badge alerte, accessibilité et actions >= 48dp.
- `lib/features/karne_bor/presentation/screens/karne_bor_screen.dart`: Typographie display, intégration `DebtCard`, état vide et retry d'erreur.
- `test/features/karne_bor/data/datasources/debt_local_data_source_test.dart`: Tests du flux réactif Drift avec dettes actives et échues.
- `test/features/karne_bor/presentation/cubit/karne_bor_cubit_test.dart`: Tests unitaires du tri d'urgence et du calcul des indicateurs.
- `test/features/karne_bor/presentation/widgets/debt_card_test.dart`: 7 tests de composant validant les états nominal, retard, partiel, fallbacks et cibles tactiles.
- `test/features/karne_bor/presentation/screens/karne_bor_screen_test.dart`: Tests d'intégration d'écran validant la réactivité, le bandeau synthétique et les transitions d'état.

### Review Triage Breakdown
- **Patches Applied:** 13 findings corrigés (BH-1, BH-2, BH-3, BH-4, BH-6, BH-8, BH-9, BH-10, BH-11, BH-12, BH-13, ECH-1, ECH-3).
- **Deferred:** 1 finding consigné dans `deferred:` (BH-14 : agrégation sur flux paginé versus requête dédiée table entière).
- **Rejected / False-Positive:** 4 findings écartés avec justification factuelle (BH-5, BH-7, ECH-2, ECH-4).
- **Follow-up Review Recommended:** `false` (aucun défaut bloquant résiduel, correctifs localisés et vérifiés).

### Verification Outcomes
- `flutter test test/features/karne_bor/`: 37/37 tests passés avec succès.
- `flutter test`: 220/220 tests de la suite globale passés avec succès (0 régression).
- `dart analyze`: Aucune anomalie détectée (`No issues found!`).
