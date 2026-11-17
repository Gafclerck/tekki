# Document d'Intention Produit (Intent Document)
## Inclusion Financière des Commerçants Informels au Sénégal

> **Statut :** Validé (issu de la session de brainstorming BMAD)  
> **Destination aval :** Product Owner (Sofia / `bmad-agent-po`) & Product Manager (John / `bmad-agent-pm`)  
> **Date de référence :** 17 Novembre 2026  
> **Marché cible :** Commerçants de détail, boutiquiers de quartier et demi-grossistes (Sénégal / Dakar & régions)

---

## 1. Synthèse Exécutive & Proposition de Valeur

### 1.1 Problématique & Thèse Centrale
Plus de 90 % du commerce de détail au Sénégal évolue dans l'économie informelle. Ces micro-entrepreneurs réalisent des volumes d'affaires significatifs mais restent structurellement exclus du financement bancaire et des Institutions de Microfinance (IMF) traditionnelles, faute d'états financiers certifiés, de bilans comptables et de garanties physiques réelles. Parallèlement, les solutions de caisse classiques échouent car la contrainte de saisie unitaire est incompatible avec le rythme effréné du comptoir informel.

**Thèse fondamentale du produit :**  
L'outil de gestion commerciale n'est pas une finalité logicielle mais le **vecteur d'acquisition de données réelles non biaisées** pour fabriquer un **Passeport Financier certifié**. Ce passeport convertit l'assiduité opérationnelle et la discipline de trésorerie en solvabilité bancable, ouvrant l'accès à des micro-avances de réassort.

### 1.2 Promesse Marché & Levier d'Adoption
> *"Ton carnet devient ton passeport financier : 30 jours de clôture régulière = accès direct au micro-crédit de réassort sans caution physique."*

La caution patrimoniale traditionnelle (titre foncier, gage matériel) est substituée par une **caution de réputation transactionnelle** adossée à trois piliers :
1. La constance des clôtures de caisse journalières.
2. La vélocité de recouvrement des créances clients (*karné bor*).
3. L'ancrage territorial et la discipline d'épargne quotidienne (*coffre Natt*).

---

## 2. Périmètre & Cadre MoSCoW (MVP)

| Priorité | Fonctionnalités & Capacités | Justification Stratégique |
| :--- | :--- | :--- |
| **MUST HAVE** | • **Saisie Hybride Universelle** (Clôture express du soir OU Caisse détaillée au choix).<br>• **Carnet de Dettes (*Karné Bor*)** avec suivi des créances et remboursements clients.<br>• **Réconciliation Grossiste-Détaillant** automatique sous condition d'inscription mutuelle.<br>• **Moteur de Score Multidimensionnel** (accent sur vélocité de recouvrement et constance).<br>• **Ancrage GPS Passif Anti-Fraude** lors des clôtures journalières.<br>• **Passeport Financier standardisé avec QR Code** pour banques et IMF partenaires.<br>• **Credit Ladder (Palier d'amorçage)** : micro-avances de réassort 25 000 à 50 000 FCFA à 7-14 jours.<br>• **Garde-fou IA Anti-Surendettement** calculant l'échéance soutenable sur marge réelle.<br>• **Coffre Natt Solo** : suivi d'épargne d'autodiscipline journalière sans tontine collective.<br>• **Briefing Vocal Hebdomadaire** asynchrone (audio synthétisé en Wolof et Français). | **Socle minimal viable :** capture sans friction, fiabilisation anti-fraude, calcul de solvabilité et amorçage du crédit à risque maîtrisé. |
| **SHOULD HAVE** | • Relances SMS/WhatsApp optionnelles aux débiteurs du carnet pour certification croisée légère.<br>• Export PDF / format impression thermique pour guichets physiques d'IMF.<br>• Alertes de réassort prioritaires sur les produits financés par le palier de crédit. | Confort opérationnel et facilitation des interactions physiques avec les agents de crédit terrain. |
| **COULD HAVE** | • **Agent IA vocal interactif complet** : pilotage total de l'application à la voix en Wolof/Français (style WhatsApp bidirectionnel).<br>• **Natt collectif solidaire digitalisé** (cercle de 5 commerçants avec abondement de l'IMF).<br>• Paiement direct au grand distributeur en nature/stock sans déboursement de cash. | Extensions à forte valeur ajoutée mais complexité d'ingénierie et d'adoption trop élevée pour le MVP. |
| **WON'T HAVE (MVP)** | • Intégration directe par API aux opérateurs Mobile Money (Wave, Orange Money, Free Money).<br>• Enrôlement forcé des tiers (clients débiteurs ou fournisseurs non-inscrits).<br>• Crédit de trésorerie libre ou non plafonné à moyen/long terme. | Élimine les dépendances réglementaires lourdes, le KYC bancaire complexe et la friction d'onboarding. |

