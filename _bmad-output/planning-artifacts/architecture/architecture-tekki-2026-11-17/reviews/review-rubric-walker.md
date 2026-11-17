# Architecture Spine Review — Rubric Walker

- **Target Document:** [`ARCHITECTURE-SPINE.md`](file:///D:/tekki/_bmad-output/planning-artifacts/architecture/architecture-tekki-2026-11-17/ARCHITECTURE-SPINE.md)
- **Reviewer Lens:** Rubric Walker (Good-Spine Checklist & Operational Alignment)
- **Inputs Evaluated:**
  - Product Brief: [`brief.md`](file:///D:/tekki/_bmad-output/planning-artifacts/briefs/brief-tekki-2026-11-17/brief.md) & [`addendum.md`](file:///D:/tekki/_bmad-output/planning-artifacts/briefs/brief-tekki-2026-11-17/addendum.md)
  - UX Specifications: [`EXPERIENCE.md`](file:///D:/tekki/_bmad-output/planning-artifacts/ux-designs/ux-tekki-2026-11-17/EXPERIENCE.md) & [`DESIGN.md`](file:///D:/tekki/_bmad-output/planning-artifacts/ux-designs/ux-tekki-2026-11-17/DESIGN.md)
  - Working Memory: [`.memlog.md`](file:///D:/tekki/_bmad-output/planning-artifacts/architecture/architecture-tekki-2026-11-17/.memlog.md)
- **Date:** 2026-11-17
- **Verdict:** **MINOR_FIXES**

---

## 1. Executive Summary

L'architecture proposée dans `ARCHITECTURE-SPINE.md` pour l'application mobile **Tekki** est d'un niveau de conception et de maturité remarquable. Le choix d'une **Clean Architecture stricte en 3 couches** (Domain en Dart pur, Data, Presentation) couplée à un pattern **Offline-First Reactive Outbox** s'aligne fidèlement sur les contraintes critiques du secteur informel sénégalais : absence de connectivité fiable, terminaux Android d'entrée de gamme, et zéro tolérance pour la latence au comptoir.

Les principes directeurs (indépendance du domaine, interdiction de blocage réseau, transactions atomiques locales, intégrité cryptographique Ed25519 hors-ligne) sont formulés avec clarté et précision. 

Le verdict est **MINOR_FIXES** car quelques omissions techniques ciblées (dépendances indispensables manquantes dans la table `Stack`, dimensionnement de la charge audio pour respecter le plafond de 15 Mo de l'APK, et explicitation du rôle du code PIN à 4 chiffres décrit dans l'UX vis-à-vis du QR Code cryptographique) doivent être résolues pour éviter toute divergence d'implémentation lors du passage aux epics et stories.

---

## 2. Evaluation against the Good-Spine Checklist

### Criterion 1: Fixes real divergence points for the level below and misses none
- **Evaluation:** **SATISFACTORY (with 2 minor ambiguities)**
- **Analysis:**
  - La spine couvre l'ensemble des 6 capacités maîtresses : `CAP-SALES-HYBRID`, `CAP-KARNE-BOR`, `CAP-FINANCIAL-PASSPORT`, `CAP-ADVISOR`, `CAP-GPS-ANCHOR`, `CAP-OFFLINE-SYNC`.
  - Les conventions d'homogénéité (identifiants UUID v4, montants en FCFA entiers sans virgule flottante, horodatages ISO-8601 UTC, gestion fonctionnelle des erreurs par types scellés Dart 3 `Result<T, Failure>`) préviennent efficacement les incompatibilités entre modules.
  - **Ambiguïté 1 (Lien Ventes <-> Clôture) :** Dans l'AD-5 et l'ERD, l'entité `SALES` possède un champ `closure_id` nullable, mais la règle stipule que la clôture s'effectue "sans écraser ni dupliquer les micro-ventes". Il convient de préciser si la validation de la clôture exécute une mise à jour SQL atomique associant les ventes ouvertes à l'ID de clôture (`UPDATE sales SET closure_id = :id WHERE closure_id IS NULL AND recorded_at <= :closureTime`), ou si l'agrégation repose uniquement sur un intervalle temporel.
  - **Ambiguïté 2 (Vérification D2D & Code PIN) :** Dans `EXPERIENCE.md` (Flow 3), l'agent de crédit scanne le QR code et saisit un code PIN temporaire à 4 chiffres dicté par le commerçant. Or, l'AD-4 et le diagramme de séquence 3 détaillent uniquement la signature asymétrique Ed25519 sur charge utile CBOR. La nature du PIN (sel visuel, HMAC court, ou affichage d'intégrité) doit être explicitée pour que les développeurs de la feature Passeport sachent comment l'intégrer au flux cryptographique.

### Criterion 2: Every AD's Rule is enforceable and actually prevents its stated divergence
- **Evaluation:** **EXCELLENT**
- **Analysis:**
  - **AD-1 (Clean Architecture) :** La règle est absolue : zéro import Flutter/Drift dans `domain`, dépendances orientées vers l'intérieur. Vérifiable automatiquement par règles de lint ou tests d'architecture.
  - **AD-2 (Offline-First SSOT) :** Interdiction des appels réseau bloquants dans l'UI. Observable par inspection des BLoCs et UseCases.
  - **AD-3 (Outbox & Idempotence) :** Enregistrement de la mutation et de l'outbox dans la même transaction SQLite Drift. Empêche la perte de données ou les états zombies.
  - **AD-4 (Signature Ed25519 & QR CBOR) :** Utilisation de types sérialisables compacts et clés cryptographiques standard.
  - **AD-5 (Ventes Hybrides & Caisse) :** Pré-remplissage dynamique et validation étanchée.
  - **AD-6 (Ancrage GPS Passif) :** Timeout strict de 5 secondes, rayon de 200 m, `is_flagged_location: true` sans blocage de l'UI. Règle parfaitement opérationnelle.
  - **AD-7 (Conseiller Déterministe) :** Moteur de règles in-app sur historique 30 jours, capsules locales `just_audio`. Élimine le risque de dérive vers un LLM distant coûteux.
  - **AD-8 (Gestion d'État BLoC) :** Flux unidirectionnel strict, interdiction de calculs ou requêtes Drift dans les widgets.

### Criterion 3: Nothing under Deferred could let two units diverge incompatibly
- **Evaluation:** **EXCELLENT**
- **Analysis:**
  - Les 4 éléments reportés dans `Deferred` sont :
    1. Choix du fournisseur Cloud backend (GCP/AWS/VPS) ;
    2. Synchronisation multi-terminaux concurrents par boutique ;
    3. Moteur vocal bidirectionnel temps réel (STT/LLM) ;
    4. Intégrations directes par API avec Wave et Orange Money.
  - Ces reports sont sains : ils isolent le périmètre du MVP sans créer de dette technique cachée. Comme le client s'appuie sur une API de synchronisation asynchrone universelle (Outbox avec charge JSON et UUID v4 d'idempotence), le choix ultérieur de l'hébergeur distant n'impacte en rien le développement de l'application mobile.

### Criterion 4: Clean Architecture and SOLID compliance (Domain Independence & DIP)
- **Evaluation:** **EXCELLENT**
- **Analysis:**
  - **Domain Independence :** La couche `domain` est rigoureusement cantonnée au SDK pur Dart 3.6+. L'utilisation des types scellés Dart 3 (`sealed class Result<T, Failure>`) pour la gestion des résultats évite d'importer des packages fonctionnels tiers (`dartz`, `fpdart`) dans le noyau métier.
  - **DIP (Dependency Inversion) :** Les cas d'utilisation manipulent exclusivement des interfaces de dépôts (`ISalesRepository`, `IDebtRepository`, `IPassportRepository`, `IAdvisorRepository`, `ISyncRepository`). L'infrastructure (`drift`, capteurs natifs, stockage sécurisé) implémente ces contrats dans la couche `data`. L'injection de dépendances est gérée de manière déclarative via `get_it` et `injectable`.
  - **ISP & SRP :** Les interfaces sont découpées et spécialisées, les cas d'utilisation portent une intention unique.

### Criterion 5: Operational envelope (Android Go, 1-2GB RAM, APK <15MB, Offline-First)
- **Evaluation:** **PASS WITH CONDITIONS (2 points d'attention)**
- **Analysis:**
  - **Performance sur terminaux 1-2 Go RAM (Android Go) :**
    - L'absence d'ombres portées complexes (spécifiée dans `DESIGN.md`), la gestion d'état unidirectionnelle sans reconstructions globales d'arbres de widgets, et la légèreté de Drift/SQLite garantissent une excellente fluidité sur SoC modeste.
    - *Point d'attention :* Les mécanismes de tâches de fond d'Android Go tuent agressivement les processus persistants. L'exécution de la vidange d'Outbox doit privilégier les événements de reprise d'application au premier plan (`WidgetsBindingObserver`) et l'écoute réactive du réseau (`ConnectivityObserver`), plutôt que de s'en remettre uniquement à un `WorkManager` susceptible d'être endormi par le système.
  - **Contrainte de taille d'APK (< 15 Mo) :**
    - L'utilisation des polices système Android (`Roboto`), de SVG compilés et du tree-shaking Flutter permet de contenir le socle de base entre 9 et 11 Mo.
    - *Condition critique :* L'AD-7 prévoit des capsules audio en Wolof et Français pour le Conseiller. Si ces capsules sont embarquées brutes dans les assets de l'APK, quelques dizaines de mégaoctets d'audio feraient exploser le plafond des 15 Mo. La spine doit fixer la règle d'encodage audio (ex. Opus/AAC mono à 32 kbps, soit ~120 Ko par capsule de 30s) et acter que seul un set initial minimal est embarqué dans l'APK, le reste étant téléchargé de façon transparente lors des synchronisations.
  - **Mécanismes Offline-First :** 100 % conformes aux exigences du brief et de l'expérience utilisateur.

---

## 3. Detailed Findings & Recommendations

### Finding 1 [HIGH] — Dépendances indispensables omises dans la table `Stack`
- **Constat :** Plusieurs fonctionnalités spécifiées dans les ADs et les flux UX requièrent des packages qui ne figurent pas dans la table `Stack` (lignes 141-162) :
  1. `url_launcher` : Indispensable pour la relance 1-clic sur WhatsApp dans le Karné Bor (`WhatsAppLauncher`).
  2. `connectivity_plus` : Indispensable pour le composant `ConnectivityObserver` (`lib/core/network/`) et le déclenchement réactif de l'Outbox.
  3. `uuid` : Indispensable pour la génération des clés primaires et identifiants d'idempotence RFC 4122 v4 côté client (AD-3).
  4. `intl` : Indispensable pour le formatage des devises en FCFA ("94 500 F") et la gestion de la localisation (Wolof / Français).
  5. `base45` : Indispensable pour l'encodage compact de la charge utile CBOR signée dans le QR Code (AD-4).
- **Impact :** Risque d'incohérence de versions ou de blocage lors de l'implémentation des premières stories si les développeurs ajoutent des versions disparates.
- **Action corrective recommandée :** Compléter la table `Stack` avec les versions vérifiées compatibles Flutter 3.27 / Dart 3.6 :
  - `url_launcher: 6.3.1`
  - `connectivity_plus: 6.1.1`
  - `uuid: 4.5.1`
  - `intl: 0.19.0`
  - `base45: 0.0.3` (ou utilitaire interne Dart sous `lib/core/crypto/`).

### Finding 2 [HIGH] — Budget et stratégie de distribution des capsules audio (Plafond APK < 15 Mo)
- **Constat :** L'AD-7 mentionne la lecture de capsules audio de 30 à 45 secondes en Wolof et Français depuis le bundle d'actifs local ou le stockage applicatif. Sans directive de compression stricte, les assets audio peuvent facilement dépasser la taille totale allouée à l'application.
- **Impact :** Dépassement du seuil impératif de 15 Mo de l'APK sur le Play Store ou en transfert Bluetooth de terminal à terminal.
- **Action corrective recommandée :** Ajouter dans l'AD-7 et dans la section *Déploiement et Enveloppe Opérationnelle* :
  - Format audio normé : **Opus** ou **AAC-LC mono**, échantillonnage 24 kHz, débit binaire bridé à **32 kbps** (poids unitaire d'une capsule de 40s : ~160 Ko).
  - Politique de bundle : Seules les 2 capsules de bienvenue/onboarding (1 Wolof, 1 Français) sont intégrées dans les assets de l'APK (~320 Ko). Les capsules hebdomadaires suivantes sont distribuées via le canal de synchronisation entrant et mises en cache dans le répertoire applicatif local.

### Finding 3 [MEDIUM] — Articulation du QR Code Ed25519 et du Code PIN à 4 chiffres (D2D)
- **Constat :** Dans `EXPERIENCE.md` (Composant `passport-qr-card` et Flow 3), un code PIN à 4 chiffres temporaire est affiché sous le QR Code pour être dicté à l'agent de crédit. L'AD-4 n'explicite pas le rôle de ce PIN dans le modèle cryptographique.
- **Impact :** Risque de divergence entre l'équipe UI (qui traite le PIN comme un simple affichage cosmétique) et l'équipe métier (qui pourrait tenter d'en faire une clé de dérivation de chiffrement sans mécanisme offline partagé).
- **Action corrective recommandée :** Clarifier dans l'AD-4 que le code PIN à 4 chiffres est une **somme de contrôle visuelle à validité temporelle (Short Visual Authentication String)** dérivée des derniers octets de la signature Ed25519 (ou d'un horodatage UTC par tranche de 10 minutes). Il permet à l'agent de crédit de confirmer visuellement sur son propre écran que le scan correspond bien au terminal physique du commerçant en face de lui, sans nécessiter de connexion réseau.

### Finding 4 [MEDIUM] — Précision de la liaison transactionnelle `Sale` <-> `DailyClosure`
- **Constat :** L'AD-5 décrit le pré-remplissage de la clôture express à partir de la somme des ventes unitaires du jour, mais ne formalise pas la mise à jour d'état des entités `Sale`.
- **Impact :** Risque d'hésitation dans l'implémentation de `ProcessDailyClosureUseCase` : doit-on modifier le statut des ventes pour les lier à la clôture, ou calculer l'agrégat à la volée par requête temporelle ?
- **Action corrective recommandée :** Préciser dans l'AD-5 que la validation de la clôture journalière exécute au sein de la transaction SQLite :
  1. L'insertion de l'enregistrement `DailyClosure` ;
  2. La mise à jour en masse des ventes du jour en positionnant `closure_id = closure.id` pour sceller définitivement la période comptable ;
  3. L'insertion de l'événement correspondant dans `sync_outbox`.

### Finding 5 [LOW] — Emplacement architectural de `GpsLocationService`
- **Constat :** Dans l'arborescence `lib/` (ligne 404), `GpsLocationService` est placé sous `features/sales_and_cash/data/datasources/`.
- **Impact :** Bien que l'ancrage GPS ne soit consommé au MVP que lors de la clôture, un service de géolocalisation matériel constitue une brique périphérique transversale. Le placer dans une feature spécifique complique sa réutilisation éventuelle (ex. onboarding de la boutique, vérification sur le terrain).
- **Action corrective recommandée :** Déclarer le contrat `ILocationService` dans `lib/core/device/` (ou `lib/core/services/`) avec son implémentation `GpsLocationServiceImpl`, et injecter cette interface dans le dépôt de clôture.

---

## 4. Alignment Matrix

| Document Source | Exigence Clé | Prise en compte dans ARCHITECTURE-SPINE.md | Statut |
| :--- | :--- | :--- | :--- |
| **Brief** | 100 % Offline-First & Zéro portail web hébergé | AD-2, AD-4 : Données locales Drift, QR Code D2D Base45 | **CONFORME** |
| **Brief** | Aucune saisie article par article obligatoire | AD-5 : Ventes unitaires directes par montant & Caisse express | **CONFORME** |
| **Brief** | Pas de prêt direct Tekki / Zéro risque de bilan | Section Périmètre & Invariants (Passeport d'attestation pur) | **CONFORME** |
| **Brief & UX** | Ancrage GPS passif 200m silencieux (sans blocage) | AD-6 : Timeout 5s, flag silencieux `is_flagged_location` | **CONFORME** |
| **UX & Design** | Conseiller Tekki en Wolof & Français (30-45s) | AD-7 : Moteur déterministe `domain`, lecteur `just_audio` | **CONFORME (avec réserve budget audio)** |
| **UX & Design** | Performance Android Go (1-2 Go RAM) & APK < 15 Mo | Section 6, BLoC AD-8, typographie native Android | **CONFORME (avec réserve dépendances)** |
| **UX & Design** | Relance 1-clic WhatsApp Karné Bor | Arborescence `WhatsAppLauncher`, entités de dettes | **CONFORME (ajouter `url_launcher`)** |

---

## 5. Conclusion & Next Steps

L'architecture est d'une grande rigueur structurelle et respecte fidèlement les préceptes de Clean Architecture et les besoins du terrain. Les corrections demandées sont mineures et чисто techniques (ajouts de packages dans la table Stack, précisions algorithmiques sur le PIN et la liaison vente-clôture, et cadrage de la compression audio).

**Recommandation :** Appliquer ces ajustements dans `ARCHITECTURE-SPINE.md` pour passer l'état du document à `final` et sécuriser la phase d'implémentation des epics.
