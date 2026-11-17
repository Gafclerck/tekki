---
title: "Story 1.5 : Ancrage Géographique Passif & Flag Silencieux d'Intégrité"
type: 'feature'
created: '2026-11-17'
status: 'done'
baseline_commit: '611fa6b198d0416e931e6c55a8446eb9bb906376'
route: 'dispatch'
review_loop_iteration: 0
context:
  - '_bmad-output/implementation-artifacts/epic-1-context.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Lors de la clôture express de caisse, il est indispensable de certifier l'ancrage géographique réel au point de vente (rayon de 200 m) pour alimenter la respectabilité et le Passeport Financier du commerçant, sans jamais le bloquer, le ralentir ou le pénaliser en cas de signal GPS instable ou indisponible.

**Approach:** Solliciter une capture passive de géolocalisation avec un délai d'expiration strict de 5 secondes lors de la clôture, calculer la distance Haversine par rapport aux coordonnées de référence de la boutique (`shops`), marquer silencieusement `is_flagged_location: true` si la distance excède 200 m ou si le GPS est indisponible, et déclencher à la validation réussie un son feutré de tiroir-caisse, un retour haptique et la confirmation de série (streak).

## Boundaries & Constraints

**Always:**
- Couche Domain en pur Dart : zéro import `package:flutter/*`, `package:geolocator/*`, `package:just_audio/*` ou `package:drift/*` dans les entités et usecases.
- Abstraction matérielle stricte : `ILocationService` et `IAudioPlayerService` définis par contrats d'interface abstraits substituables (LSP / ISP).
- Temporisation maximale de 5 secondes sur la capture GPS (`AppConstants.locationTimeoutSeconds = 5`), ne bloquant jamais l'enregistrement comptable.
- Distance calculée selon la formule mathématique de Haversine par rapport à `ShopEntity.refLatitude` et `ShopEntity.refLongitude`.
- Si la distance mesurée > 200 mètres (`AppConstants.shopGeofenceRadiusMeters = 200.0`) ou si la position GPS est indisponible (`null`), marquer silencieusement `is_flagged_location: true`.
- Aucune alerte anxiogène, aucun message d'erreur rouge, aucun blocage de l'interface en cas d'anomalie GPS : l'enregistrement comptable local s'effectue en < 1 seconde.
- À la validation réussie : émission d'un son feutré de tiroir-caisse, vibration haptique brève (`HapticFeedback.mediumImpact()`) et affichage de la confirmation avec la série en cours (`streak`).
- Tolérance aux pannes audio et matérielles : toute défaillance ou absence de périphérique audio/vibreur est interceptée silencieusement sans faire échouer la clôture.

**Never:**
- Aucun blocage de la validation de clôture en cas de GPS désactivé, refus d'autorisation ou perte de signal.
- Aucun calcul trigonométrique ou appel direct à `Geolocator` / `AudioPlayer` dans les widgets Flutter.
- Aucune modification destructrice du schéma relationnel existant (les colonnes `gps_latitude`, `gps_longitude`, `distance_meters`, `is_flagged_location` sont déjà présentes dans `DailyClosures`).
- Aucun appel réseau distant ou dépendance cloud (100% hors-ligne SQLite WAL).

## I/O & Edge-Case Matrix

| Scénario | Données en entrée / État | Sortie / Comportement attendu | Gestion d'erreur |
|---|---|---|---|
| Clôture nominale sur point de vente | Position GPS relevée à 35 m de la boutique | `is_flagged_location: false`, `gps_latitude` et `gps_longitude` renseignés, `distance_meters: 35.0`. Clôture scellée. Son de caisse + vibration + bannière streak. | Succès |
| Clôture hors point de vente | Position GPS relevée à 450 m de la boutique (> 200 m) | `is_flagged_location: true`, `distance_meters: 450.0`. Clôture scellée sans erreur ni alerte rouge. Son + vibration + streak affichés. | Succès silencieux |
| Signal GPS indisponible / timeout 5s | Délai de 5s écoulé sans fix GPS ou GPS désactivé | `is_flagged_location: true`, coordonnées et distance à null. Clôture scellée immédiatement. Zéro message d'erreur GPS. | Succès silencieux |
| Refus de permission GPS | L'utilisateur refuse l'accès à la localisation | `is_flagged_location: true`, coordonnées à null. Clôture scellée sans bloquer ni réitérer la demande de manière agressive. | Succès silencieux |
| Boutique introuvable en base locale | Aucune boutique enregistrée pour le `shop_id` | `is_flagged_location: true`, coordonnées GPS enregistrées si présentes, `distance_meters: null`. | Succès gracieux |
| Absence d'équipement audio | Haut-parleur muet, codec absent ou erreur native just_audio | Clôture validée, vibration haptique active, exception audio interceptée sans impacter l'expérience. | Dégradation gracieuse |

