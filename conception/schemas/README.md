# Schémas des relations — La Remise

Un schéma par relation, pour comprendre et défendre chaque cardinalité à l'oral.
Chaque `.mmd` est la source Mermaid (éditable), chaque `.png` est le rendu.

| Fichier | Ce qu'il montre |
|---|---|
| `01-vue-ensemble` | Le modèle complet, 11 tables |
| `02-personne-benevole` | La spécialisation 1:1 (décision D1) |
| `03-depot-objet` | Qui donne quoi, et quand (RG1, RG2, RG3) |
| `04-objet-categorie` | Le classement et le cycle de vie de l'objet (RG4, RG5, RG6) |
| `05-reparation` | Qui répare quoi, combien de temps (RG7, RG8) |
| `06-vente` | Le passage en caisse multi-objets (RG9, RG10, D13) |
| `07-competences` | Le n:n bénévole ↔ compétence (RG11) |
| `08-ateliers` | Animation et inscriptions (RG12, RG13, RG14) |
| `09-arbre-dependances` | L'ordre de création des tables |

---

## 02 — Personne / Bénévole

**Spécialisation 1:1.** `benevole.id_personne` est à la fois clé primaire et clé
étrangère vers `personne`. Un bénévole *est* une personne, il n'en est pas une copie.

- Une personne est bénévole **0 ou 1** fois.
- Un bénévole correspond à **1 et 1 seule** personne.

> Conséquence : un bénévole peut aussi donner un objet, acheter, s'inscrire à un
> atelier — sans être dupliqué. C'est tout l'intérêt de la décision D1.

---

## 03 — Personne / Dépôt / Objet

- Une personne fait **0 à n** dépôts. *(RG2 — beaucoup de gens reviennent)*
- Un dépôt est fait par **1 et 1 seule** personne. *(RG1)*
- Un dépôt contient **1 à n** objets. *(RG3 — au moins un)*
- Un objet provient de **1 et 1 seul** dépôt. *(RG3)*

`type_depot` distingue boutique et domicile : c'est un attribut, pas deux tables
*(décision D3)*.

---

## 04 — Catégorie / Objet

- Une catégorie classe **0 à n** objets.
- Un objet appartient à **1 et 1 seule** catégorie. *(RG4)*

Deux ENUM portés par l'objet :
- `etat_arrivee` : bon_etat, a_reparer, hors_service *(RG5 — figé à l'arrivée)*
- `statut` : arrive, en_reparation, en_rayon, vendu, recycle *(RG6 — évolue)*

`date_mise_en_rayon` est ce qui permet de répondre aux questions 2 et 10
(« depuis combien de temps en rayon »).

---

## 05 — Objet / Réparation / Bénévole

- Un objet subit **0 à n** réparations. *(RG7 — successives ou aucune)*
- Une réparation concerne **1 et 1 seul** objet. *(RG8)*
- Un bénévole réalise **0 à n** réparations.
- Une réparation est réalisée par **1 et 1 seul** bénévole. *(RG8)*

C'est une association n:n **porteuse de données** (date, durée, résultat) : elle
devient donc une table à part entière avec sa propre clé primaire, et non une
simple table de liaison.

> `duree_heures` alimente la question 4 (« 340 heures de bénévolat »).
> `resultat` alimente la question 5 (taux de réussite).

---

## 06 — Vente / Objet

- Une vente comporte **1 à n** objets. *(RG9 — un passage en caisse, plusieurs objets)*
- Un objet est vendu lors de **0 ou 1** vente. *(RG9)*

Association **1:n**, donc traitée par **R2** : la clé de `vente` migre dans `objet`,
accompagnée de `prix_paye`, l'attribut porté par l'association. **Pas de table de
liaison** — voir décision D13.

Deux prix cohabitent volontairement *(décision D6)* :
- `objet.prix_affiche` : le prix en rayon
- `objet.prix_paye` : ce qui a réellement été encaissé

L'écart entre les deux mesure les gestes commerciaux faits aux adhérents.

> `id_vente` et `prix_paye` sont NULL tant que l'objet n'est pas vendu, en cohérence
> avec `statut = 'vendu'`.

---

## 07 — Bénévole / Compétence

- Un bénévole possède **0 à n** compétences. *(RG11 — zéro est autorisé)*
- Une compétence est possédée par **0 à n** bénévoles. *(RG11)*

Association n:n **sans données propres** → table de liaison pure, clé primaire
composée (`id_benevole`, `id_competence`), aucun autre champ.

> `competence.libelle` est UNIQUE : c'est ce qui rend la question 9
> (« qui a la compétence électricité ») fiable *(décision D7)*.

---

## 08 — Bénévole / Atelier / Inscription

- Un bénévole anime **0 à n** ateliers.
- Un atelier est animé par **1 et 1 seul** bénévole. *(RG12)*
- Un atelier reçoit **0 à n** inscriptions. *(RG14)*
- Une personne s'inscrit à **0 à n** ateliers. *(RG14)*

`inscription` est une association n:n **porteuse de données** (`date_inscription`,
`est_present`), avec clé primaire composée — une personne ne peut pas s'inscrire
deux fois au même atelier.

> `est_present` alimente la question 8 (taux de présence réelle) : c'est exactement
> le problème des désistements évoqué par Malika.

Un atelier reproposé plus tard = une **nouvelle ligne** dans `atelier`, même
intitulé, autre date *(décision D10)*.

---

## 09 — Arbre de dépendances

Ordre de création dans `migration_up.sql` (et ordre inverse dans `migration_down.sql`) :

| Niveau | Tables | Dépend de |
|---|---|---|
| 0 | `personne`, `categorie`, `competence` | rien |
| 1 | `benevole`, `depot`, `vente` | personne |
| 2 | `objet`, `benevole_competence`, `atelier` | depot, categorie, vente, benevole, competence |
| 3 | `reparation`, `inscription` | objet, benevole, atelier, personne |

Une table ne peut être créée que si toutes celles qu'elle référence existent déjà.
Le `DROP` se fait exactement dans l'ordre inverse : niveau 3 → 0.
