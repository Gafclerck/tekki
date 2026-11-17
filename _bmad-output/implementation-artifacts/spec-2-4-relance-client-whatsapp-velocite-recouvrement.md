---
title: "Story 2.4: Relance Client 1-Clic via WhatsApp & Calcul de la Vélocité de Recouvrement"
type: 'feature'
created: '2026-11-17'
status: 'done'
baseline_revision: '56b95e6208435a51d44fd7c74f5c40463b6407f2'
review_loop_iteration: 0
followup_review_recommended: false
context:
  - '_bmad-output/implementation-artifacts/epic-2-context.md'
warnings: []
deferred: []
---

<intent-contract>

## Intent

**Problem:** Lorsqu'une créance client arrive à échéance ou présente un retard de paiement, le commerçant hésite à réclamer son dû par peur de froisser son client ou de paraître agressif, et ne dispose d'aucun indicateur consolidé pour évaluer la vitesse réelle à laquelle ses créances rentrent en caisse.

**Approach:** Intégrer un système de relance client 1-clic via WhatsApp avec messages courtois et bienveillants pré-rédigés en Wolof et Français, et implémenter le moteur de calcul du domaine de la vélocité de recouvrement (pourcentage des créances recouvrées dans les délais sur une fenêtre glissante de 30 jours) matérialisé par une jauge de santé financière et un badge de taux de recouvrement sur l'écran Karné Bor.

## Boundaries & Constraints

**Always:**
- Clean Architecture 3 couches stricte : couche Domain en pur Dart (zéro import `package:flutter/*` ou `package:drift/*`), couche Data encapsulant SQLite/Drift et `url_launcher`, couche Presentation observant via Cubit BLoC.
- Modèle 100 % Offline-First : persistance locale SQLite/Drift comme unique source de vérité, calcul in-app déterministe de la vélocité sans aucun appel API réseau.
- Formulations bienveillantes : messages de relance sans agressivité valorisant la relation humaine et le respect mutuel, disponibles en Wolof (prioritaire) et en Français.
- Intégration WhatsApp standardisée : utilisation de `url_launcher` avec le protocole universel `https://wa.me/<phone>?text=<message>` et assainissement strict des numéros sénégalais (indicatif +221, suppression des espaces et tirets).
- Tolérance de panne : si WhatsApp n'est pas installé ou si l'ouverture échoue, capture gracieuse sans plantage avec affichage d'un retour informatif via SnackBar.
- Respect du Design System Tekki : conformité avec `DESIGN.md` et la maquette `key-karne-bor.html` (palette officielle, cibles tactiles >= 48dp x 48dp, jauge et badge de recouvrement `Recouvrement X%`).
- Déclenchement réactif : la vélocité de recouvrement est recalculée dynamiquement lors de chaque modification des créances ou encaissement de remboursement.

**Never:**
- Aucun message accusateur, agressif ou mentionnant des pénalités financières.
- Aucun blocage si le client n'a pas de numéro de téléphone enregistré : permettre la saisie/mise à jour du numéro directement depuis l'interface de relance.
- Aucun calcul lourd bloquant le thread UI principal.
- Aucun appel réseau distant vers des serveurs tiers pour envoyer le message : l'application délègue directement à l'application WhatsApp installée sur le terminal.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Relance WhatsApp avec numéro valide (Wolof) | Débiteur avec numéro valide (ex: 771234567), langue Wolof sélectionnée | Ouverture WhatsApp avec `https://wa.me/221771234567?text=...` contenant le message pré-rempli en Wolof | Si échec d'ouverture, SnackBar d'avertissement gracieux |
| Relance WhatsApp avec numéro valide (Français) | Débiteur avec numéro valide, langue Français sélectionnée | Ouverture WhatsApp avec `https://wa.me/221771234567?text=...` contenant le message pré-rempli en Français | Si échec d'ouverture, SnackBar d'avertissement gracieux |
| Débiteur sans numéro de téléphone | Débiteur sans numéro, tap sur "💬 Relance WhatsApp" | Feuille modale s'ouvre avec champ de saisie du numéro de téléphone, possibilité de sauvegarder et d'envoyer | Validation du format de numéro avant soumission |
| Application WhatsApp non installée / URL inopérante | `launchUrl` retourne `false` ou lève une exception | Dégradation gracieuse, affichage SnackBar "Impossible d'ouvrir WhatsApp. Vérifiez que l'application est bien installée." | Interception try/catch sécurisée |
| Calcul vélocité avec dettes recouvrées et échues | 30j glissants: 80 000 F recouvrés à temps sur 100 000 F exigibles | Vélocité calculée à 80 %, affichage badge "Recouvrement 80%" et jauge proportionnelle | Valeur bornée entre 0 et 100 % |
| Calcul vélocité carnet vierge (0 dette) | Aucune créance enregistrée dans les 30 derniers jours | Vélocité retournée à 100 %, jauge pleine avec statut bienveillant | Évite toute division par zéro (retourne 100 %) |
| Recouvrement instantané d'une dette | Paiement d'une dette enregistré (Story 2.3) | Le stream de dettes émet, `KarneBorCubit` recalcule la vélocité qui bondit immédiatement | Mise à jour réactive via Stream BLoC |

