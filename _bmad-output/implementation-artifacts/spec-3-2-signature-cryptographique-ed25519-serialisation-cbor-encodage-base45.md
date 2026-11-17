---
title: 'Signature Cryptographique Ed25519, Sérialisation CBOR & Encodage Base45'
type: 'feature'
created: '2026-11-17'
status: 'done'
baseline_revision: '860ffd2f709b80e30347ddc7e601149dc0a39aba'
review_loop_iteration: 0
followup_review_recommended: false
context:
  - _bmad-output/implementation-artifacts/epic-3-context.md
  - _bmad-output/planning-artifacts/architecture/architecture-tekki-2026-11-17/ARCHITECTURE-SPINE.md
warnings: []
deferred:
  - summary: >-
      Unused redundant dependency dart_base45 in pubspec.yaml
    evidence: |-
      dart_base45 was pre-existing in pubspec.yaml prior to story start; custom RFC 9285 implementation in lib/core/crypto/base45.dart provides both encoding and decoding.
    location: >-
      pubspec.yaml:31
    severity: low
---

<intent-contract>

## Intent

**Problem:** Les attestations de solvabilité et scores financiers présentés par les commerçants peuvent être facilement falsifiés ou contestés s'ils ne disposent pas d'une preuve d'intégrité cryptographique vérifiable d'appareil à appareil (D2D) en zone blanche sans accès Internet.
**Approach:** Implémenter le service cryptographique asymétrique Ed25519 avec gestion sécurisée des clés via `flutter_secure_storage` (exclue des sauvegardes cloud Google Drive), la sérialisation binaire compacte CBOR des métriques du passeport, la signature numérique 64 octets, l'encodage Base45 haute densité et la dérivation du code PIN dynamique anti-rejeu.

## Boundaries & Constraints

**Always:**
- Couche Domain en pur Dart (zéro import Flutter, Drift ou réseau).
- Clé privée Ed25519 générée et stockée exclusivement dans `flutter_secure_storage` avec exclusion des sauvegardes automatiques Google Drive (`android:fullBackupContent="@xml/backup_rules"`).
- Sérialisation binaire compacte conforme à la spécification CBOR (RFC 8949).
- Encodage Base45 conforme à la RFC 9285 supportant les 45 caractères autorisés pour scan optique QR code ultra-rapide (< 1s).
- Signature asymétrique Ed25519 de 64 octets garantissant l'infalsifiabilité des métriques (score global, piliers, streak, timestamp, boutique).
- Dérivation déterministe d'un code PIN visuel à 4 chiffres par `HMAC-SHA256(Signature, Timestamp_Minute)` pour validation D2D anti-rejeu.
- Fonctionnement 100% Offline-First sans aucun appel serveur.

**Never:**
- Jamais de stockage de clé privée en clair dans SQLite, SharedPreferences non chiffré ou logs.
- Jamais d'inclusion des données de trousseau sécurisé dans les sauvegardes cloud distantes.
- Pas d'accès réseau requis pour générer, signer ou vérifier le passeport.
- Pas d'altération destructive des entités du domaine existantes (`FinancialPassportEntity`).

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Génération nominale de passeport signé | `FinancialPassportEntity` éligible (score 82, streak 12, 22 clôtures) + Shop configuré | `SignedPassportPayloadEntity` avec signature 64 octets, payload Base45 compacte, et PIN visuel 4 chiffres | No error expected |
| Première initialisation des clés de boutique | Aucune clé présente dans le stockage sécurisé | Génération d'une nouvelle paire Ed25519, persistance sécurisée de la clé privée, renvoi de la clé publique 32 octets | No error expected |
| Récupération des clés existantes | Paire de clés Ed25519 déjà persistée dans le stockage sécurisé | Réutilisation déterministe de la clé privée existante sans régénération | No error expected |
| Vérification D2D d'une payload valide | Payload Base45 intacte signée avec la clé publique correspondante | Vérification réussie (`isValid = true`), restitution fidèle des métriques du passeport | No error expected |
| Altération frauduleuse des données (score modifié) | Payload Base45 modifiée ou altérée d'un seul octet | Échec de vérification (`isValid = false`), rejet immédiat | `CryptoFailure('Signature invalide ou charge utile corrompue')` |
| Passeport non éligible (< 7 clôtures) | `FinancialPassportEntity` avec `isEligible = false` | Rejet de la signature officielle avec erreur métier explicite | `ValidationFailure('Passeport non éligible à la signature officielle')` |
| Dérivation du code PIN anti-rejeu | Signature 64 octets + horodatage minute UTC | PIN 4 chiffres exact (ex: "4821") stable pendant la même minute, renouvelé à la minute suivante | No error expected |