</frozen-after-approval>

## Code Map

- `lib/core/utils/haversine_calculator.dart` -- Calculateur trigonométrique pur Dart de la distance orthodromique en mètres entre deux coordonnées géographiques.
- `lib/core/services/location_service.dart` -- Contrat d'interface abstrait `ILocationService` et modèle de données immuable `GeoLocation` (pur Dart).
- `lib/core/services/geolocator_location_service.dart` -- Implémentation concrète `GeolocatorLocationService` utilisant `geolocator`, gérant les permissions et le timeout de 5s.
- `lib/core/services/audio_service.dart` -- Contrat d'interface abstrait `IAudioPlayerService` et implémentation concrète `JustAudioPlayerService` avec tolérance aux pannes.
- `lib/features/sales_and_cash/data/datasources/closure_local_data_source.dart` -- Requêtes Drift d'agrégation temporelle : comptage mensuel des clôtures et série consécutive (streak).
- `lib/features/sales_and_cash/domain/repositories/closure_repository.dart` -- Contrat pur Dart enrichi des méthodes `getMonthlyClosuresCount` et `getActiveStreak`.
- `lib/features/sales_and_cash/data/repositories/closure_repository_impl.dart` -- Implémentation concrète des calculs de streak et d'historique mensuel.
- `lib/features/sales_and_cash/domain/usecases/execute_daily_closure_use_case.dart` -- Orchestration de la clôture intégrant `ILocationService`, calcul Haversine, détection du flag passif et persistance atomique.
- `lib/features/sales_and_cash/presentation/cubit/express_closure_state.dart` -- État enrichi intégrant le streak actif, le nombre de clôtures du mois et le statut GPS passif.
- `lib/features/sales_and_cash/presentation/cubit/express_closure_cubit.dart` -- Chargement des métriques de streak, appel de `ExecuteDailyClosureUseCase` et notification audio/haptique.
- `lib/features/sales_and_cash/presentation/screens/express_closure_screen.dart` -- Mise à jour de la bannière streak dynamique, émission du son tiroir-caisse et notification de succès.
- `lib/injection_container.dart` -- Enregistrement IoC de `ILocationService`, `IAudioPlayerService` et mise à jour des usecases/cubits.

## Tasks & Acceptance

