# Epic 1 Context: Caisse Express & Enregistrement Hybride des Ventes

<!-- Compiled from planning artifacts. Edit freely. Regenerate with compile-epic-context if planning docs change. -->

## Goal

Permettre au commerçant de consigner instantanément ses ventes au comptoir en 2 secondes au fil de l'eau, de réaliser sa clôture de caisse du soir en moins de 30 secondes en 3 étapes avec réconciliation automatique non-destructive et ancrage géographique passif silencieux, et d'obtenir une vision nette et immédiate de ses encaissements du jour sur un socle mobile 100 % hors-ligne.

## Stories

- Story 1.1: Socle Applicatif, Thème Visuel Tekki & Persistance Locale Drift
- Story 1.2: Enregistrement Rapide de Vente au Fil de l'Eau (Quick Sale)
- Story 1.3: Tableau de Bord Caisse & Suivi des Ventes en Temps Réel
- Story 1.4: Clôture Express ("Tiroir-Caisse") & Snapshotting Atomique
- Story 1.5: Ancrage Géographique Passif & Flag Silencieux d'Intégrité

## Requirements & Constraints

- **Fonctionnement 100 % Offline-First (NFR1)** : La base SQLite/Drift locale est l'unique source de vérité. Aucune dépendance réseau pour la saisie de vente, le calcul de caisse ou la clôture.
- **Performance au comptoir (NFR3)** : Enregistrement d'une vente en moins de 1.5 seconde, validation de clôture en moins de 1 seconde.
- **Saisie hybride non-destructive (FR1, FR2, FR3)** : Prise en charge combinée des micro-ventes unitaires au fil de l'eau et de la clôture consolidée du soir sans doublon ni écrasement dans le grand livre.
- **Ancrage géographique passif (FR12, FR13)** : Vérification de cohérence dans un rayon de 200 m par rapport à l'emplacement de référence de la boutique. Temporisation stricte de 5 secondes sur le GPS. Si écart > 200 m ou GPS indisponible, marquage silencieux `is_flagged_location: true` sans bloquer le commerçant ni afficher d'alerte anxiogène.
- **Empreinte légère et Android Go (NFR2)** : Exécution fluide sur terminaux 1 Go à 2 Go de RAM (Android 8.0+ / API 26+), requêtes limitées et paginées (`limit(50)`), SQLite en mode WAL.

## Technical Decisions

- **Clean Architecture 3 couches** : Découpage strict `presentation -> domain <- data`. La couche `domain` est en pur Dart (zéro import `package:flutter/*` ou `package:drift/*`).
- **Injection de dépendances** : Enregistrement déclaratif avec `get_it` et `injectable`.
- **Base de données Drift SQLite (Mode WAL)** :
  - Pragmas obligatoires : `PRAGMA journal_mode = WAL;` et `PRAGMA synchronous = NORMAL;`.
  - Table `shops` : `id` (UUID v4), `name`, `ref_latitude`, `ref_longitude`, `public_key`, `sync_status`, `created_at`.
  - Table `sales` : `id` (UUID v4), `amount` (INTEGER FCFA entiers), `payment_method` (`ESPECES`, `MOBILE_MONEY`, `CREDIT_CLIENT`), `recorded_at` (ISO-8601 UTC), `closure_id` (nullable, lié atomiquement lors de la clôture), `sync_status`, `last_synced_at`. Index sur `closure_id` et `sync_status`.
  - Table `daily_closures` : `id` (UUID v4), `shop_id`, `closure_date` (YYYY-MM-DD), `cutoff_timestamp` (ISO-8601 UTC), `total_sales_amount`, `total_cash_debt_inflow`, `total_credit_sales_amount`, `total_expenses_amount`, `cash_counted`, `gps_latitude`, `gps_longitude`, `distance_meters`, `is_flagged_location`, `sync_status`, `created_at`.
  - Table `sync_outbox` : `client_event_id` (UUID v4), `event_type`, `payload` (JSON), `status`, `created_at`.
- **Séparation CQRS locale & BLoC** :
  - Query UseCases retournant des `Stream<T>` Drift observés par les BLoCs via `emit.forEach`.
  - Command UseCases atomiques retournant `Future<Result<T, Failure>>`.
  - Les BLoCs gèrent les états immuables sans calcul direct dans les widgets Flutter.
- **Snapshotting atomique de clôture** :
  - À l'ouverture du formulaire de clôture, `cutoff_timestamp = DateTime.now().toUtc()` est figé.
  - La validation exécute une transaction SQL atomique scellant les ventes orphelines antérieures (`UPDATE sales SET closure_id = ? WHERE closure_id IS NULL AND recorded_at <= ?`) et insérant la `daily_closures`. Les ventes ultérieures restent orphelines pour la vacation suivante.
- **Formule d'encaisse théorique** : `Encaisse_Theorique = Ventes_Comptant_Especes + Remboursements_Dettes_Especes - Depenses_Especes`. Les ventes `CREDIT_CLIENT` sont exclues de l'encaisse physique.

## UX & Interaction Patterns

- **Design System Tekki (DESIGN.md)** :
  - Fond blush `#FEECEA`, primaire bleu marine `#133E59`, surface blanche `#FFFFFF`, accent orange `#FF7A41`, tertiaire `#8CB8C3`.
  - Pas de mode sombre.
  - Cibles tactiles minimales de 48dp x 48dp (bouton primaire CTA >= 52dp).
  - Grands chiffres de caisse lisibles à 1 mètre (`display` 28px gras 800).
  - Bouton focal unique orange `button-primary-cta` sur l'accueil avec protection anti-double-clic.
- **Comportement Vente Rapide** :
  - Bottom sheet immédiate déclenchée par `+ Vente rapide`.
  - Pavé numérique géant (touches >= 60dp), saisie en FCFA entiers sans décimale, validation avec micro-retour haptique (20ms).
- **Comportement Clôture Express** :
  - Formulaire en 3 étapes guidées (< 30s) : confirmation/ajustement du CA, saisie des dépenses, déclaration de l'encaisse comptée.
  - Validation accompagnée d'un son feutré de tiroir-caisse, vibration haptique et affichage de la série de clôtures (streak).

## Cross-Story Dependencies

- **Story 1.1** pose le socle commun (thème Tekki, injection `get_it`, initialisation Drift WAL et tables `shops` / `sales`). Toutes les stories suivantes de l'Epic 1 (et des Epics 2 à 4) dépendent directement de ce socle.
- **Story 1.2** nécessite la table `sales` et l'injection posées en 1.1 pour persister les ventes au fil de l'eau.
- **Story 1.3** consomme le flux réactif Drift issu de la table `sales` via BLoC pour afficher le cumul en temps réel.
- **Story 1.4** s'appuie sur les ventes créées en 1.2/1.3 pour opérer le snapshotting atomique et la création de `daily_closures`.
- **Story 1.5** intervient à l'étape finale de validation de la clôture de la Story 1.4 pour intégrer la capture GPS et le calcul de distance Haversine.
