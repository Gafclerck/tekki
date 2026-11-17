---
name: tekki
status: draft
sources:
  - "{planning_artifacts}/briefs/brief-tekki-2026-11-17/brief.md"
  - "{planning_artifacts}/briefs/brief-tekki-2026-11-17/addendum.md"
updated: 2026-11-17
---

# Tekki — Spécification de l'Expérience Utilisateur (EXPERIENCE.md)

> **Règle de prévalence :** Le présent document `EXPERIENCE.md` et son jumeau `DESIGN.md` constituent les contrats normatifs du produit. En cas de divergence avec un prototype ou une maquette, les spécifications écrites des spines prévalent formellement (*spines win on conflict*).
> Références visuelles associées :
> - [`mockups/directions-hero.html`](file:///D:/tekki/_bmad-output/planning-artifacts/ux-designs/ux-tekki-2026-11-17/mockups/directions-hero.html) (Orientation stylistique)
> - [`mockups/key-home-dashboard.html`](file:///D:/tekki/_bmad-output/planning-artifacts/ux-designs/ux-tekki-2026-11-17/mockups/key-home-dashboard.html) (Accueil & Caisse Hybride)
> - [`mockups/key-cloture-express.html`](file:///D:/tekki/_bmad-output/planning-artifacts/ux-designs/ux-tekki-2026-11-17/mockups/key-cloture-express.html) (Clôture Express du Soir)
> - [`mockups/key-karne-bor.html`](file:///D:/tekki/_bmad-output/planning-artifacts/ux-designs/ux-tekki-2026-11-17/mockups/key-karne-bor.html) (Carnet de Dettes Numérique)
> - [`mockups/key-passport-qr.html`](file:///D:/tekki/_bmad-output/planning-artifacts/ux-designs/ux-tekki-2026-11-17/mockups/key-passport-qr.html) (Passeport Financier & Scan D2D)

---

## 1. Foundation

* **Périmètre 100 % Application Mobile :** Tekki est conçu exclusivement comme une application mobile Android (Android 8.0+), optimisée pour les terminaux d'entrée de gamme (1 Go à 2 Go de RAM, profil Android Go).
* **Zéro Portail Web :** Aucun site web, portail de vérification en ligne (`verify.tekki.sn`) ou interface desktop n'est développé. Toute l'expérience (gestion, calcul de score, affichage et vérification du Passeport) s'exécute **100 % in-app** ou via l'écosystème mobile familier du commerçant (**WhatsApp**).
* **Pas de mode sombre :** L'application applique en permanence le fond blush chaleureux `{colors.background}` et les surfaces `{colors.surface}`, garantissant une clarté solaire et une lisibilité maximale en boutique de jour comme sous un éclairage modeste la nuit.
* **Architecture Offline-First Absolue :** 100 % des interactions (ventes au fil de l'eau, clôtures, relances, consultation de score) s'exécutent en local sur base SQLite/Drift. La synchronisation distante s'opère en tâche de fond dès la détection de connectivité, sans aucun écran de chargement bloquant.

---

## 2. Information Architecture

L'application s'articule autour de 5 surfaces principales, accessibles via une barre de navigation basse persistante à 4 onglets et des modales d'action instantanée.

| Surface | Provenance / Accès | Rôle & Modèle mental | Composants clés | Référence visuelle |
| :--- | :--- | :--- | :--- | :--- |
| **Accueil / Caisse** | Ouverture de l'app (Cold open) | Tour de contrôle de la journée : total des ventes en temps réel, capsule audio du Conseiller Tekki, statut du Karné Bor, accès au bouton focal du soir. | `cash-card`, `audio-capsule`, `button-primary-cta` | [`mockups/key-home-dashboard.html`](file:///D:/tekki/_bmad-output/planning-artifacts/ux-designs/ux-tekki-2026-11-17/mockups/key-home-dashboard.html) |
| **Vente Rapide (Au fil de l'eau)** | Bouton `+ Vente rapide` depuis l'Accueil | Modalité d'enregistrement instantané en 2 secondes au comptoir (montant direct, zéro gestion d'articles). | `quick-sale-keypad`, pavé numérique géant | Intégré à [`mockups/key-home-dashboard.html`](file:///D:/tekki/_bmad-output/planning-artifacts/ux-designs/ux-tekki-2026-11-17/mockups/key-home-dashboard.html) |
| **Clôture Express ("Tiroir-Caisse")** | Bouton orange focal de l'Accueil | Validation de fin de journée en 3 étapes rapides (< 30s) : ajustement ventes, dépenses réassort/frais, espèces déclarées. Ancrage GPS passif silencieux. | Formulaire étagé, indicateur de streak, bouton de validation | [`mockups/key-cloture-express.html`](file:///D:/tekki/_bmad-output/planning-artifacts/ux-designs/ux-tekki-2026-11-17/mockups/key-cloture-express.html) |
| **Karné Bor** | Onglet 2 de navigation | Ardoise numérique des dettes clients : montant total dehors, taux de recouvrement, alertes de retard, relance 1-clic WhatsApp, encaissement d'acompte. | `debt-card`, badge de retard, bouton relance WhatsApp | [`mockups/key-karne-bor.html`](file:///D:/tekki/_bmad-output/planning-artifacts/ux-designs/ux-tekki-2026-11-17/mockups/key-karne-bor.html) |
| **Passeport Financier** | Onglet 3 de navigation | Fiche d'identité financière infalsifiable : score /100 basé sur 4 piliers, QR Code dynamique scannable d'appareil à appareil, bouton partage PDF WhatsApp. | `passport-qr-card`, badge de score, bouton de partage | [`mockups/key-passport-qr.html`](file:///D:/tekki/_bmad-output/planning-artifacts/ux-designs/ux-tekki-2026-11-17/mockups/key-passport-qr.html) |
| **Conseiller Tekki** | Onglet 4 de navigation | Hub d'éducation financière : historique des capsules audio courtes en Wolof et Français, feux tricolores d'audit de gestion. | Lecteur audio avec onde, feux tricolores | Bannière sur [`mockups/key-home-dashboard.html`](file:///D:/tekki/_bmad-output/planning-artifacts/ux-designs/ux-tekki-2026-11-17/mockups/key-home-dashboard.html) |

---

## 3. Voice and Tone (Microcopy)

La tonalité de Tekki est **bienveillante, concrète et valorisante**. Elle respecte l'expertise du commerçant et évite toute condescendance ou vocabulaire financier anxiogène.

### Règles de langage
* **Bannir le jargon comptable :**
  * ❌ *Ne jamais écrire :* Bilan, Actif/Passif, Compte d'exploitation, Créances douteuses, Débiteur, Solvabilité bancaire, Amortissement.
  * ✅ *Toujours écrire :* Ventes du jour, Dépenses & Achats, Argent dehors, Karné Bor, Caisse du soir, Mon Passeport, Série de clôtures.
* **Primauté des formules orales familières :**
  * Salutation d'ouverture : *"Dalal ak jàmm, Moussa"* (Wolof : Bienvenue en paix).
  * Validation de caisse : *"Caisse verrouillée ! Beau travail aujourd'hui."*
  * Alerte bienveillante de crédit : *"Modou Fall dépasse son délai de 4 jours. Voulez-vous lui envoyer un rappel amical sur WhatsApp ?"*
* **Langues :** Textes d'interface disponibles en Français simplifié et Wolof. Les capsules du Conseiller Tekki sont systématiquement enregistrées en **Wolof** (format natif prioritaire) et **Français**.

---

## 4. Component Patterns (Spécifications Comportementales)

* **`button-primary-cta` (Bouton Focal Unique) :**
  * *Comportement :* Déclenché par un tap unique avec retour haptique court (vibration 20ms).
  * *Verrouillage :* Dès le premier tap, le bouton se verrouille pour interdire les doubles clics pendant l'écriture en base SQLite.
* **`quick-sale-keypad` (Saisie Hybride au Fil de l'Eau) :**
  * *Comportement :* S'ouvre sous forme de panneau inférieur (*bottom sheet*) immédiatement après appui sur `+ Vente rapide`.
  * *Frappe :* Pavé numérique de 0 à 9 avec grande touche "Effacer" et touche géante orange "Valider". Aucun séparateur décimal (toutes les transactions s'effectuent en FCFA entiers).
  * *Fermeture :* La validation incrémente instantanément le total du jour sur l'accueil et referme le panneau en moins de 1.5 seconde.
* **`audio-capsule` (Capsule Conseiller Tekki) :**
  * *Comportement :* Lecteur audio autonome au format note vocale WhatsApp.
  * *Contrôle :* Appui sur Play lance la lecture de la capsule (30 à 45s) avec progression visuelle de la jauge. Un sélecteur permet de basculer en un tap entre *Wolof* et *Français*.
  * *Résilience :* Si un appel téléphonique survient ou si l'utilisateur quitte l'application, la capsule se met automatiquement en pause.
* **`debt-card` (Ligne de Crédit Karné Bor) :**
  * *Comportement :* Carte tactile interactive. Un tap ouvre le détail (historique des achats du client).
  * *Actions rapides :* Bouton `Relance WhatsApp` générant un message poli avec le nom, le montant et le rappel de la date convenue. Bouton `Encaisser` ouvrant un dialogue pour saisir un montant partiel ou solder la dette d'un clic.
* **`passport-qr-card` (Vérification d'Appareil à Appareil) :**
  * *Comportement :* À l'ouverture de l'onglet Passeport, l'écran Android pousse temporairement la luminosité à son maximum pour optimiser le scan par un smartphone tiers (agent IMF ou grossiste).
  * *Sécurité :* Le QR Code intègre une signature cryptographique locale vérifiable hors-ligne. Un code PIN à 4 chiffres à usage temporaire est affiché sous le code pour validation par l'agent.

---

## 5. State Patterns

| Surface / Composant | État Normal | État Vide (Empty State) | État Erreur | État Hors-Ligne (Offline) |
| :--- | :--- | :--- | :--- | :--- |
| **Accueil / Caisse** | Montant cumulé en grand, bouton focal orange actif. | *"0 FCFA aujourd'hui. Enregistrez votre première vente ou faites votre clôture ce soir."* | Montant de dépenses supérieur aux ventes : bannière d'avertissement douce sans blocage. | Aucun changement visible : fonctionnement 100 % nominal, pastille discrète *"Sauvegardé en local"*. |
| **Clôture Express** | 3 champs pré-remplis avec calcul automatique du solde. | Première clôture de l'artisan : tutoriel visuel animé en 3 images. | Champ obligatoire laissé vide : surbrillance orange douce sur le champ omis. | Clôture enregistrée en SQLite avec horodatage local ; synchronisation différée. |
| **Karné Bor** | Liste des créances triées par urgence (retards en tête). | *"Aucun argent dehors ! Vos créances sont toutes à jour."* (Illustration positive). | Montant d'encaissement supérieur à la dette : ajustement automatique au solde restant dû. | Enregistrement local des dettes et relances WhatsApp opérationnelles sans réseau mobile data. |
| **Passeport Financier** | Score calculé, streak visible, QR Code affiché. | Moins de 7 jours de clôtures : *"Encore 3 clôtures pour générer votre premier Passeport Financier officiel."* | Erreur de lecture caméra par l'agent : affichage en clair de la clé d'attestation courte (PIN). | QR Code généré et vérifiable localement sans aucune connexion Internet. |

---

## 6. Interaction Primitives

* **Cibles tactiles minimales :** Minimum strict de 48dp x 48dp pour toutes les zones d'appui (norme d'accessibilité motrice).
* **Retours haptiques et sonores :**
  * Chaque validation de clôture et chaque encaissement de dette client déclenchent un son court et chaleureux (bruit feutré de tiroir-caisse) et une vibration haptique brève.
  * Ces retours confirment au commerçant que son geste a été enregistré sans qu'il ait besoin de fixer l'écran attentivement.
* **Ancrage GPS passif et silencieux :**
  * Lors de la clôture du soir, la position GPS est relevée en tâche de fond (rayon de 200m).
  * **Absence totale de blocage :** Si la localisation est indisponible ou hors rayon, l'application ne bloque jamais le commerçant et n'affiche aucun message alarmant : elle enregistre la clôture et pose un flag discret d'audit en base de données.

---

## 7. Accessibility Floor

* **Littératie & Oralité :** L'interface privilégie les pictogrammes explicites et les messages vocaux intégrés pour les commerçants ayant des difficultés de lecture du français écrit.
* **Contraste & Éclairage difficile :** Respect rigoureux des ratios de contraste WCAG AA sur le fond `{colors.background}`. Les chiffres de montants sont dimensionnés pour être lus à bout de bras dans une boutique sombre.
* **Redondance des états :** Aucun statut n'est indiqué par la couleur seule. Les feux tricolores de gestion sont systématiquement doublés d'icônes (✓ Vert = conforme, ⏳ Orange = attention, ! Rouge = urgent).

---

## 8. Key Flows (Parcours Utilisateurs Clés)

### Flow 1 : Enregistrement Hybride & Clôture Express du Soir ("Tiroir-Caisse")
* **Protagoniste :** Moussa Diop, 38 ans, boutiquier à Pikine.
* **Contexte :** 22h50, Moussa ferme les grilles de sa boutique après une longue journée. Il a enregistré quelques ventes au fil de l'eau l'après-midi, et veut consigner le reste en moins de 30 secondes pour aller se coucher.
* **Étapes du flux :**
  1. Moussa ouvre Tekki : l'écran d'accueil affiche 94 500 F déjà cumulés via ses ventes rapides du jour.
  2. Il clique sur le gros bouton orange `{colors.accent}` : *🔒 Clôturer la caisse du soir*.
  3. L'écran de clôture s'ouvre avec le total pré-rempli. Moussa ajoute 14 000 F d'achats de fin de soirée (ventes totales = 108 500 F).
  4. À l'étape 2, il déclare 15 000 F de dépenses (achat de glace et pain).
  5. À l'étape 3, il confirme que son tiroir contient 93 500 F en liquide et solde Wave.
  6. **Climax beat :** Moussa appuie sur *✅ Valider et Verrouiller*. L'application émet un son chaleureux de caisse et fait vibrer le téléphone. La bannière affiche : *"🔥 Clôture n°22 réussie ce mois-ci ! Passeport Financier consolidé."*
  7. **Chemin d'anomalie (Failure path) :** Le réseau mobile est coupé et le signal GPS est faible dans sa boutique en tôle : Tekki enregistre la clôture localement en 0.2 seconde, sans aucun message d'erreur, et marque un flag d'audit silencieux en tâche de fond.

### Flow 2 : Carnet de Dettes Karné Bor & Recouvrement
* **Protagonistes :** Moussa et Fatou Kiné (cliente de confiance du quartier).
* **Contexte :** Fatou vient prendre du riz et de l'huile pour 5 000 FCFA à crédit, promettant de payer vendredi.
* **Étapes du flux :**
  1. Moussa ouvre l'onglet *Karné Bor* et clique sur `+ Noter une Dette Client`.
  2. Il sélectionne "Fatou Kiné" dans ses contacts récents, tape "5000", choisit l'échéance à vendredi, et valide en 2 clics.
  3. Le vendredi suivant, l'application affiche un badge orange sur la ligne de Fatou.
  4. Moussa clique sur le bouton `💬 Relance WhatsApp` : Tekki ouvre automatiquement WhatsApp avec une note cordiale rédigée en Wolof/Français rappelant le solde dû.
  5. **Climax beat :** Fatou passe en début d'après-midi et remet un billet de 5 000 F. Moussa clique sur `✓ Encaisser` : la dette disparaît de la liste des arriérés, et la jauge de vélocité de recouvrement de Moussa bondit à 92 %.
  6. **Chemin d'anomalie (Failure path) :** Fatou ne peut payer que 2 000 F : Moussa clique sur `Encaisser`, saisit 2 000 F ; Tekki recalcule le solde restant dû (3 000 F) et reporte l'échéance sans générer de pénalité anxiogène.

### Flow 3 : Présentation et Vérification du Passeport Financier (D2D & WhatsApp)
* **Protagonistes :** Moussa et Amadou (agent de crédit terrain de la microfinance PAMECAS).
* **Contexte :** Moussa souhaite négocier une avance de trésorerie de 300 000 FCFA pour doubler son stock avant la fête de la Tabaski, mais ne possède aucun titre foncier ni bilan comptable.
* **Étapes du flux :**
  1. Amadou se rend à la boutique de Moussa et lui demande une preuve d'activité.
  2. Moussa ouvre Tekki sur son smartphone Android et se rend sur l'onglet *Passeport Financier*.
  3. L'écran augmente automatiquement sa luminosité et présente un grand QR Code sécurisé accompagné de la mention *"Score : 82/100 · 22 clôtures/mois · Taux de recouvrement : 92 %"*.
  4. Amadou scanne le QR Code directement d'appareil à appareil avec l'application de son agence de microfinance et saisit le code PIN temporaire (4821) que Moussa lui dicte.
  5. **Climax beat :** En 10 secondes chrono, l'écran d'Amadou affiche l'attestation certifiée et infalsifiable attestant de 90 jours de gestion ininterrompue. Simultanément, Moussa appuie sur `📲 Partager l'Attestation PDF sur WhatsApp` pour envoyer le dossier PDF complet au bureau d'Amadou. Amadou déclare : *"Dossier limpide, votre avance de 300 000 F est accordée dès demain."*
  6. **Chemin d'anomalie (Failure path) :** Le code PIN temporaire expire avant qu'Amadou n'ait fini de le saisir : Tekki régénère un nouveau PIN à 4 chiffres en un tap sans recharger la page, préservant la fluidité de l'échange.