</intent-contract>

## Code Map

- `android/app/src/main/res/xml/backup_rules.xml` -- Règles d'exclusion des sauvegardes Android excluant les fichiers de `flutter_secure_storage`.
- `android/app/src/main/res/xml/data_extraction_rules.xml` -- Règles d'extraction Android 12+ (API 31+) interdisant le backup cloud des clés.
- `android/app/src/main/AndroidManifest.xml` -- Déclaration des attributs `fullBackupContent` et `dataExtractionRules`.
- `lib/core/crypto/secure_key_storage.dart` -- Abstraction `ISecureKeyStorage` et implémentation `FlutterSecureKeyStorage` basée sur `flutter_secure_storage`.
- `lib/core/crypto/base45.dart` -- Encodeur et décodeur Base45 pur Dart conforme à la RFC 9285.
- `lib/core/crypto/crypto_signature_service.dart` -- Contrat et service de génération de clés Ed25519, signature 64 octets, vérification et dérivation de PIN HMAC-SHA256.
- `lib/features/financial_passport/data/models/cbor_passport_payload.dart` -- Modèle DTO sérialisant / désérialisant les métriques financières en CBOR binaire compact.
- `lib/features/financial_passport/domain/entities/signed_passport_payload_entity.dart` -- Entité immuable représentant la charge complète signée (score, piliers, signature, payload Base45, PIN visuel).
- `lib/features/financial_passport/domain/usecases/generate_signed_passport_use_case.dart` -- Cas d'utilisation orchestrant le calcul, la signature Ed25519, la sérialisation CBOR et l'encodage Base45.
- `lib/features/financial_passport/domain/usecases/verify_passport_payload_use_case.dart` -- Cas d'utilisation de vérification autonome D2D de la payload Base45 et de sa signature.
- `lib/injection_container.dart` -- Enregistrement des nouveaux services et use cases dans GetIt.
- `test/core/crypto/base45_test.dart` -- Tests unitaires exhaustifs Base45 avec vecteurs officiels RFC 9285.
- `test/core/crypto/crypto_signature_service_test.dart` -- Tests unitaires du service cryptographique (clés, Ed25519, PIN HMAC).
- `test/features/financial_passport/data/models/cbor_passport_payload_test.dart` -- Tests unitaires de sérialisation / désérialisation binaire CBOR.
- `test/features/financial_passport/domain/usecases/generate_signed_passport_use_case_test.dart` -- Tests unitaires du cas d'utilisation de signature.
- `test/features/financial_passport/domain/usecases/verify_passport_payload_use_case_test.dart` -- Tests unitaires du cas d'utilisation de vérification D2D.
- `test/helpers/mocks.dart` -- Mocks partagés Mocktail pour les tests cryptographiques.
- `test/all_tests.dart` -- Intégration des nouvelles suites de tests.

## Tasks & Acceptance

