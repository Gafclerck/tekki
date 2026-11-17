# Revue de Vérification Technique & Adéquation Réelle — Architecture Spine Tekki

- **Document audité :** `D:/tekki/_bmad-output/planning-artifacts/architecture/architecture-tekki-2026-11-17/ARCHITECTURE-SPINE.md`
- **Rôle :** Tech Verification & Real-World Fit Reviewer
- **Date :** 17 Novembre 2026
- **Statut de l'évaluation :** **MINOR_FIXES** (Feu Vert sous réserve de compléments de stack et de garde-fous mémoire)

---

## 1. Synthèse Exécutive & Verdict

| Critère d'Évaluation | Résultat | Commentaire |
| :--- | :---: | :--- |
| **Existence & Cohérence de la Stack** | **CONFORME** | Tous les packages et versions déclarés existent sur `pub.dev`, ciblent Dart 3.x / Flutter 3.27+, et s'assemblent sans conflit de bornes de dépendances. |
| **Faisabilité Cryptographique & QR D2D** | **EXCELLENTE** | La chaîne Ed25519 + CBOR + Base45 produit un payload de 140–160 octets (210–240 caractères Base45), logeable dans un QR Version 8–9 (ECC M), parfaitement lisible par une optique mobile 5–8 MP. |
| **Performance sur Android Go (1–2 Go RAM)** | **FAISABLE AVEC GARDE-FOUS** | SQLite + Drift via `drift_flutter` consomme peu de RAM (<10 Mo), mais exige impérativement le mode WAL, des streams bornés/paginés et l'indexation pour éviter les freeze GC. |
| **Complétude de la Stack (Missing Packages)** | **INCOMPLET (6 manquants)** | Des packages clés mentionnés dans les flux métier (`workmanager`, `connectivity_plus`, `uuid`, `path_provider`, `http`, `base45`) sont absents du tableau `## Stack`. |

**Verdict Global : MINOR_FIXES**  
L'architecture est solide, moderne et particulièrement bien pensée pour le contexte ouest-africain. Les corrections requises n'altèrent pas les choix de conception fondamentaux mais complètent la liste des dépendances et formalisent les règles d'optimisation mémoire pour Android Go.

---

## 2. Audit Détaillé du Tableau `## Stack`

Chaque package a été vérifié individuellement sur le registre officiel `pub.dev` et confronté aux contraintes de la plateforme cible (Flutter 3.27.4 / Dart 3.6.2 sur Android API 26+).

| Package | Version Spine | Statut pub.dev | Compatibilité Dart / Flutter | Analyse & Rôle Réel |
| :--- | :---: | :---: | :---: | :--- |
| **Flutter SDK** | `3.27.4` | Réelle (Stable) | SDK Système | Moteur Impeller par défaut sur Android, gestion améliorée des isolates d'arrière-plan, espacement natif `Row`/`Column`. |
| **Dart SDK** | `3.6.2` | Réelle (Stable) | SDK Système | Support des workspaces pub, séparateurs de chiffres (`1_000_000`), exhaustivité du pattern matching. |
| **flutter_bloc** | `9.1.1` | Réelle (Stable) | Dart >=3.0, Flutter >=3.24 | Conforme. Version moderne, gestion optimisée des sélecteurs et providers sans fuite de mémoire. |
| **drift** | `2.24.2` | Réelle (Stable) | Dart >=3.0 | Conforme. Support de `jsonb`, requêtes de flux réactifs typés, interceptors. |
| **drift_flutter** | `0.3.1` | Réelle (Stable) | Dart >=3.0, Flutter >=3.10 | **Critique :** Fournit l'initialisation universelle `driftDatabase` et le partage multi-isolates (`shareAcrossIsolates: true`). |
| **get_it** | `8.0.3` | Réelle (Stable) | Dart >=3.0 | Conforme. Service locator ultra-léger et rapide sans overhead de build tree. |
| **injectable** | `2.5.0` | Réelle (Stable) | Dart >=3.0 | Conforme. Générateur d'injection de dépendances pour `get_it`. |
| **cryptography** | `2.7.0` | Réelle (Stable) | Dart >=3.1 | Conforme. Algorithmes cryptographiques purs (Ed25519, SHA-512). |
| **cryptography_flutter** | `2.7.0` | Réelle (Stable) | Flutter >=3.0 | **Critique :** Accélération native Android des signatures Ed25519 (< 1 ms par opération). |
| **cbor** | `6.3.0` | Réelle (Stable) | Dart >=3.0 | Conforme. Sérialisation binaire standardisée RFC 8949 ultra-compacte. |
| **qr_flutter** | `4.1.0` | Réelle (Stable) | Flutter >=3.7 | Conforme. Rendu vectoriel Flutter natif via `CustomPainter` sans passerelle webview. |
| **just_audio** | `0.9.44` | Réelle (Stable) | Flutter >=3.0 | Conforme. Moteur audio léger, lecture sans faille des assets locaux et fichiers mis en cache. |
| **geolocator** | `13.0.2` | Réelle (Stable) | Flutter >=3.0, Android API 21+ | Conforme. Acquisition GPS avec support de timeout strict natif (`timeLimit`). |
| **pdf** | `3.11.2` | Réelle (Stable) | Dart >=3.0, Flutter >=3.0 | Conforme. Moteur PDF pur Dart sans dépendance à une bibliothèque native externe. |
| **share_plus** | `10.1.4` | Réelle (Stable) | Flutter >=3.3 | Conforme. Déclenchement propre de la feuille de partage native Android (envoi vers WhatsApp). |
| **flutter_secure_storage** | `9.2.4` | Réelle (Stable) | Flutter >=3.0, Android API 18+ | Conforme. Chiffrement matériel via Android Keystore / EncryptedSharedPreferences. |
| **build_runner** | `2.4.14` | Réelle (Dev) | Dart >=3.0 | Conforme. Outil standard d'orchestration de code generation. |
| **drift_dev** | `2.24.2` | Réelle (Dev) | Dart >=3.0 | Conforme. Générateur de code des DAO et tables Drift. |
| **injectable_generator** | `2.6.2` | Réelle (Dev) | Dart >=3.0 | Conforme. Générateur des modules d'injection `get_it`. |

