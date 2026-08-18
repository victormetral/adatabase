# AdaDatabase — La Remise

Base de données PostgreSQL de **La Remise**, ressourcerie associative : collecte
d'objets, réparation par des bénévoles, revente en boutique, ateliers ouverts au public.

Conçue à partir d'un entretien avec la coordinatrice, de l'analyse au SQL.
Elle servira de socle à **AdaRemise** (React + Express).

---

## Démarrer en trois commandes

```bash
docker compose up -d --wait
docker exec -i laremise_db psql -U remise -d laremise < migration_up.sql
docker exec -i laremise_db psql -U remise -d laremise < seed.sql
```

PostgreSQL 16, exposé sur le port **5433** (pour ne pas entrer en conflit avec une
installation locale). Identifiants : `remise` / `remise`, base `laremise`.

L'option `--wait` s'appuie sur le `healthcheck` du `docker-compose.yml` : elle bloque
tant que PostgreSQL n'accepte pas les connexions. Sans elle, sur un volume neuf, les
deux commandes suivantes partiraient avant que le serveur soit prêt.

**Répondre aux 10 questions du client :**

```bash
docker exec -i laremise_db psql -U remise -d laremise < queries.sql
```

**Repartir de zéro :**

```bash
docker exec -i laremise_db psql -U remise -d laremise < migration_down.sql
```

---

## Le modèle

**11 tables**, issues de 9 entités et 11 associations.

| Niveau | Tables |
|---|---|
| 0 | `personne` · `categorie` · `competence` |
| 1 | `benevole` · `depot` · `vente` |
| 2 | `objet` · `benevole_competence` · `atelier` |
| 3 | `reparation` · `inscription` |

L'ordre de création suit cet arbre de dépendances ; `migration_down.sql` fait
exactement l'inverse.

**Trois choix structurants :**

- **Une seule table `personne`**, avec `benevole` en spécialisation 1:1. Donateurs,
  acheteurs, inscrits et bénévoles sont la même population : on cumule les rôles
  sans dupliquer les individus.
- **`reparation` est une entité**, pas une association : un même bénévole peut
  réparer deux fois le même objet.
- **Pas de table `ligne_vente`.** Un objet n'est vendu qu'une fois : l'association
  est 1:n, donc la clé de `vente` et `prix_paye` migrent dans `objet`.

Les 13 décisions de conception sont documentées dans `conception/decisions.md`.

---

## Structure

```
adatabase/
├── conception/
│   ├── dictionnaire.md        toutes les données, types, contraintes
│   ├── decisions.md           les 13 ambiguïtés tranchées
│   ├── schema-ea.png          schéma entité-association (sans clé étrangère)
│   ├── cardinalites.md        phrases de lecture des cardinalités
│   ├── schema-relationnel.md  les 11 relations + la règle qui a produit chacune
│   ├── arbre-dependances.png  ordre de création des tables
│   ├── schemas/               sources Mermaid, éditables et regénérables
│   └── supports/recap.html    fiche de rappel du projet, 5 min de lecture
├── migration_up.sql           ENUM puis CREATE TABLE, toutes contraintes
├── migration_down.sql         l'inverse exact, IF EXISTS partout
├── seed.sql                   jeu de données cohérent, dates relatives
├── queries.sql                les 10 requêtes, commentées et avec leurs résultats
└── docker-compose.yml
```

---

## Vérifier

**Le script est rejouable** — `up → down → up` doit passer sans erreur :

```bash
for i in 1 2; do
  docker exec -i laremise_db psql -U remise -d laremise < migration_down.sql
  docker exec -i laremise_db psql -U remise -d laremise < migration_up.sql
done
docker exec -it laremise_db psql -U remise -d laremise -c "\dt"
```

Attendu : 11 tables.

**Depuis zéro**, dans les conditions d'un premier clone — volume supprimé compris :

```bash
docker compose down -v
docker compose up -d --wait
docker exec -i laremise_db psql -U remise -d laremise < migration_up.sql
docker exec -i laremise_db psql -U remise -d laremise < seed.sql
```

**Le jeu de données** contient 26 personnes (dont 12 bénévoles), 40 objets
répartis sur les 5 statuts, 15 réparations, 10 ventes et 4 ateliers.
Les dates sont relatives à `CURRENT_DATE` : les résultats restent pertinents
quel que soit le jour d'exécution.

---

## Les 10 questions auxquelles la base répond

1. Objets reçus le mois dernier, et poids total
2. Objets en rayon, et depuis combien de temps
3. Catégorie qui se vend le mieux, et celle qui rapporte le plus
4. Heures de bénévolat consacrées à la réparation cette année
5. Taux de réussite des réparations, par bénévole et globalement
6. Personnes ayant fait plus de trois dépôts
7. **Poids total détourné de la déchetterie** — le chiffre exigé par la mairie
8. Taux de présence réelle sur les ateliers
9. Bénévoles compétents en électricité et disponibles
10. Objets en rayon depuis plus de six mois

---

## Régénérer les schémas

Les `.mmd` de `conception/schemas/` sont les sources Mermaid.

```bash
npm install -g @mermaid-js/mermaid-cli
cd conception/schemas
mmdc -i 00-mcd-conceptuel.mmd -o 00-mcd-conceptuel.png -b white -s 2
```

Ou coller le contenu sur https://mermaid.live pour un rendu immédiat.

---

Projet AdaDatabase · Ada Tech School · Bloc 1