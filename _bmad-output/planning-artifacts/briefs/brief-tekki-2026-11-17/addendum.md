# Addendum au Product Brief: Tekki

Ce document consigne les détails techniques, choix d'architecture, matrices d'options rejetées et spécifications algorithmiques destinés aux documents aval (PRD, Architecture Système, Spécifications UX).

---

## 1. Justification Stratégique de l'Option "Zéro Financement Direct"

- **Option rejetée :** Financement direct par Tekki avec décaissement de micro-avances de réassort (25 000 à 50 000 FCFA).
- **Raisons du rejet pour le MVP :**
  1. **Contraintes réglementaires BCEAO :** L'octroi de crédit direct exige un agrément d'institution financière ou d'émetteur de monnaie électronique, avec des exigences prudentielles et de fonds propres incompatibles avec un lancement rapide de MVP.
  2. **Risque de bilan & Défaut de paiement :** Sans nantissement ni garantie physique, l'exposition directe aux défauts ferait peser un risque critique sur la trésorerie de l'entreprise.
  3. **Portabilité et indépendance :** En restant pur émetteur d'un Passeport Financier vérifiable, Tekki conserve une position neutre de tiers de confiance pour l'ensemble des banques, IMF et grossistes du marché.

---

## 2. Spécifications Algorithmiques & Données de Scoring (Recommandations PRD)

L'algorithme de calcul du score de réputation opérationnelle s'appuie sur la régularité et la dynamique de gestion plutôt que sur un chiffre d'affaires déclaré facilement manipulable :

- **Régularité des clôtures journalières (35 %) :**
  - Mesure du nombre de clôtures effectuées sur une période glissante de 30 jours (seuil minimal recommandé : 20 à 22 clôtures/mois).
- **Vélocité de recouvrement du Karné Bor (40 %) :**
  - Délai moyen écoulé entre la création d'une créance client et son règlement partiel ou total.
  - Taux de créances en souffrance (créances > 30 jours sans mouvement).
- **Stabilité géographique anti-fraude (15 %) :**
  - Corrélation entre les balises GPS capturées lors des clôtures du soir et la position de référence enregistrée pour la boutique (rayon de cohérence fixé à 200 mètres avec flag silencieux d'audit sans blocage de l'utilisateur).
- **Discipline d'épargne ou encaisse résiduelle déclarée (10 %) :**
  - Constance du solde de caisse restant en fin de journée.

---

## 3. Spécifications du Module Conseiller Tekki (MVP)

- **Nature du Conseiller :**
  - Moteur d'**éducation financière et de conseil personnalisé**, alimenté par l'historique réel des ventes et dépenses du commerçant.
  - Il ne s'agit pas d'un modèle LLM conversationnel lourd, ni d'un simple système d'alerte passif : c'est un module analytique dédié à la montée en compétences financières du commerçant (gestion du fonds de roulement, seuils d'endettement soutenables, anticipation du réassort).
- **Mode de délivrance des conseils :**
  - **Indicateurs visuels simples :** Feux tricolores (vert/orange/rouge) sur la santé des créances clients et le rythme de clôture.
  - **Capsules audio courtes (30 à 45s) :** Synthétisées ou scénarisées en Wolof et Français (style note vocale WhatsApp), faciles à écouter le matin ou lors de la clôture.

---

## 4. Contraintes Techniques Mobiles (Architecture & Dev)

- **Architecture Offline-First :** Base de données locale (ex. SQLite / Drift ou équivalent) avec mécanisme de synchronisation en arrière-plan dès la récupération d'un signal réseau (Edge / 3G / 4G / Wi-Fi).
- **Empreinte mémoire et compatibilité :**
  - APK optimisé pour fonctionner de manière fluide sur Android 8+ et appareils de 1 Go à 2 Go de RAM (profil Android Go).
  - Poids de l'application plafonné à moins de 15 Mo pour faciliter le téléchargement direct ou le partage en Bluetooth / ShareIt.
- **Vérification Mobile & Partage 100 % in-app (Zéro Portail Web) :**
  - Aucun portail web hébergé ni URL publique : le Passeport Financier est vérifié directement d'appareil à appareil via le QR Code sécurisé affiché in-app (scannable par l'application partenaire ou un lecteur standard) et via l'export PDF cryptographiquement certifié partageable directement par WhatsApp.

---

## 5. Spécifications du Mode d'Enregistrement Hybride des Ventes
- **Au fil de l'eau (Saisie rapide 2 clics) :** Pavé numérique épuré permettant de taper un montant en 2 secondes après une vente (sans gestion de catalogue d'articles obligatoire) pour les moments calmes.
- **Consolidé le soir (Clôture express "Tiroir-Caisse") :** Déclaration globale en fin de journée pour les journées à fort rush au comptoir.
- **Harmonisation :** L'application agrège dynamiquement les ventes au fil de l'eau avec la clôture du soir sans créer de doublons, laissant l'entière liberté de rythme au commerçant.
