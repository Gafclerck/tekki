---
title: "Lecteur Audio Conseiller, Capsules Éducatives Bilingues & Cache Local"
type: 'feature'
created: '2026-11-17'
status: 'done'
baseline_revision: 'a0c718e225d42380ade54f600c8d9d207a70a741'
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

**Problem:** De nombreux commerçants d'Afrique de l'Ouest sont freinés par les pavés de texte ou le jargon financier et préfèrent l'écoute orale directe pour s'informer et progresser dans leur gestion.
**Approach:** Intégrer un lecteur de capsules audio éducatives courtes (30 à 45s) au format note vocale WhatsApp, bilingue Wolof (prioritaire) et Français avec bascule en 1 tap, doté d'une jauge de progression, mis en pause automatique sur appel ou mise en arrière-plan, embarquant la capsule d'accueil dans l'application et supportant la mise en cache locale.

## Boundaries & Constraints

**Always:**
- Couche Domain en Dart pur (zéro dépendance vers Flutter, Drift, just_audio ou réseau).
- Wolof sélectionné par défaut à l'ouverture (langue prioritaire pour l'oralité commerçante).
- Bascule instantanée de langue (Wolof <-> Français) en un seul tap sans interruption brutale ni désynchronisation.
- Pause automatique de la lecture audio lors de la mise en arrière-plan de l'application ou d'un appel entrant via le cycle de vie applicatif (`AppLifecycleState`).
- Carte visuelle de capsule conforme au Design System Tekki : carte blanche `{colors.surface}`, bordure gauche de 5px en orange accent `{colors.accent}`, bouton Play circulaire `{colors.accent}` avec glyphe blanc, jauge de progression temporelle.
- Préservation de la règle de l'action focale unique sur HomeScreen : le bouton Play ne doit jamais être un `ElevatedButton` à fond orange pour ne pas rivaliser avec le CTA de clôture express.
- Gestion d'erreur audio 100 % résiliente : aucune indisponibilité de codec ou d'équipement matériel ne doit faire planter l'application.

