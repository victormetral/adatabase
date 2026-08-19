-- ------------------------------------------------------------
-- 1. Objets recus le mois dernier, et poids total ?
-- ------------------------------------------------------------
-- La date d'arrivee est portee par le DEPOT, pas par l'objet (RG3).
-- date_trunc borne le mois calendaire precedent, quel que soit le
-- jour ou la requete est jouee.
-- Poids stocke en grammes (D9), converti a l'affichage.
-- AFFICHAGE : OBJET et DEPOT.

SELECT
   COUNT (*)   as nb_objets,
   ROUND(SUM(o.poids_g)/1000.0, 2)  as poids_kg
FROM objet o 
JOIN depot d USING (id_depot)
WHERE d.date_depot >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 month'
  AND d.date_depot < date_trunc('month', CURRENT_DATE);

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
  c.libelle      as categorie,
  o.prix_affiche,
  CURRENT_DATE - o.date_mise_en_rayon  as jours_en_rayon
FROM objet o
JOIN categorie c USING id_categorie
WHERE o.statut = 'en_rayon'
ORDER BY jours_en_rayon DESC;



-- ------------------------------------------------------------
-- 3. Quelle categorie se vend le mieux ? Laquelle rapporte le plus ?
-- ------------------------------------------------------------
-- Deux questions, deux colonnes : le volume et la valeur.
-- Elles ne designent pas forcement la meme categorie.
-- prix_paye est sur objet : attribut de COMPORTE migre par R2 (D13).
-- TABLE : objet et categorie.

SELECT
  c.libelle      as categorie,
  COUNT (*)     as nb_vendus,
  SUM(o.prix_paye)  as chiffre_affaires,
FROM objet 
JOIN categorie USING (id_categorie)
WHERE o.statut = 'vendu'
GROUP BY categorie
ORDER BY nb_vendus DESC, chiffre_affaires DESC;


-- ------------------------------------------------------------
-- 4. Heures de benevolat en reparation cette annee ?
-- ------------------------------------------------------------
-- Le chiffre du bilan annuel : "cette annee, 340 heures".
-- Les reparations echouees comptent : le temps a ete passe.
-- Table REPARATION.

SELECT
    COUNT(*)          AS nb_reparations,
    SUM(duree_heures) AS heures_totales
FROM reparation
WHERE date_reparation >= date_trunc('year', CURRENT_DATE);


-- ------------------------------------------------------------
-- 5. Taux de reussite des reparations, par benevole et global ?
-- ------------------------------------------------------------
-- La jointure passe par personne : le benevole 42 EST la personne 42
-- (D1), il n'a pas de nom en propre.
-- FILTER compte les lignes qui remplissent la condition, dans le
-- groupe courant.

-- 5a. Par benevole (tables: reparation, benevole, personne)
SELECT
    p.prenom || ' ' || p.nom            AS benevole,
    COUNT(*)                                       AS nb_reparations,
    COUNT(*) FILTER (WHERE r.resultat = 'reussie') AS reussies,
    ROUND(100.0 * COUNT(*) FILTER (WHERE r.resultat = 'reussie') / COUNT(*), 1)
                                                AS taux_pct
FROM reparation r 
JOIN personne p ON p.id_personne = r.id_benevole
GROUP BY p.id_personne, p.prenom, p.nom
ORDER BY taux_pct DESC;

-- 5b. Global
SELECT
    COUNT(*)                                     AS nb_reparations,
    COUNT(*) FILTER (WHERE resultat = 'reussie') AS reussies,
    ROUND(100.0 * COUNT(*) FILTER (WHERE resultat = 'reussie') / COUNT(*), 1)
                                        AS taux_pct
FROM reparation;  


-- ------------------------------------------------------------
-- 6. Quelles personnes nous ont fait plus de trois depots ?
-- ------------------------------------------------------------
-- La question qui justifie D1 : avec quatre populations separees,
-- un donateur qui achete aussi apparaitrait deux fois.
-- HAVING filtre apres le regroupement, WHERE avant.
--Table : depot et personne

SELECT 
   p.prenom,
   p.nom,
   p.telephone,
   COUNT (*) as nb_depots
   FROM depot d
   JOIN personne p USING (id_personne)
   GROUP BY p.id_personne, p.nom, p.prenom, p.telephone
   HAVING COUNT(*) > 3
   ORDER BY nb_depots DESC

-- ------------------------------------------------------------
-- 7. Poids total detourne de la dechetterie ?
-- ------------------------------------------------------------
-- LE chiffre que la mairie exige pour la subvention.
-- Detourne = tout sauf 'recycle' : arrive, en rayon, en reparation
-- ou vendu, l'objet n'est pas parti a la dechetterie.
--Table: objet

SELECT
  COUNT(*)    as nb_objets,
  ROUND(SUM(poids_g) / 1000000.0, 3).  as poids_tonnes
  FROM objet
  WHERE statut = 'recycle'; 

-- ------------------------------------------------------------
-- 8. Taux de presence reelle sur les ateliers ?
-- ------------------------------------------------------------
-- Le probleme des desistements evoque par Malika.
-- est_present est porte par S'INSCRIT A, devenue la table
-- inscription par R3 (RG13).

--PAr atelier :
SELECT
  a.intitule,
  a.nb_places  as places,
  COUNT (*)     as inscrits,
  count (*) FILTER (WHERE i.est_present)     as presents,
  ROUND(100.0 * count(*) FILTER(WHERE i.est_present)/COUNT (*), 1) as taux_pct
from inscription i
join atelier a USING (id_atelier)
GROUP BY a.id_atelier, a.intitule, a.nb_places
ORDER BY taux_pct DESC;

--global :

SELECT
    COUNT(*)                            AS inscrits,
    COUNT(*) FILTER (WHERE est_present) AS presents,
    ROUND(100.0 * COUNT(*) FILTER (WHERE est_present) / COUNT(*), 1)
                                        AS taux_pct
FROM inscription;




-- ------------------------------------------------------------
-- 9. Benevoles competents en electricite et disponibles ?
-- ------------------------------------------------------------
-- "Disponible" n'existe pas dans l'entretien : c'est D8 qui tranche
-- = benevole actif ET n'animant pas deja un atelier ce jour-la.
-- competence.libelle est UNIQUE (D7) : pas de variante d'orthographe.
-- Changer CURRENT_DATE pour tester un autre jour.

SELECT
  p.prenom,
  p.nom,
  p.telephone,
  b.date_entree
FROM benevole b
JOIN personne p USING (id_personne)
JOIN benevole_competence bc on bc.id_benevole = id_personne
JOIN competence c on c.id_competence = id_competence
WHERE c.libelle = 'electricite'
  AND b.est_actif
ORDER BY b.date_entree;

-- ------------------------------------------------------------
-- 10. Objets en rayon depuis plus de six mois ?
-- ------------------------------------------------------------
-- La regle de Malika : "au bout de six mois on le sort".
-- Meme socle que la question 2, avec un filtre d'anciennete.
-- INTERVAL '6 months' gere les mois de longueurs differentes.
--table: objet et categorie

SELECT 
   o.etiquette,
   o.designation,
   o.libelle as categorie,
   o.prix_affiche,
   CURRENT_DATE - o.date_mise_en_rayon as jours_en_rayon
FROM objet o
JOIN categorie c USING (id_categorie)
WHERE statut = 'en_rayon'
    AND o.date_mise_en_rayon < CURRENT_DATE - INTERVAL '6 months'
ORDER BY jours_en_rayon DESC;

   