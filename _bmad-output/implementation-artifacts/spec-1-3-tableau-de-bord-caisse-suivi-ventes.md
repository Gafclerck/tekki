---
title: 'Story 1.3 : Tableau de Bord Caisse & Suivi des Ventes en Temps Réel'
type: 'feature'
created: '2026-11-17'
status: 'done'
baseline_commit: '57d08efdf1fca05eed74683bea960ee36795d934'
route: 'dispatch'
review_loop_iteration: 0
context:
  - '_bmad-output/implementation-artifacts/epic-1-context.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Le commerçant au comptoir a besoin d'avoir une visibilité instantanée et continue sur le montant total de ses encaissements du jour pour suivre son activité commerciale sans calcul mental et savoir quand déclencher sa clôture de fin de journée.

**Approach:** Développer l'écran d'accueil avec la carte de caisse réactive `CashCard` affichant le total cumulé des ventes en typographie display géante (mise à jour en temps réel via un Stream Drift et BLoC), un état vide bienveillant lorsqu'aucune vente n'est consignée, et le bouton d'action focal unique orange `PrimaryCtaButton` ("🔒 Clôturer la caisse") avec verrouillage anti-double-clic.

## Boundaries & Constraints

**Always:**
- Couche Domain en pur Dart : zéro import `package:flutter/*` ou `package:drift/*`.
- Flux réactif Drift observé par un BLoC (`CashDashboardBloc`) via `emit.forEach` conformément au CQRS local de l'Epic 1.
- Filtrage des ventes orphelines du jour (`closure_id IS NULL` et date locale correspondant au jour en cours).
- Typographie `display` 28px gras 800 lisible à 1 mètre pour le montant cumulé principal avec formatage en entiers FCFA sans décimales.
- Bouton focal unique orange `button-primary-cta` (`#FF7A41`, hauteur min 52dp, cible tactile >= 52dp) avec retour haptique court (20ms) et verrouillage anti-double-clic.
- Fond d'écran global blush `#FEECEA`, surface `#FFFFFF` avec bordure 1px tertiaire `#8CB8C3`.
- Pas de mode sombre (verrouillé sur `ThemeMode.light`).
- Message d'état vide exact : `"0 FCFA aujourd'hui. Enregistrez votre première vente ou faites votre clôture de caisse."`.

**Never:**
- Aucun recalcul manuel ou boucle impérative dans les widgets de l'arborescence UI Flutter.
- Jamais plus d'un bouton orange accent (`#FF7A41`) sur l'écran d'accueil.
- Pas d'écriture ou modification destructrice des ventes existantes lors de la consultation.
- Aucun import réseau ou dépendance en ligne pour le calcul ou l'affichage de la caisse.

## I/O & Edge-Case Matrix

| Scénario | Données en entrée / État | Sortie / Comportement attendu | Gestion d'erreur |
|---|---|---|---|
| Caisse à zéro (Empty state) | Aucune vente enregistrée aujourd'hui (`sales = []`) | `CashCard` affiche `0 FCFA`, sous-titre bienveillant exact `"0 FCFA aujourd'hui. Enregistrez votre première vente ou faites votre clôture de caisse."`, bouton `+ Vente rapide` actif. | N/A |
| Flux de ventes actives | 3 ventes : 5 000 F, 2 500 F, 10 000 F enregistrées | Montant display `17 500 F` (ou `17 500 FCFA`), compteur `3 ventes`, note informative hybride visible. | N/A |
| Réactivité temps réel | Nouvelle vente de 3 000 F insérée au fil de l'eau via Drift | Le Stream émet automatiquement le nouveau total `20 500 F` et `4 ventes` sans recharger la page. | N/A |
| Ventes de vacations précédentes clôturées | Ventes avec `closure_id != null` | Exclues du calcul du jour : seules les ventes orphelines du jour sont cumulées. | N/A |
| Clic sur Clôturer la caisse | Tap sur `PrimaryCtaButton` "🔒 Clôturer la caisse" | Déclenchement du retour haptique (20ms), verrouillage immédiat anti-double-clic, notification/action de clôture. | N/A |
| Erreur flux Drift | Exception de lecture base de données SQLite | État d'erreur discret avec message courtois sans bloquer la possibilité d'ajouter une vente rapide. | Affichage d'un message d'erreur non bloquant |

</frozen-after-approval>

## Code Map