---

## 3. Architecture Détaillée des 3 Blocs Fonctionnels

```
+---------------------------------------------------------------------------------------+
|                                    APPLICATION TEKKI                                  |
+---------------------------------------------------------------------------------------+
|  BLOC 1 : CAPTURE & DONNÉES TRANSACTIONNELLES                                         |
|  - Saisie Hybride Universelle (Express "Tiroir-Caisse" du soir VS Caisse détaillée)   |
|  - Carnet de Dettes Numérique (Karné Bor : octroi, suivi, échéance, encaissement)    |
|  - Pont Réconciliation Grossiste <-> Détaillant (Activation conditionnelle si inscrits) |
+-------------------------------------------+-------------------------------------------+
                                            |
                                            v Flux de données horodatées & géolocalisées
+-------------------------------------------+-------------------------------------------+
|  BLOC 2 : MOTEUR DE SCORE & FINANCEMENT                                               |
|  - Score Multidimensionnel : Vélocité de recouvrement Bor + Constance + Ancienneté   |
|  - Filtre Anti-Fraude : Ancrage GPS passif aux clôtures (détection anomalies fantômes) |
|  - Passeport Financier : Fiche standardisée + QR Code vérifiable pour Banques/IMF     |
|  - Module Credit Ladder : Micro-avances réassort stock (25k-50k FCFA sur 7-14 jours)   |
+-------------------------------------------+-------------------------------------------+
                                            |
                                            v Calcul de capacité & Accompagnement
+-------------------------------------------+-------------------------------------------+
|  BLOC 3 : IA ÉCONOMIQUE, PROTECTION & CONSEIL                                         |
|  - Garde-fou Anti-Surendettement : Plafond d'emprunt indexé sur la marge réelle nette |
|  - Coffre Natt Solo : Suivi de discipline d'épargne journalière auto-déclarée         |
|  - Briefing Vocal Hebdomadaire : Note vocale 3 conseils de trésorerie (Wolof/Français) |
|  - [Couche Future / Could-Have] : Agent vocal interactif de saisie libre              |
+---------------------------------------------------------------------------------------+
```

### 3.1 Bloc 1 : Capture & Données (Low Friction)

#### A. Saisie Hybride Universelle
Chaque commerçant configure son mode de saisie à tout moment sans rupture de données :
1. **Mode Express "Tiroir-Caisse" (Recommandé petits détaillants / boutiquiers) :**  
   - Aucune saisie au fil de l'eau durant la journée.
   - En fin de journée, saisie en 30 secondes de deux métriques : *Total Ventes Espèces du Jour* et *Dépenses d'approvisionnement immédiates*.
2. **Mode Caisse Détaillée (Recommandé demi-grossistes et boutiques structurées) :**  
   - Enregistrement article par article des ventes, gestion des stocks unitaires et marges brutes.

#### B. Carnet de Dettes Numérique (*Karné Bor*)
Le crédit informel fait partie intégrante du commerce de proximité sénégalais. Le module numérise cette pratique :
- Enregistrement instantané d'une dette client (Nom/Contact, Montant, Date limite convenue).
- Enregistrement des paiements partiels ou soldes de tout compte.
- Calcul de la **vélocité de recouvrement** : délai moyen entre l'octroi du crédit client et son remboursement effectif.

