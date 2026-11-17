# Revue Adversariale d'Architecture : Risques de Divergence & Failles du Spine Tekki

- **Document audité :** [ARCHITECTURE-SPINE.md](file:///D:/tekki/_bmad-output/planning-artifacts/architecture/architecture-tekki-2026-11-17/ARCHITECTURE-SPINE.md)
- **Rôle :** Architecture Adversarial Reviewer
- **Date :** 17 Novembre 2026
- **Verdict Global :** **FAIL (Blocages de Divergence & Trous d'Intégrité Métier)**

---

## 1. Résumé Exécutif & Motivation du Verdict

Bien que l'épine dorsale architecturale (**Architecture Spine**) démontre une excellente adhérence conceptuelle aux principes de Clean Architecture, BLoC et Offline-First, une analyse adversariale approfondie révèle **quatre failles structurelles majeures**.

Si deux développeurs ou deux sous-agents indépendants implémentent aujourd'hui les modules `sales_and_cash`, `karne_bor`, `sync` et `financial_passport` en suivant strictement et littéralement chaque Décision d'Architecture (AD-1 à AD-8) :
1. **La caisse physique divergera systématiquement du grand livre comptable** dès le premier remboursement de dette en espèces.
2. **Une condition de course (*race condition*) silencieuse corrompra le scellement de la clôture du soir** en cas de vente concurrente.
3. **Le système de synchronisation souffrira d'amnésie locale**, rendant impossible l'affichage de l'état de synchronisation sur l'interface et ouvrant la porte à des corruptions silencieuses lors des conflits.
4. **Le Passeport Financier hors-ligne présente une faille cryptographique d'auto-signature** permettant à n'importe quel commerçant de fabriquer un score parfait offline sans que le vérificateur ne puisse détecter l'imposture.

Le verdict est donc **FAIL** tant que les contrats inter-modules, les modèles de données partagés et le modèle de confiance cryptographique ne sont pas formellement verrouillés.

---

## 2. Attaque 1 : Sales & Cash vs. Karné Bor — Le « Cash Fantôme » & Rupture du Grand Livre

### Contexte & Règles en conflit apparent
- **AD-5 (Sales & Cash) :** Pré-remplit la clôture express à partir de la somme des `Sale` du jour. `DailyClosure` enregistre `total_sales_amount`, `total_expenses_amount` et `cash_counted`.
- **AD-2 & AD-3 (Karné Bor) :** Persiste les dettes et remboursements dans `DEBTS` et `DEBT_PAYMENTS`.
- **ERD Local (Lignes 311-383) :**
  - Table `SALES` : `amount`, `payment_method` (`ESPECES` ou `MOBILE_MONEY`), `closure_id`.
  - Table `DEBT_PAYMENTS` : `id`, `debt_id`, `payment_amount`, `paid_at`.

### Le Scénario de Rupture
1. À 15h00, un client débiteur (Moussa) vient rembourser **15 000 FCFA en espèces** au comptoir.
2. Le développeur de l'Epic **Karné Bor** a implémenté `RecordPaymentUseCase` en respectant AD-1 et AD-3 :
   - Insertion dans `DEBT_PAYMENTS` (`payment_amount: 15000`).
   - Décrément de `remaining_amount` dans `DEBTS`.
   - Insertion dans `SYNC_OUTBOX`.
   - **Aucune écriture dans `SALES`** car un remboursement de dette n'est pas une vente (le produit est sorti du stock des jours plus tôt).
3. À 20h00, le commerçant procède à sa clôture journalière via `DailyClosureBloc` :
   - Le développeur de l'Epic **Sales & Cash** a implémenté `ProcessDailyClosureUseCase` conformément à l'AD-5 :
     ```sql
     SELECT SUM(amount) FROM sales WHERE closure_id IS NULL; -- Total: 50 000 FCFA
     ```
   - Le commerçant compte physiquement les billets dans son tiroir-caisse (`cash_counted`) : 50 000 FCFA (ventes) + 15 000 FCFA (remboursement Moussa) = **65 000 FCFA**.
   - L'écran affiche un écart inexpliqué de **+15 000 FCFA** !

### La Rupture Réciproque : Vente à Crédit
1. Un client achète pour **8 000 FCFA** de marchandises à crédit.
2. Si le commerçant enregistre l'opération dans Karné Bor (`CreateDebtUseCase`), la table `SALES` ne reçoit rien. Le chiffre d'affaires du jour est sous-évalué de 8 000 FCFA.
3. Si le développeur ajoute un mode `CREDIT` dans `SALES.payment_method` :
   - Est-ce que `sales_and_cash` crée la dette dans `DEBTS` ? (Violation de SRP / Deux propriétaires pour une dette).
   - Lors du remboursement ultérieur, est-ce une vente ? Si oui, le chiffre d'affaires est comptabilisé deux fois !

> **Verdict Faille 1 :** L'architecture manque d'une entité pivot **`CashMovement` (Mouvement de Caisse)** ou d'un livre de caisse unifié. Les deux modules gèrent des flux de trésorerie de manière étanche et incompatible.

---

## 3. Attaque 2 : Concurrence & Condition de Course lors de la Clôture du Soir

### Le Scénario de Rupture
1. À 19h30, le gérant ouvre la page `ExpressClosurePage`.
2. Le `DailyClosureBloc` s'initialise et exécute une requête d'agrégation :
   - Ventes non clôturées : V1 (2 000 FCFA), V2 (5 000 FCFA) $\rightarrow$ `total_sales_amount = 7 000 FCFA`.
   - Le formulaire affiche 7 000 FCFA.
3. À 19h31, alors que le gérant recompte ses pièces, un client pressé achète un savon à **500 FCFA**. L'apprenti prend le téléphone, revient sur l'écran d'accueil ou utilise le pavé tactile rapide, et enregistre la vente V3 (500 FCFA).
4. À 19h32, le gérant revient sur l'écran de clôture (ou clique sur "Valider" sans rafraîchissement) :
   - `ProcessDailyClosureUseCase` est déclenché avec la valeur saisie/affichée à 19h30 : `7 000 FCFA`.
   - Deux implémentations concurrentes divergentes sont possibles pour sceller les ventes :
     - **Implémentation Développeur A :** `UPDATE sales SET closure_id = @closureId WHERE closure_id IS NULL;` $\rightarrow$ La vente V3 (500 FCFA) est estampillée avec `closure_id`, mais le montant consolidé de la clôture reste à `7 000 FCFA`. **Le grand livre est mathématiquement désynchronisé** (la somme des ventes liées à la clôture fait 7 500 FCFA, la clôture indique 7 000 FCFA).
     - **Implémentation Développeur B :** Le cas d'utilisation ne met à jour que les ventes identifiées à 19h30. V3 reste `closure_id = NULL`. Le lendemain, V3 est agrégée dans la journée du lendemain avec un horodatage de la veille, faussant la régularité temporelle.

> **Verdict Faille 2 :** L'AD-5 ne définit pas de mécanisme d'instantané (*snapshotting*) ni de verrouillage d'état durant la clôture express. Deux sous-agents produiront des comportements de scellement corrupteurs d'intégrité.

---

## 4. Attaque 3 : Passeport Financier — L'Illusion de la Signature Ed25519 & L'Incertitude d'Audit

### Le Scénario de Rupture : Falsification Hors-Ligne par Auto-Signature
L'AD-4 stipule :
> *"Le score de réputation et le Passeport Financier sont calculés intégralement in-app par le cas d'utilisation `CalculateFinancialPassport`... signé avec l'algorithme Ed25519... scannable d'appareil à appareil en moins d'une seconde par un agent de crédit sans accès réseau."*

Considérons l'adversaire (un commerçant malveillant ou un développeur de ROM modifiée) :
1. Dans l'ERD, la table `SHOPS` contient `public_key`. La clé privée est stockée dans `flutter_secure_storage`.
2. Le terminal génère sa propre paire de clés Ed25519 lors de l'onboarding local offline.
3. Le commerçant injecte dans SQLite 100 fausses ventes de 50 000 FCFA avec des clôtures régulières.
4. L'application calcule un score parfait de 95/100, encode le CBOR, et signe la charge utile avec sa clé privée locale.
5. Le QR code contient : `[Payload, Signature, PublicKeyId]`.
6. L'agent de crédit de l'IMF scanne le QR code hors-ligne :
   - Avec quelle clé publique l'agent vérifie-t-il la signature ?
   - Si la clé publique est dans le QR code ou dans le terminal du commerçant sans signature de certification racine (*Certificate Authority / Tekki Root Key*), **la signature prouve uniquement que le terminal a signé ses propres données**, elle n'apporte **aucune preuve d'authenticité ou de non-falsification** !

### Le Scénario de Rupture : Ventes Non-Synchronisées vs. Ventes Frauduleuses
- L'AD-6 prévoit `is_flagged_location: true` sur `DAILY_CLOSURES`.
- Mais que fait le moteur `CalculateFinancialPassport` face à des clôtures non encore synchronisées (`status = PENDING` dans `SYNC_OUTBOX`) ?
  - Doit-il intégrer les clôtures non synchronisées dans le score ?
    - **Si OUI :** Le commerçant peut créer 30 jours de clôtures fictives en 5 minutes hors-ligne et obtenir une attestation officielle immédiate.
    - **Si NON :** En zone blanche rurale (où le commerçant ne capte pas pendant 2 semaines), son passeport financier chutera à zéro pour "inactivité", détruisant la promesse même de Tekki !
- De plus, la table `SALES` ne contient **aucun champ d'intégrité ou d'audit** (`is_flagged`). Seule `DAILY_CLOSURES` en possède un. Si une vente individuelle est anormale, le Passeport Financier n'a aucun moyen de le savoir.

> **Verdict Faille 3 :** Le modèle cryptographique pèche par absence d'Ancre de Confiance (*Trust Anchor / PKI*). La vérification hors-ligne D2D sans contre-signature serveur ou autorité racine est vulnérable à l'auto-génération frauduleuse.

---

## 5. Attaque 4 : Sync Outbox vs. Base Locale — L'Amnésie Post-Synchronisation

### Le Scénario de Rupture
L'AD-3 et le diagramme de séquence Outbox (lignes 243-276) stipulent :
1. `Repo` écrit atomiquement dans `sales` et `sync_outbox`.
2. Le worker `SyncOutboxWorker` lit `sync_outbox`, envoie en batch, et exécute :
   ```sql
   DELETE FROM sync_outbox WHERE client_event_id IN (Processed IDs);
   ```
3. Observons l'état des tables métier locales (`SALES`, `DEBTS`, `DAILY_CLOSURES`) après cette suppression :
   - `SALES` contient : `id`, `amount`, `payment_method`, `recorded_at`, `closure_id`.
   - **Aucune colonne `synced_at`, `is_synced` ou `sync_version` n'existe dans les tables métier !**

### Conséquences Directes d'Implémentation
1. **Impossibilité d'afficher le statut UI :** Sally (UX Designer) a prévu des indicateurs de synchronisation (icône nuage vert / horloge grise). Le développeur de l'UI / BLoC est incapable de savoir si une vente affichée est déjà synchronisée ou non, car une fois l'événement supprimé de `sync_outbox`, la vente redevient indistinguable d'un enregistrement orphelin !
2. **Conflit de Résolution & Mutation :** Si le serveur rejette une clôture ou signale une incohérence (ex. clôture rejetée car date antérieure), où est enregistré l'état d'échec ? La table `sync_outbox` marque `FAILED`, mais l'entité `DAILY_CLOSURES` reste intouchée et valide en local. Le commerçant continue d'opérer sur une clôture que le cloud a rejetée.
3. **Format du Payload Non Contractualisé :** L'AD-3 impose `payload_json` sans définir de contrat de schéma d'événement.
   - Le développeur `sales_and_cash` sérialise `{ "sale_id": "...", "price": 5000 }`.
   - Le développeur `karne_bor` sérialise `{ "id": "...", "amount": 5000, "debtor": { ... } }`.
   - Le module `sync` envoie des payloads hétérogènes non typés, rendant le parsing serveur fragile et non versionné.

> **Verdict Faille 4 :** L'absence de métadonnées de synchronisation sur les entités métier crée une amnésie d'état dès que l'outbox est vidée.

---

## 6. Inventaire des Ambiguïtés & Trous Secondaires

| Réf | Composant | Ambiguïté / Faille Détectée | Risque d'Implémentation Divergente |
| :--- | :--- | :--- | :--- |
| **AMB-1** | `SalesBloc` & Drift Streams | Concurrence entre le `Future<Result>` du UseCase et le `Stream` Drift réactif (Lignes 83-85 vs 121). | Double émission d'état dans BLoC, clignotement de l'UI ou écrasement de toasts d'erreur. |
| **AMB-2** | Bounded Contexts | Le module `financial_passport` lit directement les tables `sales`, `daily_closures` et `debts`. | Violation de Clean Architecture (dépendance croisée entre features au niveau Data/Domain) ou duplication de code de lecture. |
| **AMB-3** | Annulation / Erreur de Saisie | Aucune table ni AD ne documente l'annulation d'une vente erronée (ex: frappe 50 000 au lieu de 5 000 FCFA). | Un développeur implémentera un `DELETE` physique (cassant l'outbox idempotente), un autre un avoir négatif. |
| **AMB-4** | GPS Timeout | Délai passif de 5 secondes sur géolocalisation dans le thread UI / UseCase de clôture (Ligne 109). | Risque d'ANR (*Application Not Responding*) ou blocage de la boucle événementielle Flutter si le service natif ne respecte pas l'asynchronisme pur. |

---

## 7. Recommandations de Durcissement du Spine (Actions Correctives Immédiates)

Pour transformer ce Spine en un substrat de build inattaquable, appliquer les 5 amendements d'architecture suivants :

### Recommandation 1 : Introduire le concept de `CashMovement` & Unifier la Caisse
Modifier l'ERD et le domaine pour que toute entrée ou sortie physique d'argent liquide génère une écriture de caisse :
```text
CASH_MOVEMENTS (id, source_type ['SALE', 'DEBT_PAYMENT', 'EXPENSE'], source_id, amount, direction ['IN', 'OUT'], recorded_at, closure_id)
```
- Une vente en espèces génère une `Sale` + un `CashMovement(IN)`.
- Un remboursement de dette en espèces génère un `DebtPayment` + un `CashMovement(IN)`.
- La clôture express n'agrège plus les ventes pour le tiroir-caisse, elle agrège les `CASH_MOVEMENTS` où `closure_id IS NULL`. L'encaisse physique est rigoureusement exacte.

### Recommandation 2 : Mécanisme de Clôture par Snapshot Atomique & Token de Session
Remplacer le simple calcul à la volée par une procédure de scellement en deux étapes :
1. L'ouverture de l'écran de clôture crée une session d'instantané (`ClosureSnapshot`) identifiant la liste immuable des IDs de ventes et de mouvements à sceller.
2. Toute nouvelle vente enregistrée pendant que l'écran est ouvert reçoit un horodatage postérieur à la session et reste rattachée à la période suivante.
3. La validation lie atomiquement les IDs du snapshot au `closure_id` créé.

### Recommandation 3 : Ajouter les Métadonnées de Sync sur les Entités Métier
Ne pas détruire l'état de synchronisation lors de la purge de l'outbox :
- Ajouter sur `SALES`, `DEBTS`, `DAILY_CLOSURES` les colonnes :
  - `sync_status` (`LOCAL_ONLY`, `PENDING_SYNC`, `SYNCED`, `SYNC_ERROR`)
  - `synced_at` (nullable ISO-8601 UTC)
- Le worker d'outbox, lors de la réception du 200 OK, met à jour `sync_status = 'SYNCED'` sur l'entité source dans la même transaction que le nettoyage de `sync_outbox`.

### Recommandation 4 : Architecture Cryptographique à Deux Niveaux (Chaîne de Confiance)
Pour que la vérification D2D hors-ligne soit infalsifiable :
1. Le backend Tekki signe la clé publique du commerçant lors de l'onboarding (ou dès la première synchronisation) sous la forme d'un certificat marchand compact CBOR (*Merchant Identity Certificate* signé par la clé maîtresse `Tekki Root Authority`).
2. Le QR Code hors-ligne embarque :
   `[Certificate(ShopId, PublicKey, RootSignature), PassportPayload, ShopSignature]`
3. L'application vérificatrice (IMF) intègre la clé publique `Tekki Root Authority` codée en dur. Elle valide d'abord le certificat de la boutique, puis la signature du passeport avec la clé de la boutique.
4. Pour le mode 100% offline avant première sync : marquer explicitement le passeport comme `UNVERIFIED_PROVISIONAL` dans la charge utile CBOR.

### Recommandation 5 : Contrat d'Événements Outbox & Interfaces Inter-Features
1. Définir dans `core/sync/contracts/` une structure scellée `DomainSyncEvent` avec sérialisation versionnée (`schema_version: 1`).
2. Définir des interfaces de façade inter-domaines : `features/financial_passport` ne requête pas la base de données brute, elle consomme `IFinancialHistoryReader` fourni par `core` ou implémenté via des façades dédiées.

---

## 8. Conclusion de la Revue

Le Spine présente une vision métier et ergonomique de haute qualité, mais pèche par des **frontières de données perméables** et une **absence de primitives de réconciliation de trésorerie**. L'implémentation immédiate par plusieurs agents conduirait inévitablement à un échec d'intégration entre le carnet de dettes et la caisse journalière.

L'application des 5 recommandations ci-dessus permettra de lever le verdict **FAIL** et de démarrer la génération de code sur une base saine et mathématiquement cohérente.