- `lib/core/theme/app_colors.dart` -- Constantes de couleur Tekki (primary `#133E59`, accent `#FF7A41`, background `#FEECEA`, surface `#FFFFFF`, tertiary `#8CB8C3`)
- `lib/core/theme/app_theme.dart` -- Thème Flutter clair sans mode sombre
- `lib/core/utils/currency_formatter.dart` -- Formatage uniforme des montants entiers FCFA
- `lib/features/sales_and_cash/domain/entities/sale_entity.dart` -- Entité métier Sale (id, amount, paymentMethod, recordedAt, closureId, syncStatus)
- `lib/features/sales_and_cash/domain/repositories/sales_repository.dart` -- Contrat du repository de ventes (pur Dart), fournit `watchOrphanSales()`
- `lib/features/sales_and_cash/data/repositories/sales_repository_impl.dart` -- Implémentation du repository consommant `SalesLocalDataSource`
- `lib/features/sales_and_cash/presentation/widgets/quick_sale_button.dart` -- Bouton secondaire `+ Vente rapide` déclenchant la bottom sheet de saisie
- `lib/features/sales_and_cash/presentation/widgets/quick_sale_bottom_sheet.dart` -- Modale de vente rapide
- `lib/injection_container.dart` -- Configuration de l'injection des dépendances `get_it`
- `lib/app.dart` -- Point d'entrée de l'application et affichage de l'écran d'accueil

## Tasks & Acceptance

**Execution:**
- [x] `lib/features/sales_and_cash/domain/entities/cash_summary_entity.dart` -- Créer l'entité métier `CashSummaryEntity` (totalAmount: int, salesCount: int, sales: List<SaleEntity>) en pur Dart.
- [x] `lib/features/sales_and_cash/domain/usecases/watch_today_sales_use_case.dart` -- Créer le Use Case pur Dart `WatchTodaySalesUseCase` consommant `SalesRepository.watchOrphanSales()` et filtrant pour le jour en cours pour émettre `Stream<CashSummaryEntity>`.
- [x] `lib/features/sales_and_cash/presentation/bloc/cash_dashboard_event.dart` -- Définir les événements BLoC (`WatchCashDashboardStarted`, `CashDashboardUpdated`, `CloseCashierTapped`).
- [x] `lib/features/sales_and_cash/presentation/bloc/cash_dashboard_state.dart` -- Définir les états Equatable (`CashDashboardInitial`, `CashDashboardLoading`, `CashDashboardLoaded`, `CashDashboardError`).
- [x] `lib/features/sales_and_cash/presentation/bloc/cash_dashboard_bloc.dart` -- Implémenter le BLoC observant le flux réactif avec `emit.forEach` et gérant le verrouillage anti-double-clic.
- [x] `lib/features/sales_and_cash/presentation/widgets/primary_cta_button.dart` -- Implémenter le widget `PrimaryCtaButton` (`button-primary-cta`, orange `#FF7A41`, texte bold blanc, hauteur min 52dp, anti-double-clic, retour haptique 20ms).
- [x] `lib/features/sales_and_cash/presentation/widgets/cash_card.dart` -- Implémenter la carte `CashCard` (surface blanche, bordure 1px tertiaire `#8CB8C3`, montant display géant 28px/800, empty state bienveillant, intégration de `QuickSaleButton`).
- [x] `lib/features/sales_and_cash/presentation/screens/home_screen.dart` -- Implémenter l'écran d'accueil `HomeScreen` avec header commerçant, `CashCard`, espace réservé pour les futures cartes (Karné Bor, Conseiller) et bouton focal unique `PrimaryCtaButton`.
- [x] `lib/injection_container.dart` -- Enregistrer `WatchTodaySalesUseCase` et `CashDashboardBloc` dans le conteneur `get_it`.
- [x] `lib/app.dart` -- Remplacer le placeholder temporaire par `HomeScreen` connecté au `CashDashboardBloc`.
- [x] `test/features/sales_and_cash/domain/usecases/watch_today_sales_use_case_test.dart` -- Tests unitaires du cas d'utilisation `WatchTodaySalesUseCase` (calcul cumul, filtrage orphelines, dates).
- [x] `test/features/sales_and_cash/presentation/bloc/cash_dashboard_bloc_test.dart` -- Tests unitaires du BLoC (émission états loading/loaded, réactivité stream, anti-double-clic).
- [x] `test/features/sales_and_cash/presentation/widgets/cash_card_test.dart` -- Tests widgets de `CashCard` (état vide bienveillant vs état avec ventes, formatage montants).
- [x] `test/features/sales_and_cash/presentation/widgets/primary_cta_button_test.dart` -- Tests widgets de `PrimaryCtaButton` (hauteur >= 52dp, anti-double-clic, haptique).
- [x] `test/features/sales_and_cash/presentation/screens/home_screen_test.dart` -- Tests d'intégration widget de `HomeScreen` (présence du bouton focal unique, de la carte et du bouton de vente rapide).

**Acceptance Criteria:**
- Given l'écran d'accueil ouvert sans aucune vente aujourd'hui, when l'utilisateur regarde la carte de caisse, then le montant affiché est "0 FCFA" accompagné du message bienveillant exact "0 FCFA aujourd'hui. Enregistrez votre première vente ou faites votre clôture de caisse.".
- Given l'écran d'accueil ouvert, when une ou plusieurs ventes rapides sont enregistrées, then le montant cumulé du jour se met à jour instantanément en typographie display (28px gras 800) avec le nombre total de ventes.
- Given l'écran d'accueil ouvert, when l'utilisateur regarde le bas de l'écran, then un bouton focal unique orange button-primary-cta "🔒 Clôturer la caisse" est affiché avec une hauteur minimale de 52dp et un verrouillage anti-double-clic dès le premier tap.

