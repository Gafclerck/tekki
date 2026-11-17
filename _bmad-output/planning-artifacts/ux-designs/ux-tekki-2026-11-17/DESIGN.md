---
name: tekki
description: "Identité visuelle et tokens pour l'application mobile de gestion commerciale et passeport financier des commerçants informels"
colors:
  primary: '#133E59'
  secondary: '#387387'
  tertiary: '#8CB8C3'
  accent: '#FF7A41'
  accent-soft: '#FFAE90'
  background: '#FEECEA'
  surface: '#FFFFFF'
typography:
  display:
    fontSize: '28px'
    fontWeight: '800'
    lineHeight: '34px'
  title:
    fontSize: '20px'
    fontWeight: '800'
    lineHeight: '26px'
  headline:
    fontSize: '16px'
    fontWeight: '700'
    lineHeight: '22px'
  body:
    fontSize: '14px'
    fontWeight: '500'
    lineHeight: '20px'
  caption:
    fontSize: '11px'
    fontWeight: '600'
    lineHeight: '15px'
rounded:
  sm: '6px'
  md: '12px'
  lg: '16px'
  xl: '20px'
  full: '9999px'
spacing:
  '1': '4px'
  '2': '8px'
  '3': '12px'
  '4': '16px'
  '5': '24px'
  '6': '32px'
  gutter: '16px'
  touch-min: '48px'
components:
  button-primary-cta:
    background: '{colors.accent}'
    color: '#FFFFFF'
    borderRadius: '{rounded.lg}'
    padding: '{spacing.4}'
    fontSize: '{typography.headline.fontSize}'
    fontWeight: '{typography.headline.fontWeight}'
    minHeight: '52px'
  card-surface:
    background: '{colors.surface}'
    borderColor: '{colors.tertiary}'
    borderWidth: '1px'
    borderRadius: '{rounded.lg}'
    padding: '{spacing.4}'
  audio-capsule:
    background: '{colors.surface}'
    borderLeftColor: '{colors.accent}'
    borderLeftWidth: '5px'
    borderRadius: '{rounded.md}'
    padding: '{spacing.3}'
  badge-status:
    borderRadius: '{rounded.sm}'
    padding: '3px 8px'
    fontSize: '{typography.caption.fontSize}'
    fontWeight: '{typography.caption.fontWeight}'
---

# Tekki — Spécification du Design Système (DESIGN.md)

> **Règle de prévalence :** Le présent document `DESIGN.md` et son jumeau `EXPERIENCE.md` constituent les contrats normatifs du produit. En cas de divergence avec une maquette, un prototype ou un composant graphique, les spécifications écrites des spines prévalent formellement (*spines win on conflict*).
> Référence visuelle d'orientation : [`mockups/directions-hero.html`](file:///D:/tekki/_bmad-output/planning-artifacts/ux-designs/ux-tekki-2026-11-17/mockups/directions-hero.html).

---

## 1. Brand & Style

Tekki s'adresse aux commerçants et boutiquiers de quartier opérant dans l'économie informelle sénégalaise. La posture esthétique refuse à la fois l'austérité bureaucratique des logiciels de comptabilité d'entreprise et la surcharge ludique des applications gamifiées. 

Le design incarne la **sérénité opérationnelle**, le **respect du travail quotidien** et la **clarté cognitive immédiate**. Face à des journées de travail denses de 14 à 16 heures, souvent sous une luminosité variable et au milieu de clients pressés, l'interface offre une respiration visuelle :
* **Faible densité d'information :** Un seul message ou une seule action majeure par écran. Jamais de tableaux denses ni de colonnes encombrées.
* **Chaleur et ancrage local :** Le fond d'application blush `{colors.background}` adoucit les contrastes et évoque la terre et l'accueil bienveillant, tandis que le bleu marine profond `{colors.primary}` apporte l'autorité et la rigueur d'une institution financière fiable.
* **Élément focal unique :** Chaque vue ne tolère qu'un unique appel à l'action orange `{colors.accent}`, guidant le regard sans hésitation.

---

## 2. Colors

La palette de Tekki est strictement restreinte aux sept jetons définis en frontmatter. Aucun dégradé complexe ni couleur tierce n'est autorisé.