**Execution:**
- [x] `lib/core/utils/haversine_calculator.dart` -- Implémenter le calculateur de distance Haversine en pur Dart -- Calcul précis de l'écart métrique entre le relevé GPS et la boutique.
- [x] `lib/core/services/location_service.dart` -- Définir le contrat d'interface `ILocationService` et `GeoLocation` en pur Dart -- Abstraction du capteur GPS respectant DIP/LSP.
- [x] `lib/core/services/geolocator_location_service.dart` -- Implémenter `GeolocatorLocationService` avec timeout 5s et gestion des permissions -- Capture passive non-bloquante via geolocator.
- [x] `lib/core/services/audio_service.dart` -- Définir `IAudioPlayerService` et implémenter `JustAudioPlayerService` -- Déclenchement du son tiroir-caisse avec tolérance totale aux pannes.
- [x] `lib/features/sales_and_cash/data/datasources/closure_local_data_source.dart` -- Ajouter les méthodes de calcul du streak et des clôtures mensuelles -- Fourniture des métriques de régularité pour l'UI et le Passeport.
- [x] `lib/features/sales_and_cash/domain/repositories/closure_repository.dart` -- Déclarer `getMonthlyClosuresCount` et `getActiveStreak` dans `ClosureRepository` -- Découplage architectural des requêtes de régularité.
- [x] `lib/features/sales_and_cash/data/repositories/closure_repository_impl.dart` -- Implémenter les méthodes de calcul de streak dans `ClosureRepositoryImpl` -- Traduction des requêtes locales en résultats de domaine.
- [x] `lib/features/sales_and_cash/domain/usecases/execute_daily_closure_use_case.dart` -- Intégrer `ILocationService`, calcul Haversine et flag d'intégrité passif -- Respect strict des critères d'ancrage passif à la clôture.
- [x] `lib/features/sales_and_cash/presentation/cubit/express_closure_state.dart` -- Ajouter `activeStreak` et `monthlyClosuresCount` dans `ExpressClosureState` -- Support déclaratif de la série de clôtures.
- [x] `lib/features/sales_and_cash/presentation/cubit/express_closure_cubit.dart` -- Initialiser les métriques de streak et piloter la capture passive -- Orchestration complète du flux de validation de clôture.
- [x] `lib/features/sales_and_cash/presentation/screens/express_closure_screen.dart` -- Afficher dynamiquement la bannière streak et intégrer le feedback audio/haptique -- Expérience utilisateur fluide et rassurante (< 30s).
- [x] `lib/injection_container.dart` -- Enregistrer `ILocationService` et `IAudioPlayerService` dans `get_it` -- Câblage complet des dépendances applicatives.
- [x] `test/core/utils/haversine_calculator_test.dart` -- Créer les tests unitaires du calculateur Haversine -- Vérification des distances (0m, < 200m, > 200m, cas limites).
- [x] `test/core/services/location_service_test.dart` -- Créer les tests unitaires du service de localisation et fakes -- Vérification du respect du timeout et de la résilience aux erreurs.
- [x] `test/features/sales_and_cash/domain/usecases/execute_daily_closure_use_case_test.dart` -- Mettre à jour les tests du Use Case avec localisation et shop -- Validation des règles d'ancrage et de flagging silencieux.
- [x] `test/features/sales_and_cash/presentation/cubit/express_closure_cubit_test.dart` -- Mettre à jour les tests du Cubit de clôture -- Vérification du chargement du streak et de l'exécution complète.
- [x] `test/features/sales_and_cash/presentation/screens/express_closure_screen_test.dart` -- Mettre à jour les tests de composants de l'écran de clôture -- Vérification de la bannière dynamique et des retours de validation.

**Acceptance Criteria:**
- Given la validation de la clôture express par le commerçant, when le cas d'utilisation ExecuteDailyClosureUseCase s'exécute, then une capture passive de géolocalisation est sollicitée avec un délai d'expiration strict de 5 secondes.
- Given une capture GPS réussie, when la distance entre la position relevée et les coordonnées de référence du point de vente (shops) est calculée selon la formule de Haversine, then si la distance est supérieure à 200 mètres, la clôture est enregistrée avec is_flagged_location: true et la distance mesurée, sans afficher d'alerte rouge ni bloquer la validation.
- Given un capteur GPS désactivé, refusé ou un délai d'attente de 5 secondes expiré, when la clôture est validée, then la clôture est enregistrée avec is_flagged_location: true et sans coordonnées, de manière totalement silencieuse et immédiate (< 1s).
- Given une clôture validée avec succès, when l'écran de clôture confirme l'enregistrement, then l'application émet un son chaleureux de tiroir-caisse, une vibration haptique brève et affiche la confirmation de la clôture avec la série en cours (streak) et le nombre de clôtures du mois.

## Implementation Notes

- Implémentation du calculateur Haversine en pur Dart (`HaversineCalculator`) avec rayon terrestre moyen WGS 84 (6 371 000 m).
- Définition de l'abstraction `ILocationService` et de `GeoLocation` en pur Dart (zéro dépendance Flutter/Geolocator dans le Domain).
- Implémentation concrète `GeolocatorLocationService` avec timeout strict de 5 secondes (`AppConstants.locationTimeoutSeconds`), interception silencieuse des refus de permission et coupures de capteurs.
- Définition de l'abstraction `IAudioPlayerService` et implémentation `JustAudioPlayerService` tolérante aux pannes (dégradation silencieuse sans plantage en cas d'absence de hardware).
- Extension de `ClosureLocalDataSource` et `ClosureRepository` avec les requêtes SQL de cumul mensuel (`getMonthlyClosuresCount`) et de série active (`getActiveStreak`).
- Intégration de la capture passive dans `ExecuteDailyClosureUseCase` : calcul Haversine, seuil de 200 m (`AppConstants.shopGeofenceRadiusMeters`), flagging silencieux `is_flagged_location: true` sans bloquer le commerçant.
- Enrichissement de `ExpressClosureState`, `ExpressClosureCubit` et `ExpressClosureScreen` : affichage dynamique de la bannière streak, émission du son tiroir-caisse et retour haptique au scellement de la caisse.
- Couverture complète par 36 nouveaux tests unitaires et widget, portant la suite à 181 tests au vert.

