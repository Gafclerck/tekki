# Epic 2 Context: Carnet de Dettes Numérique (Karné Bor) & Recouvrement

<!-- Generated from planning artifacts. Regenerate with compile-epic-context if planning docs change. -->

## Goal

Permettre au commerçant de consigner ses créances clients sans cahier papier, d'enregistrer les encaissements partiels ou totaux réconciliés avec le tiroir-caisse, de relancer courtoisement les retardataires en 1 clic sur WhatsApp en Wolof ou Français, et de suivre sa vélocité de recouvrement sur un socle mobile 100 % hors-ligne.

## Stories

- Story 2.1: Enregistrement d'une Dette Client & Création du Débiteur dans Drift
- Story 2.2: Tableau de Bord Karné Bor, Total "Argent Dehors" & Suivi des Retards
- Story 2.3: Encaissement de Remboursement & Réconciliation avec le Tiroir-Caisse
- Story 2.4: Relance Client 1-Clic via WhatsApp & Calcul de la Vélocité de Recouvrement

## Requirements & Constraints

- **Fonctionnement 100 % Offline-First (NFR1)** : SQLite/Drift comme unique source de vérité. Aucune dépendance réseau pour la création de débiteurs, l'enregistrement de créances ou la consultation du carnet.
- **Performance et latence (NFR3)** : Enregistrement et validation d'une créance en moins de 1 seconde.
- **Gestion des créances (FR4)** : Enregistrement d'une dette client avec débiteur (nom obligatoire, téléphone/WhatsApp optionnel), montant initial en FCFA entiers, date d'échéance convenue et note optionnelle.
- **Suivi des remboursements (FR5)** : Règlement total ou acomptes partiels avec recalcul instantané du solde restant dû (`remaining_amount`).
- **Relance WhatsApp 1-clic (FR6)** : Message courtois pré-rempli en Wolof ou Français avec montant et date d'échéance, sans intermédiaire serveur.
- **Vélocité de recouvrement & alertes retards (FR7)** : Alertes visuelles de retard avec tri par urgence des créances échues.
- **Accessibilité et ergonomie (NFR5)** : Cibles tactiles >= 48dp x 48dp, montants lisibles, contraste WCAG AA sur fond blush.

## Technical Decisions

- **Clean Architecture 3 couches** : Découpage strict `presentation -> domain <- data`. La couche `domain` est en pur Dart (zéro import `package:flutter/*` ou `package:drift/*`).
- **Injection de dépendances** : Enregistrement déclaratif avec `get_it` et `injectable`.
- **Base de données Drift SQLite (Mode WAL)** :
  - Table `debtors` : `id` (UUID v4 PK), `name` (TEXT), `phone_number` (TEXT nullable), `sync_status` (TEXT: PENDING, SYNCED, FAILED), `created_at` (ISO-8601 UTC).
  - Table `debts` : `id` (UUID v4 PK), `debtor_id` (TEXT FK vers debtors), `initial_amount` (INTEGER FCFA), `remaining_amount` (INTEGER FCFA), `due_date` (ISO-8601 UTC), `status` (TEXT: ACTIVE, SETTLED, OVERDUE), `sync_status` (TEXT), `last_synced_at` (nullable ISO-8601 UTC), `created_at` (ISO-8601 UTC).
  - Table `debt_payments` : `id` (UUID v4 PK), `debt_id` (TEXT FK vers debts), `payment_amount` (INTEGER FCFA), `payment_method` (TEXT: ESPECES, MOBILE_MONEY), `sync_status` (TEXT), `last_synced_at` (nullable), `paid_at` (ISO-8601 UTC).
  - Index SQLite sur `debtor_id`, `status` et `sync_status`. Requêtes `Stream` bornées et paginées (`limit(50)`).
  - Transaction atomique obligatoire lors de la création conjointe débiteur/dette et enregistrement dans `sync_outbox` avec `client_event_id` (UUID v4).
- **Séparation CQRS & BLoC** :
  - Query UseCases retournant des `Stream<T>` Drift observés par les BLoCs via `emit.forEach`.
  - Command UseCases atomiques retournant `Future<Result<T, Failure>>`.
- **Intégration Caisse-Dettes (AD-9)** :
  - Encaisse théorique : `Encaisse_Theorique = Ventes_Comptant_Especes + Remboursements_Dettes_Especes - Depenses_Especes`.
  - Les encaissements de dettes en espèces participent à la clôture journalière via `total_cash_debt_inflow`.

## UX & Interaction Patterns

- **Design System Tekki (DESIGN.md)** :
  - Fond blush `#FEECEA`, primaire bleu marine `#133E59`, surface blanche `#FFFFFF`, accent orange `#FF7A41`, tertiaire `#8CB8C3`.
  - Cibles tactiles >= 48dp x 48dp.
- **Composant Carte Dette Karné Bor (`debt-card`)** :
  - Affichage du montant restant dû, nom du débiteur, date d'échéance.
  - Badge d'alerte retard avec icône visuelle et couleur d'avertissement.
  - Bouton d'encaissement partiel/total et bouton de relance WhatsApp 1-clic.
- **Microcopie Bienveillante** :
  - Libellé "Argent dehors" au lieu de termes comptables anxiogènes.
  - Empty state motivant : "Aucun argent dehors ! Vos créances sont toutes à jour."
- **Formulaire d'enregistrement de dette** :
  - Bouton d'action "+ Noter une Dette Client".
  - Saisie intuitive du nom du client (ou sélection existante), téléphone optionnel, montant FCFA entiers, date d'échéance.
  - Validation rapide < 1s avec retour visuel immédiat.

## Cross-Story Dependencies

- **Story 2.1** : Met en place les tables Drift `debtors` et `debts`, les entités/modèles du Domain et Data, le repository de dettes, le cas d'utilisation d'enregistrement atomique et le formulaire de saisie de créance.
- **Story 2.2** : Dépend des tables et entités de 2.1 pour afficher le tableau de bord Karné Bor, le cumul "Argent dehors" et la liste réactive des dettes avec détection des retards.
- **Story 2.3** : Dépend de 2.1 et 2.2 pour introduire `debt_payments`, l'encaissement total/partiel et la réconciliation avec le tiroir-caisse de l'Epic 1.
- **Story 2.4** : Dépend de 2.1-2.3 pour intégrer la relance WhatsApp 1-clic et le calcul de la vélocité de recouvrement.