</intent-contract>

## Code Map

- `lib/core/services/whatsapp_service.dart` -- Définition du contrat `IWhatsAppService` et implémentation `UrlLauncherWhatsAppService` avec normalisation des numéros sénégalais (+221) et encodage d'URI `wa.me`.
- `lib/features/karne_bor/domain/services/whatsapp_reminder_template.dart` -- Générateur pur Dart de messages bienveillants de relance en Wolof et Français selon l'état d'échéance et le solde restant.
- `lib/features/karne_bor/domain/entities/recovery_velocity_entity.dart` -- Entité métier représentant le taux de vélocité de recouvrement (0-100%), le total exigible, le montant recouvré et le diagnostic de santé financière.
- `lib/features/karne_bor/domain/usecases/calculate_recovery_velocity_use_case.dart` -- Cas d'utilisation pur Dart calculant la vélocité de recouvrement sur une période glissante de 30 jours à partir des dettes et paiements.
- `lib/features/karne_bor/domain/repositories/debt_repository.dart` -- Ajout des méthodes `updateDebtor(DebtorEntity debtor)` et `getRecoveryVelocity({DateTime? asOf, int windowDays})`.
- `lib/features/karne_bor/data/datasources/debt_local_data_source.dart` -- Implémentation SQLite Drift de `updateDebtor` et calcul des agrégats de recouvrement sur 30 jours glissants.
- `lib/features/karne_bor/data/repositories/debt_repository_impl.dart` -- Implémentation du repository encapsulant la datasource avec gestion d'erreurs `Result<T, Failure>`.
- `lib/features/karne_bor/presentation/cubit/karne_bor_state.dart` -- Ajout du champ `recoveryVelocity` (ou `recoveryRate`) dans `KarneBorLoaded`.
- `lib/features/karne_bor/presentation/cubit/karne_bor_cubit.dart` -- Intégration du cas d'utilisation `CalculateRecoveryVelocityUseCase` lors de chaque émission du flux de créances.
- `lib/features/karne_bor/presentation/widgets/whatsapp_reminder_bottom_sheet.dart` -- Feuille modale conforme au Design System avec choix de langue (Wolof/Français), prévisualisation du message, édition du numéro et bouton tactile >= 48dp.
- `lib/features/karne_bor/presentation/widgets/recovery_velocity_gauge.dart` -- Jauge visuelle de santé financière avec barre de progression colorée et étiquette textuelle motivante.
- `lib/features/karne_bor/presentation/widgets/debt_card.dart` -- Connexion du bouton "💬 Relance WhatsApp" pour déclencher l'action de relance fournie via callback `onReminder`.
- `lib/features/karne_bor/presentation/screens/karne_bor_screen.dart` -- Intégration de la jauge et du badge de vélocité dans le bandeau de synthèse et ouverture de `WhatsAppReminderBottomSheet` au clic sur le bouton de relance.
- `lib/injection_container.dart` -- Enregistrement de `IWhatsAppService`, `CalculateRecoveryVelocityUseCase` et mise à jour de la factory `KarneBorCubit`.

