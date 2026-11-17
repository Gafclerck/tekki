# Epic 3 Context: Passeport Financier Infalsifiable & Vérification D2D

<!-- Generated from planning artifacts. Regenerate with compile-epic-context if planning docs change. -->

## Goal

Permettre au commerçant de convertir son assiduité opérationnelle en un score de réputation financière sur 100 fondé sur 4 piliers, d'afficher un QR Code autonome infalsifiable (Ed25519/CBOR/Base45) avec code PIN dynamique vérifiable d'appareil à appareil (D2D) sans Internet par un agent de crédit ou grossiste, et de partager une attestation officielle PDF certifiée via WhatsApp.

## Stories

- Story 3.1: Moteur de Notation In-App du Passeport Financier (4 Piliers)
- Story 3.2: Signature Cryptographique Ed25519, Sérialisation CBOR & Encodage Base45
- Story 3.3: Affichage Écran du QR Code Passeport, Boost de Luminosité & Code PIN Dynamique
- Story 3.4: Génération de l'Attestation Officielle PDF Certifiée & Partage 1-Clic WhatsApp

## Requirements & Constraints

- **Fonctionnement 100 % Offline-First (NFR1)** : SQLite/Drift comme unique source de vérité locale. Calcul de score, signature et affichage de QR Code s'exécutent entièrement en local sans connexion Internet.
- **Performance et latence (NFR3)** : Calcul du score en pur Dart sans latence, affichage et scan du QR Code < 1s, génération du PDF certifié < 2s.
- **Sécurité et intégrité cryptographique (NFR4)** : Gestion des clés Ed25519 dans `flutter_secure_storage` exclue des sauvegardes cloud. Signature asymétrique Ed25519 garantissant l'infalsifiabilité des attestations.
- **Neutralité financière (NFR7)** : Aucun décaissement de prêt ni portage de risque de crédit dans l'application ; Tekki agit en tiers de confiance indépendant émetteur de passeport.
- **Calcul de réputation in-app (FR8)** : Score global sur 100 sur une période glissante de 30 jours selon 4 piliers pondérés :
  1. Régularité des clôtures journalières (35 %) — seuil recommandé 20 à 22 clôtures/mois.
  2. Vélocité de recouvrement du Karné Bor (40 %) — délai moyen de règlement et taux de créances en souffrance.
  3. Stabilité géographique anti-fraude (15 %) — proportion de clôtures dans le rayon de cohérence de 200 m.
  4. Discipline d'épargne ou encaisse résiduelle déclarée (10 %) — constance du solde de caisse restant en fin de journée.
- **Seuil d'éligibilité (FR8 / UX)** : Si moins de 7 clôtures sont enregistrées en base, le passeport est en état d'encouragement affichant le nombre de clôtures restantes pour débloquer le premier passeport officiel.
- **QR Code sécurisé autonome (FR9)** : Charge binaire sérialisée en CBOR, signée en Ed25519 (64 octets), encodée en Base45.
- **Code PIN visuel anti-rejeu (FR10)** : PIN dynamique à 4 chiffres dérivé par `HMAC-SHA256(Signature, Timestamp_Minute)` renouvelé chaque minute.
- **Attestation PDF certifiée (FR11)** : Export vectoriel aux couleurs Tekki (#133E59, #FF7A41) partageable en 1-clic via WhatsApp via `share_plus`.

## Technical Decisions

- **Clean Architecture 3 couches** : Découpage strict `presentation -> domain <- data`. La couche `domain` (`features/financial_passport/domain/`) est en pur Dart (zéro import Flutter ni Drift).
- **Moteur de scoring (`PassportScoringPolicy` / `CalculateFinancialPassportUseCase`)** :
  - `CalculateFinancialPassportUseCase` agrège les données des 30 derniers jours à partir de `daily_closures` et `debts`/`debt_payments`.
  - Retourne une entité `FinancialPassportEntity` contenant le score global (/100), le détail des 4 piliers (`ScoreBreakdownEntity`), le streak de clôtures, le nombre total de clôtures sur 30 jours, et l'éligibilité (actif vs encouragement < 7 clôtures).
- **Chaîne de confiance PKI & Sécurité (AD-4, AD-11)** :
  - Clé privée boutique stockée dans `flutter_secure_storage` (Keystore Android avec `android:fullBackupContent` désactivant la sauvegarde Google Drive).
  - Signature asymétrique Ed25519 via `cryptography` / `cryptography_flutter`.
  - Format binaire compact CBOR via `cbor` et encodage Base45 via `dart_base45`.
  - Dérivation du PIN 4 chiffres par HMAC-SHA256 tronqué sur l'horodatage minute UTC.
- **Export & Partage PDF** :
  - Génération de document vectoriel via package `pdf`.
  - Partage natif via `share_plus` (WhatsApp, Bluetooth, etc.).
- **Gestion d'état BLoC (AD-8)** :
  - `PassportBloc` écoute les changements ou calcule à la demande l'état du passeport pour l'UI.

## UX & Interaction Patterns

- **Composant Carte Passeport (`passport-qr-card`) (UX-DR7, DESIGN.md)** :
  - QR Code centré (150x150dp avec marge blanche 8dp).
  - Boost automatique temporaire de luminosité de l'écran Android à l'ouverture de l'onglet.
  - Badge PIN 4-chiffres dynamique avec jauge de renouvellement 60s.
  - Bouton focal ou secondaire pour le partage PDF WhatsApp.
- **État d'encouragement (< 7 clôtures)** :
  - Message motivant : "Encore X clôtures pour générer votre premier Passeport Financier officiel."
  - Jauge de progression vers le seuil des 7 clôtures.
- **Microcopie Bienveillante** :
  - Vocabulaire positif et valorisant ("Mon Passeport", "Série de clôtures", "Fiabilité financière").
  - Bannir le jargon bancaire anxiogène.

## Cross-Story Dependencies

- **Story 3.1** : Établit le modèle de domaine (`FinancialPassportEntity`, `ScoreBreakdownEntity`), les contrats de repository et le cas d'utilisation de calcul de score `CalculateFinancialPassportUseCase` sur 30 jours basé sur les données Drift de l'Epic 1 (clôtures, GPS) et de l'Epic 2 (dettes, remboursements).
- **Story 3.2** : Dépend du calcul de score de 3.1 pour implémenter la cryptographie Ed25519, la sérialisation CBOR et l'encodage Base45.
- **Story 3.3** : Dépend de 3.1 et 3.2 pour concevoir la page `PassportOverviewPage`, l'affichage du QR Code avec boost de luminosité et le badge PIN dynamique 4 chiffres.
- **Story 3.4** : Dépend de 3.1-3.3 pour générer l'attestation officielle PDF et déclencher le partage 1-clic sur WhatsApp.
