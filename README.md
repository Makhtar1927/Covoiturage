# 🚗 CommuniRide - Plateforme de Covoiturage Communautaire

CommuniRide est une application mobile de covoiturage de confiance développée avec **Flutter & Riverpod**. Elle met en relation les membres d'une même communauté (entreprises, universités, quartiers) pour partager des trajets planifiés. L'accent est mis sur la sécurité via la validation des cercles d'appartenance et sur la robustesse avec un mode hors-ligne intelligent pour valider les étapes d'un trajet (départs et arrivées en zone blanche).

---

## 🚀 Fonctionnalités Principales

### 🛡️ Module 1 : Cercles Communautaires & Profils Vérifiés
* **Inscription & Validation** : Attribution automatique d'un cercle (ex: *UKAC Touba*, *Quartier Dianatou*, *Complexe Keur Nabi*) selon l'email ou les informations déclarées.
* **Badges de Confiance** : Icône de validation pour les profils certifiés.
* **Gestion de Véhicule** : Les conducteurs configurent leur véhicule par catégorie (Particulier, Mini-bus, Bus) avec adaptation dynamique du nombre maximum de places autorisées.

### 🔍 Module 2 : Recherche & Réservation Premium
* **Recherche par Filtres** : Recherche intelligente filtrant par point de départ, destination, prix maximal, date de trajet et appartenance au cercle communautaire.
* **Cartes de Trajets Interactives** : Fiches détaillées avec étapes intermédiaires, horaires, prix et places disponibles.
* **Demandes en attente** : Gestion des réservations entrantes côté conducteur dans l'espace dédié.

### 📡 Module 3 : Mode Hors-ligne & Carnet de Voyage
* **Feuille de Route Embarquée** : Accès local à toutes les informations de contact, trajet et itinéraire même en l'absence complète de réseau.
* **Validation Résiliente (Zone Blanche)** : Déclaration du départ et de l'arrivée hors-ligne. Les actions sont mémorisées localement dans la file d'attente (Hive).
* **Synchronisation en Arrière-plan** : Dès que l'application détecte le retour d'une connexion internet, elle synchronise les validations en arrière-plan sans interrompre l'expérience utilisateur.

---

## 🎨 Design & Esthétique Premium

L'application a été repensée avec un design moderne Material 3 intégrant :
* **Glow & Glassmorphism** : Cartes translucides floutées (`BackdropFilter`) avec de fins liserés et des ombres douces.
* **Règle des Demi-Cercles Complets (StadiumBorder)** : Alignement strict de la charte graphique : tous les boutons, champs de saisie, chips de filtres et barres de navigation se terminent par des demi-cercles parfaits.
* **Mélange d'Avatars Réels & Initiaux (`UserAvatar`)** :
  * Affichage de photos de profils réelles et qualitatives pour les utilisateurs factices.
  * Génération automatique d'un avatar à initiales avec un dégradé unique basé sur le code de hachage du nom pour les profils sans photo.
* **Thème Sombre Fluorescent** : Palette moderne basée sur un bleu/violet profond (`#0F0B1E`), avec des accents cyan (`#00D4FF`) et violets pour une esthétique nocturne épurée.

---

## 🛠️ Stack Technique

* **Framework** : Flutter (M3)
* **Gestion d'état** : Riverpod (StateNotifier)
* **Stockage Local & Cache** : Hive & Hive Flutter (persistance locale hors-ligne pour les profils, trajets, réservations et file d'attente de synchronisation)
* **Formatage & Dates** : Intl (support complet du français)

---

## ⚙️ Installation & Lancement

1. **Cloner le dépôt** :
   ```bash
   git clone <url-du-depot>
   cd Covoiturage
   ```

2. **Récupérer les dépendances** :
   ```bash
   flutter pub get
   ```

3. **Lancer l'application** :
   ```bash
   flutter run
   ```

---

## 🧪 Simulation Réseau & Jeu de Test

L'application intègre un **Bandeau de Réseau interactif** en haut de chaque page pour basculer facilement entre les états **En ligne** et **Hors-ligne**.

### Scénario de test recommandé :
1. **Connexion & Accueil** : Connectez-vous lors de l'onboarding. Votre profil initialisé utilisera le système d'avatar personnalisé.
2. **Consultation du Carnet de Voyage** : Ouvrez l'onglet "Carnet". Vous verrez les trajets simulés (prêts pour la démo). Certains sont indiqués comme terminés, d'autres sont actifs.
3. **Simuler la zone blanche** : Appuyez sur le bandeau en haut pour passer en **"Hors-ligne"**.
4. **Valider hors-ligne** : Cliquez sur **"Valider le Départ"** sur l'une des courses en cours. Le système mémorise l'action localement et affiche l'état transitoire orange *"Sync. ⏳"*.
5. **Reconnexion** : Rétablissez la connexion en cliquant sur le bandeau pour repasser **"En ligne"**. La file d'attente se synchronise et l'état passe immédiatement au vert *"Validé ✓"*.