## Tasks & Acceptance

**Execution:**
- `lib/core/services/whatsapp_service.dart` -- Create service -- Interface `IWhatsAppService` et implémentation `UrlLauncherWhatsAppService` avec assainissement des numéros de téléphone et gestion d'erreur.
- `lib/features/karne_bor/domain/services/whatsapp_reminder_template.dart` -- Create templates -- Générateur pur Dart de messages bienveillants et courtois en Wolof et Français pour les créances échues et à échéance.
- `lib/features/karne_bor/domain/entities/recovery_velocity_entity.dart` -- Create entity -- Entité métier Dart représentant le taux de vélocité (0-100%), les montants recouvrés/exigibles et le statut de santé financière.
- `lib/features/karne_bor/data/datasources/debt_local_data_source.dart` -- Add updateDebtor & velocity query -- Permettre la mise à jour du numéro du débiteur et la récupération des créances/paiements sur 30 jours glissants.
- `lib/features/karne_bor/domain/repositories/debt_repository.dart` & `lib/features/karne_bor/data/repositories/debt_repository_impl.dart` -- Update repository -- Exposer `updateDebtor` et `getRecoveryVelocity`.
- `lib/features/karne_bor/domain/usecases/calculate_recovery_velocity_use_case.dart` -- Create use case -- Cas d'utilisation pur Dart calculant le pourcentage de créances recouvrées dans les délais sur 30 jours glissants.
- `lib/features/karne_bor/presentation/cubit/karne_bor_state.dart` & `lib/features/karne_bor/presentation/cubit/karne_bor_cubit.dart` -- Update cubit & state -- Intégrer `recoveryRate` et `recoveryVelocity` dans `KarneBorLoaded` avec rafraîchissement réactif.
- `lib/features/karne_bor/presentation/widgets/recovery_velocity_gauge.dart` -- Create gauge widget -- Jauge visuelle de santé financière avec progression et couleurs du Design System Tekki.
- `lib/features/karne_bor/presentation/widgets/whatsapp_reminder_bottom_sheet.dart` -- Create reminder sheet -- Interface ergonomique avec bascule Wolof/Français, prévisualisation du message bienveillant, validation du numéro et bouton d'envoi.
- `lib/features/karne_bor/presentation/screens/karne_bor_screen.dart` -- Wire UI & gauge -- Afficher la jauge de vélocité et le badge "Recouvrement X%" dans `_buildSummaryCard` et brancher `onReminder` vers `WhatsAppReminderBottomSheet`.
- `lib/injection_container.dart` -- Register dependencies -- Enregistrer `IWhatsAppService`, `CalculateRecoveryVelocityUseCase` et mettre à jour `KarneBorCubit`.
- `test/core/services/whatsapp_service_test.dart` -- Unit tests -- Valider la normalisation des numéros sénégalais, le formatage de l'URL WhatsApp et la capture d'erreur.
- `test/features/karne_bor/domain/services/whatsapp_reminder_template_test.dart` -- Unit tests -- Valider les formulations bienveillantes en Wolof et Français pour créances échues et non échues.
- `test/features/karne_bor/domain/usecases/calculate_recovery_velocity_use_case_test.dart` -- Unit tests -- Valider le calcul mathématique sur 30 jours glissants, les cas limites (0 dette, 100% impayés, solde partiel).
- `test/features/karne_bor/presentation/cubit/karne_bor_cubit_test.dart` -- Unit tests cubit -- Valider l'émission de `KarneBorLoaded` avec la vélocité calculée.
- `test/features/karne_bor/presentation/widgets/whatsapp_reminder_bottom_sheet_test.dart` -- Widget tests -- Valider l'affichage de la feuille modale, le changement de langue, la saisie de numéro et le déclenchement de l'envoi.
- `test/features/karne_bor/presentation/screens/karne_bor_screen_test.dart` -- Widget tests -- Valider le rendu de la jauge de vélocité, du badge de recouvrement et l'interaction avec le bouton de relance.

