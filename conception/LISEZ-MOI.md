# Dossier conception — La Remise

## Contenu

| Fichier | Phase | Rôle |
|---|---|---|
| `dictionnaire.md` | 1 | Inventaire de toutes les données |
| `decisions.md` | 1 | Les 13 ambiguïtés tranchées |
| `schema-ea.png` | 2 | Schéma entité-association — **sans clé étrangère** |
| `schema-ea.mmd` | 2 | Source éditable du schéma E-A (Mermaid) |
| `phrases-cardinalites.md` | 2 | Lecture à voix haute de chaque cardinalité |
| `schema-relationnel.md` | 3 | Les 11 relations + la règle qui a produit chacune |
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
npm install -g @mermaid-js/mermaid-cli
mmdc -i schema-ea.mmd -o schema-ea.png -b white -s 2
```

Ou coller le `.mmd` sur https://mermaid.live pour un rendu immédiat.
