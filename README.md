# Tekki

Application mobile Android de gestion commerciale, d'education financiere et de passeport financier portable pour les commercants.

## Architecture

Le projet applique une **Clean Architecture** combinee a une organisation **Feature-first** et au paradigme **Offline-First Reactive Outbox**.

```text
lib/
├── core/                       # Fondations transverses partagees
│   ├── constants/              # Constantes et seuils applicatifs
│   ├── errors/                 # Failures et Exceptions
│   ├── network/                # Detection de connectivite
│   ├── theme/                  # Design tokens et theme visuel
│   └── utils/                  # Formateurs (FCFA) et Result type
│
├── features/                   # Modules metier decoupes en 3 couches
│   ├── sales_and_cash/         # Vente rapide et cloture express de caisse
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── karne_bor/              # Carnet de dettes et velocite de recouvrement
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── financial_passport/     # Passeport financier et QR Code signe
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── advisor/                # Conseiller financier et capsules audio
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   └── sync/                   # File d'attente outbox et synchronisation
│       ├── domain/
│       ├── data/
│       └── presentation/
│
├── app.dart                    # Configuration MaterialApp et theme
├── injection_container.dart    # Service Locator (GetIt)
└── main.dart                   # Point d'entree de l'application
```

## Regles Architecturales

- **Couche Domain :** Dart pur. Zéro dépendance vers Flutter, Drift ou réseau.
- **Couche Data :** Implémentations des dépôts, base Drift SQLite locale (mode WAL), sources distantes.
- **Couche Presentation :** BLoC / Cubit pour la gestion d'état, widgets découplés de toute logique métier.
- **Sens des dépendances :** Strictement dirigé vers le domaine (`presentation -> domain <- data`).

## Workflow Git

- `main` : Branche protégée, réservée aux versions stables de production.
- `develop` : Branche protégée, intégration continue des développements validés.
- `feat/*` : Branches de fonctionnalités ou de tooling créées à partir de `develop`.
- `fix/*` : Branches de correction d'anomalies.

### Convention de Commits

Le projet utilise les Conventional Commits :
- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bogue
- `refactor:` Refactorisation sans modification de comportement
- `chore:` Tâches de maintenance, configuration ou outillage
- `test:` Ajout ou modification de tests
- `docs:` Documentation
- `build:` Dépendances ou système de compilation
- `ci:` Intégration continue

## Commandes Utiles

### Installation des Dépendances
```bash
flutter pub get
```

### Analyse Statique et Formatage
```bash
flutter analyze
dart format --output=none --set-exit-if-changed .
```

### Exécution des Tests
```bash
flutter test
```

### Génération de Code (Drift / Injectable)
```bash
dart run build_runner build --delete-conflicting-outputs
```
