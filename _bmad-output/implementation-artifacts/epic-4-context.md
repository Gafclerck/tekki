# Epic 4 Context: Conseiller Tekki & Synchronisation Résiliente

<!-- Generated from planning artifacts. Regenerate with compile-epic-context if planning docs change. -->

## Goal

Permettre au commerçant de monter en compétences de gestion financière grâce à des indicateurs visuels simples (feux tricolores) et des capsules audio courtes hebdomadaires en Wolof et Français, tout en assurant la synchronisation automatique, silencieuse et idempotente des données locales vers le serveur sans risque de blocage ni de perte de données.

## Stories

- Story 4.1: Moteur Déterministe d'Audit & Indicateurs Visuels de Gestion (Feux Tricolores)
- Story 4.2: Lecteur Audio Conseiller, Capsules Éducatives Bilingues & Cache Local
- Story 4.3: File d'Attente Locale Outbox, Idempotence & Synchronisation Résiliente en Tâche de Fond

## Requirements & Constraints

- **Fonctionnement 100 % Offline-First & Zéro LLM Runtime (AD-2, AD-7)** : SQLite/Drift comme unique source de vérité locale. L'évaluation de santé financière s'effectue via un moteur déterministe autonome sans dépendance à un modèle LLM distant ni latence réseau.
- **Accessibilité visuelle et redondance des états** : Les feux tricolores d'audit ne reposent jamais sur la couleur seule ; ils sont systématiquement doublés d'icônes de forme (✓ Vert = conforme, ⏳ Orange = attention, ! Rouge = urgent).
- **Capsules audio pédagogiques (Story 4.2, AD-7)** : Capsules audio scénarisées pré-enregistrées de 30 à 45 secondes, prioritairement en Wolof et secondairement en Français, compressées en Opus mono @ 32 kbps (~160 Ko). Capsule d'accueil embarquée dans l'APK, capsules suivantes mises en cache localement. Pause automatique sur appel entrant ou mise en arrière-plan.
- **Résilience et synchronisation Outbox (Story 4.3, AD-2, AD-12)** : Toute écriture métier locale génère un enregistrement dans la table `sync_outbox` avec un UUID v4 (`client_event_id`). Synchronisation en tâche de fond via WorkManager lorsque le réseau est stable et la batterie > 15 %. Idempotence stricte côté serveur et retry exponentiel silencieux.

## Technical Decisions

- **Architecture Clean 3 couches** : Découpage `presentation -> domain <- data`. La couche `domain` (`features/advisor/domain/`, `features/sync/domain/`) est en Dart pur (zéro dépendance Flutter, Drift ou réseau).
- **Moteur d'Audit Déterministe (`EvaluateFinancialHealthUseCase`)** :
  - Analyse autonome de 4 axes de gestion : régularité de clôture, vélocité/taux de recouvrement des dettes (Karné Bor), constance de l'encaisse de trésorerie, et intégrité géographique des clôtures.
  - Production d'indicateurs de statut (`HealthStatus`: healthy, warning, critical) accompagnés de recommandations concises et de la référence vers la capsule audio associée.
- **Gestion d'état BLoC (AD-8)** :
  - `AdvisorBloc` ou `AdvisorCubit` orchestre l'évaluation de santé financière et le statut des capsules audio.
  - Intégration sur l'onglet Conseiller Tekki (`AdvisorPage`) et pastille synthétique discrète sur `HomeScreen`.
- **Lecteur Audio (`AudioService` / `just_audio`)** :
  - Service audio dédié gérant le chargement (asset ou fichier local), la lecture, la pause, la reprise et la libération des ressources.
  - Bascule de langue (Wolof / Français) instantanée en un tap.
- **Outbox SQLite & Sync Manager** :
  - Table Drift `sync_outbox` stockant payload JSON, table cible, type d'opération (INSERT, UPDATE, DELETE), timestamp et statut d'envoi.

## UX & Interaction Patterns

- **Onglet Conseiller Tekki (Navigation principale)** : Hub d'éducation financière avec diagnostic en feux tricolores (carte d'audit) et lecteur de capsule audio au format note vocale WhatsApp avec forme d'onde / jauge de progression.
- **Pastille de synthèse sur l'Accueil** : Badge discret sur le tableau de bord reflétant le statut global de gestion (Vert / Orange / Rouge avec pictogramme associé).
- **Lecteur de capsule audio (`audio-capsule`)** : Carte avec bordure gauche orange accent (`#FF7A41`), bouton Play circulaire géant, jauge de progression temporelle et sélecteur Wolof / Français à bascule 1-tap.

## Cross-Story Dependencies

- **Story 4.1** fournit le moteur d'évaluation financière et les indicateurs visuels consommés par l'écran Conseiller et l'écran d'accueil.
- **Story 4.2** intègre le lecteur audio aux côtés des recommandations issues du moteur d'audit de Story 4.1.
- **Story 4.3** opère en tâche de fond pour synchroniser l'ensemble des données créées par les Stories 1.x, 2.x, 3.x et 4.x vers le serveur distant.