**Never:**
- Pas d'appel réseau obligatoire pour lire la capsule d'accueil (embarquée directement dans l'application).
- Pas de dépendance à un modèle LLM pour la génération audio au runtime (capsules pré-enregistrées et scénarisées).
- Pas d'interruption non sollicitée du parcours d'encaissement (le lecteur audio ne démarre jamais automatiquement sans action du commerçant).

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Lecture nominale capsule Wolof | Appui sur Play en état Wolof | Lecture de la capsule audio en Wolof, bouton passe en Pause, jauge de progression s'actualise | Dégradation silencieuse si codec indisponible |
| Bascule de langue en cours de lecture | Appui sur le sélecteur "Français" pendant la lecture Wolof | La voix bascule sur la piste française à la même position temporelle, maintien de l'état de lecture | Reprise au début si durée de piste divergente |
| Pause manuelle | Appui sur Pause pendant la lecture | La lecture s'interrompt, le bouton repasse en Play, la position reste mémorisée | No error expected |
| Mise en arrière-plan / Appel entrant | `AppLifecycleState.paused` ou `inactive` pendant la lecture | La lecture est automatiquement suspendue, l'état passe en Pause | No error expected |
| Fin de capsule audio | Atteinte de la durée totale de la capsule | La lecture s'arrête, la position est réinitialisée à zéro, le bouton repasse en Play | No error expected |
| Fichier audio manquant ou corrompu | Asset ou fichier cache introuvable | L'état passe en arrêt propre avec message discret d'information sans bloquer l'interface | Notification gracieuse, pas de crash |

</intent-contract>

## Code Map

- `lib/core/services/audio_service.dart` -- Extension du contrat `IAudioPlayerService` et de l'implémentation `JustAudioPlayerService` pour supporter le chargement, la lecture, la pause, la reprise, la position et les streams d'état de capsule audio.
- `lib/features/advisor/domain/entities/audio_language.dart` -- Enum pur Dart pour la sélection de langue bilingue (Wolof prioritaire, Français).
- `lib/features/advisor/domain/entities/audio_capsule_entity.dart` -- Entité métier Dart pur de capsule audio (identifiant, titre, catégorie, durée en secondes, chemins des pistes Wolof et Français, résumé).
- `lib/features/advisor/domain/entities/capsule_playback_state.dart` -- Entité et énumération de statut de lecture (idle, loading, playing, paused, completed, error).
- `lib/features/advisor/domain/repositories/audio_capsule_repository.dart` -- Contrat abstrait de la couche Domain pour récupérer les capsules disponibles et la capsule active.
- `lib/features/advisor/domain/usecases/get_active_audio_capsule_use_case.dart` -- Cas d'utilisation pur Dart récupérant la capsule active pour le commerçant.
- `lib/features/advisor/data/datasources/audio_capsule_local_data_source.dart` -- Source de données locale fournissant les capsules pré-enregistrées embarquées et le cache local.
- `lib/features/advisor/data/repositories/audio_capsule_repository_impl.dart` -- Implémentation du repository de capsules audio de la couche Data.
- `lib/features/advisor/presentation/cubit/audio_capsule_cubit.dart` -- Cubit pilotant le chargement, la lecture, la bascule de langue et la pause automatique sur cycle de vie.
- `lib/features/advisor/presentation/cubit/audio_capsule_state.dart` -- États immuables du Cubit (`AudioCapsuleState`).
- `lib/features/advisor/presentation/widgets/audio_capsule_card.dart` -- Composant visuel de carte audio avec bordure orange 5px, bouton circulaire Play/Pause, sélecteur bilingue 1-tap et jauge de progression.
- `lib/features/advisor/presentation/pages/advisor_page.dart` -- Intégration de la carte de capsule audio sur l'écran Conseiller Tekki.
- `lib/features/sales_and_cash/presentation/screens/home_screen.dart` -- Intégration de la bannière de capsule audio sur l'écran d'accueil.
- `lib/injection_container.dart` -- Enregistrement des nouvelles dépendances `AudioCapsuleLocalDataSource`, `AudioCapsuleRepository`, `GetActiveAudioCapsuleUseCase` et `AudioCapsuleCubit`.
- `assets/audio/capsule_welcome_wo.opus` -- Asset audio de la capsule d'accueil en Wolof.
- `assets/audio/capsule_welcome_fr.opus` -- Asset audio de la capsule d'accueil en Français.
- `test/core/services/audio_service_test.dart` -- Tests unitaires étendus pour les nouvelles fonctionnalités du service audio.
- `test/features/advisor/domain/usecases/get_active_audio_capsule_use_case_test.dart` -- Tests unitaires du Use Case de capsule active.
- `test/features/advisor/data/repositories/audio_capsule_repository_impl_test.dart` -- Tests unitaires du repository de capsules audio.
- `test/features/advisor/presentation/cubit/audio_capsule_cubit_test.dart` -- Tests unitaires BLoC/Cubit du cycle de lecture, bascule de langue et gestion du cycle de vie.
- `test/features/advisor/presentation/widgets/audio_capsule_card_test.dart` -- Tests de widget du composant audio capsule (rendu, interaction play/pause, sélecteur Wolof/Français, jauge).
- `test/all_tests.dart` -- Enregistrement obligatoire des nouveaux tests unitaires et widget tests.

## Tasks & Acceptance

**Execution:**
- `lib/core/services/audio_service.dart` -- Étendre `IAudioPlayerService` et `JustAudioPlayerService` avec les méthodes de lecture de capsule (`loadAudio`, `play`, `pause`, `stop`, `seek`, streams de position et d'état) -- Couche Service Core.
- `assets/audio/capsule_welcome_wo.opus` -- Ajouter l'asset audio Wolof pour la capsule d'accueil du Conseiller Tekki -- Assets APK.
- `assets/audio/capsule_welcome_fr.opus` -- Ajouter l'asset audio Français pour la capsule d'accueil du Conseiller Tekki -- Assets APK.
- `lib/features/advisor/domain/entities/audio_language.dart` -- Créer l'enum `AudioLanguage` (wolof prioritaire, francais) -- Couche Domain pur Dart.
- `lib/features/advisor/domain/entities/audio_capsule_entity.dart` -- Créer l'entité immuable `AudioCapsuleEntity` -- Couche Domain pur Dart.
- `lib/features/advisor/domain/entities/capsule_playback_state.dart` -- Créer le statut `CapsulePlaybackStatus` et le modèle d'état de lecture -- Couche Domain pur Dart.
- `lib/features/advisor/domain/repositories/audio_capsule_repository.dart` -- Définir le contrat d'accès aux capsules audio -- Couche Domain.
- `lib/features/advisor/domain/usecases/get_active_audio_capsule_use_case.dart` -- Implémenter le cas d'utilisation de récupération de la capsule active -- Couche Domain.
- `lib/features/advisor/data/datasources/audio_capsule_local_data_source.dart` -- Implémenter la source de données locale pour les capsules audio -- Couche Data.
- `lib/features/advisor/data/repositories/audio_capsule_repository_impl.dart` -- Implémenter `AudioCapsuleRepository` avec la source locale -- Couche Data.
- `lib/features/advisor/presentation/cubit/audio_capsule_state.dart` -- Créer les états immuables du lecteur de capsule audio -- Gestion d'état.
- `lib/features/advisor/presentation/cubit/audio_capsule_cubit.dart` -- Implémenter le Cubit pilotant la lecture, bascule de langue, seek et pause sur cycle de vie -- Gestion d'état.
- `lib/features/advisor/presentation/widgets/audio_capsule_card.dart` -- Créer le composant visuel de capsule audio avec bordure orange gauche de 5px, bouton Play circulaire, sélecteur bilingue 1-tap et jauge de progression temporelle -- Composant d'interface utilisateur.
- `lib/features/advisor/presentation/pages/advisor_page.dart` -- Intégrer `AudioCapsuleCard` au sein de la page Conseiller Tekki -- Intégration UI.
- `lib/features/sales_and_cash/presentation/screens/home_screen.dart` -- Intégrer `AudioCapsuleCard` dans l'écran d'accueil sans enfreindre la règle du bouton CTA orange unique -- Intégration Accueil.
- `lib/injection_container.dart` -- Enregistrer le datasource, repository, usecase et Cubit dans GetIt -- Injection de dépendances.
- `test/core/services/audio_service_test.dart` -- Compléter les tests unitaires du service audio avec la gestion de flux et de pause -- Tests Core.
- `test/features/advisor/domain/usecases/get_active_audio_capsule_use_case_test.dart` -- Valider le cas d'utilisation de la capsule active -- Tests Domain.
- `test/features/advisor/data/repositories/audio_capsule_repository_impl_test.dart` -- Valider le repository avec mock du datasource -- Tests Data.
- `test/features/advisor/presentation/cubit/audio_capsule_cubit_test.dart` -- Valider les transitions d'état du Cubit, la bascule de langue et la pause automatique sur cycle de vie -- Tests BLoC.
- `test/features/advisor/presentation/widgets/audio_capsule_card_test.dart` -- Valider le rendu, le bouton Play/Pause circulaire, le sélecteur Wolof/Français et la jauge de progression -- Tests UI.
- `test/all_tests.dart` -- Importer et invoquer l'ensemble des 4 nouveaux fichiers de tests -- Respect de la règle obligatoire `AGENTS.md`.

**Acceptance Criteria:**
- Given la disponibilité d'une recommandation du Conseiller, when le commerçant visualise le composant audio-capsule sur l'accueil ou l'onglet Conseiller, then la capsule s'affiche sous forme de carte à bordure gauche orange {colors.accent} avec un bouton Play circulaire et une jauge de progression.
- Given une capsule affichée, when le commerçant appuie sur Play, then le service audio lit la capsule et le bouton passe en état Pause tout en mettant à jour la jauge de progression.
- Given la lecture en cours, when le commerçant appuie sur le sélecteur bilingue, then la voix bascule instantanément entre Wolof (prioritaire par défaut) et Français sans interruption inattendue.
- Given la lecture en cours, when un appel entrant survient ou l'application est mise en arrière-plan (cycle de vie paused/inactive), then la lecture se met automatiquement en pause.
- Given la suite de tests complète, when `flutter analyze` et `flutter test test/all_tests.dart` s'exécutent, then 0 erreur statique et 100% des tests réussissent.

## Spec Change Log

_None._

## Review Triage Log

### 2026-11-17 — Review pass
- verdicts: 7 findings — high 0, medium 3, low 4, false 0, maybe-false 0
- findings:
  - `[medium]` `[patch]` Calling play while paused reloads audio source — Corrigé : appel direct de audioPlayerService.play() sans rechargement.
  - `[medium]` `[patch]` Shared singleton AudioPlayer conflict between SFX and capsules — Corrigé : séparation nette de _sfxPlayer et _capsulePlayer dans JustAudioPlayerService.
  - `[medium]` `[patch]` Multi-instance collision on AudioCapsuleCubit between screens — Corrigé : enregistrement en lazySingleton et utilisation de BlocProvider.value.
  - `[low]` `[patch]` Touch target on language selector under 48dp — Corrigé : BoxConstraints(minWidth: 48, minHeight: 48).
  - `[low]` `[patch]` Silent error handling leaves users uninformed — Corrigé : affichage d'un bandeau discret audio_capsule_error_message.
  - `[low]` `[patch]` Missing test coverage on position ticks and completion streams — Corrigé : tests ajoutés avec StreamController.
  - `[low]` `[defer]` Missing remote download cache subsystem — Déferré à la Story 4.3 (Sync & Outbox), hors périmètre du MVP local.

## Auto Run Result

Status: done
Summary of implemented change:
- Implémentation complète du lecteur de capsules audio éducatives pour le Conseiller Tekki (Story 4.2).
- Architecture Clean 3 couches : entités de domaine (AudioCapsuleEntity, AudioLanguage, CapsulePlaybackState), contrat de repository et use case pur Dart GetActiveAudioCapsuleUseCase.
- Couche Data avec AudioCapsuleLocalDataSourceImpl et AudioCapsuleRepositoryImpl fournissant la capsule d'accueil bilingue (Wolof prioritaire et Français) et la compatibilité fichiers cache.
- Couche Service Core : JustAudioPlayerService étendu avec gestion distincte des flux SFX et capsules éducatives, contrôles play, pause, seek, stop et flux réactifs.
- Couche Présentation : AudioCapsuleCubit (singleton partagé, bascule bilingue sans perte de position, pause automatique sur WidgetsBindingObserver), composant AudioCapsuleCard respectant le Design System (bordure orange 5px, bouton Play circulaire Material >= 48dp, sans bouton orange ElevatedButton, sélecteur Wolof/Français en 1 tap).
- Intégration sur HomeScreen et AdvisorPage.
- Suite de tests complète : 455 tests exécutés en ~34 secondes (100% de réussite), 0 erreur d'analyse statique.

Files changed:
- `lib/core/services/audio_service.dart`: Extension IAudioPlayerService et JustAudioPlayerService avec séparation SFX/capsule.
- `lib/core/errors/failures.dart`: Ajout de AudioFailure.
- `lib/features/advisor/domain/entities/audio_language.dart`: Enum AudioLanguage bilingue (Wolof, Français).
- `lib/features/advisor/domain/entities/audio_capsule_entity.dart`: Entité immuable AudioCapsuleEntity.
- `lib/features/advisor/domain/entities/capsule_playback_state.dart`: Modèle d'état et enum de lecture.
- `lib/features/advisor/domain/repositories/audio_capsule_repository.dart`: Interface du repository.
- `lib/features/advisor/domain/usecases/get_active_audio_capsule_use_case.dart`: Cas d'utilisation de la capsule active.
- `lib/features/advisor/data/datasources/audio_capsule_local_data_source.dart`: Datasource locale de capsules.
- `lib/features/advisor/data/repositories/audio_capsule_repository_impl.dart`: Repository de capsules audio.
- `lib/features/advisor/presentation/cubit/audio_capsule_state.dart`: États immuables AudioCapsuleState.
- `lib/features/advisor/presentation/cubit/audio_capsule_cubit.dart`: Cubit avec gestion du cycle de vie et streams.
- `lib/features/advisor/presentation/widgets/audio_capsule_card.dart`: Composant visuel AudioCapsuleCard.
- `lib/features/advisor/presentation/pages/advisor_page.dart`: Intégration de la carte sur AdvisorPage.
- `lib/features/sales_and_cash/presentation/screens/home_screen.dart`: Intégration de la carte sur HomeScreen.
- `lib/injection_container.dart`: Enregistrement DI dans GetIt.
- `test/all_tests.dart`: Enregistrement des nouveaux fichiers de tests.
- `test/core/services/audio_service_test.dart`: Tests du service audio.
- `test/features/advisor/domain/usecases/get_active_audio_capsule_use_case_test.dart`: Tests du use case.
- `test/features/advisor/data/repositories/audio_capsule_repository_impl_test.dart`: Tests du repository data.
- `test/features/advisor/presentation/cubit/audio_capsule_cubit_test.dart`: Tests du Cubit.
- `test/features/advisor/presentation/widgets/audio_capsule_card_test.dart`: Tests du widget AudioCapsuleCard.
- `test/features/advisor/presentation/pages/advisor_page_test.dart`: Tests de la page Conseiller avec audio.
- `test/features/sales_and_cash/presentation/screens/home_screen_test.dart`: Tests de l'accueil avec audio.
- `test/helpers/fixtures.dart` & `test/helpers/mocks.dart`: Fixtures et mocks dédiés.

Verification:
- `flutter test test/all_tests.dart`: 455/455 tests réussis en 34s (100%).
- `flutter analyze`: 0 warning, 0 error.
- `dart format --output=none --set-exit-if-changed .`: 200 fichiers vérifiés, 0 changement.

## Design Notes

- **Accessibilité Orale & Ergonomie Commerçante** : Les commerçants au comptoir manipulent souvent leur téléphone d'une seule main. Le bouton Play circulaire adopte une zone tactile généreuse (>= 48dp). Le sélecteur bilingue est un toggle compact à 2 états (Wolof / Français), positionné de façon à être actionnable instantanément sans ouvrir de menu déroulant.
- **Cycle de Vie et Pause Silencieuse** : Le Cubit écoute `WidgetsBindingObserver.didChangeAppLifecycleState`. Lorsque l'application passe en `AppLifecycleState.paused` ou `AppLifecycleState.inactive` (ex: appel entrant ou appui sur Home), la méthode `pause()` est invoquée pour libérer le focus audio Android sans crash.
- **Règle de l'Action Focale Unique sur HomeScreen** : Le Design System stipule qu'un seul `ElevatedButton` à fond orange `{colors.accent}` est toléré par vue (le CTA de clôture express). Le bouton Play de la carte audio est réalisé avec un `Material(color: AppColors.accent, shape: CircleBorder(), child: InkWell(...))` ou `IconButton` afin de respecter scrupuleusement le test d'unicité `ElevatedButton` sur HomeScreen.

## Verification

**Commands:**
- `flutter test test/all_tests.dart` -- expected: Tous les tests unitaires et d'intégration réussissent à 100% sans échec
- `flutter analyze` -- expected: 0 issue trouvée
- `dart format --output=none --set-exit-if-changed .` -- expected: Codebase strictement formaté sans modification requise