---

## 3. Faisabilité du Passeport Financier : Signature Ed25519 + CBOR + QR Code D2D

### 3.1. Calcul Précis de la Charge Utile (Payload Breakdown)

Pour un passeport financier autonome certifiant 30 jours d'activité, les données nécessaires au contrôle par un agent d'IMF sont réparties comme suit :

| Champ | Type / Encodage CBOR | Taille Binaire |
| :--- | :---: | :---: |
| **Version Schema** | `uint8` | 1 octet |
| **Shop ID / UUID** | `byte string (16)` ou UUID brut | 16 octets |
| **Timestamp Émission (UTC)** | `uint32` (Secondes Unix) | 4 octets |
| **Timestamp Expiration** | `uint32` (Secondes Unix, +30j) | 4 octets |
| **Score Global Tekki** | `uint16` (0 à 1 000 points) | 2 octets |
| **Score Détails (4 axes)** | 4 × `uint8` (Régularité, Dette, GPS, Encaisse) | 4 octets |
| **Agrégats Métier Clés (30j)** | CA total (`uint32`: 4o), Clôtures valides (`uint8`: 1o), Anomalies GPS (`uint8`: 1o), Vélocité dette (`uint8`: 1o), Ratio impayés (`uint8`: 1o) | 8 octets |
| **Overhead structure CBOR** | Balises d'entêtes map/array (RFC 8949) | ~8 octets |
| **Sous-total Données Métier** | — | **~48 octets** |
| **Clé Publique Ed25519 (ou ID)** | Clé publique brute 32 octets (ou ID boutique 16 octets) | 32 octets |
| **Signature Cryptographique Ed25519** | Signature asymétrique brute (RFC 8032) | **64 octets** |
| **Total Enveloppe Binaire Signée** | — | **144 à 152 octets** |

### 3.2. Encodage Base45 & Capacité QR Code

1. **Raison d'être de Base45 (RFC 9285) :**  
   L'encodage Base45 compresse 2 octets binaires en 3 caractères alphanumériques.
   Pour 150 octets binaires :  
   $$\text{Longueur Base45} = \lceil 150 / 2 \rceil \times 3 = 225 \text{ caractères alphanumériques}$$
   Ces caractères appartiennent exclusivement au jeu Alphanumérique standard des QR Codes (`0-9`, `A-Z`, espace, `$`, `%`, `*`, `+`, `-`, `.`, `/`, `:`), qui n'occupe que **5,5 bits par caractère** (contre 8 bits en mode Byte), maximisant la tolérance et minimisant la densité des modules.

2. **Matrice de Sélection de Version QR Code (Mode Alphanumérique) :**

| Version QR | Modules | Capacité Niveau L (~7%) | Capacité Niveau M (~15%) | Capacité Niveau Q (~25%) | Adéquation pour Tekki (225 car.) |
| :---: | :---: | :---: | :---: | :---: | :--- |
| **Version 6** | 41 × 41 | 195 car. | 154 car. | 108 car. | Insuffisant |
| **Version 7** | 45 × 45 | 224 car. | 178 car. | 125 car. | Limite haute en L |
| **Version 8** | 49 × 49 | **279 car.** | **221 car.** | 157 car. | **Excellente en Niveau L / M** |
| **Version 9** | 53 × 53 | **335 car.** | **262 car.** | **189 car.** | **Idéale en Niveau M (Recommandée)** |
| **Version 10** | 57 × 57 | **395 car.** | **311 car.** | **221 car.** | **Idéale en Niveau M ou Q** |