#### C. Réconciliation Automatique Grossiste-Détaillant
- **Condition stricte :** Fonctionne de manière automatique **uniquement si les deux acteurs possèdent un compte actif sur la plateforme**.
- **Mécanisme :** Lorsqu'un grossiste inscrit enregistre une vente au nom d'un détaillant inscrit (identifié par numéro de téléphone), cette transaction est injectée automatiquement comme un *achat certifié* dans le livre de comptes du détaillant.
- **Impact crédit :** Les achats certifiés par un tiers bénéficient d'un coefficient de pondération supérieur dans l'algorithme de scoring.
- **Règle de résilience :** Si le grossiste n'est pas inscrit, le détaillant peut déclarer ses achats manuellement (avec ou sans photo de reçu papier).

---

### 3.2 Bloc 2 : Moteur de Score & Financement (Confiance & Solvabilité)

#### A. Algorithme de Score Multidimensionnel
Le volume brut des ventes est jugé trompeur et facile à manipuler. L'algorithme fonde la solvabilité sur la **discipline opérationnelle et la rotation financière** :
- **Pondération 1 (40 %) : Vélocité de recouvrement du *Karné Bor***. Capacité du commerçant à faire rentrer son argent rapidement et faible taux de créances douteuses.
- **Pondération 2 (30 %) : Régularité et constance des clôtures journalières**. Clôture quotidienne enregistrée sur au moins 30 jours consécutifs (preuve de rigueur de gestion).
- **Pondération 3 (15 %) : Ancienneté et historique sur la plateforme**.
- **Pondération 4 (15 %) : Discipline d'épargne déclarée (*Coffre Natt*)**.