**Execution:**
- `android/app/src/main/res/xml/backup_rules.xml` -- Créer les règles de backup Android excluant les Shared Preferences de `flutter_secure_storage` -- Protection des clés cryptographiques en Keystore.
- `android/app/src/main/res/xml/data_extraction_rules.xml` -- Créer les règles d'extraction pour Android 12+ interdisant la sauvegarde cloud du trousseau -- Conformité NFR4 / AD-11.
- `android/app/src/main/AndroidManifest.xml` -- Mettre à jour `<application>` avec `android:fullBackupContent` et `android:dataExtractionRules` -- Exclusion effective des sauvegardes Google Drive.
- `lib/core/crypto/secure_key_storage.dart` -- Créer l'interface `ISecureKeyStorage` et son implémentation `FlutterSecureKeyStorage` utilisant `FlutterSecureStorage` avec `AndroidOptions(encryptedSharedPreferences: true)` -- Gestion sécurisée du stockage des clés privées.
- `lib/core/crypto/base45.dart` -- Implémenter l'encodeur et le décodeur Base45 pur Dart conforme à la RFC 9285 avec gestion des morceaux de 2 octets vers 3 caractères et reste de 1 octet vers 2 caractères -- Densité optimale pour QR code hors-ligne.
- `lib/core/crypto/crypto_signature_service.dart` -- Implémenter `ICryptoSignatureService` pour gérer la paire de clés Ed25519 (génération, persistance sécurisée, signature 64 octets, vérification) et la dérivation du code PIN visuel 4 chiffres par HMAC-SHA256 tronqué sur l'horodatage minute UTC -- Invariants AD-4 et AD-11.
- `lib/features/financial_passport/domain/entities/signed_passport_payload_entity.dart` -- Créer l'entité immuable de domaine contenant le passeport financier, la signature binaire, la chaîne Base45, le PIN 4 chiffres et l'identifiant de boutique -- Contrat métier domain pur Dart.
- `lib/features/financial_passport/data/models/cbor_passport_payload.dart` -- Implémenter la sérialisation / désérialisation binaire compacte CBOR des métriques clés (version, shopId, overallScore, totalClosures, streak, debtScore, gpsScore, cashScore, calculatedAt, signature, publicKey) -- Charge utile compacte pour QR Code scannable en < 1s.
- `lib/features/financial_passport/domain/usecases/generate_signed_passport_use_case.dart` -- Implémenter le cas d'utilisation pur Dart qui valide l'éligibilité du passeport, sérialise les métriques, signe en Ed25519, assemble le CBOR et produit la payload Base45 avec son code PIN -- Cas d'utilisation Command.
- `lib/features/financial_passport/domain/usecases/verify_passport_payload_use_case.dart` -- Implémenter le cas d'utilisation de vérification D2D qui décode la charge Base45, lit le CBOR et valide mathématiquement la signature Ed25519 avec la clé publique -- Vérification tiers sans Internet.
- `lib/injection_container.dart` -- Déclarer `ISecureKeyStorage`, `ICryptoSignatureService`, `GenerateSignedPassportUseCase` et `VerifyPassportPayloadUseCase` dans GetIt -- Câblage de dépendances.
- `test/helpers/mocks.dart` -- Ajouter les classes de mocks `MockSecureKeyStorage` et `MockCryptoSignatureService` -- Helpers de test partagés.
- `test/core/crypto/base45_test.dart` -- Tester l'encodage et décodage Base45 avec vecteurs RFC 9285 ("Hello!!", "base-45", "ietf!") et données binaires aléatoires -- Rigueur algorithmique.
- `test/core/crypto/crypto_signature_service_test.dart` -- Tester la génération de clés, la persistance dans `ISecureKeyStorage`, la signature Ed25519, la vérification et le calcul de PIN 4-chiffres dynamique -- Couverture cryptographique.
- `test/features/financial_passport/data/models/cbor_passport_payload_test.dart` -- Tester l'encodage et le décodage CBOR aller-retour (roundtrip) et l'intégrité des champs -- Robustesse du format.
- `test/features/financial_passport/domain/usecases/generate_signed_passport_use_case_test.dart` -- Tester la génération de passeport signé, le refus des passeports non éligibles (< 7 clôtures), et la complétude des champs retournés -- Validation du use case.
- `test/features/financial_passport/domain/usecases/verify_passport_payload_use_case_test.dart` -- Tester la vérification D2D valide, le rejet des payloads corrompues, et la détection d'altération de score -- Sécurité anti-fraude.
- `test/all_tests.dart` -- Importer et enregistrer tous les nouveaux tests dans le runner consolidé -- Règle stricte AGENTS.md.