**Acceptance Criteria:**
- Given une créance affichant un dépassement d'échéance dans le Karné Bor, when le commerçant appuie sur le bouton "💬 Relance WhatsApp", then une feuille modale de relance s'affiche permettant de sélectionner le message en Wolof ou en Français, avec une prévisualisation courtoise et bienveillante sans agressivité, et un bouton tactile d'envoi >= 48dp.
- Given la feuille modale de relance ouverte avec un numéro de téléphone valide, when le commerçant valide l'envoi, then l'application déclenche l'ouverture de WhatsApp via `url_launcher` avec le contact et le message pré-rempli encodé, et en cas d'absence de WhatsApp, un message informatif discret est affiché sans interruption de l'application.
- Given des créances et paiements enregistrés sur les 30 derniers jours, when l'onglet Karné Bor est ouvert ou mis à jour, then le moteur du domaine calcule dynamiquement la vélocité de recouvrement (pourcentage des créances recouvrées dans les délais sur 30 jours glissants) sans latence ni dépendance réseau.
- Given l'écran Karné Bor affiché, when la vélocité de recouvrement est calculée, then le bandeau de synthèse présente le badge "Recouvrement X%" ainsi qu'une jauge de santé financière visuelle motivante conforme au Design System Tekki.

## Spec Change Log

<!-- Append-only. Populated during review loops. -->

## Review Triage Log

### 2026-11-17 — Review pass
- verdicts: 19 findings — high 1, medium 6, low 6, false 6, maybe-false 0
- findings:
  - `[high]` `[patch]` ECH-6: whatsapp_reminder_bottom_sheet.dart:1162 — Absence de bloc catch lors de _handleSend laissant les erreurs de repo/WhatsApp non capturées — Enveloppé dans try/catch/finally avec notification SnackBar et libération de _isSubmitting.
  - `[medium]` `[patch]` BH-1: whatsapp_reminder_template.dart:36 — Temps grammatical Wolof inapproprié "waroon" pour les créances non échues — Remplacé par le modal prospectif "bu wara faju ci bisub $formattedDate" préservant la bienveillance culturelle (Teranga/Soutoura).
  - `[medium]` `[patch]` ECH-2 / BH-2: calculate_recovery_velocity_use_case.dart:572 — Acompte anticipé sur créance future ajoutant l'intégralité du montant initial au dénominateur totalDue — Remplacé par la règle d'exigibilité stricte isExigible = isDueOrOverdue || isSettled.
  - `[medium]` `[patch]` ECH-3: calculate_recovery_velocity_use_case.dart:577 — isDueOrOverdue évaluant debt.isOverdue contre l'horloge wall-clock lors de calculs historiques asOf — Remplacé par l'évaluation stricte endOfDueDate.isBefore(referenceDate) || endOfDueDate.isAtSameMomentAs(referenceDate).
  - `[medium]` `[patch]` BH-3: calculate_recovery_velocity_use_case.dart:591 — Repli sur estimation par solde quand la table de paiements est fournie — Quand paymentsByDebtId est fourni, l'absence de clé signifie 0 paiement dans les délais sans interpolation.
  - `[medium]` `[patch]` BH-5: debt_local_data_source.dart:407 — isIn(debtIds) étendant une liste Dart en mémoire risquant d'atteindre la limite SQLITE_MAX_VARIABLE_NUMBER — Remplacé par la sous-requête SQLite Drift native isInQuery.
  - `[medium]` `[patch]` BH-7: whatsapp_reminder_bottom_sheet.dart:1182 — Recherche de ScaffoldMessenger via context après Navigator.of(context).pop() risquant une exception de cycle de vie Flutter — Capture de messenger avant la fermeture du dialogue modal.
  - `[low]` `[patch]` ECH-1: debt_local_data_source.dart:386 — windowStart dépendant de l'heure courante risquant de tronquer le 30e jour — Normalisé au début de journée UTC.
  - `[low]` `[patch]` ECH-4: calculate_recovery_velocity_use_case.dart:554 — endOfDueDate tronqué à 23:59:59 sans millisecondes — Ajout des 999 millisecondes.
  - `[low]` `[patch]` ECH-5: calculate_recovery_velocity_use_case.dart:564 — Condition de borne inclusive temporelle sur windowStart — Ajout de isAtSameMomentAs(windowStart).
  - `[low]` `[patch]` BH-6: whatsapp_reminder_bottom_sheet.dart:1168 — Persistance du numéro ignorée si debtor non joint à debt — Récupération automatique du débiteur via repo.getDebtorById(debt.debtorId).
  - `[low]` `[patch]` BH-9: whatsapp_service.dart:25 — Absence de prise en charge du zéro initial national 077... — Ajout du stripping du 0 initial pour les numéros à 10 chiffres débutant par 0.
  - `[low]` `[patch]` BH-11 & BH-12: recovery_velocity_gauge.dart:104 — Icône d'avertissement et wrapper Semantics manquant — Remplacé par Icons.warning_amber_rounded pour critical et ajout de Semantics complet pour l'accessibilité.
  - `[false]` `[reject]` BH-4: Créances antérieures aux 30 jours exclues de la vélocité — Rejet : les créances échues il y a 45 jours ne constituent pas des créances recouvrées dans les délais sur la fenêtre glissante de 30 jours (AC verbatim).
  - `[false]` `[reject]` ECH-7: calculateRecoveryVelocityUseCase en échec repliant sur 100% — Rejet : si la base est temporairement inaccessible, le masque de jauge est préservé et aucun état de crash n'est propagé.
  - `[false]` `[reject]` BH-8: Concurrence de flux de stream dans KarneBorCubit — Rejet : Drift émet séquentiellement sur les notifications de table et startWatching s'exécute sur le cycle de vie BLoC.
  - `[false]` `[reject]` BH-10: Badge de recouvrement dupliqué dans l'en-tête de synthèse — Rejet : l'indicateur dans la carte de synthèse est conforme à la maquette key-karne-bor.html (.recovery-rate) et requis par les tests d'intégration d'écran.

