---
title: "File d'Attente Locale Outbox, Idempotence & Synchronisation Résiliente en Tâche de Fond"
type: 'feature'
created: '2026-11-18'
status: 'done'
baseline_revision: 'c5b7ccf'
review_loop_iteration: 0
followup_review_recommended: false
context:
  - _bmad-output/implementation-artifacts/epic-4-context.md
  - _bmad-output/planning-artifacts/architecture/architecture-tekki-2026-11-17/ARCHITECTURE-SPINE.md
warnings: []
deferred: []
---

<intent-contract>

## Intent

**Problem:** Les commerçants d'Afrique de l'Ouest alternent fréquemment entre zones de bonne couverture réseau (marchés urbains, centres-villes) et zones blanches ou instables (boutiques enclavées, coupures d'électricité). Les transactions locales au comptoir ne doivent jamais être ralenties ni bloquées par l'attente d'un serveur distant, tout en assurant une sauvegarde en ligne fiable, résiliente et sans duplication dès que le réseau est rétabli.
**Approach:** Implémenter une table Drift `sync_outbox` alimentée de façon atomique dans la même transaction SQLite que chaque mutation métier (`sales`, `daily_closures`, `debtors`, `debts`, `debt_payments`), associée à un UUID v4 d'idempotence (`client_event_id`). En arrière-plan, un worker résilient transmet les événements par lot dès détection d'une connexion réseau et d'une batterie > 15 %, met à jour le statut des entités locales en `synced`, purge l'outbox et applique un mécanisme silencieux de repli exponentiel avec temporisation.

## Boundaries & Constraints

**Always:**
- Couche Domain en Dart pur (zéro dépendance vers Flutter, Drift, http ou réseau).
- Base de données locale Drift SQLite comme unique source de vérité locale (Single Source of Truth) en mode WAL.
- Atomicité stricte : toute création ou mise à jour locale de données métier doit insérer dans la même transaction SQL l'entité concernée et son événement outbox avec un UUID v4 unique.
- Idempotence stricte : le `client_event_id` est systématiquement transmis au serveur comme clé d'idempotence pour prévenir toute duplication lors des retries.
- Résilience et silence opérationnel : les erreurs réseau ou indisponibilités serveur ne doivent générer aucun pop-up bloquant ni altérer l'expérience d'encaissement au comptoir.
- Règle de l'action focale unique sur HomeScreen : l'indicateur visuel de synchronisation doit être discret, accessible et ne jamais rivaliser avec le bouton orange de clôture express.

**Never:**
- Aucun appel réseau synchrone bloquant pendant les opérations de caisse (vente rapide, clôture, encaissement de dette).
- Pas de perte de données locales lors d'une panne réseau ou d'un arrêt imprévu du terminal.
- Pas de duplication de transactions lors des réémissions de paquets.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Enregistrement vente au comptoir | `insertSale(sale)` | Vente insérée + événement `SALE_CREATED` inséré dans `sync_outbox` avec statut `PENDING` (transaction atomique) | Rollback complet si échec DB |
| Clôture express de caisse | `executeDailyClosure(closure)` | Clôture enregistrée + ventes et paiements scellés + événement `CLOSURE_SUBMITTED` inséré dans `sync_outbox` | Rollback complet si échec DB |
| Enregistrement dette & débiteur | `recordDebtWithDebtor(...)` | Débiteur + Dette enregistrés + événements `DEBTOR_CREATED` et `DEBT_CREATED` dans l'outbox | Rollback complet si échec DB |
| Encaissement d'un acompte | `recordDebtPayment(...)` | Paiement enregistré + solde dette mis à jour + événements `DEBT_PAYMENT_RECORDED` et `DEBT_UPDATED` dans l'outbox | Rollback complet si échec DB |
| Réseau disponible & batterie > 15% | Événements en attente dans outbox | Batch envoyé via HTTP POST, réponse 200 OK reçue, entités cibles passent à `sync_status = 'synced'`, entrées outbox purgées | Retry si échec partiel |
| Perte de réseau / Mode avion | Déconnexion détectée via `connectivity_plus` | Aucune tentative d'envoi réseau, les opérations s'accumulent silencieusement dans `sync_outbox` | N/A |
| Panne serveur / HTTP 500 / Timeout | Tentative d'envoi échoue | Incrémentation de `retry_count`, enregistrement de `last_attempt_at` et mise en veille exponentielle silencieuse (Backoff) | Retry silencieux après délai progressif |
| Rétablissement de la connexion | Événement réseau émis par `NetworkInfo` | Dépilement immédiat de la file d'attente Outbox et transmission du lot d'événements | Backoff réinitialisé sur succès |

</intent-contract>