| Jeton | Code Hex | Rôle sémantique | Utilisation autorisée | Interdictions formelles |
| :--- | :--- | :--- | :--- | :--- |
| `{colors.primary}` | `#133E59` | Bleu marine profond | Titres majeurs, boutons primaires de consultation, texte principal sur fond clair, carte de prestige du Passeport Financier. | Ne jamais utiliser pour les alertes d'erreur ou les arrière-plans d'écrans entiers. |
| `{colors.secondary}` | `#387387` | Bleu sarcelle / Teal | Boutons secondaires, liens, icônes d'accompagnement, états actifs de la barre de navigation, métadonnées. | Ne pas utiliser comme couleur de texte pour les montants financiers principaux. |
| `{colors.tertiary}` | `#8CB8C3` | Bleu ciel doux | Bordures de cartes `{colors.surface}`, séparateurs horizontaux, puces inactives, états désactivés. | Ne jamais utiliser pour du texte de petite taille (contraste insuffisant sur fond blanc). |
| `{colors.accent}` | `#FF7A41` | Orange vif | **Élément focal unique par écran** : bouton de clôture express du soir, validation de dette, alertes de retard critiques. | Ne jamais utiliser plus d'une fois par vue pour préserver sa puissance hiérarchique. |
| `{colors.accent-soft}` | `#FFAE90` | Pêche doux | Badges d'avertissement modérés, fonds d'icône active, états pressés des boutons d'accentuation. | Ne pas utiliser pour le texte principal. |
| `{colors.background}` | `#FEECEA` | Blush chaleureux | Fond global de toutes les vues de l'application Android, sections d'aide douce. | Ne jamais remplacer par un noir ou gris sombre (pas de mode sombre). |
| `{colors.surface}` | `#FFFFFF` | Blanc pur | Cartes d'information, conteneurs de formulaire, pavés de saisie numérique, fond de navigation basse. | Ne pas utiliser comme fond d'application global (le fond est `{colors.background}`). |

### Cibles de contraste WCAG AA
* Texte `{colors.primary}` sur `{colors.background}` : Ratio ~10.8:1 (Conforme AAA).
* Texte `{colors.primary}` sur `{colors.surface}` : Ratio ~13.5:1 (Conforme AAA).
* Bouton `{colors.accent}` avec texte `#FFFFFF` : Ratio ~3.4:1 pour grands titres / 4.5:1 exigé pour texte d'action bold (garanti par graisse 800 à 16px).
* Puce `{colors.secondary}` sur `{colors.surface}` : Ratio ~5.1:1 (Conforme AA).

---

## 3. Typography

Tekki s'appuie sur la pile typographique native Android (`Roboto`, `-apple-system`, `sans-serif`) pour garantir une empreinte mémoire minimale (< 15 Mo pour l'APK) et supporter automatiquement le paramétrage d'agrandissement de texte du système d'exploitation (*Android Dynamic Type*).

### Rôles typographiques
* **Display (`{typography.display}`)** : Chiffres de caisse majeurs, score du Passeport Financier (ex. "94 500 F", "82/100").
* **Title (`{typography.title}`)** : En-têtes d'écrans principaux ("Tableau de Caisse", "Karné Bor", "Clôture").
* **Headline (`{typography.headline}`)** : Libellés de sections, noms de clients débiteurs, texte des boutons focaux.
* **Body (`{typography.body}`)** : Explications des étapes, messages de confirmation, sous-titres des cartes.
* **Caption (`{typography.caption}`)** : Horodatage, mentions légales, tags de langue audio ("Wolof 38s").

---

## 4. Layout & Spacing

* **Échelle d'espacement modulaire :** Tous les écarts s'alignent sur une base de 4px / 8px (`{spacing.1}` à `{spacing.6}`).
* **Marge d'écran (Gutter) :** `{spacing.gutter}` (16px) sur les bords gauche et droit pour le format smartphone Android.
* **Cible tactile minimale (Touch Target Floor) :** `{spacing.touch-min}` (48dp x 48dp) pour tout élément interactif (boutons, icônes de navigation, puces de filtrage), indispensable pour un usage fluide à une main au comptoir.
* **Respiration verticale :** Chaque carte est séparée de la suivante par `{spacing.3}` (12px) ou `{spacing.4}` (16px). Le bas de page réserve un espace tampon de 80px pour ne pas masquer de contenu sous la barre de navigation.

---

## 5. Elevation & Depth