**Acceptance Criteria:**
- Given un passeport financier calculé et éligible, when `GenerateSignedPassportUseCase` est invoqué, then une charge utile binaire compacte est sérialisée en CBOR, signée en Ed25519 (64 octets), encodée en Base45 et associée à un code PIN visuel à 4 chiffres.
- Given un commerçant sur son terminal, when la clé de boutique est créée, then la clé privée Ed25519 est stockée dans `flutter_secure_storage` avec exclusion des sauvegardes automatiques Google Drive configurée dans le manifeste Android.
- Given une payload Base45 générée, when `VerifyPassportPayloadUseCase` analyse la chaîne, then la signature Ed25519 est validée mathématiquement et les métriques d'origine sont intégralement restituées.
- Given une payload Base45 dont un seul caractère ou champ a été falsifié, when la vérification s'exécute, then la signature est déclarée invalide et la charge est rejetée.
- Given un passeport avec moins de 7 clôtures (`isEligible = false`), when la signature est demandée, then une erreur de validation explicite est retournée sans émettre de fausse attestation.
- Given l'ensemble de la suite de tests, when `flutter analyze` et `flutter test test/all_tests.dart` s'exécutent, then 0 avertissement statique et 100% des tests passent en isolate unique.

## Spec Change Log

_None._

## Review Triage Log

