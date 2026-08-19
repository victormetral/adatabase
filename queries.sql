-- ============================================================
-- queries.sql — La Remise
--
-- Sous chaque requete, le resultat obtenu sur le jeu de donnees de
-- seed.sql. Les dates du seed etant relatives a CURRENT_DATE, les
-- chiffres restent stables ; seules les dates absolues glissent.
-- ============================================================


-- ------------------------------------------------------------
-- 1. Objets recus le mois dernier, et poids total ?
-- ------------------------------------------------------------
-- La date d'arrivee est portee par le DEPOT, pas par l'objet (RG3).
-- date_trunc borne le mois calendaire precedent, quel que soit le
-- jour ou la requete est jouee.
-- Poids stocke en grammes (D9), converti a l'affichage.
-- AFFICHAGE : OBJET et DEPOT.

SELECT
    COUNT(*)                          AS nb_objets,
    ROUND(SUM(o.poids_g) / 1000.0, 2) AS poids_kg
FROM objet o
JOIN depot d USING (id_depot)
WHERE d.date_depot >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 month'
  AND d.date_depot <  date_trunc('month', CURRENT_DATE);

-- REPONSE (execution du 18/08/2026, mois de juillet) :
--  nb_objets | poids_kg 
-- -----------+----------
--         23 |   116.22


