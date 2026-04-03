# RPG Project — Dragon Quest 2 Style

## Vision
RPG tour par tour complet, style SNES 16-bit, inspiré de Dragon Quest 2.
Jeu personnel complet (pas un prototype).

## Contexte narratif
Le joueur incarne un fermier qui protège son troupeau de brebis.
- Scène d'ouverture : un champ, le fermier affronte un loup qui menace son troupeau
- Ce combat tutoriel pose les bases du système de combat
- Au fil de l'histoire, 1 ou 2 compagnons rejoignent le groupe

## Stack technique
- **Moteur** : Godot 4.6
- **Langage** : GDScript uniquement
- **Données** : Resources (.tres) pour toutes les données statiques (héros, ennemis, sorts, items)
- **UI** : Control nodes (CanvasLayer + Control)
- **Audio** : AudioStreamPlayer + AudioBus

---

## Architecture générale

### Organisation des dossiers
- `scripts/Core/` — GameManager (Autoload), SceneLoader, SaveSystem
- `scripts/World/` — Déplacement, TileMap, Caméra
- `scripts/Party/` — Gestion du groupe, stats des héros, inventaire
- `scripts/Combat/` — State machine de combat, calculs, IA ennemie
- `scripts/Characters/` — PNJ, brebis, comportements
- `scripts/UI/` — HUD, menus, fenêtres de combat, dialogues
- `resources/` — Toutes les Resources (.tres) : HeroData, EnemyData, SpellData, ItemData
- `scenes/World/` — Scènes de terrain (Field, Overworld, Towns…)
- `scenes/Characters/` — Scènes de personnages (Player, Sheep…)
- `scenes/Battle/` — Scène de combat réutilisable
- `scenes/UI/` — Scènes d'interface

### Patterns imposés
- **Resource** (.tres) pour toutes les données statiques (jamais de valeurs hardcodées)
- **State Machine** explicite pour le combat (enum + match ou classes d'état)
- **Autoload** uniquement pour GameManager, AudioManager, SaveSystem
- **Signals** pour la communication entre systèmes

---

## Mécaniques cibles

### Groupe
- 1 personnage au départ, puis 1 ou 2 compagnons rejoignent au fil de l'histoire
- Chaque personnage a : HP, MP, ATK, DEF, AGI, LVL, XP
- Formule de dégâts : `dmg = max(1, ATK - DEF/2) + Random(-2, 2)`

### Combat
- Tour par tour, vue frontale 2D
- Ordre des tours basé sur AGI
- Actions : Attaque, Sort (coût MP), Item, Défendre, Fuir
- Rencontres aléatoires sur overworld et donjons (pas sur routes/villes)
- Ennemis groupés (1 à 4 ennemis par combat)

### Carte du monde
- Tilemap grande échelle (overworld)
- Zones de terrain : herbe, forêt, montagne, désert, mer
- Taux de rencontre variable selon terrain

### Véhicules
- Pas de bateau. Déplacement uniquement à pied sur toutes les zones.

### Sorts et MP
- Sorts offensifs (dégâts mono/groupe), défensifs (soin, buff), utilitaires (téléport)
- Chaque sort défini dans un `SpellData` ScriptableObject
- Apprentissage des sorts par niveau (table définie dans `HeroData`)

---

## Structure de scènes Unity
```
Scenes/
  Boot          ← initialisation, chargement SaveSystem
  MainMenu
  Overworld     ← carte du monde principale
  Town_[Name]   ← une scène par ville/intérieur
  Dungeon_[Name]
  Battle        ← scène de combat réutilisable unique
```

---

## Conventions de code
- Noms de classes en PascalCase (`class_name`), variables privées en `_snake_case`
- Tout export doit avoir un commentaire `##` si non-évident
- Pas de `get_node()` dans `_process()` — cacher les références dans `_ready()`
- Utiliser `@onready` pour les dépendances de nœuds enfants
- Un fichier = une classe

---

## Priorités de développement
1. Déplacement joueur sur grille (Tilemap, collisions)
2. Transition de scènes + chargement
3. ScriptableObjects de base (HeroData, EnemyData)
4. State machine de combat fonctionnelle
5. UI de combat (menus, barres HP/MP)
6. Overworld complet + rencontres aléatoires
7. Recrutement de compagnons (événements narratifs)
8. Sorts et inventaire
9. Sauvegarde / chargement
10. Contenu (niveaux, ennemis, histoire)

---

## Ce que Claude Code doit toujours faire
- Respecter l'organisation des dossiers définie ci-dessus
- Créer les Resources dans `resources/`
- Placer les scripts dans `scripts/[domaine]/`
- Ajouter des commentaires `##` sur toutes les fonctions publiques
- Signaler si une décision d'architecture semble incohérente avec ce document
