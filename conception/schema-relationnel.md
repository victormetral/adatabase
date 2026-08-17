# Schéma relationnel — La Remise

---

## Les trois règles de passage

| Règle | Énoncé | Où elle s'applique ici |
|---|---|---|
| **R1** | Toute entité devient une table. Son identifiant devient la clé primaire. | Les 9 entités (+ 2 tables issues d'associations)| 
| **R2** | Association binaire dont **une patte a une cardinalité max = 1** : la clé de l'entité opposée migre en clé étrangère du côté (x,1), avec les éventuels attributs de l'association. | EST AUSSI, FAIT, CONTIENT, APPARTIENT A, CONCERNE, EFFECTUE, ACHETE, COMPORTE, ANIME |
| **R3** | Association dont **les deux pattes ont une cardinalité max = n** : elle devient une table, clé primaire composée des clés des entités, plus ses attributs propres. | POSSEDE, S'INSCRIT A |

---

## Les 11 relations

### 1. personne
```
personne(id_personne, nom, prenom, telephone, email, est_adherent)
```
> **R1** sur l'entité PERSONNE. Aucune association ne lui envoie de clé : toutes ses associations sont du côté (x,n).

### 2. categorie
```
categorie(id_categorie, libelle)
```
> **R1** sur l'entité CATEGORIE.

### 3. competence
```
competence(id_competence, libelle)
```
> **R1** sur l'entité COMPETENCE.

### 4. benevole
```
benevole(#id_personne, date_entree, est_actif)
```
> **R1** sur l'entité BENEVOLE, puis **R2** sur EST AUSSI — PERSONNE (0,1) — (1,1) BENEVOLE.
> Cardinalité max 1 des deux côtés : la clé de `personne` migre et **devient elle-même la clé primaire**. C'est la signature d'une spécialisation 1:1 *(D1)*.
FK → référence la personne correspondante.
PK → empêche une personne d’être enregistrée plusieurs fois comme bénévole.
Le bénévole 42 est la personne 42. On ne crée pas un nouvel id_benevole.

### 5. depot
```
depot(id_depot, date_depot, type_depot, #id_personne)
```
> **R1** sur DEPOT, puis **R2** sur FAIT — PERSONNE (0,n) — (1,1) DEPOT.
> La patte DEPOT est en (1,1) : la clé de `personne` migre dans `depot`. NOT NULL, car le minimum est 1 *(RG1)*.

### 6. vente
```
vente(id_vente, date_vente, mode_paiement, #id_personne)
```
> **R1** sur VENTE, puis **R2** sur ACHETE LORS DE — PERSONNE (0,n) — (0,1) VENTE.
> La patte VENTE est en (0,1) : la clé de `personne` migre. Minimum 0 → la colonne est **nullable** *(D11 : client de passage)*.

### 7. objet
```
objet(id_objet, etiquette, designation, poids_g, etat_arrivee, statut,
      prix_affiche, date_mise_en_rayon, date_sortie_rayon, prix_paye,
      #id_depot, #id_categorie, #id_vente)
```
> **R1** sur OBJET, puis **R2** trois fois :
> - CONTIENT — DEPOT (1,n) — (1,1) OBJET → `#id_depot`, NOT NULL *(RG3)*
> - APPARTIENT A — OBJET (1,1) — (0,n) CATEGORIE → `#id_categorie`, NOT NULL *(RG4)*
> - COMPORTE — VENTE (1,n) — (0,1) OBJET → `#id_vente` **et l'attribut `prix_paye` porté par l'association**, tous deux nullables *(RG9, RG10, D13)*
>
> L'association est 1:n, donc R2, pas R3 — pas de table de liaison.

### 8. atelier
```
atelier(id_atelier, intitule, date_atelier, duree_heures, nb_places, #id_benevole)
```
> **R1** sur ATELIER, puis **R2** sur ANIME — BENEVOLE (0,n) — (1,1) ATELIER.
> `#id_benevole` NOT NULL *(RG12 : un seul animateur, obligatoire)*.

### 9. reparation
```
reparation(id_reparation, date_reparation, duree_heures, resultat,
           #id_objet, #id_benevole)
```
> **R1** sur REPARATION *(entité et non association — voir D12)*, puis **R2** deux fois :
> - CONCERNE — OBJET (0,n) — (1,1) REPARATION → `#id_objet`, NOT NULL
> - EFFECTUE — BENEVOLE (0,n) — (1,1) REPARATION → `#id_benevole`, NOT NULL
>
> *(RG7, RG8)*

### 10. benevole_competence
```
benevole_competence(#id_benevole, #id_competence)
```
> **R3** sur POSSEDE — BENEVOLE (0,n) — (0,n) COMPETENCE.
> Les deux pattes sont en (x,n) : l'association devient une table. Clé primaire composée des deux clés. Aucun attribut propre → table de liaison pure *(RG11)*.

### 11. inscription
```
inscription(#id_atelier, #id_personne, date_inscription, est_present)
```
> **R3** sur S'INSCRIT A — PERSONNE (0,n) — (0,n) ATELIER.
> Les deux pattes en (x,n) : table, clé primaire composée. L'association **porte des attributs** (`date_inscription`, `est_present`), qui deviennent des colonnes *(RG13, RG14)*.
> La clé composée garantit qu'une personne ne s'inscrit pas deux fois au même atelier.

---

## Récapitulatif : quelle règle a produit quoi

| Relation | Règle(s) | Association source |
|---|---|---|
| `personne` | R1 | — |
| `categorie` | R1 | — |
| `competence` | R1 | — |
| `benevole` | R1 + R2 | EST AUSSI |
| `depot` | R1 + R2 | FAIT |
| `vente` | R1 + R2 | ACHETE LORS DE |
| `objet` | R1 + R2 ×3 | CONTIENT, APPARTIENT A, COMPORTE |
| `atelier` | R1 + R2 | ANIME |
| `reparation` | R1 + R2 ×2 | CONCERNE, EFFECTUE |
| `benevole_competence` | R3 | POSSEDE |
| `inscription` | R3 | S'INSCRIT A |

**9 entités → 9 tables (R1). 9 associations 1:n → 9 clés étrangères (R2). 2 associations n:n → 2 tables (R3). Total : 11 tables.**

---

## Arbre de dépendances

Voir `arbre-dependances.png`. Ordre de création dans `migration_up.sql` :

| Niveau | Tables | Dépend de |
|---|---|---|
| **0** | `personne`, `categorie`, `competence` | rien |
| **1** | `benevole`, `depot`, `vente` | personne |
| **2** | `objet`, `benevole_competence`, `atelier` | depot, categorie, vente, benevole, competence |
| **3** | `reparation`, `inscription` | objet, benevole, atelier, personne |

`migration_down.sql` fait exactement l'inverse : niveau 3 → niveau 0.

---

## Contraintes d'intégrité complémentaires

Non déductibles des règles de passage, mais imposées par les RG :

| Contrainte | Table | Source |
|---|---|---|
| `UNIQUE(etiquette)` | objet | Étiquette physique unique |
| `UNIQUE(libelle)` | categorie, competence | D7 |
| `CHECK(poids_g > 0)` | objet |  |
| `CHECK(duree_heures > 0)` | reparation, atelier | RG8, RG12 |
| `CHECK(nb_places > 0)` | atelier | RG12 |
| `CHECK(prix_paye >= 0)` | objet | RG10 |
| `CHECK` cohérence vente | objet | `statut='vendu'` ⟺ `id_vente` renseigné *(D13)* |
| Cardinalité min 1 sur CONTIENT | depot | RG3 — **non implémentée**, voir D4 |