-- ------------------------------------------------------------
-- 2. Quels objets sont en rayon, et depuis combien de temps ?
-- ------------------------------------------------------------
-- statut = 'en_rayon' (RG6) et date_mise_en_rayon (D2 : une date
-- suffit, pas besoin d'historiser les transitions).
-- Soustraire deux DATE renvoie un nombre de jours.
-- Affichage OBJET et CATEGORIE. 

SELECT
    o.etiquette,
    o.designation,
    c.libelle                           AS categorie,
    o.prix_affiche,
    CURRENT_DATE - o.date_mise_en_rayon AS jours_en_rayon
FROM objet o
JOIN categorie c USING (id_categorie)
WHERE o.statut = 'en_rayon'
ORDER BY jours_en_rayon DESC;

-- REPONSE : 12 objets en rayon, de 8 a 240 jours. Extrait :
--  etiquette |       designation        |   categorie    | prix_affiche | jours_en_rayon
-- -----------+--------------------------+----------------+--------------+----------------
--  ET-0026   | Etabli metal             | bricolage      |        90.00 |            240
--  ET-0024   | Collection Larousse 1978 | livres         |        30.00 |            230
--  ET-0025   | Rideaux velours vert     | textile        |        18.00 |            210
--  ET-0022   | Armoire normande         | mobilier       |       150.00 |            205
--  ET-0023   | Television cathodique    | electromenager |        15.00 |            200
--  ...
--  ET-0015   | Buffet chene 2 portes    | mobilier       |        80.00 |              8


-- ------------------------------------------------------------
-- 3. Quelle categorie se vend le mieux ? Laquelle rapporte le plus ?
-- ------------------------------------------------------------
-- Deux questions, deux colonnes : le volume et la valeur.
-- Elles ne designent pas forcement la meme categorie.
-- prix_paye est sur objet : attribut de COMPORTE migre par R2 (D13).
-- TABLE : objet et categorie.

SELECT
    c.libelle        AS categorie,
    COUNT(*)         AS nb_vendus,
    SUM(o.prix_paye) AS chiffre_affaires
FROM objet o
JOIN categorie c USING (id_categorie)
WHERE o.statut = 'vendu'
GROUP BY c.libelle
ORDER BY nb_vendus DESC, chiffre_affaires DESC;

-- REPONSE : le mobilier gagne sur les deux tableaux (volume ET valeur).
--    categorie    | nb_vendus | chiffre_affaires
-- ----------------+-----------+------------------
--  mobilier       |         4 |           125.00
--  electromenager |         3 |            72.00
--  vaisselle      |         2 |            22.00
--  jouets         |         1 |            30.00
--  bricolage      |         1 |            28.00
--  livres         |         1 |            20.00
--  luminaire      |         1 |            15.00
--  textile        |         1 |            12.00


-- ------------------------------------------------------------
-- 4. Heures de benevolat en reparation cette annee ?
-- ------------------------------------------------------------
-- Le chiffre du bilan annuel : "cette annee, 340 heures".
-- Les reparations echouees comptent : le temps a ete passe.

SELECT
    COUNT(*)          AS nb_reparations,
    SUM(duree_heures) AS heures_totales
FROM reparation
WHERE date_reparation >= date_trunc('year', CURRENT_DATE);

-- REPONSE :
--  nb_reparations | heures_totales
-- ----------------+----------------
--              14 |          46.50
-- La 15e reparation date de decembre 2025 : hors annee 2026.


-- ------------------------------------------------------------
-- 5. Taux de reussite des reparations, par benevole et global ?
-- ------------------------------------------------------------
-- La jointure passe par personne : le benevole 42 EST la personne 42
-- (D1), il n'a pas de nom en propre.
-- FILTER compte les lignes qui remplissent la condition, dans le
-- groupe courant. Equivalent standard : SUM(CASE WHEN ... THEN 1 END).

-- 5a. Par benevole
SELECT
    p.prenom || ' ' || p.nom                       AS benevole,
    COUNT(*)                                       AS nb_reparations,
    COUNT(*) FILTER (WHERE r.resultat = 'reussie') AS reussies,
    ROUND(100.0 * COUNT(*) FILTER (WHERE r.resultat = 'reussie') / COUNT(*), 1)
                                                   AS taux_pct
FROM reparation r
JOIN personne p ON p.id_personne = r.id_benevole
GROUP BY p.id_personne, p.prenom, p.nom
ORDER BY taux_pct DESC; 

-- REPONSE 5a :
--       benevole      | nb_reparations | reussies | taux_pct
--  --------------------+----------------+----------+----------
--  Claire Fontaine    |              2 |        2 |    100.0
--  Jean-Pierre Moreau |              4 |        4 |    100.0
--  Karim Benali       |              1 |        1 |    100.0
--  Thi Lan Nguyen     |              1 |        1 |    100.0
--  Yves Marchand      |              1 |        1 |    100.0
--  Marco Rossi        |              3 |        2 |     66.7
--  Aminata Diallo     |              3 |        2 |     66.7

-- 5b. Global
SELECT
    COUNT(*)                                     AS nb_reparations,
    COUNT(*) FILTER (WHERE resultat = 'reussie') AS reussies,
    ROUND(100.0 * COUNT(*) FILTER (WHERE resultat = 'reussie') / COUNT(*), 1)
                                                 AS taux_pct
FROM reparation;

-- REPONSE 5b :
--  nb_reparations | reussies | taux_pct
-- ----------------+----------+----------
--              15 |       13 |     86.7


-- ------------------------------------------------------------
-- 6. Quelles personnes nous ont fait plus de trois depots ?
-- ------------------------------------------------------------
-- La question qui justifie D1 : avec quatre populations separees,
-- un donateur qui achete aussi apparaitrait deux fois. 
-- Table: depot et personne

SELECT
    p.prenom,
    p.nom,
    p.telephone,
    COUNT(*) AS nb_depots
FROM depot d
JOIN personne p USING (id_personne)
GROUP BY p.id_personne, p.prenom, p.nom, p.telephone
HAVING COUNT(*) > 3
ORDER BY nb_depots DESC;

-- REPONSE : deux donateurs reguliers.
--  prenom |  nom   |   telephone    | nb_depots
-- --------+--------+----------------+-----------
--  Thomas | Leroy  | 06 44 55 66 77 |         4
--  Helene | Dupont | 06 33 44 55 66 |         4


-- ------------------------------------------------------------
-- 7. Poids total detourne de la dechetterie ?
-- ------------------------------------------------------------
-- LE chiffre que la mairie exige pour la subvention.
-- Detourne = tout sauf 'recycle' : arrive, en rayon, en reparation
-- ou vendu, l'objet n'est pas parti a la dechetterie.

SELECT
    COUNT(*)                              AS nb_objets,
    ROUND(SUM(poids_g) / 1000000.0, 3)    AS poids_tonnes
FROM objet
WHERE statut <> 'recycle';

-- REPONSE : LE chiffre pour la mairie.
--  nb_objets | poids_tonnes
-- -----------+--------------
--         34 |        0.329
-- 34 objets sur 40 : 6 seulement sont partis au recyclage.


-- ------------------------------------------------------------
-- 8. Taux de presence reelle sur les ateliers ?
-- ------------------------------------------------------------
-- Le probleme des desistements evoque par Malika.
-- est_present est porte par S'INSCRIT A, devenue la table
-- inscription par R3 (RG13).
-- Table : inscription, atelier

-- 8a. Par atelier
SELECT
    a.intitule,
    a.nb_places                           AS places,
    COUNT(*)                              AS inscrits,
    COUNT(*) FILTER (WHERE i.est_present) AS presents,
    ROUND(100.0 * COUNT(*) FILTER (WHERE i.est_present) / COUNT(*), 1)
                                          AS taux_pct
FROM inscription i
JOIN atelier a USING (id_atelier)
GROUP BY a.id_atelier, a.intitule, a.nb_places
ORDER BY taux_pct DESC;

-- REPONSE 8a :
--            intitule           | places | inscrits | presents | taux_pct
-- ------------------------------+--------+----------+----------+----------
--  Retaper un meuble            |      5 |        4 |        3 |     75.0
--  Depannage electrique de base |     10 |        6 |        4 |     66.7
--  Repare ton velo              |      8 |        6 |        4 |     66.7
--  Initiation couture           |      6 |        5 |        3 |     60.0

-- 8b. Global
SELECT
    COUNT(*)                            AS inscrits,
    COUNT(*) FILTER (WHERE est_present) AS presents,
    ROUND(100.0 * COUNT(*) FILTER (WHERE est_present) / COUNT(*), 1)
                                        AS taux_pct
FROM inscription;

-- REPONSE 8b : un inscrit sur trois ne vient pas.
--  inscrits | presents | taux_pct
-- ----------+----------+----------
--        21 |       14 |     66.7


-- ------------------------------------------------------------
-- 9. Benevoles competents en electricite et disponibles ?
-- ------------------------------------------------------------
-- "Disponible" n'existe pas dans l'entretien : c'est D8 qui tranche
-- = benevole actif ET n'animant pas deja un atelier ce jour-la.
-- competence.libelle est UNIQUE (D7) : pas de variante d'orthographe.
--TAble: benevole, personne, benevole_competence, competence.

SELECT
    p.prenom,
    p.nom,
    p.telephone,
    b.date_entree
FROM benevole b
JOIN personne p            USING (id_personne)
JOIN benevole_competence bc ON bc.id_benevole  = b.id_personne
JOIN competence c           ON c.id_competence = bc.id_competence
WHERE c.libelle = 'electricite'
  AND b.est_actif
ORDER BY b.date_entree;

-- REPONSE : 4 benevoles mobilisables.
--  prenom  |   nom    |   telephone    | date_entree
-- ---------+----------+----------------+-------------
--  Aminata | Diallo   | 06 45 67 89 01 | 2021-06-08
--  Marco   | Rossi    | 06 67 89 01 23 | 2022-02-14
--  Karim   | Benali   | 06 89 01 23 45 | 2023-01-09
--  Yves    | Marchand | 06 22 33 44 55 | 2023-09-18


-- ------------------------------------------------------------
-- 10. Objets en rayon depuis plus de six mois ?
-- ------------------------------------------------------------
-- La regle de Malika : "au bout de six mois on le sort".
-- Meme socle que la question 2, avec un filtre d'anciennete.
-- INTERVAL '6 months' gere les mois de longueurs differentes.
--Table :objet et categorie.

SELECT
    o.etiquette,
    o.designation,
    c.libelle                           AS categorie,
    o.prix_affiche,
    CURRENT_DATE - o.date_mise_en_rayon AS jours_en_rayon
FROM objet o
JOIN categorie c USING (id_categorie)
WHERE o.statut = 'en_rayon'
  AND o.date_mise_en_rayon < CURRENT_DATE - INTERVAL '6 months'
ORDER BY jours_en_rayon DESC;

-- REPONSE : 5 objets a sortir du rayon.
--  etiquette |       designation        |   categorie    | prix_affiche | jours_en_rayon
-- -----------+--------------------------+----------------+--------------+----------------
--  ET-0026   | Etabli metal             | bricolage      |        90.00 |            240
--  ET-0024   | Collection Larousse 1978 | livres         |        30.00 |            230
--  ET-0025   | Rideaux velours vert     | textile        |        18.00 |            210
--  ET-0022   | Armoire normande         | mobilier       |       150.00 |            205
--  ET-0023   | Television cathodique    | electromenager |        15.00 |            200