## Spec Change Log

## Review Triage Log

### 2026-11-17 — Review pass
- verdicts: 15 findings — high 0, medium 4, low 5, false 6, maybe-false 0
- findings:
  - `[medium]` `[patch]` Double déclenchement audio sur validation de clôture (Cubit et View listener) — Action : Suppression de l'appel audio dans `ExpressClosureCubit`, centralisé dans le listener de `ExpressClosureScreen` aux côtés du retour haptique.
  - `[medium]` `[patch]` Temporisations cumulatives dans `GeolocatorLocationService.getCurrentLocation()` pouvant dépasser 5s — Action : Encapsulation de toute l'acquisition dans un timeout global unique via `_captureLocation().timeout(effectiveTimeout)`.
  - `[low]` `[patch]` Demande interactive de permission GPS lors d'une clôture passive — Action : Retour immédiat de `null` sans dialogue modal si la permission n'est pas déjà accordée (`denied` ou `deniedForever`).
  - `[medium]` `[patch]` Périmètre `shopId` divergent entre `ExpressClosureCubit.init()` et `submitClosure()` — Action : Paramètre `shopId = 'default-shop'` ajouté à `init()` et transmis de manière homogène aux requêtes de streak et clôtures mensuelles.
  - `[medium]` `[patch]` Fragilité du repli de boutique par défaut dans `ExecuteDailyClosureUseCase` — Action : Repli automatique sur `repository.getShop()` si `getShopById(shopId)` renvoie null avant de déclarer la boutique introuvable.
  - `[low]` `[patch]` Risque d'émission sur Cubit fermé (`StateError`) lors de la validation de clôture — Action : Ajout d'une garde `if (isClosed) return;` avant l'émission de l'état `success`.
  - `[low]` `[patch]` Risque d'appel à `ScaffoldMessenger` sur un contexte démonté — Action : Ajout d'une garde `if (!context.mounted) return;` avant l'affichage de la SnackBar.
  - `[low]` `[patch]` Absence de fichier physique pour l'asset audio `assets/audio/cash_drawer.mp3` — Action : Création sur disque d'un fichier audio MP3 valide (4 trames MPEG-1 Layer 3).
  - `[low]` `[patch]` Gestion des distances non finies (`NaN` ou `Infinity`) dans le Use Case — Action : Traitement des distances invalides comme anomalie : `finalDistance = null` et `is_flagged_location = true`.
  - `[false]` `[reject]` Normalisation UTC dans le calcul de streak — Réfutation : Toutes les dates de base Drift et de domaine sont strictement stockées et comparées en UTC conformément à l'architecture.
  - `[false]` `[reject]` Bannière de streak affirmant la conformité GPS avant soumission — Réfutation : Texte de réassurance visuelle strictement conforme à la maquette de référence `key-cloture-express.html`.
  - `[false]` `[reject]` Priorité du paramètre optionnel `isFlaggedLocation` dans `ExecuteDailyClosureUseCase` — Réfutation : Paramètre optionnel exclusivement prévu pour les tests unitaires et non exploité en production.
  - `[false]` `[reject]` Décrémentation par `Duration(days: 1)` sensible au changement d'heure (DST) — Réfutation : Le Sénégal (UTC+0) n'applique aucun changement d'heure saisonnier.
  - `[false]` `[reject]` Textes d'interface en français codés en dur sans internationalisation — Réfutation : L'internationalisation multilingue est hors périmètre de l'Epic 1 (Phase MVP unilingue).
  - `[false]` `[reject]` Précision `LocationAccuracy.high` risquant des timeouts en intérieur — Réfutation : Exigence contractuelle de précision métrique (200m) ; le timeout passif strict de 5s prévient tout blocage.

## Verification

**Commands:**
- `flutter test test/core/utils/haversine_calculator_test.dart` -- expected: Tests Haversine validés à 100%
- `flutter test test/features/sales_and_cash/domain/usecases/execute_daily_closure_use_case_test.dart` -- expected: Tests d'ancrage GPS et de flagging silencieux validés
- `flutter test test/features/sales_and_cash/presentation/cubit/express_closure_cubit_test.dart` -- expected: Tests du Cubit de clôture avec streak validés
- `flutter test test/features/sales_and_cash/presentation/screens/express_closure_screen_test.dart` -- expected: Tests de l'écran de clôture avec bannière dynamique validés
- `flutter test` -- expected: Ensemble de la suite de tests (145+ tests) au vert
