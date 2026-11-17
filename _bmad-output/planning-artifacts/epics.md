---
status: final
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - _bmad-output/planning-artifacts/briefs/brief-tekki-2026-11-17/brief.md
  - _bmad-output/planning-artifacts/briefs/brief-tekki-2026-11-17/addendum.md
  - _bmad-output/planning-artifacts/architecture/architecture-tekki-2026-11-17/ARCHITECTURE-SPINE.md
  - _bmad-output/planning-artifacts/ux-designs/ux-tekki-2026-11-17/DESIGN.md
  - _bmad-output/planning-artifacts/ux-designs/ux-tekki-2026-11-17/EXPERIENCE.md
---

# tekki - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for tekki, decomposing the requirements from the PRD (Product Brief & Addendum), UX Design, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

FR1: Saisie rapide de vente au fil de l'eau (Quick Sale) en 2 clics avec pavé numérique géant dédié sans gestion de catalogue d'articles obligatoire.
FR2: Clôture express du soir ("Tiroir-Caisse") en 3 étapes (ajustement des ventes du jour, déclaration des dépenses/achats, saisie de l'encaisse comptée).
FR3: Réconciliation automatique et non-destructive des ventes au fil de l'eau et de la clôture express sans écrasement ni doublons dans le grand livre local.
FR4: Enregistrement d'une dette client dans le carnet numérique (Karné Bor) avec débiteur, montant initial, date d'échéance convenue et note optionnelle.
FR5: Gestion et suivi des remboursements de dette (règlement total ou acomptes partiels) avec recalcul instantané du solde restant dû.
FR6: Relance client 1-clic via WhatsApp générant un message cordial pré-rempli en Wolof ou Français avec montant et date d'échéance.
FR7: Suivi et affichage de la vélocité de recouvrement des créances et des alertes de retard de paiement avec tri par urgence.
FR8: Calcul autonome in-app du score de solvabilité et de réputation financière sur 100 basé sur les 4 piliers (35% régularité clôtures, 40% vélocité Karné Bor, 15% ancrage GPS, 10% discipline d'épargne/encaisse).
FR9: Génération du Passeport Financier infalsifiable avec QR Code sécurisé autonome (signature Ed25519, sérialisation CBOR, encodage Base45) vérifiable d'appareil à appareil (D2D) sans connexion Internet.
FR10: Affichage et validation d'un code PIN visuel dynamique à 4 chiffres dérivé par HMAC pour la vérification D2D anti-rejeu.
FR11: Génération et export d'une attestation de revenus certifiée au format PDF partageable en 1-clic via WhatsApp.
FR12: Ancrage géographique passif lors de la clôture journalière avec vérification du rayon de cohérence de 200 m par rapport à l'emplacement de référence de la boutique.
FR13: Marquage silencieux d'audit (is_flagged_location: true) en cas d'écart GPS > 200 m ou d'indisponibilité du signal, sans blocage de l'utilisateur ni message d'erreur.
FR14: Module du Conseiller Tekki évaluant l'historique financier et restituant des indicateurs visuels d'audit de gestion (feux tricolores : vert, orange, rouge doublés d'icônes).
FR15: Lecture audio de capsules courtes d'éducation financière (30 à 45 secondes) en Wolof et en Français avec contrôle de lecture (play, pause, sélection de langue, pause auto sur appel).
FR16: Synchronisation asynchrone des données locales vers le serveur via une file d'attente Outbox avec gestion d'idempotence (client_event_id UUID v4).

### NonFunctional Requirements

NFR1: Architecture 100% Offline-First : persistance locale SQLite/Drift comme unique source de vérité, aucune dépendance réseau pour la gestion courante, le calcul du score ou la vérification du QR Code.
NFR2: Empreinte mémoire et poids d'APK légers : taille d'APK plafonnée à moins de 15 Mo (8.5 à 11 Mo par architecture CPU via split-per-abi) pour exécution fluide sur terminaux Android Go (1 à 2 Go RAM, Android 8.0+ / API 26+).
NFR3: Performance et latence au comptoir : enregistrement de vente rapide < 1.5s, validation locale de clôture < 1s, affichage et scan du QR Code < 1s.
NFR4: Sécurité et intégrité cryptographique : stockage sécurisé des clés dans flutter_secure_storage exclu des sauvegardes cloud, signature asymétrique Ed25519 garantissant l'infalsifiabilité des attestations.
NFR5: Accessibilité et ergonomie : cibles tactiles minimales de 48dp x 48dp, contraste visuel conforme WCAG AA sur fond blush, grands chiffres de caisse lisibles à 1 mètre, support d'Android Dynamic Type.
NFR6: Sobriété réseau et gestion batterie : capsules audio compressées en Opus mono @ 32 kbps (~160 Ko/capsule), synchronisation de fond (WorkManager) conditionnée à une connectivité stable et batterie > 15%.
NFR7: Conformité et neutralité financière : aucun décaissement direct de prêt, aucun portage de bilan ni risque de crédit porté par l'application (tiers de confiance indépendant).

### Additional Requirements

- Mise en place du Starter Template Flutter sous Clean Architecture en 3 couches strictes (presentation -> domain <- data), injection de dépendances via get_it et injectable, zéro import Flutter dans domain.
- Configuration de la base de données Drift SQLite en mode WAL (journal_mode = WAL, synchronous = NORMAL), indexation (closure_id, status, debtor_id, sync_status) et pagination bornée (limit 50) pour prévenir les OOM sur Android Go.
- Séparation CQRS locale stricte : Query UseCases retournant des Stream<T> Drift observés par les BLoCs via emit.forEach, Command UseCases atomiques retournant des Result<T, Failure>.
- Snapshotting atomique et scellement temporel de la clôture : figement de cutoff_timestamp à l'ouverture du formulaire de clôture et assignation atomique de closure_id aux ventes orphelines antérieures.
- Règle de réconciliation caisse-dettes : Encaisse_Theorique = Ventes_Comptant_Especes + Remboursements_Dettes_Especes - Depenses_Especes ; les ventes à crédit sont catégorisées CREDIT_CLIENT et exclues des espèces attendues.
- Chaîne de confiance PKI et QR compact : homologation de la clé publique de boutique par la Tekki Root CA, encodage CBOR et Base45, dérivation dynamique du PIN 4-chiffres par HMAC-SHA256(Signature, Timestamp_Minute).
- Table sync_outbox locale avec client_event_id (UUID v4) pour garantir l'idempotence stricte des synchronisations serveur dès le rétablissement de la connectivité.

### UX Design Requirements

UX-DR1: Système de Tokens et Thème Visuel Tekki : Implémentation fidèle des jetons visuels (fond blush #FEECEA, primaire #133E59, accent focal unique #FF7A41, surface #FFFFFF, secondaire #387387, tertiaire #8CB8C3, accent-soft #FFAE90) sans mode sombre.
UX-DR2: Pile typographique native Android : Configuration des styles Display (28px/800), Title (20px/800), Headline (16px/700), Body (14px/500) et Caption (11px/600) supportant l'agrandissement dynamique système.
UX-DR3: Composant Bouton Focal Unique (button-primary-cta) : Widget rectangulaire arrondi (16px) avec fond orange accent, hauteur min 52dp, retour haptique 20ms et verrouillage anti-double-clic dès le premier tap.
UX-DR4: Composant Pavé Numérique de Vente Rapide (quick-sale-keypad) : Panneau inférieur (bottom sheet) avec touches géantes (min 60dp), afficheur display, saisie d'entiers FCFA sans décimales et fermeture ultra-rapide (< 1.5s).
UX-DR5: Composant Lecteur Audio Conseiller (audio-capsule) : Lecteur compact au format note vocale WhatsApp avec bordure gauche orange, bouton circulaire Play/Pause, onde visuelle, sélecteur Wolof/Français et pause sur interruption système.
UX-DR6: Composant Carte Dette Karné Bor (debt-card) : Carte interactive avec montant restant dû, badge d'alerte retard avec icône, bouton d'encaissement partiel/total et bouton de relance 1-clic ouvrant WhatsApp avec message pré-rempli poli.
UX-DR7: Composant Carte Passeport Financier (passport-qr-card) : Affichage plein écran du QR Code (150x150dp, marge 8dp), boost automatique de luminosité Android, badge PIN 4-chiffres dynamique et bouton de partage PDF WhatsApp.
UX-DR8: Système de Microcopie Bienveillante : Intégration des libellés en Français simplifié et Wolof, bannissement strict du jargon comptable (remplacé par "Ventes du jour", "Argent dehors", "Caisse du soir", "Mon Passeport").
UX-DR9: États d'Interface & Accessibilité Visuelle : Empty states motivants avec illustrations positives, feux tricolores doublés d'icônes de forme (✓ Vert, ⏳ Orange, ! Rouge) et retours sonores feutrés de tiroir-caisse aux validations.
UX-DR10: Iconographie Conforme à l'Identité Visuelle : Toute icône ou élément graphique utilisé dans l'application doit respecter rigoureusement la palette et la grammaire visuelle Tekki (couleurs primaire #133E59, secondaire #387387, tertiaire #8CB8C3, accent #FF7A41), sous format vectoriel épuré et optimisé, sans styles disparates ni dégradés non homologués.

### FR Coverage Map

- **FR1 (Saisie rapide au fil de l'eau)** : Epic 1 — Caisse Express & Enregistrement Hybride des Ventes
- **FR2 (Clôture express du soir)** : Epic 1 — Caisse Express & Enregistrement Hybride des Ventes
- **FR3 (Réconciliation ventes / clôture)** : Epic 1 — Caisse Express & Enregistrement Hybride des Ventes
- **FR4 (Enregistrement d'une dette client)** : Epic 2 — Carnet de Dettes Numérique (Karné Bor)
- **FR5 (Gestion des remboursements/acomptes)** : Epic 2 — Carnet de Dettes Numérique (Karné Bor)
- **FR6 (Relance 1-clic WhatsApp)** : Epic 2 — Carnet de Dettes Numérique (Karné Bor)
- **FR7 (Vélocité de recouvrement & alertes retards)** : Epic 2 — Carnet de Dettes Numérique (Karné Bor)
- **FR8 (Calcul in-app du score de solvabilité)** : Epic 3 — Passeport Financier Infalsifiable & Vérification D2D
- **FR9 (QR Code autonome signé Ed25519)** : Epic 3 — Passeport Financier Infalsifiable & Vérification D2D
- **FR10 (PIN visuel dynamique 4 chiffres)** : Epic 3 — Passeport Financier Infalsifiable & Vérification D2D
- **FR11 (Attestation PDF certifiée WhatsApp)** : Epic 3 — Passeport Financier Infalsifiable & Vérification D2D
- **FR12 (Ancrage géographique passif 200m)** : Epic 1 — Caisse Express & Enregistrement Hybride des Ventes
- **FR13 (Flag d'audit silencieux GPS)** : Epic 1 — Caisse Express & Enregistrement Hybride des Ventes
- **FR14 (Conseiller Tekki & feux tricolores)** : Epic 4 — Conseiller Tekki & Synchronisation Résiliente
- **FR15 (Capsules audio Wolof/Français)** : Epic 4 — Conseiller Tekki & Synchronisation Résiliente
- **FR16 (Synchronisation Outbox idempotente)** : Epic 4 — Conseiller Tekki & Synchronisation Résiliente

## Epic List

### Epic 1: Caisse Express & Enregistrement Hybride des Ventes
Permettre au commerçant d'enregistrer instantanément ses ventes au comptoir en 2 secondes (au fil de l'eau), de clôturer sa journée en 3 étapes en moins de 30 secondes ("Tiroir-Caisse") avec réconciliation automatique non-destructive et ancrage GPS passif silencieux, et d'obtenir une vision nette et immédiate de sa caisse du jour.
**FRs covered:** FR1, FR2, FR3, FR12, FR13
**NFRs & Architecture couverts:** NFR1, NFR2, NFR3, NFR5, AR1 (Starter Clean Architecture), AR2 (Drift WAL), AR3 (CQRS/BLoC), AR4 (Snapshotting clôture), UX-DR1, UX-DR2, UX-DR3, UX-DR4, UX-DR8, UX-DR10.

### Epic 2: Carnet de Dettes Numérique (Karné Bor) & Recouvrement
Permettre au commerçant de consigner ses créances clients sans cahier papier, d'enregistrer les encaissements partiels ou totaux réconciliés avec le tiroir-caisse, de relancer courtoisement les retardataires en 1 clic sur WhatsApp en Wolof/Français, et de suivre sa vélocité de recouvrement.
**FRs covered:** FR4, FR5, FR6, FR7
**NFRs & Architecture couverts:** NFR1, NFR3, NFR5, AR5 (Réconciliation caisse-dettes), UX-DR6, UX-DR8, UX-DR9, UX-DR10.

### Epic 3: Passeport Financier Infalsifiable & Vérification D2D
Permettre au commerçant de convertir son assiduité opérationnelle en un score de réputation financière sur 100 fondé sur 4 piliers, d'afficher un QR Code autonome infalsifiable (Ed25519/CBOR/Base45) avec code PIN dynamique vérifiable d'appareil à appareil (D2D) sans Internet par un agent de crédit, et de partager une attestation officielle PDF certifiée via WhatsApp.
**FRs covered:** FR8, FR9, FR10, FR11
**NFRs & Architecture couverts:** NFR1, NFR2, NFR3, NFR4, NFR7, AR6 (Chaîne de confiance PKI & CBOR/Base45), UX-DR7, UX-DR8, UX-DR10.

### Epic 4: Conseiller Tekki & Synchronisation Résiliente
Permettre au commerçant de monter en compétences de gestion financière grâce à des indicateurs visuels simples (feux tricolores) et des capsules audio courtes hebdomadaires en Wolof et Français, tout en assurant la synchronisation automatique, silencieuse et idempotente des données locales vers le serveur sans risque de blocage ni de perte de données.
**FRs covered:** FR14, FR15, FR16
**NFRs & Architecture couverts:** NFR1, NFR2, NFR6, AR7 (File Outbox & WorkManager), UX-DR5, UX-DR9, UX-DR10.


## Epic 1: Caisse Express & Enregistrement Hybride des Ventes

Permettre au commerçant (détaillant de quartier comme demi-grossiste de marché) d'enregistrer instantanément ses ventes au comptoir en 2 secondes (au fil de l'eau), de clôturer sa journée ou vacation en 3 étapes en moins de 30 secondes ("Tiroir-Caisse") avec réconciliation automatique non-destructive et ancrage GPS passif silencieux, et d'obtenir une vision nette et immédiate de ses encaissements et ventes de la journée.

### Story 1.1: Socle Applicatif, Thème Visuel Tekki & Persistance Locale Drift

As a commerçant (détaillant ou grossiste),
I want une application mobile stable, rapide et fidèle à son identité visuelle chaleureuse,
So that disposer d'un outil de travail fiable qui démarre instantanément 100 % hors-ligne.

**Acceptance Criteria:**

**Given** une installation fraîche de l'application sur un terminal Android (API 26+),
**When** l'application démarre pour la première fois,
**Then** le socle Clean Architecture s'initialise via get_it et injectable avec zéro dépendance Flutter dans la couche domain,
**And** le thème applique les tokens officiels Tekki (fond blush #FEECEA, primaire #133E59, surface #FFFFFF, accent #FF7A41) sans mode sombre,
**And** la base Drift SQLite s'ouvre avec les pragmas journal_mode = WAL et synchronous = NORMAL,
**And** les tables locales shops (nom, latitude/longitude de référence du point de vente, clé publique) et sales (id UUID v4, amount INTEGER, payment_method [ESPECES, MOBILE_MONEY, CREDIT_CLIENT], recorded_at ISO-8601, closure_id nullable, sync_status) sont créées avec index sur closure_id et sync_status.

### Story 1.2: Enregistrement Rapide de Vente au Fil de l'Eau (Quick Sale)

As a commerçant au comptoir (détaillant ou grossiste),
I want enregistrer un montant de vente en 2 touches sur un pavé numérique géant,
So that consigner mes encaissements au fil de l'eau en moins de 2 secondes sans être ralenti par un catalogue d'articles.

**Acceptance Criteria:**

**Given** le commerçant sur l'écran d'accueil,
**When** il clique sur le bouton secondaire "+ Vente rapide",
**Then** une feuille modale inférieure (bottom sheet) s'ouvre immédiatement avec le pavé numérique géant quick-sale-keypad (touches >= 60dp),
**When** le commerçant tape un montant entier en FCFA (sans décimales), sélectionne si besoin le mode d'encaissement (Espèces par défaut, Mobile Money) et appuie sur le bouton de validation,
**Then** une entité Sale est persistée en moins de 1.5 seconde dans la table SQLite sales avec UUID v4 et sync_status = 'pending',
**And** la modale se referme automatiquement avec un micro-retour haptique sans rechargement lourd d'écran.

### Story 1.3: Tableau de Bord Caisse & Suivi des Ventes en Temps Réel

As a commerçant (détaillant ou grossiste),
I want voir immédiatement sur l'écran d'accueil le cumul de mes ventes du jour et l'accès rapide à la clôture,
So that connaître l'état de mon activité en continu et préparer ma fin de journée ou de vacation.

**Acceptance Criteria:**

**Given** l'écran d'accueil ouvert,
**When** des ventes ont été enregistrées au fil de l'eau,
**Then** la carte cash-card affiche le montant total du jour en typographie display géante (lisible à 1 mètre) mis à jour en temps réel via un Stream Drift et BLoC,
**And** si aucune vente n'a été saisie aujourd'hui, un état vide bienveillant affiche : "0 FCFA aujourd'hui. Enregistrez votre première vente ou faites votre clôture de caisse.",
**And** un bouton focal unique orange button-primary-cta "🔒 Clôturer la caisse" est affiché en bas de page, avec cible tactile >= 52dp et verrouillage anti-double-clic.

### Story 1.4: Clôture Express ("Tiroir-Caisse") & Snapshotting Atomique

As a commerçant finalisant son service (fin de journée ou relève),
I want valider ma clôture de caisse consolidée en 3 étapes en moins de 30 secondes,
So that sceller mes comptes de la journée sans risque de doublon avec mes ventes au fil de l'eau.

**Acceptance Criteria:**

**Given** le commerçant ouvrant l'écran de clôture express,
**When** le formulaire s'affiche,
**Then** un instantané temporel cutoff_timestamp = DateTime.now().toUtc() est figé,
**And** l'Étape 1 pré-remplit la somme des ventes rapides non clôturées tout en permettant d'ajuster le chiffre d'affaires total de la période,
**And** l'Étape 2 permet de consigner les dépenses opérationnelles de la période (achats de stock/réassort chez le grossiste, transport, frais divers),
**And** l'Étape 3 permet de déclarer les disponibilités réelles (espèces en tiroir et soldes Mobile Money perçus),
**When** le commerçant valide la clôture,
**Then** une transaction SQL atomique scelle les ventes orphelines antérieures à cutoff_timestamp sous le nouveau closure_id et insère la ligne dans la table daily_closures,
**And** toute vente enregistrée après le cutoff_timestamp demeure orpheline et bascule automatiquement sur la journée comptable suivante.

### Story 1.5: Ancrage Géographique Passif & Flag Silencieux d'Intégrité

As a système Tekki au service de la respectabilité du commerçant,
I want capturer silencieusement la position géographique lors de la clôture de caisse,
So that attester de la régularité d'exploitation au point de vente sans jamais bloquer ni pénaliser le commerçant en cas de réseau instable.

**Acceptance Criteria:**

**Given** la validation de la clôture express par le commerçant,
**When** le cas d'utilisation ProcessDailyClosure s'exécute,
**Then** une capture passive de géolocalisation est sollicitée avec un délai d'expiration strict de 5 secondes,
**And** la distance entre la position relevée et les coordonnées de référence du point de vente (shops) est calculée selon la formule de Haversine,
**And** si la distance est supérieure à 200 mètres ou si le capteur GPS est indisponible, la clôture est enregistrée avec is_flagged_location: true et la distance mesurée, sans afficher d'alerte rouge ni bloquer la validation,
**And** lorsque la clôture est validée avec succès, l'application émet un son chaleureux feutré de tiroir-caisse, une vibration haptique brève et affiche la confirmation de la clôture avec la série en cours (streak).


## Epic 2: Carnet de Dettes Numérique (Karné Bor) & Recouvrement

Permettre au commerçant de consigner ses créances clients sans cahier papier, d'enregistrer les encaissements partiels ou totaux réconciliés avec le tiroir-caisse, de relancer courtoisement les retardataires en 1 clic sur WhatsApp en Wolof/Français, et de suivre sa vélocité de recouvrement.

### Story 2.1: Enregistrement d'une Dette Client & Création du Débiteur dans Drift

As a commerçant accordant un crédit de dépannage à un client,
I want noter rapidement son nom, le montant accordé et la date convenue de remboursement,
So that ne plus rien oublier sans être encombré par un carnet papier susceptible d'être perdu ou taché.

**Acceptance Criteria:**

**Given** le commerçant sur l'onglet Karné Bor,
**When** il clique sur le bouton d'action "+ Noter une Dette Client",
**Then** un formulaire simple s'affiche permettant de saisir le nom du client (ou de sélectionner un client existant), un numéro de téléphone/WhatsApp optionnel, le montant en FCFA entiers et la date d'échéance,
**When** le commerçant valide l'enregistrement,
**Then** les tables locales Drift debtors et debts sont alimentées dans une transaction atomique avec un statut initial ACTIVE, un montant restant dû égal au montant initial et un sync_status = 'pending',
**And** la saisie se valide en moins de 1 seconde et redirige vers la liste des créances avec confirmation visuelle.

### Story 2.2: Tableau de Bord Karné Bor, Total "Argent Dehors" & Suivi des Retards

As a commerçant,
I want consulter en un coup d'œil le montant total de mon argent dehors et voir immédiatement les dettes en retard,
So that savoir qui relancer en priorité sans calcul mental.

**Acceptance Criteria:**

**Given** l'ouverture de l'onglet Karné Bor,
**When** des dettes actives existent en base Drift,
**Then** un bandeau affiche le montant total cumulé sous le libellé clair "Argent dehors" en typographie display,
**And** la liste présente les créances sous forme de composants debt-card triées par urgence (créances échues avec badge d'avertissement orange/rouge et icône d'alerte en tête de liste, suivies des créances à venir),
**And** si aucune dette n'est en cours, un état vide motivant et illustré s'affiche : "Aucun argent dehors ! Vos créances sont toutes à jour.",
**And** la liste est alimentée par un Stream Drift réactif paginé (limit 50).

### Story 2.3: Encaissement de Remboursement & Réconciliation avec le Tiroir-Caisse

As a commerçant recevant un paiement d'un client débiteur,
I want consigner l'acompte ou le solde en un clic et voir cet argent s'ajouter automatiquement à ma caisse physique,
So that tenir mon ardoise à jour et garantir la concordance exacte de mon tiroir-caisse le soir.

**Acceptance Criteria:**

**Given** une dette active sélectionnée sur une debt-card,
**When** le commerçant clique sur le bouton "✓ Encaisser",
**Then** un dialogue propose de régler le solde complet en 1 clic ou de saisir un montant partiel (acompte),
**When** le commerçant valide un encaissement en espèces,
**Then** une ligne debt_payments est insérée et le montant restant dû de la dette est réduit (passant à SETTLED si le solde atteint 0 FCFA),
**And** le montant perçu en espèces est instantanément consigné dans le journal de caisse comme flux entrant (debt_cash_inflow), participant au calcul d'Encaisse_Theorique de fin de journée,
**And** l'action déclenche un retour sonore de tiroir-caisse et une vibration haptique brève.

### Story 2.4: Relance Client 1-Clic via WhatsApp & Calcul de la Vélocité de Recouvrement

As a commerçant constatant un dépassement d'échéance,
I want envoyer un message de rappel poli et pré-rédigé sur WhatsApp en un seul tap,
So that préserver de bonnes relations avec mon client tout en accélérant la rentrée de ma trésorerie.

**Acceptance Criteria:**

**Given** une créance affichant un dépassement d'échéance,
**When** le commerçant appuie sur le bouton "💬 Relance WhatsApp",
**Then** l'application ouvre l'application WhatsApp du téléphone via url_launcher avec le contact et un message bienveillant pré-rempli en Wolof ou Français formulé sans agressivité,
**And** le moteur du domaine calcule dynamiquement la vélocité de recouvrement (pourcentage des créances recouvrées dans les délais sur 30 jours glissants),
**And** cette vélocité est affichée sous forme de jauge de santé financière sur l'onglet Karné Bor pour encourager la bonne gestion.


## Epic 3: Passeport Financier Infalsifiable & Vérification D2D

Permettre au commerçant de convertir son assiduité opérationnelle en un score de réputation financière sur 100 fondé sur 4 piliers, d'afficher un QR Code autonome infalsifiable (Ed25519/CBOR/Base45) avec code PIN dynamique vérifiable d'appareil à appareil (D2D) sans Internet par un agent de crédit, et de partager une attestation officielle PDF certifiée via WhatsApp.

### Story 3.1: Moteur de Notation In-App du Passeport Financier (4 Piliers)

As a commerçant assidu,
I want que l'application calcule automatiquement mon score de solvabilité sur 100 à partir de mes données réelles,
So that objectiver ma fiabilité financière sans avoir besoin d'un bilan comptable traditionnel.

**Acceptance Criteria:**

**Given** les données de clôtures et de dettes enregistrées sur une période glissante de 30 jours,
**When** le cas d'utilisation CalculateFinancialPassport est déclenché,
**Then** il calcule le score global sur 100 selon la pondération exacte des 4 piliers : régularité des clôtures (35%), vélocité de recouvrement Karné Bor (40%), stabilité géographique anti-fraude (15%), et discipline d'encaisse déclarée (10%),
**And** si le commerçant compte moins de 7 clôtures enregistrées, un état d'encouragement affiche le nombre de clôtures restantes pour débloquer son premier passeport officiel,
**And** le calcul s'exécute en pur Dart sans latence d'affichage ni dépendance réseau.

### Story 3.2: Signature Cryptographique Ed25519, Sérialisation CBOR & Encodage Base45

As a partenaire financier ou agent de crédit examinant un passeport,
I want une charge utile compacte et signée numériquement par la clé de la boutique,
So that avoir la certitude absolue que les chiffres présentés sont infalsifiables et n'ont pas été modifiés localement.

**Acceptance Criteria:**

**Given** un passeport financier calculé,
**When** le service CryptoSignatureService génère la charge exportable,
**Then** la paire de clés Ed25519 du point de vente est gérée via flutter_secure_storage avec exclusion des sauvegardes automatiques Google Drive,
**And** les métriques clés (score, streak, taux de recouvrement, identifiant de clé publique) sont sérialisées en binaire compact CBOR,
**And** la signature Ed25519 (64 octets) est calculée sur la charge utile,
**And** l'ensemble est encodé en Base45 pour garantir une densité de caractères minimale compatible avec un scan optique immédiat en zone blanche (< 1 seconde).

### Story 3.3: Affichage Écran du QR Code Passeport, Boost de Luminosité & Code PIN Dynamique

As a commerçant présentant son passeport à un agent de crédit,
I want un QR Code lisible instantanément même en extérieur ou sous un faible éclairage, et un code de confirmation visuel,
So that faciliter la vérification d'appareil à appareil (D2D) et empêcher toute fraude par capture d'écran.

**Acceptance Criteria:**

**Given** le commerçant ouvrant l'onglet Passeport Financier,
**When** la page PassportOverviewPage s'affiche,
**Then** la luminosité de l'écran Android est temporairement poussée à son maximum pour optimiser le scan optique tiers,
**And** le composant passport-qr-card présente le QR Code centré (150x150dp avec marge blanche de 8dp),
**And** un code PIN visuel à 4 chiffres dérivé par HMAC-SHA256(Signature, Timestamp_Minute) s'affiche sous le code QR avec un indicateur de renouvellement d'une minute, permettant à l'agent de crédit de valider l'instantanéité du scan,
**And** un appui tactile sur le QR Code permet de l'afficher en plein écran.

### Story 3.4: Génération de l'Attestation Officielle PDF Certifiée & Partage 1-Clic WhatsApp

As a commerçant transmettant son dossier à une institution ou un grossiste,
I want générer une attestation PDF officielle et l'envoyer en 1 clic sur WhatsApp,
So that appuyer ma demande de crédit ou de réassort avec un document d'aspect professionnel.

**Acceptance Criteria:**

**Given** un passeport financier actif,
**When** le commerçant clique sur "📲 Partager l'Attestation PDF sur WhatsApp",
**Then** le service PdfGeneratorService génère localement un document PDF vectoriel soigné reprenant l'identité visuelle Tekki (en-tête bleu marine #133E59, score /100, récapitulatif des 4 piliers, QR Code sécurisé et empreinte cryptographique),
**And** l'application déclenche la feuille de partage native Android via share_plus pour expédier le fichier PDF en un clic sur WhatsApp, par email ou via Bluetooth/ShareIt,
**And** le document est généré en moins de 2 secondes sans nécessiter de connexion Internet active.


## Epic 4: Conseiller Tekki & Synchronisation Résiliente

Permettre au commerçant de monter en compétences de gestion financière grâce à des indicateurs visuels simples (feux tricolores) et des capsules audio courtes hebdomadaires en Wolof et Français, tout en assurant la synchronisation automatique, silencieuse et idempotente des données locales vers le serveur sans risque de blocage ni de perte de données.

### Story 4.1: Moteur Déterministe d'Audit & Indicateurs Visuels de Gestion (Feux Tricolores)

As a commerçant consultant son application,
I want des repères visuels simples sur la santé de mon activité (régularité de caisse, état des dettes, trésorerie),
So that comprendre immédiatement mes points forts et les points de vigilance sans jargon comptable.

**Acceptance Criteria:**

**Given** l'historique des ventes, des clôtures et du Karné Bor en base locale,
**When** le cas d'utilisation EvaluateFinancialHealth s'exécute,
**Then** il applique un ensemble de règles déterministes autonomes évaluant les 4 métriques de gestion sans solliciter de serveur distant ni de modèle LLM,
**And** il produit un diagnostic sous forme de feux tricolores systématiquement doublés d'icônes de forme pour l'accessibilité visuelle (✓ Vert = conforme, ⏳ Orange = attention, ! Rouge = urgent),
**And** ces indicateurs sont restitués clairement sur l'onglet Conseiller Tekki et sous forme d'une pastille synthétique discrète sur l'écran d'accueil.

### Story 4.2: Lecteur Audio Conseiller, Capsules Éducatives Bilingues & Cache Local

As a commerçant préférant l'écoute orale aux textes longs,
I want écouter une courte capsule audio de conseil financier (30 à 45s) en Wolof ou en Français,
So that recevoir des conseils pratiques de gestion adaptés à ma boutique au moment de l'ouverture ou de la fermeture.

**Acceptance Criteria:**

**Given** la disponibilité d'une recommandation du Conseiller,
**When** le commerçant visualise le composant audio-capsule sur l'accueil ou l'onglet Conseiller,
**Then** la capsule s'affiche sous forme de carte à bordure gauche orange {colors.accent} avec un bouton Play circulaire et une jauge de progression,
**When** le commerçant appuie sur Play,
**Then** le service audio (just_audio) lit la capsule compressée en format Opus mono @ 32 kbps (~160 Ko),
**And** un sélecteur en un tap permet de basculer instantanément la voix entre le Wolof (prioritaire) et le Français,
**And** en cas d'appel entrant ou de mise en arrière-plan de l'application, la lecture se met automatiquement en pause.

### Story 4.3: File d'Attente Locale Outbox, Idempotence & Synchronisation Résiliente en Tâche de Fond

As a commerçant alternant entre zones de bonne couverture réseau et zones blanches,
I want que mes données locales soient sauvegardées en ligne automatiquement dès que la connexion est rétablie,
So that sécuriser mon historique sans jamais bloquer l'usage de mon application au comptoir.

**Acceptance Criteria:**

**Given** toute création ou modification locale de données métier (vente, dette, remboursement, clôture),
**When** la transaction locale SQLite s'exécute,
**Then** un événement est inséré dans la table sync_outbox avec un identifiant universel client_event_id (UUID v4) et le statut initial PENDING,
**When** le worker de fond (WorkManager) détecte une connexion Internet stable (connectivity_plus) et un niveau de batterie supérieur à 15 %,
**Then** les événements en attente sont transmis au serveur par lot avec le client_event_id comme clé d'idempotence stricte,
**And** dès confirmation du serveur, les entités locales associées passent à sync_status = 'synced' et les entrées traitées de l'outbox sont purgées,
**And** en cas de coupure réseau ou d'indisponibilité du serveur, le worker passe en veille avec un mécanisme de temporisation exponentielle silencieuse sans perturber le commerçant.