3. **Scannabilité Optique Réelle D2D :**
   - **Taille à l'écran :** Un QR code Version 9 (53 × 53 modules) affiché à 240 dp sur un écran de smartphone de 6 pouces mesure environ 52 mm × 52 mm.
   - **Taille de module :** Chaque module mesure ~0,98 mm.
   - **Capteur de décodage :** N'importe quel capteur photo basique (5 MP ou 8 MP, même sans autofocus laser) distingue parfaitement des modules de 1 mm à une distance de 15 à 25 cm en **moins de 300 millisecondes**.
   - **Robustesse :** Le niveau de correction d'erreur **M (15 %)** permet de tolérer les reflets de soleil fréquents sur les marchés sénégalais ou de micro-rayures sur la vitre de l'appareil.

---

## 4. Faisabilité SQLite Réactif & Sync d'Arrière-Plan sur Android Go (1–2 Go RAM)

### 4.1. Empreinte Mémoire & Concurrence SQLite (WAL Mode)

Sur les terminaux Android Go (1 Go à 2 Go de RAM totale), la mémoire allouée à chaque application (heap VM) est bridée par le système entre **128 Mo et 192 Mo**. Le daemon `lmkd` (Low Memory Killer) purge sans préavis les processus consommant des ressources excessives.

1. **Empreinte Drift / SQLite :**
   Le moteur `sqlite3` compilé en C consomme moins de 4 Mo de mémoire vive résidente pour une base de données de plusieurs mégaoctets. C'est le composant le plus économe de la pile.
2. **Risque Majeur : Streams Non Bornés :**  
   Si un composant UI observe la table des ventes via `select(sales).watch()`, Drift ré-exécute la requête à chaque insertion et instancie la liste complète des objets Dart en mémoire. Après 6 mois d'activité (3 000 à 5 000 ventes), cela provoquerait des pics de garbage collection (GC thrashing) et des saccades visibles.  
   > **Garde-fou obligatoire :** Les requêtes réactives Drift doivent être **strictement bornées** par date (`WHERE recorded_at >= :startOfDay`), limitées (`LIMIT 50`) ou agrégées (`SELECT SUM(amount)`).
3. **Activation Impérative du Mode WAL (Write-Ahead Logging) :**  
   Par défaut, SQLite verrouille l'intégralité du fichier lors d'une transaction d'écriture. Si le worker d'outbox synchronise en tâche de fond pendant que le commerçant enregistre une vente rapide, SQLite lèverait une exception `database is locked`.  
   > **Garde-fou obligatoire :** Configurer explicitement `PRAGMA journal_mode = WAL;` et `PRAGMA busy_timeout = 5000;` lors de l'ouverture de Drift. En mode WAL, les lecteurs (BLoCs UI) ne bloquent jamais les écrivains (Outbox Worker).

### 4.2. Synchronisation Multi-Isolates via `drift_flutter`

`WorkManager` exécute les tâches de fond dans un **Dart Isolate distinct** de l'isolate principal de l'UI.  
Grâce à `drift_flutter: 0.3.1`, le paramètre :
```dart
DriftNativeOptions(shareAcrossIsolates: true)
```
utilise en coulisse `IsolateNameServer` pour router les requêtes du worker de fond vers l'isolate de base de données déjà ouvert, évitant ainsi d'ouvrir deux gestionnaires SQLite concurrents sur le même fichier physique.

---

## 5. Dépendances Manquantes, Incompatibilités & Risques Identifiés

Bien que la sélection de base soit remarquable, six éléments indispensables aux capacités décrites dans l'Architecture Spine sont manquants dans le tableau `## Stack` :

### 5.1. Dépendances Manquantes dans `## Stack`

1. **`workmanager: ^0.10.10`** :  
   - *Justification :* Explicitement cité dans la Section 6 (ligne 467) pour le déclenchement de la vidange d'outbox en tâche de fond selon la connectivité et la batterie.
2. **`connectivity_plus: ^7.3.2`** :  
   - *Justification :* Requis pour implémenter le `ConnectivityObserver` (`core/network/`) et déclencher la vidange immédiate lors du retour du signal 3G/4G/Wi-Fi sans attendre le polling système.
3. **`uuid: ^4.6.0`** :  
   - *Justification :* Spécifié dans AD-3 et les conventions de cohérence pour générer les `client_event_id` et IDs d'entités RFC 4122 côté client en mode déconnecté.