### 2026-11-17 — Review pass
- verdicts: 22 findings — high 0, medium 9, low 6, false 7, maybe-false 0
- findings:
  - `[medium]` `[patch]` Dynamic Visual PIN Anti-Replay Flaw (generate_signed_passport_use_case.dart & verify_passport_payload_use_case.dart) — Added optional pinTimestamp defaulting to DateTime.now() in GenerateSignedPassportUseCase, and verification with 1-minute drift tolerance in VerifyPassportPayloadUseCase.
  - `[medium]` `[patch]` Missing PIN Verification Input in VerifyPassportPayloadUseCase — Added visualPinToVerify parameter and cryptographically validated PIN with -1 min tolerance.
  - `[low]` `[reject]` Missing Expiry and Freshness Validation on Signed Passports — Passports are evaluated at presentation time; freshness policy is deferred to UI/business rules in Story 3.3/3.4 without arbitrary hardcoded cutoff in crypto layer.
  - `[medium]` `[patch]` Device-to-Device Migration Key Corruption in data_extraction_rules.xml — Changed device-transfer to exclude FlutterSecureStorage and FlutterSecureStorage.xml to avoid Android Keystore unwrap crashes.
  - `[low]` `[patch]` Incomplete Path Matching in Android Auto Backup XML Rules — Added exclude for FlutterSecureStorage.xml alongside FlutterSecureStorage in both backup_rules.xml and data_extraction_rules.xml.
  - `[low]` `[patch]` Missing iOS Keychain Accessibility and Backup Configuration in FlutterSecureKeyStorage — Configured iOptions: const IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device) preventing iCloud syncing.
  - `[low]` `[defer]` Unused Redundant Dependency dart_base45 in pubspec.yaml — Pre-existing dependency in pubspec.yaml prior to story start; deferred to dependency cleanup chore.
  - `[false]` `[reject]` Silent Key Pair Overwrite on Corrupted Storage in CryptoSignatureService — Refuted: self-healing fallback is explicitly designed and tested in unit tests for resilience on storage corruption.
  - `[false]` `[reject]` Non-Canonical CBOR Map Ordering — Refuted: Dart cbor package serializes maps in insertion order of deterministic integer keys 1..12; verified by roundtrip and signature matching tests.
  - `[medium]` `[patch]` Inconsistent Invariant Enforcement Between SignedPassportPayloadEntity Constructors — Added assertions in SignedPassportPayloadEntity.raw ensuring identical invariant guarantees.
  - `[medium]` `[patch]` Input Validation Missing in Base45.encode — Added bounds check ensuring 0 <= byte <= 255 throwing ArgumentError.
  - `[medium]` `[patch]` Cross-Platform Unsigned Integer Handling in CryptoSignatureService.deriveVisualPin — Replaced bitwise shift with ByteData.sublistView(Uint8List.fromList(bytes)).getUint32(0, Endian.big) % 10000.
  - `[false]` `[reject]` Missing Concurrency Synchronization in CryptoSignatureService._getKeyPair — Refuted: getOrCreatePublicKey is invoked sequentially per shop at startup or single-threaded use case execution; no concurrent re-generation issue exists.
  - `[medium]` `[patch]` Missing Version Compatibility Validation in CborPassportPayload.fromCbor — Added if (version != 1) throw FormatException(...).
  - `[medium]` `[patch]` Zero Test Coverage for FlutterSecureKeyStorage — Created dedicated unit test suite test/core/crypto/secure_key_storage_test.dart with 6 tests.
  - `[medium]` `[patch]` data contains byte value below 0 or above 255 in Base45.encode — Patched with 0 <= byte <= 255 validation.
  - `[false]` `[reject]` stored private key decodes to byte length other than 32 — Refuted: self-healing fallback pattern.
  - `[low]` `[patch]` signature with length other than 64 bytes passed to deriveVisualPin — Added if (signature.length != 64) throw ArgumentError(...).
  - `[low]` `[patch]` visualPin of length 4 containing non-digit characters — Added int.tryParse(visualPin) != null check in SignedPassportPayloadEntity.
  - `[medium]` `[patch]` CBOR payload contains unsupported schema version other than 1 — Patched with if (version != 1) throw FormatException(...).
  - `[medium]` `[patch]` PIN stable during same minute, renewed at subsequent minute anti-replay — Patched with dynamic timestamp and verifier tolerance.
  - `[false]` `[reject]` Optical rendering and presentation UI missing — Refuted: Intent and Epic 3 breakdown specifically allocate presentation UI / QR rendering to Story 3.3 and PDF to Story 3.4; Story 3.2 is the cryptographic, serialization and domain foundation.

## Auto Run Result

Status: done

### Summary of implemented change
Implémentation complète, durcie et vérifiée du socle cryptographique, de la sérialisation binaire compacte et de l'encodage haute densité pour le Passeport Financier Tekki (Story 3.2) :
1. Protection des clés en trousseau matériel Android Keystore via `flutter_secure_storage` avec exclusion stricte des sauvegardes automatiques Google Drive (`backup_rules.xml`, `data_extraction_rules.xml`) et migration d'appareils.
2. Configuration iOS Keychain avec accessibilité `first_unlock_this_device_only` interdisant la synchronisation iCloud du trousseau.
3. Implémentation complète et optimisée de l'encodeur / décodeur Base45 pur Dart conforme à la RFC 9285 avec validation des bornes d'octets `0..255`.
4. Moteur de signature asymétrique Ed25519 (64 octets) et vérification mathématique via `package:cryptography` avec persistance déterministe par boutique.
5. Dérivation sécurisée et multi-plateforme du code PIN visuel dynamique à 4 chiffres anti-rejeu par `HMAC-SHA256(Signature, Timestamp_Minute)` avec tolérance de glissement d'horloge (-1 min).
6. Sérialisation et désérialisation binaire CBOR compacte (RFC 8949) sous clés entières courtes 1 à 12, avec séparation de la charge signable (clés 1 à 11) et de la charge complète avec signature (clés 1 à 12).
7. Cas d'utilisation Command `GenerateSignedPassportUseCase` (validant le seuil d'éligibilité de 7 clôtures) et de vérification D2D autonome `VerifyPassportPayloadUseCase` sans connexion Internet.

