# CommuniRide - Plateforme de Covoiturage Communautaire

CommuniRide est une application mobile de covoiturage communautaire développée avec **Flutter**. Elle met en relation les membres d'une même communauté (entreprises, universités, quartiers) pour partager des trajets planifiés. L'accent est mis sur la confiance grâce à la validation des profils et sur la robustesse du trajet via une feuille de route embarquée accessible hors-ligne.

---

## 🚀 Fonctionnalités Principales

### 🛡️ Module 1 : Profils Vérifiés & Cercles Communautaires
* **Inscription & Vérification d'Email** : Validation stricte des adresses email (ex: `@gmail.com`) pour attribuer automatiquement des badges de confiance et joindre un cercle spécifique (ex: *Sorbonne Université*, *Google Paris*, *Station F*, *Université Paris-Saclay*).
* **Gestion du Véhicule** : Les conducteurs déclarent leur véhicule en choisissant parmi 3 catégories : **Particulier** (1-4 places), **Mini-bus** (5-15 places), ou **Bus** (16-50 places). La capacité des trajets est bridée par la catégorie sélectionnée.

### 🚗 Module 2 : Publication & Recherche de Trajets
* **Conducteur** : Publication simplifiée avec arrêt de départ, arrivée, étapes intermédiaires, date et heure, prix unitaire et cercles autorisés.
* **Passager** : Recherche multicritères avancée avec filtres dynamiques (prix max, horaires, et appartenance aux cercles). Réservation instantanée en attente de validation par le conducteur.

### 📡 Module 3 : Mode Hors-ligne & Carnet de Voyage
* **Feuille de Route Embarquée** : Une fois la réservation acceptée, toutes les informations clés (contact du conducteur, adresses, instructions textuelles d'itinéraire) sont persistées localement dans la base de données.
* **Validation Hors-ligne (Zone Blanche)** : Le passager et le conducteur peuvent confirmer le départ et l'arrivée même sans réseau. L'action est datée, mémorisée localement et mise en file d'attente.
* **Synchronisation Automatique** : Dès que l'un des appareils capte à nouveau du réseau, les actions en attente sont synchronisées avec le serveur simulé.

---

## 🎨 Design & Esthétique Premium

L'application a été construite selon les règles graphiques les plus modernes de Google (Material 3) :
* **Glassmorphism (Effet Verre Dépoli)** : Des conteneurs translucides avec floutage d'arrière-plan (`BackdropFilter`) et bordures fines et lumineuses.
* **Thème Sombre Fluorescent** : Palette de couleurs futuriste reposant sur un violet profond de fond (`0xFF0F0B1E`) combiné à des touches de cyan fluorescent (`Colors.cyanAccent`) et de violet électrique.
* **Contours Arrondis & Animations** : Systématiquement appliqués sur toutes les cartes, champs de texte et boutons avec des arrondis prononcés (16.0 à 24.0 pixels).

---

## 🛠️ Prérequis

Pour exécuter ce projet localement, assurez-vous d'avoir installé :
* **Flutter SDK** (v3.12.x ou supérieur)
* **Dart SDK** (v3.0.x ou supérieur)
* Un émulateur Android/iOS ou un appareil physique connecté.

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

## 🧪 Simulation Réseau (Démonstration du Mode Hors-ligne)

Un bandeau **"Réseau"** est présent en haut de chaque écran :
1. **Étape 1** : Connectez-vous, configurez votre véhicule (conducteur) et publiez un trajet.
2. **Étape 2** : Connectez un autre profil (ou utilisez les données de test préchargées) pour réserver un trajet.
3. **Étape 3** : Côté conducteur, acceptez la demande de réservation dans l'onglet **"Demandes"**.
4. **Étape 4** : Ouvrez les détails du trajet côté passager. La **Feuille de Route** s'affiche. Cliquez sur **"Ouvrir le Carnet de Voyage"**.
5. **Étape 5** : Utilisez le bandeau supérieur pour passer en **"Hors-ligne"** (Simule une zone blanche).
6. **Étape 6** : Cliquez sur **"Valider le Départ"**. Le statut passe en *"En attente de sync. ⏳"*.
7. **Étape 7** : Repassez le réseau en **"En ligne"**. La synchronisation se déclenche automatiquement en arrière-plan et le statut passe au vert *"Validé ✓"*.
