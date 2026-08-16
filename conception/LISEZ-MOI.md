# Dossier conception — La Remise

## Contenu

| Fichier | Phase | Rôle |
|---|---|---|
| `dictionnaire.md` | 1 | Inventaire de toutes les données |
| `decisions.md` | 1 | Les 12 ambiguïtés tranchées |
| `schema-ea.png` | 2 | Schéma entité-association — **sans clé étrangère** |
| `schema-ea.dot` | 2 | Source éditable du schéma E-A (graphviz) |
| `phrases-cardinalites.md` | 2 | Lecture à voix haute de chaque cardinalité |
| `arbre-dependances.png` | 3 | Ordre de création des tables |
| `schemas-relations/` | — | 9 schémas de détail, un par relation, pour réviser |

## Pourquoi deux schémas différents

`schema-ea.png` (Phase 2) décrit **le métier** : entités, associations, cardinalités.
Aucune clé étrangère — c'est une exigence de l'énoncé.

`schemas-relations/01-vue-ensemble.png` (Phase 3) décrit **les tables** : avec les
clés étrangères, qui sont le *résultat* du passage R1/R2/R3.

Les FK ne sont pas une donnée de départ, elles sont ce qu'on démontre en Phase 3.

## Régénérer les images

```bash
brew install graphviz
dot -Tpng -Gdpi=140 schema-ea.dot -o schema-ea.png
```
