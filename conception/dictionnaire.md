# Dictionnaire de données — La Remise

Conventions : `snake_case`, sans accent. Types PostgreSQL.
Les clés primaires techniques sont des `SERIAL` (entier auto-incrémenté).

---

## PERSONNE

| Nom | Description | Type | Taille | Contraintes | Remarques |
|---|---|---|---|---|---|
| id_personne | Identifiant technique | SERIAL | — | PK | Substitut : ni le nom ni le tel ne sont fiables |
| nom | Nom de famille | VARCHAR | 100 | NOT NULL | |
| prenom | Prénom | VARCHAR | 100 | NOT NULL | |
| telephone | Téléphone | VARCHAR | 20 | — | VARCHAR : garde le 0 initial, jamais calculé |
| email | Courriel | VARCHAR | 255 | UNIQUE, NULL autorisé | Non cité dans l'entretien, utile pour les ateliers |
| est_adherent | Adhérent de l'asso | BOOLEAN | — | NOT NULL, DEFAULT FALSE | Décision D5 |

## BENEVOLE — spécialisation de personne (D1)

| Nom | Description | Type | Taille | Contraintes | Remarques |
|---|---|---|---|---|---|
| id_personne | Identifiant hérité de personne | INTEGER | — | PK, FK → personne | 1:1 : la PK est la FK |
| date_entree | Date d'arrivée dans l'asso | DATE | — | NOT NULL | Citée par Malika |
| est_actif | Bénévole encore actif | BOOLEAN | — | NOT NULL, DEFAULT TRUE | Décision D8, sert la question 9 |

## CATEGORIE

| Nom | Description | Type | Taille | Contraintes | Remarques |
|---|---|---|---|---|---|
| id_categorie | Identifiant technique | SERIAL | — | PK | |
| libelle | Nom de la catégorie | VARCHAR | 50 | NOT NULL, UNIQUE | mobilier, électroménager, livres, vaisselle, textile, jouets, bricolage |

## DEPOT

| Nom | Description | Type | Taille | Contraintes | Remarques |
|---|---|---|---|---|---|
| id_depot | Identifiant technique | SERIAL | — | PK | |
| date_depot | Date du dépôt | DATE | — | NOT NULL, DEFAULT CURRENT_DATE | RG1 |
| type_depot | Boutique ou domicile | ENUM | — | NOT NULL | RG1, décision D3 |
| id_personne | Donateur | INTEGER | — | NOT NULL, FK → personne | RG1 : un seul donateur |

## OBJET

| Nom | Description | Type | Taille | Contraintes | Remarques |
|---|---|---|---|---|---|
| id_objet | Identifiant technique | SERIAL | — | PK | |
| etiquette | Numéro d'étiquette physique | VARCHAR | 20 | NOT NULL, UNIQUE | Clé naturelle collée sur l'objet |
| designation | Ce que c'est | VARCHAR | 255 | NOT NULL | « chaise en bois », « grille-pain » |
| poids_g | Poids en grammes | INTEGER | — | NOT NULL, CHECK > 0 | Décision D9 |
| etat_arrivee | État constaté à l'arrivée | ENUM | — | NOT NULL | RG5, figé |
| statut | Où en est l'objet | ENUM | — | NOT NULL, DEFAULT 'arrive' | RG6, évolue |
| prix_affiche | Prix en rayon | NUMERIC | 8,2 | NULL tant que non mis en rayon | Décision D6 |
| date_mise_en_rayon | Entrée en rayon | DATE | — | NULL autorisé | Questions 2 et 10 |
| date_sortie_rayon | Sortie de rayon | DATE | — | NULL autorisé | Invendu au bout de 6 mois |
| prix_paye | Prix réellement encaissé | NUMERIC | 8,2 | NULL tant que non vendu, CHECK >= 0 | RG10, décision D6 |
| id_depot | Dépôt d'origine | INTEGER | — | NOT NULL, FK → depot | RG3 |
| id_categorie | Catégorie | INTEGER | — | NOT NULL, FK → categorie | RG4 |
| id_vente | Vente | INTEGER | — | NULL tant que non vendu, FK → vente | RG9, produit par R2 (D13) |

## REPARATION