### Files changed
- `android/app/src/main/res/xml/backup_rules.xml` : Règles d'exclusion de sauvegarde Android excluant `FlutterSecureStorage` et `FlutterSecureStorage.xml`.
- `android/app/src/main/res/xml/data_extraction_rules.xml` : Règles d'extraction Android 12+ interdisant la sauvegarde cloud et le transfert direct de clé matérielle.
- `android/app/src/main/AndroidManifest.xml` : Configuration des attributs `fullBackupContent` et `dataExtractionRules`.
- `lib/core/crypto/secure_key_storage.dart` : Interface `ISecureKeyStorage` et implémentation `FlutterSecureKeyStorage` avec options Android Keystore et iOS Keychain.
- `lib/core/crypto/base45.dart` : Encodeur et décodeur Base45 pur Dart conforme à la RFC 9285 avec validation d'octets.
- `lib/core/crypto/crypto_signature_service.dart` : Service de gestion des clés Ed25519, signature 64 octets, vérification et dérivation de PIN HMAC-SHA256 non-signé 32 bits.
- `lib/core/errors/failures.dart` : Ajout de la classe d'erreur `CryptoFailure`.
- `lib/features/financial_passport/data/models/cbor_passport_payload.dart` : Modèle DTO CBOR compact RFC 8949 avec validation de version de schéma.
- `lib/features/financial_passport/domain/entities/signed_passport_payload_entity.dart` : Entité immuable représentant le passeport complet signé avec validation du PIN 4 chiffres.
- `lib/features/financial_passport/domain/usecases/generate_signed_passport_use_case.dart` : Cas d'utilisation de signature numérique et génération Base45 avec horodatage minute dynamique.
- `lib/features/financial_passport/domain/usecases/verify_passport_payload_use_case.dart` : Cas d'utilisation de vérification autonome D2D avec validation de PIN et tolérance de glissement.
- `lib/injection_container.dart` : Enregistrement GetIt des composants cryptographiques et use cases du Passeport Financier.
- `test/core/crypto/base45_test.dart` : 11 tests unitaires validant l'encodage/décodage RFC 9285, cas limites et validation d'octets.
- `test/core/crypto/crypto_signature_service_test.dart` : 12 tests unitaires pour la gestion de clés, signatures Ed25519, rejet d'altérations et PIN 4 chiffres.
- `test/core/crypto/secure_key_storage_test.dart` : 6 tests unitaires pour `FlutterSecureKeyStorage` vérifiant la délégation vers `FlutterSecureStorage`.
- `test/features/financial_passport/data/models/cbor_passport_payload_test.dart` : 6 tests unitaires de sérialisation / désérialisation binaire CBOR et contrôle de version.
- `test/features/financial_passport/domain/entities/signed_passport_payload_entity_test.dart` : 6 tests unitaires validant les invariants et constructeurs d'entité.
- `test/features/financial_passport/domain/usecases/generate_signed_passport_use_case_test.dart` : 7 tests unitaires couvrant l'éligibilité, la signature et le PIN dynamique.
- `test/features/financial_passport/domain/usecases/verify_passport_payload_use_case_test.dart` : 11 tests unitaires couvrant la vérification D2D, la détection de falsification et la validation de PIN avec dérive.
- `test/helpers/mocks.dart` & `test/helpers/fixtures.dart` : Mocks partagés et fixtures pour le passeport signé.
- `test/all_tests.dart` : Intégration de l'ensemble des 7 nouveaux fichiers de tests dans le runner unifié.