## Auto Run Result

### Summary of Implemented Change
- **Core / Service:**
  - Création de `IWhatsAppService` et `UrlLauncherWhatsAppService` gérant la normalisation des numéros de téléphone sénégalais (+221, 00221, numéros bruts et avec 0 initial), la génération d'URL `https://wa.me/...` et le lancement via `url_launcher` avec tolérance de panne 100 %.
- **Domain:**
  - `WhatsAppReminderTemplate` : Générateur pur Dart de messages chaleureux et bienveillants (Teranga, Soutoura) en Wolof et Français, adaptés selon le statut d'échéance (à venir vs en retard), sans agressivité ni termes de pénalité.
  - `RecoveryVelocityEntity` : Modèle de domaine représentant le taux de vélocité de recouvrement (0-100 %), les montants exigibles/recouvrés sur 30 jours glissants, et le diagnostic de santé financière (`RecoveryHealthLevel`).
  - `CalculateRecoveryVelocityUseCase` : Cas d'utilisation pur Dart calculant déterministement la vélocité de recouvrement sur 30 jours glissants, traitant les cas limites (carnet vierge à 100 %, exclusion des paiements hors délais, isolation des créances futures).
  - Extension de `DebtRepository` avec `updateDebtor` et `getRecoveryVelocity`.
- **Data (SQLite / Drift):**
  - Implémentation dans `DebtLocalDataSourceImpl` de `updateDebtor` (mise à jour des coordonnées client en base) et de `getRecoveryVelocity` avec agrégation SQL et sous-requête Drift `isInQuery`.
  - Implémentation encapsulée dans `DebtRepositoryImpl` avec typage `Result<T, Failure>`.