#### B. Ancrage GPS Passif Anti-Fraude
Pour neutraliser le risque de faux comptes ou de "remboursements fantômes" (inventions d'écritures pour gonfler artificiellement le score) :
- Capture silencieuse et passive des coordonnées géographiques lors de la validation de la clôture du soir.
- **Règle d'invalidation :** Toute clôture réalisée en dehors d'un rayon de tolérance par rapport à l'emplacement physique habituel du commerce déclenche un flag de défiance. Une dispersion spatiale anormale suspend la progression du score.

#### C. Passeport Financier & QR Code Vérifiable
- Document standardisé synthétisant les 30 à 90 derniers jours d'activité : chiffre d'affaires reconstitué, marge moyenne estimée, volume de crédit client accordé/recouvré, score global de fiabilité.
- Mise à disposition d'un **QR Code dynamique sécurisé** permettant à un agent d'IMF partenaire ou d'une banque d'accéder instantanément à la vue d'audit infalsifiable sans consulter le détail confidentiel de chaque transaction.

#### D. Mécanisme "Credit Ladder" (Micro-avances de réassort)
Pour mitiger le risque d'impayé tout en habituant le commerçant au cycle de remboursement :
- **Palier 1 (Amorçage) :** Micro-avance de 25 000 FCFA remboursable à J+7.
- **Palier 2 :** 50 000 FCFA à J+14 après succès du Palier 1.
- **Palier 3 :** 100 000 FCFA à J+30.
- **Affectation :** Le crédit est prioritairement alloué au réassort de stock à haute rotation (denrées de première nécessité, cartes de recharge, gaz) pour éviter la déviation vers des dépenses d'urgence sociale.

---

### 3.3 Bloc 3 : IA Économique, Protection & Conseil

#### A. Garde-Fou Anti-Surendettement
Avant toute éligibilité ou proposition de crédit :
- L'algorithme calcule la **marge bénéficiaire nette soutenable**.
- L'échéance de remboursement maximale autorisée ne peut excéder **25 % du flux net quotidien ou hebdomadaire moyen constaté**.
- Si les marges du commerçant se contractent, le palier de crédit est automatiquement plafonné pour préserver sa survie économique.

#### B. Coffre Natt Solo (Discipline d'Épargne Individuelle)
Inspiré de la tradition sénégalaise du *Natt* (tontine), mais délesté de la lourdeur d'un groupe collectif pour le MVP :
- Module individuel où le commerçant s'engage sur un objectif quotidien d'auto-discipline (ex. : "Mettre 2 000 FCFA de côté chaque soir").
- Simple coche déclarative lors de la clôture du soir.
- Démontre la capacité de rétention d'épargne de précaution, renforçant le profil d'évaluation du risque.

#### C. Briefing Vocal Hebdomadaire (Wolof & Français)
- Chaque lundi matin, génération d'une capsule audio (30 à 45 secondes) écoutable comme une note vocale WhatsApp.
- Synthétise en langage naturel et accessible 3 insights concrets :
  1. Le volume total encaissé la semaine passée.
  2. Les créances prioritaires à recouvrer dans le *karné bor*.
  3. L'état d'avancement vers le prochain palier du Passeport Financier.

#### D. Couche Future (Could-Have) : Agent Vocal Interactif
- Pilotage intégral par la voix de l'application (dialogue bidirectionnel en Wolof sénégalais pour dicter ses ventes ou interroger son solde). Classé formellement en horizon v2.

---

## 4. Exclusions Formelles & Garde-fous du MVP

1. **Aucune intégration API Mobile Money (Wave, Orange Money, Free) :**
   - *Raison d'exclusion :* Les délais d'approbation d'agrégation, les frais de commissionnement et les contraintes réglementaires de la BCEAO alourdiraient le MVP. Le suivi des flux de caisse s'effectue sur les montants globaux déclarés.
2. **Aucun enrôlement forcé des tiers :**
   - Ni les clients débiteurs du commerçant, ni ses fournisseurs ne sont obligés de créer un compte ou de télécharger l'application. La valeur est autonome et immédiate pour le commerçant isolé.
3. **Aucune gestion de crédit d'investissement lourd :**
   - Le système refuse de financer du matériel ou des investissements long terme. Il est strictement calibré sur des avances de réassort de trésorerie de cycle court (7 à 14 jours).

---

## 5. Directives pour le Product Owner (Sofia / `bmad-agent-po`)

Pour la conversion de cet Intent Document en backlog exécutable (Épics et User Stories) :

### 5.1 Découpage Recommandé en Épics
1. **ÉPIC 1 : Moteur de Clôture & Saisie Hybride (UX Low Friction)**  
   *Focus :* Bascule fluide entre clôture express du soir et saisie détaillée ; ergonomie grand écran / petits claviers ; fonctionnement offline-first intégral.
2. **ÉPIC 2 : Registre des Dettes (*Karné Bor*) & Réconciliation Partenaire**  
   *Focus :* Saisie rapide d'un débiteur, suivi des échéances, calcul temps réel de la vélocité de recouvrement, matching automatique des transactions inter-utilisateurs par numéro MSISDN.
3. **ÉPIC 3 : Moteur de Score, Géolocalisation & Passeport QR Code**  
   *Focus :* Algorithme pondéré de scoring, capture de la balise GPS de clôture, génération de la page d'attestation publique sécurisée derrière le QR Code.
4. **ÉPIC 4 : Mécanisme Credit Ladder & Garde-Fou de Solvabilité**  
   *Focus :* Paliers progressifs 25k -> 50k FCFA, verrou d'échéance basé sur la marge réelle soutenable, simulateur d'éligibilité.
5. **ÉPIC 5 : Module Natt & Briefing Vocal d'Accompagnement**  
   *Focus :* Coffre virtuel solo, moteur de synthèse text-to-speech en Wolof/Français pour le débriefing hebdomadaire.

### 5.2 Contraintes Non-Fonctionnelles & Terrain
- **Offline-First & Résilience Réseau :** L'application doit pouvoir enregistrer les clôtures et les bor même sans connexion Internet, avec synchronisation différée dès la détection de connectivité 3G/4G.
- **Littératie & Clarté Visuelle :** Utiliser des codes couleur francs (vert = encaissé, rouge = dette, jaune = en attente), des pictogrammes universels et des feedbacks audio courts.
- **Empreinte Données Mobiles :** Application légère (< 15 Mo), compatible Android Go / appareils d'entrée de gamme fréquents sur les marchés sénégalais.

### 5.3 Métriques Clés de Succès (KPIs MVP)
- **Régularité de Clôture :** > 70 % des utilisateurs actifs effectuant au moins 22 clôtures par mois.
- **Vélocité de Recouvrement Bor :** Baisse d'au moins 20 % du délai moyen d'encaissement des crédits clients après 60 jours d'usage.
- **Taux de Remboursement Palier 1 (25k FCFA) :** > 95 % de remboursement à échéance J+7 sur les premières cohortes de micro-avances.