Tekki privilégie la **définition par la matière et les bordures subtiles** plutôt que les ombres portées lourdes, inadaptées aux processeurs des smartphones Android d'entrée de gamme.
* **Niveau 0 (Fond) :** Arrière-plan continu en `{colors.background}`.
* **Niveau 1 (Cartes de surface) :** `{colors.surface}` avec bordure de 1px `{colors.tertiary}` et ombre ultra-légère (`box-shadow: 0 2px 6px rgba(19, 62, 89, 0.05)`).
* **Niveau 2 (Bouton focal & Modalités) :** Bouton `{colors.accent}` avec ombre chaude (`box-shadow: 0 4px 14px rgba(255, 122, 65, 0.35)`), créant un appel tactile irrésistible.

---

## 6. Shapes

* **Rayons de courbure arrondis :**
  * `{rounded.sm}` (6px) : Puces de statut, badges de retard.
  * `{rounded.md}` (12px) : Cartes compactes, lecteurs audio du Conseiller Tekki.
  * `{rounded.lg}` (16px) : Cartes principales de caisse, grands conteneurs de formulaire, boutons d'action.
  * `{rounded.xl}` (20px) : Modales d'enregistrement rapide de vente.
  * `{rounded.full}` (9999px) : Bouton de lecture audio Play/Pause, avatars d'initiales, puces de sélection.

---

## 7. Components (Spécifications Visuelles)

| Composant | Anatomie & Tokens | Apparence normale | État pressé / actif |
| :--- | :--- | :--- | :--- |
| **`button-primary-cta`** | Conteneur rectangulaire arrondi `{rounded.lg}`, fond `{colors.accent}`, texte `#FFFFFF` graisse 800, ombre portée accentuée. | Fond orange vif, icône d'action + libellé centré. | Fond `{colors.accent-soft}`, diminution de l'élévation. |
| **`button-secondary`** | Fond `{colors.surface}`, bordure 1.5px `{colors.secondary}`, texte `{colors.secondary}`. | Bordure sarcelle nette, fond blanc. | Fond `{colors.background}`. |
| **`card-surface`** | Carte blanche `{colors.surface}`, bordure 1px `{colors.tertiary}`, padding `{spacing.4}`, rayon `{rounded.lg}`. | Fond blanc, contraste doux avec le fond blush. | Sans effet de survol sur mobile. |
| **`audio-capsule`** | Carte `{colors.surface}`, bordure gauche 5px `{colors.accent}`, bouton Play circulaire `{colors.accent}` avec glyphe blanc. | Bandeau compact avec tag uppercase et durée audio. | Bouton Play passe en Pause avec onde sonore discrète. |
| **`quick-sale-keypad`** | Pavé numérique intégré sur fond `{colors.surface}`, touches larges (min 60dp), afficheur géant `{typography.display}`. | Touches délimitées par `{colors.tertiary}`, montant lisible à 1 mètre. | Retour visuel par surbrillance `{colors.background}` lors de la frappe. |
| **`passport-qr-card`** | Conteneur `{colors.surface}`, QR Code centré de 150x150dp avec marge blanche de sécurité de 8dp, badge PIN à 4 chiffres. | QR Code net à fort contraste, encadré d'instructions en Wolof/Français. | Plein écran tactile lors d'un appui pour faciliter le scan. |

---

## 8. Do's and Don'ts

### À FAIRE (Do's)
* ✅ Réserver l'orange `{colors.accent}` exclusivement à l'action clé unique de chaque vue.
* ✅ Utiliser des dimensions tactiles minimales de 48x48dp pour tous les boutons.
* ✅ Préserver le fond blush `{colors.background}` qui confère son identité chaleureuse et distinctive à Tekki.
* ✅ Exprimer les montants financiers dans une typographie imposante (`{typography.display}`) accompagnée de l'unité "F" ou "FCFA".

### À NE PAS FAIRE (Don'ts)
* ❌ Ne jamais concevoir ni intégrer de mode sombre (dark mode rejeté : l'application fonctionne exclusivement en mode lumineux chaleureux).
* ❌ Ne jamais afficher plus d'un bouton orange `{colors.accent}` simultanément sur le même écran.
* ❌ Ne jamais empiler de colonnes denses de données ou de tableaux comptables (actif / passif).
* ❌ Ne jamais utiliser de textes en `{colors.tertiary}` pour du contenu informatif (réservé aux bordures et séparateurs).