| Nom | Description | Type | Taille | Contraintes | Remarques |
|---|---|---|---|---|---|
| id_reparation | Identifiant technique | SERIAL | — | PK | Entité, pas association (D12) |
| date_reparation | Date de la réparation | DATE | — | NOT NULL | RG8 |
| duree_heures | Temps passé | NUMERIC | 5,2 | NOT NULL, CHECK > 0 | RG8, décimal : 1h30 = 1.5 |
| resultat | Issue de la réparation | ENUM | — | NOT NULL | RG8 : reussie / echouee |
| id_objet | Objet réparé | INTEGER | — | NOT NULL, FK → objet | RG8 |
| id_benevole | Réparateur | INTEGER | — | NOT NULL, FK → benevole | RG8 |

## VENTE

| Nom | Description | Type | Taille | Contraintes | Remarques |
|---|---|---|---|---|---|
| id_vente | Identifiant technique | SERIAL | — | PK | Un passage en caisse |
| date_vente | Date de la vente | DATE | — | NOT NULL, DEFAULT CURRENT_DATE | RG10 |
| mode_paiement | Moyen de paiement | ENUM | — | NOT NULL | RG10 |
| id_personne | Acheteur | INTEGER | — | NULL autorisé, FK → personne | Décision D11 |

## COMPETENCE

| Nom | Description | Type | Taille | Contraintes | Remarques |
|---|---|---|---|---|---|
| id_competence | Identifiant technique | SERIAL | — | PK | |
| libelle | Nom de la compétence | VARCHAR | 50 | NOT NULL, UNIQUE | couture, électricité, menuiserie, informatique, vente (D7) |

## BENEVOLE_COMPETENCE — liaison pure (RG11)

| Nom | Description | Type | Taille | Contraintes | Remarques |
|---|---|---|---|---|---|
| id_benevole | Bénévole | INTEGER | — | PK composée, FK → benevole | |
| id_competence | Compétence | INTEGER | — | PK composée, FK → competence | Aucune donnée propre |

## ATELIER

| Nom | Description | Type | Taille | Contraintes | Remarques |
|---|---|---|---|---|---|
| id_atelier | Identifiant technique | SERIAL | — | PK | |
| intitule | Nom de l'atelier | VARCHAR | 150 | NOT NULL | « répare ton vélo » |
| date_atelier | Date de la session | DATE | — | NOT NULL | RG12 |
| duree_heures | Durée | NUMERIC | 4,2 | NOT NULL, CHECK > 0 | RG12 |
| nb_places | Nombre de places | INTEGER | — | NOT NULL, CHECK > 0 | RG12 |
| id_benevole | Animateur | INTEGER | — | NOT NULL, FK → benevole | RG12 |

## INSCRIPTION — association porteuse (RG13, RG14)

| Nom | Description | Type | Taille | Contraintes | Remarques |
|---|---|---|---|---|---|
| id_atelier | Atelier | INTEGER | — | PK composée, FK → atelier | |
| id_personne | Inscrit | INTEGER | — | PK composée, FK → personne | Pas deux fois le même atelier |
| date_inscription | Date de l'inscription | DATE | — | NOT NULL, DEFAULT CURRENT_DATE | RG13 |
| est_present | Venu ou désisté | BOOLEAN | — | NOT NULL, DEFAULT FALSE | RG13, question 8 |

---

## Types ENUM à créer

| Type | Valeurs | Source |
|---|---|---|
| `type_depot_enum` | boutique, domicile | RG1 |
| `etat_objet_enum` | bon_etat, a_reparer, hors_service | RG5 |
| `statut_objet_enum` | arrive, en_reparation, en_rayon, vendu, recycle | RG6 |
| `resultat_reparation_enum` | reussie, echouee | RG8 |
| `mode_paiement_enum` | especes, carte, cheque | RG10 |

---

## Choix de typage défendables à l'oral

1. `telephone` en VARCHAR, jamais INTEGER — on ne calcule pas avec, et le 0 initial disparaîtrait.
2. `poids_g` en entier — pas de flottant, pas d'arrondi cumulé.
3. Prix en NUMERIC(8,2) — jamais FLOAT pour de l'argent.
4. SERIAL partout, sauf pour les associations où la PK composée porte du sens.