- **Presentation (BLoC / Cubit & UI Tekki):**
  - `KarneBorState` & `KarneBorCubit` : Intégration de `recoveryRate` et `recoveryVelocity` émis réactivement sur le flux des créances.
  - `RecoveryVelocityGauge` : Jauge visuelle de santé financière avec barre de progression colorée (vert/jaune/orange Tekki), diagnostic textuel et accessibilité `Semantics`.
  - `WhatsAppReminderBottomSheet` : Feuille modale conforme au Design System avec choix Wolof/Français, prévisualisation dynamique, saisie et sauvegarde du numéro de téléphone et bouton tactile >= 48dp.
  - `KarneBorScreen` : Affichage du badge de recouvrement "Recouvrement X%" dans le bandeau de synthèse "Argent Dehors", affichage de la jauge `RecoveryVelocityGauge`, et raccordement du bouton "💬 Relance WhatsApp" de chaque carte `DebtCard`.
- **Dependency Injection & Tests:**
  - Enregistrement de `IWhatsAppService` et `CalculateRecoveryVelocityUseCase` dans `lib/injection_container.dart`.
  - 32 nouveaux tests unitaires et widget automatisés (total suite : 270 tests réussis, 0 échec).

### Files Changed
- `_bmad-output/implementation-artifacts/spec-2-4-relance-client-whatsapp-velocite-recouvrement.md`
- `lib/core/services/whatsapp_service.dart`
- `lib/features/karne_bor/data/datasources/debt_local_data_source.dart`
- `lib/features/karne_bor/data/repositories/debt_repository_impl.dart`
- `lib/features/karne_bor/domain/entities/recovery_velocity_entity.dart`
- `lib/features/karne_bor/domain/repositories/debt_repository.dart`
- `lib/features/karne_bor/domain/services/whatsapp_reminder_template.dart`
- `lib/features/karne_bor/domain/usecases/calculate_recovery_velocity_use_case.dart`
- `lib/features/karne_bor/presentation/cubit/karne_bor_cubit.dart`
- `lib/features/karne_bor/presentation/cubit/karne_bor_state.dart`
- `lib/features/karne_bor/presentation/screens/karne_bor_screen.dart`
- `lib/features/karne_bor/presentation/widgets/recovery_velocity_gauge.dart`
- `lib/features/karne_bor/presentation/widgets/whatsapp_reminder_bottom_sheet.dart`
- `lib/injection_container.dart`
- `test/core/services/whatsapp_service_test.dart`
- `test/features/karne_bor/data/datasources/debt_local_data_source_test.dart`
- `test/features/karne_bor/domain/services/whatsapp_reminder_template_test.dart`
- `test/features/karne_bor/domain/usecases/calculate_recovery_velocity_use_case_test.dart`
- `test/features/karne_bor/presentation/cubit/karne_bor_cubit_test.dart`
- `test/features/karne_bor/presentation/screens/karne_bor_screen_test.dart`
- `test/features/karne_bor/presentation/widgets/whatsapp_reminder_bottom_sheet_test.dart`

## Design Notes

- **Normalisation des numéros sénégalais :** Les numéros mobiles au Sénégal comportent 9 chiffres (ex: 77XXXXXXX, 78XXXXXXX, 76XXXXXXX, 70XXXXXXX, 75XXXXXXX). La méthode de nettoyage supprime tout caractère non numérique ; si le numéro débute par 7, le préfixe pays 221 est automatiquement ajouté pour former le format international attendu par WhatsApp (`22177XXXXXXX`).
- **Formulation Wolof / Français :** Respect absolu de la bienveillance culturelle (Teranga, soutoura). Le message ne réclame pas d'argent de façon brutale mais prend des nouvelles de la famille et rappelle poliment l'accord d'échéance.
- **Formule de vélocité de recouvrement (30 jours glissants) :**
  $$\text{Vélocité} = \begin{cases} 100 \% & \text{si aucune créance exigible} \\ \text{round}\left( \frac{\text{Montant recouvré dans les délais}}{\text{Montant total des créances exigibles sur 30j}} \times 100 \right) & \text{sinon} \end{cases}$$
  Le résultat est systématiquement borné entre 0 et 100.

## Verification

**Commands:**
- `flutter test` -- expected: Tous les tests unitaires et widget passent (0 failure).
- `flutter analyze` -- expected: Aucune erreur d'analyse statique.