## Implementation Notes

- Entité de domaine `CashSummaryEntity` créée en pur Dart sans fuite Drift ou Flutter.
- Cas d'utilisation `WatchTodaySalesUseCase` consommant le stream Drift `watchOrphanSales()`, filtrant strictement sur le jour local et les ventes orphelines `closureId == null`.
- `CashDashboardBloc` observant le flux via `emit.forEach` conformément au CQRS local d'Epic 1 et gérant l'invalidation / verrouillage anti-double-clic.
- `CashCard` stylisé avec surface blanche, bordure tertiaire 1px `#8CB8C3`, typographie 28px gras 800, badge dynamique de comptage et message d'état vide exact.
- `PrimaryCtaButton` (`#FF7A41`, hauteur 52dp) avec retour haptique 20ms et verrouillage anti-double-clic immédiat.
- `HomeScreen` intégrant le header commerçant, le badge 100% hors-ligne, les cartes réservées (Karné Bor, Conseiller Tekki) et l'unique bouton CTA orange.
- Tous les tests de régression et les nouveaux tests unitaires/widgets (89 tests au total) passent avec 0 erreurs et 0 avertissements statiques (`flutter analyze`).

## Spec Change Log

## Review Triage Log

- `[medium]` `[patch]` Double dispatch redondant de `WatchCashDashboardStarted` au lancement — Résolu par suppression de `..add(...)` dans `app.dart`.
- `[medium]` `[patch]` Omission du retour visuel SnackBar sur `CashCard` lors d'une vente rapide — Résolu par câblage de `onSaleRecorded` sur `CashCard` affichant la SnackBar flottante.
- `[medium]` `[patch]` Verrouillage permanent du `PrimaryCtaButton` en cas de tap lors d'un état non chargé — Résolu en désactivant le bouton (`onPressed: null`) hors de l'état `CashDashboardLoaded`.
- `[low]` `[patch]` Apparence active du `PrimaryCtaButton` quand `onPressed` est nul — Résolu par intégration de `widget.onPressed == null` dans `_isEffectiveLocked`.
- `[low]` `[patch]` Risque d'utilisation d'un contexte démonté dans `HomeScreen.listener` — Résolu par garde `if (!context.mounted) return;`.
- `[low]` `[patch]` Événement mort inutilisé `CashDashboardUpdated` — Résolu par suppression de l'événement et de son handler BLoC.
- `[low]` `[patch]` Risque de débordement de texte sur grands montants dans `CashCard` — Résolu par encapsulation dans un `FittedBox(fit: BoxFit.scaleDown)`.
- `[low]` `[patch]` Espacement vertical excessif (80dp) en bas du défilement de `HomeScreen` — Résolu par réduction à 16dp.
- `[low]` `[patch]` Absence de test d'intégration pour le wiring DI réel de `TekkiApp` — Résolu par ajout d'un test dans `test/widget_test.dart` avec `initDependencyInjection(inMemoryDatabase: true)`.
- `[false]` `[reject]` Absence de transition automatique à minuit sans nouvelle vente — Réfutation : Application de caisse opérant en journée; toute nouvelle vente ou réouverture matinale actualise le Stream réactif Drift.
- `[false]` `[reject]` Exclusion des ventes orphelines antérieures non clôturées — Réfutation : Conforme au contrat figé de la spécification ("seules les ventes orphelines du jour sont cumulées").
- `[false]` `[reject]` Paramètre constructeur `cashDashboardBloc` sur `TekkiApp` — Réfutation : Modèle canonique Flutter pour tests de widgets isolés sans pollution globale.
- `[false]` `[reject]` Marque boutique codée en dur dans l'en-tête commerçant — Réfutation : Périmètre respecté (l'affichage personnalisé du point de vente relève des stories de profil boutique).
- `[false]` `[reject]` Erreur de stream SQLite destructrice — Réfutation : La base Drift locale SQLite en mode WAL est robuste; en cas d'erreur transitoire, la bannière discrète s'affiche sans bloquer la saisie.

## Design Notes

- Typographie Display pour le montant :
  ```dart
  Text(
    CurrencyFormatter.format(state.totalAmount),
    style: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: AppColors.primary,
    ),
  );
  ```
- Carte de surface :
  ```dart
  BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.tertiary, width: 1),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  )
  ```
- Bouton focal unique :
  ```dart
  SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: _isLocked ? null : _handleTap,
      child: const Text('🔒 Clôturer la caisse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
    ),
  )
  ```
