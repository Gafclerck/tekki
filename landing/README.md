# Tekki - Landing Page Vitrine

Site vitrine officiel de présentation de l'application mobile **Tekki** (gestion commerciale, *karné bor* et passeport financier pour les commerçants du Sénégal).

---

## 1. Structure du projet

Ce dossier est 100 % autonome et n'affecte en rien le développement de l'application mobile Flutter :

```text
landing/
├── index.html            # Page vitrine unique, sémantique, ultra-rapide (< 100 Ko)
├── assets/
│   ├── css/styles.css    # Design tokens stricts de Tekki (#133E59, #FF7A41, #FEECEA)
│   └── icons/            # Logos Tekki, Google Play, WhatsApp, SVG vectoriels
├── src/
│   └── js/main.js        # Simulateur de smartphone interactif, accordéon FAQ, toast
├── package.json          # Commandes de prévisualisation locale
└── README.md             # Ce guide
```

---

## 2. Comment tester en local

### Méthode 1 : Ouverture directe dans le navigateur
Double-cliquez simplement sur le fichier `index.html` ou ouvrez-le avec n'importe quel navigateur web (Chrome, Edge, Firefox, Safari).

### Méthode 2 : Avec un serveur local (Node.js)
Dans un terminal, positionnez-vous dans le dossier `landing` :
```bash
cd landing
npm run dev
```
Puis ouvrez `http://localhost:3000`.

---

## 3. Personnalisation des liens (À faire lors du lancement)

### Remplacer le lien Google Play Store
Dans `landing/index.html`, recherchez les balises `data-playstore-link` :
```html
<!-- Remplacer href="#" et data-playstore-url="#" par votre vrai lien Play Store : -->
<a href="https://play.google.com/store/apps/details?id=com.tekki.app" class="btn-playstore" data-playstore-link data-playstore-url="https://play.google.com/store/apps/details?id=com.tekki.app">
```

### Remplacer le numéro WhatsApp de contact
Dans `landing/index.html`, recherchez le lien `wa.me` :
```html
<!-- Remplacer 221000000000 par le numéro de téléphone de l'équipe Tekki : -->
<a href="https://wa.me/221XXXXXXXXX?text=Bonjour%20Tekki..." ...>
```

---

## 4. Déploiement

Le site étant constitué de fichiers statiques légers, il peut être hébergé gratuitement en quelques secondes sur :
- **Vercel** : Nouveau projet > Sélectionner le dépôt > Définir le `Root Directory` sur `landing`.
- **Netlify** : Glisser-déposer le dossier `landing` ou connecter le dépôt Git avec le `Base directory: landing`.
- **Cloudflare Pages** ou **GitHub Pages**.