### Review findings breakdown
- Patches appliqués : 15 correctifs (exclusion XML de migration Keystore, extension .xml, options iOS keychain, validation des octets Base45, int 32-bit non-signé pour PIN, validation 4 chiffres PIN, assertions constructeur raw, vérification de version CBOR, timestamp dynamique de PIN, vérification de PIN avec tolérance de dérive -1 min, suite de tests pour FlutterSecureKeyStorage).
- Items déférés : 1 élément de dépendance pré-existante (`dart_base45` dans `pubspec.yaml:31`).
- Findings rejetés : 6 faux positifs (comportement d'auto-guérison sur corruption de clé testé et approuvé, déterminisme de l'ordonnancement CBOR vérifié par tests, concurrence monoposte séquentielle, validation de fraîcheur temporelle globale allouée à la couche de présentation/UI Story 3.3, périmètre UI/optique alloué aux Stories 3.3 et 3.4).

### Follow-up review recommendation
- `followup_review_recommended`: false. Tous les correctifs appliqués ont été rigoureusement vérifiés par 355 tests unitaires et d'intégration, 0 avertissement statique et 0 violation de formatage. Aucun risque résiduel non vérifié.

### Verification performed
- `flutter analyze` : 0 issue found (ran in 8.5s).
- `dart format --output=none --set-exit-if-changed .` : Formatted 148 files (0 changed) in 1.94s.
- `flutter test test/all_tests.dart` : 355 tests passed in 19s (0 failures, single isolate).

### Residual risks
- Aucun sur le périmètre de la Story 3.2. Le rendu optique du QR code et son affichage avec boost de luminosité seront traités dans la Story 3.3. L'export PDF certifié sera traité dans la Story 3.4._

## Design Notes

### 1. Spécification de la charge CBOR compacte (RFC 8949)

Pour garantir que le QR Code reste lisible en moins de 1 seconde par n'importe quelle caméra de smartphone d'entrée de gamme, la charge utile utilise des clés entières CBOR très courtes :
- Clé 1 : Version du schéma (entier `1`)
- Clé 2 : Identifiant de boutique `shopId` (texte UTF-8)
- Clé 3 : Score global sur 100 (entier)
- Clé 4 : Total des clôtures sur 30 jours (entier)
- Clé 5 : Série de clôtures consécutives `streak` (entier)
- Clé 6 : Score pilier Karné Bor (entier)
- Clé 7 : Score pilier Clôtures (entier)
- Clé 8 : Score pilier GPS (entier)
- Clé 9 : Score pilier Encaisse (entier)
- Clé 10 : Horodatage du calcul `calculatedAt` (entier secondes epoch UTC)
- Clé 11 : Clé publique Ed25519 de la boutique (octets `Uint8List`, 32 octets)
- Clé 12 : Signature numérique Ed25519 (octets `Uint8List`, 64 octets)

La signature Ed25519 est calculée sur la sérialisation canonique CBOR des champs 1 à 11 (la charge sans la signature elle-même), puis le champ 12 est ajouté dans la charge finale CBOR encodée en Base45.

### 2. Dérivation du code PIN dynamique 4 chiffres (AD-11)

Pour empêcher le rejeu de vieilles captures d'écran par un tiers malveillant, le PIN est calculé sur une base temporelle à la minute UTC :
`Timestamp_Minute = (calculatedAt / 60).floor()`
`HMAC = HMAC-SHA256(Key: SignatureBytes, Data: UTF8(Timestamp_Minute.toString()))`
`PIN_Number = (HMAC[0..3] as uint32) % 10000`
`PIN = PIN_Number.toString().padLeft(4, '0')`

## Verification

**Commands:**
- `flutter analyze` -- expected: 0 issue found
- `dart format --output=none --set-exit-if-changed .` -- expected: 0 formatted files changed
- `flutter test test/all_tests.dart` -- expected: All tests pass successfully in a single isolate