4. **`path_provider: ^2.1.5`** :  
   - *Justification :* Requis pour obtenir le répertoire temporaire de l'application afin d'écrire le fichier PDF certifié généré par `package:pdf` avant de transmettre son URI à `share_plus`.
5. **`http: ^1.6.0`** :  
   - *Justification :* Requis par `RemoteSyncApiClient` (`core/network/` et `features/sync/`) pour les requêtes REST de transmission des lots d'outbox avec timeouts configurables.
6. **Encodage Base45 (`dart_base45: ^1.0.0` ou utilitaire interne)** :  
   - *Justification :* Spécifié dans AD-4. L'algorithme RFC 9285 étant très court (~40 lignes de pur Dart), il peut soit être intégré via `dart_base45`, soit rédigé directement dans `core/crypto/base45.dart` pour éviter une dépendance tierce.

### 5.2. Risque Matériel Réel : Défaillance de l'Android Keystore sur Modèles Low-Cost

Sur certains terminaux Android d'entrée de gamme (API 26 à 28), les composants matériels du Keystore peuvent lever une exception `GeneralSecurityException: Keystore operation failed` ou `AEADBadTagException` suite à une mise à jour d'OS ou une restauration de sauvegarde.
- **Mesure d'atténuation :**
  1. Configurer `android:fullBackupContent` et `android:dataExtractionRules` dans `AndroidManifest.xml` pour exclure `FlutterSecureStorage.xml` des sauvegardes cloud Google Drive.
  2. Encapsuler les lectures de la clé privée Ed25519 dans un wrapper résilient capable d'intercepter ces erreurs sans faire crasher l'application.

### 5.3. Découpage APK pour Respecter le Plafond de 15 Mo

Un binaire universel Flutter `app-release.apk` intégrant le moteur C++, SQLite et Impeller pèse couramment entre 18 et 24 Mo.  
- **Mesure d'atténuation :** La procédure de compilation doit obligatoirement imposer :
  ```bash
  flutter build apk --split-per-abi
  ```
  Cela génère des APK distincts (`armeabi-v7a` pour 32 bits, `arm64-v8a` pour 64 bits) d'un poids unitaire de **8,5 à 11 Mo**, parfaitement conforme au plafond strict de 15 Mo fixé dans le Brief.

---

## 6. Modifications Recommandées pour l'Architecture Spine

Afin d'élever l'Architecture Spine au standard de robustesse maximale, les ajouts suivants doivent être apportés :

### Action 1 : Mettre à jour le tableau `## Stack`
Ajouter les 5 packages officiels manquants :
```markdown
| workmanager | 0.10.10 |
| connectivity_plus | 7.3.2 |
| uuid | 4.6.0 |
| path_provider | 2.1.5 |
| http | 1.6.0 |
```

### Action 2 : Compléter `## Invariants & Rules` avec AD-9 et AD-10

- **AD-9 — Prémunition Mémoire & Streams Drift Bornés [RECOMMENDED] :**  
  *Prevents :* Le plantage par dépassement de mémoire (OOM) et les saccades de Garbage Collection sur les terminaux Android Go (1–2 Go de RAM).  
  *Rule :* Il est formellement interdit d'émettre des `Stream` Drift non bornés sur des tables à forte croissance (`sales`, `sync_outbox`). Toute requête réactive exposée à l'UI doit comporter une clause de restriction temporelle (`WHERE recorded_at >= :startOfDay`), une clause d'agrégation SQL ou une pagination explicite. Le mode WAL (`PRAGMA journal_mode = WAL;`) est actif dès l'initialisation.

- **AD-10 — Sécurisation du Keystore & Exclusion de Sauvegarde [RECOMMENDED] :**  
  *Prevents :* Le blocage au démarrage suite à la corruption de l'Android Keystore sur téléphones reconditionnés ou post-mise à jour.  
  *Rule :* Les règles d'extraction et de sauvegarde Android (`backup_rules.xml`) doivent explicitement exclure les fichiers de préférences chiffrées de `flutter_secure_storage`. Tout accès à la clé privée Ed25519 doit être encapsulé avec gestion d'erreur dédiée.

### Action 3 : Indexation Explicite dans l'ERD Drift
Ajouter des index sur les colonnes clés dans la définition des tables :
- `SALES` : Index sur `(closure_id)` et `(recorded_at DESC)`
- `SYNC_OUTBOX` : Index sur `(status, created_at ASC)`
- `DEBTS` : Index sur `(debtor_id, status)`

---

## 7. Conclusion

L'architecture technique de **Tekki** est technologiquement viable, remarquablement alignée sur les contraintes locales ouest-africaines et bâtie sur des composants pérennes. L'intégration des quelques dépendances manquantes et des règles d'hygiène mémoire Android Go consolidera définitivement le socle de développement.
