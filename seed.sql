-- ============================================================
-- seed.sql — La Remise
-- ============================================================

BEGIN;

-- ---------- CATEGORIES (8) — RG4 ----------
INSERT INTO categorie (libelle) VALUES
    ('mobilier'),
    ('electromenager'),
    ('livres'),
    ('vaisselle'),
    ('textile'),
    ('jouets'),
    ('bricolage'),
    ('luminaire');

-- ---------- COMPETENCES (6) — RG11, decision D7 ----------
INSERT INTO competence (libelle) VALUES
    ('couture'),
    ('electricite'),
    ('menuiserie'),
    ('informatique'),
    ('vente'),
    ('mecanique');

-- ---------- PERSONNES (26) — decision D1 ----------
-- Une seule population : donateurs, acheteurs, inscrits et benevoles.
INSERT INTO personne (nom, prenom, telephone, email, est_adherent) VALUES
    ('Bernard', 'Malika', '06 12 34 56 78', 'malika.bernard@example.fr', TRUE),
    ('Nguyen', 'Thi Lan', '06 23 45 67 89', 'lan.nguyen@example.fr', TRUE),
    ('Moreau', 'Jean-Pierre', '06 34 56 78 90', 'jp.moreau@example.fr', TRUE),
    ('Diallo', 'Aminata', '06 45 67 89 01', 'aminata.diallo@example.fr', TRUE),
    ('Lefevre', 'Sylvie', '06 56 78 90 12', 'sylvie.lefevre@example.fr', TRUE),
    ('Rossi', 'Marco', '06 67 89 01 23', 'marco.rossi@example.fr', TRUE),
    ('Chevalier', 'Odile', '06 78 90 12 34', 'odile.chevalier@example.fr', TRUE),
    ('Benali', 'Karim', '06 89 01 23 45', 'karim.benali@example.fr', TRUE),
    ('Girard', 'Lucie', '06 90 12 34 56', 'lucie.girard@example.fr', TRUE),
    ('Petit', 'Andre', '06 01 23 45 67', 'andre.petit@example.fr', TRUE),
    ('Fontaine', 'Claire', '06 11 22 33 44', 'claire.fontaine@example.fr', TRUE),
    ('Marchand', 'Yves', '06 22 33 44 55', 'yves.marchand@example.fr', TRUE),
    ('Dupont', 'Helene', '06 33 44 55 66', 'helene.dupont@example.fr', TRUE),
    ('Leroy', 'Thomas', '06 44 55 66 77', 'thomas.leroy@example.fr', FALSE),
    ('Garnier', 'Sophie', '06 55 66 77 88', 'sophie.garnier@example.fr', TRUE),
    ('Roux', 'Vincent', '06 66 77 88 99', 'vincent.roux@example.fr', FALSE),
    ('Mercier', 'Nadia', '06 77 88 99 00', 'nadia.mercier@example.fr', FALSE),
    ('Blanc', 'Julien', '06 88 99 00 11', 'julien.blanc@example.fr', TRUE),
    ('Perrin', 'Camille', '06 99 00 11 22', 'camille.perrin@example.fr', FALSE),
    ('Simon', 'Bruno', '06 10 20 30 40', 'bruno.simon@example.fr', FALSE),
    ('Dubois', 'Fatou', '06 20 30 40 50', 'fatou.dubois@example.fr', TRUE),
    ('Henry', 'Paul', '06 30 40 50 60', 'paul.henry@example.fr', FALSE),
    ('Masson', 'Elodie', '06 40 50 60 70', 'elodie.masson@example.fr', FALSE),
    ('Guerin', 'Antoine', '06 50 60 70 80', 'antoine.guerin@example.fr', FALSE),
    ('Lambert', 'Rachida', '06 60 70 80 90', 'rachida.lambert@example.fr', TRUE),
    ('Fischer', 'Olivier', NULL, NULL, FALSE);

-- ---------- BENEVOLES (12) — specialisation 1:1 ----------
-- Les personnes 1 a 12 sont aussi benevoles. Meme identifiant.
INSERT INTO benevole (id_personne, date_entree, est_actif) VALUES
    (1, DATE '2019-03-04', TRUE),
    (2, DATE '2020-09-15', TRUE),
    (3, DATE '2018-01-22', TRUE),
    (4, DATE '2021-06-08', TRUE),
    (5, DATE '2019-11-30', TRUE),
    (6, DATE '2022-02-14', TRUE),
    (7, DATE '2020-05-19', TRUE),
    (8, DATE '2023-01-09', TRUE),
    (9, DATE '2021-10-25', TRUE),
    (10, DATE '2017-04-12', FALSE),
    (11, DATE '2022-08-03', TRUE),
    (12, DATE '2023-09-18', TRUE);

-- ---------- COMPETENCES DES BENEVOLES — RG11 (n:n) ----------
INSERT INTO benevole_competence (id_benevole, id_competence) VALUES
    (1, 5),
    (1, 4),
    (2, 1),
    (2, 5),
    (3, 3),
    (3, 6),
    (4, 2),
    (4, 4),
    (5, 1),
    (6, 2),
    (6, 6),
    (7, 5),
    (8, 3),
    (8, 2),
    (9, 1),
    (9, 5),
    (10, 3),
    (11, 4),
    (12, 2),
    (12, 6);

-- ---------- DEPOTS (16) — RG1, RG2 ----------
-- La personne 13 a fait 4 depots, la 14 aussi : elles repondent a la question 6.
INSERT INTO depot (date_depot, type_depot, id_personne) VALUES
    (CURRENT_DATE - INTERVAL '12 days', 'boutique', 13),
    (CURRENT_DATE - INTERVAL '38 days', 'domicile', 13),
    (CURRENT_DATE - INTERVAL '75 days', 'boutique', 13),
    (CURRENT_DATE - INTERVAL '140 days', 'boutique', 13),
    (CURRENT_DATE - INTERVAL '20 days', 'boutique', 14),
    (CURRENT_DATE - INTERVAL '45 days', 'domicile', 14),
    (CURRENT_DATE - INTERVAL '190 days', 'boutique', 14),
    (CURRENT_DATE - INTERVAL '240 days', 'domicile', 14),
    (CURRENT_DATE - INTERVAL '35 days', 'domicile', 16),
    (CURRENT_DATE - INTERVAL '40 days', 'boutique', 17),
    (CURRENT_DATE - INTERVAL '25 days', 'boutique', 19),
    (CURRENT_DATE - INTERVAL '42 days', 'domicile', 20),
    (CURRENT_DATE - INTERVAL '60 days', 'boutique', 2),
    (CURRENT_DATE - INTERVAL '110 days', 'boutique', 22),
    (CURRENT_DATE - INTERVAL '215 days', 'domicile', 23),
    (CURRENT_DATE - INTERVAL '250 days', 'boutique', 26);

-- ---------- VENTES (10) — RG10 ----------
-- id_personne NULL = client de passage non identifie (decision D11).
INSERT INTO vente (date_vente, mode_paiement, id_personne) VALUES
    (CURRENT_DATE - INTERVAL '11 days', 'carte', 13),
    (CURRENT_DATE - INTERVAL '29 days', 'especes', 13),
    (CURRENT_DATE - INTERVAL '31 days', 'carte', 17),
    (CURRENT_DATE - INTERVAL '26 days', 'cheque', 19),
    (CURRENT_DATE - INTERVAL '39 days', 'especes', NULL),
    (CURRENT_DATE - INTERVAL '21 days', 'carte', 20),
    (CURRENT_DATE - INTERVAL '25 days', 'cheque', 22),
    (CURRENT_DATE - INTERVAL '19 days', 'especes', NULL),
    (CURRENT_DATE - INTERVAL '34 days', 'carte', 4),
    (CURRENT_DATE - INTERVAL '49 days', 'especes', 23);

-- ---------- OBJETS (40) — RG3, RG4, RG5, RG6 ----------
-- Repartition : 14 vendus, 12 en rayon (dont 5 depuis plus de 6 mois),
-- 4 en reparation, 4 arrives, 6 recycles.
-- id_vente et prix_paye ne sont renseignes que si statut = 'vendu' (D13).
INSERT INTO objet (etiquette, designation, poids_g, etat_arrivee, statut,
                   prix_affiche, date_mise_en_rayon, date_sortie_rayon,
                   prix_paye, id_depot, id_categorie, id_vente) VALUES
    ('ET-0001', 'Table de chevet en pin', 8400, 'bon_etat', 'vendu', 25.0, CURRENT_DATE - INTERVAL '10 days', NULL, 22.0, 1, 1, 1),
    ('ET-0002', 'Lot de 6 assiettes', 2100, 'bon_etat', 'vendu', 8.0, CURRENT_DATE - INTERVAL '10 days', NULL, 8.0, 1, 4, 1),
    ('ET-0003', 'Grille-pain 2 fentes', 1900, 'a_reparer', 'vendu', 12.0, CURRENT_DATE - INTERVAL '30 days', NULL, 10.0, 2, 2, 2),
    ('ET-0004', 'Chaise bistrot', 4200, 'bon_etat', 'vendu', 15.0, CURRENT_DATE - INTERVAL '32 days', NULL, 15.0, 2, 1, 3),
    ('ET-0005', 'Lampe de bureau articulee', 1600, 'a_reparer', 'vendu', 18.0, CURRENT_DATE - INTERVAL '28 days', NULL, 15.0, 2, 8, 3),
    ('ET-0006', 'Manteau laine taille 40', 1200, 'bon_etat', 'vendu', 14.0, CURRENT_DATE - INTERVAL '15 days', NULL, 12.0, 5, 5, 3),
    ('ET-0007', 'Perceuse filaire', 3100, 'a_reparer', 'vendu', 30.0, CURRENT_DATE - INTERVAL '18 days', NULL, 28.0, 5, 7, 4),
    ('ET-0008', 'Encyclopedie 12 volumes', 14500, 'bon_etat', 'vendu', 20.0, CURRENT_DATE - INTERVAL '40 days', NULL, 20.0, 6, 3, 5),
    ('ET-0009', 'Service a the porcelaine', 2600, 'bon_etat', 'vendu', 16.0, CURRENT_DATE - INTERVAL '38 days', NULL, 14.0, 6, 4, 5),
    ('ET-0010', 'Velo enfant 20 pouces', 7800, 'a_reparer', 'vendu', 35.0, CURRENT_DATE - INTERVAL '22 days', NULL, 30.0, 9, 6, 6),
    ('ET-0011', 'Commode 3 tiroirs', 21000, 'bon_etat', 'vendu', 45.0, CURRENT_DATE - INTERVAL '26 days', NULL, 40.0, 10, 1, 7),
    ('ET-0012', 'Cafetiere italienne', 680, 'bon_etat', 'vendu', 7.0, CURRENT_DATE - INTERVAL '20 days', NULL, 7.0, 11, 2, 8),
    ('ET-0013', 'Machine a coudre mecanique', 9200, 'a_reparer', 'vendu', 60.0, CURRENT_DATE - INTERVAL '35 days', NULL, 55.0, 12, 2, 9),
    ('ET-0014', 'Fauteuil crapaud', 13500, 'a_reparer', 'vendu', 55.0, CURRENT_DATE - INTERVAL '50 days', NULL, 48.0, 13, 1, 10),
    ('ET-0015', 'Buffet chene 2 portes', 34000, 'bon_etat', 'en_rayon', 80.0, CURRENT_DATE - INTERVAL '8 days', NULL, NULL, 1, 1, NULL),
    ('ET-0016', 'Aspirateur traineau', 5400, 'a_reparer', 'en_rayon', 25.0, CURRENT_DATE - INTERVAL '14 days', NULL, NULL, 2, 2, NULL),
    ('ET-0017', 'Lot de romans policiers', 3900, 'bon_etat', 'en_rayon', 6.0, CURRENT_DATE - INTERVAL '16 days', NULL, NULL, 5, 3, NULL),
    ('ET-0018', 'Robe ete taille 38', 340, 'bon_etat', 'en_rayon', 9.0, CURRENT_DATE - INTERVAL '12 days', NULL, NULL, 5, 5, NULL),
    ('ET-0019', 'Puzzle 1000 pieces', 900, 'bon_etat', 'en_rayon', 4.0, CURRENT_DATE - INTERVAL '24 days', NULL, NULL, 9, 6, NULL),
    ('ET-0020', 'Scie sauteuse', 2400, 'a_reparer', 'en_rayon', 28.0, CURRENT_DATE - INTERVAL '30 days', NULL, NULL, 10, 7, NULL),
    ('ET-0021', 'Suspension osier', 1100, 'bon_etat', 'en_rayon', 22.0, CURRENT_DATE - INTERVAL '19 days', NULL, NULL, 11, 8, NULL),
    ('ET-0022', 'Armoire normande', 62000, 'bon_etat', 'en_rayon', 150.0, CURRENT_DATE - INTERVAL '205 days', NULL, NULL, 7, 1, NULL),
    ('ET-0023', 'Television cathodique', 18000, 'bon_etat', 'en_rayon', 15.0, CURRENT_DATE - INTERVAL '200 days', NULL, NULL, 7, 2, NULL),
    ('ET-0024', 'Collection Larousse 1978', 22000, 'bon_etat', 'en_rayon', 30.0, CURRENT_DATE - INTERVAL '230 days', NULL, NULL, 8, 3, NULL),
    ('ET-0025', 'Rideaux velours vert', 2800, 'bon_etat', 'en_rayon', 18.0, CURRENT_DATE - INTERVAL '210 days', NULL, NULL, 15, 5, NULL),
    ('ET-0026', 'Etabli metal', 41000, 'a_reparer', 'en_rayon', 90.0, CURRENT_DATE - INTERVAL '240 days', NULL, NULL, 16, 7, NULL),
    ('ET-0027', 'Radio vintage bois', 3300, 'a_reparer', 'en_reparation', NULL, NULL, NULL, NULL, 3, 2, NULL),
    ('ET-0028', 'Chaise paillee', 3600, 'a_reparer', 'en_reparation', NULL, NULL, NULL, NULL, 4, 1, NULL),
    ('ET-0029', 'Ordinateur portable 2015', 2200, 'a_reparer', 'en_reparation', NULL, NULL, NULL, NULL, 12, 2, NULL),
    ('ET-0030', 'Trottinette enfant', 2900, 'a_reparer', 'en_reparation', NULL, NULL, NULL, NULL, 14, 6, NULL),
    ('ET-0031', 'Carton de vaisselle depareillee', 6700, 'bon_etat', 'arrive', NULL, NULL, NULL, NULL, 1, 4, NULL),
    ('ET-0032', 'Sac de vetements enfant', 3400, 'bon_etat', 'arrive', NULL, NULL, NULL, NULL, 5, 5, NULL),
    ('ET-0033', 'Bibliotheque demontee', 17000, 'bon_etat', 'arrive', NULL, NULL, NULL, NULL, 11, 1, NULL),
    ('ET-0034', 'Lot de jouets plastique', 4100, 'bon_etat', 'arrive', NULL, NULL, NULL, NULL, 12, 6, NULL),
    ('ET-0035', 'Micro-ondes HS', 11000, 'hors_service', 'recycle', NULL, NULL, NULL, NULL, 3, 2, NULL),
    ('ET-0036', 'Canape tissu dechire', 48000, 'hors_service', 'recycle', NULL, NULL, NULL, NULL, 4, 1, NULL),
    ('ET-0037', 'Imprimante jet d encre', 6200, 'hors_service', 'recycle', NULL, NULL, NULL, NULL, 6, 2, NULL),
    ('ET-0038', 'Poupees cassees', 1500, 'hors_service', 'recycle', NULL, NULL, NULL, NULL, 9, 6, NULL),
    ('ET-0039', 'Perceuse moteur grille', 2700, 'a_reparer', 'recycle', NULL, NULL, NULL, NULL, 13, 7, NULL),
    ('ET-0040', 'Lampadaire pied fendu', 4800, 'hors_service', 'recycle', NULL, NULL, NULL, NULL, 14, 8, NULL);

-- ---------- REPARATION (15) — RG7, RG8 ----------
-- L'objet 39 a subi deux reparations echouees : il est parti au recyclage.
INSERT INTO reparation (date_reparation, duree_heures, resultat, id_objet, id_benevole) VALUES
    (CURRENT_DATE - INTERVAL '34 days', 1.5, 'reussie', 3, 4),
    (CURRENT_DATE - INTERVAL '31 days', 2.0, 'reussie', 5, 4),
    (CURRENT_DATE - INTERVAL '21 days', 3.5, 'reussie', 7, 3),
    (CURRENT_DATE - INTERVAL '26 days', 4.0, 'reussie', 10, 6),
    (CURRENT_DATE - INTERVAL '40 days', 6.5, 'reussie', 13, 2),
    (CURRENT_DATE - INTERVAL '55 days', 12.0, 'reussie', 14, 3),
    (CURRENT_DATE - INTERVAL '18 days', 2.5, 'reussie', 16, 12),
    (CURRENT_DATE - INTERVAL '33 days', 1.75, 'reussie', 20, 8),
    (CURRENT_DATE - INTERVAL '245 days', 8.0, 'reussie', 26, 3),
    (CURRENT_DATE - INTERVAL '5 days', 1.0, 'reussie', 27, 11),
    (CURRENT_DATE - INTERVAL '7 days', 3.0, 'reussie', 28, 3),
    (CURRENT_DATE - INTERVAL '4 days', 2.25, 'reussie', 29, 11),
    (CURRENT_DATE - INTERVAL '9 days', 1.5, 'reussie', 30, 6),
    (CURRENT_DATE - INTERVAL '60 days', 2.0, 'echouee', 39, 6),
    (CURRENT_DATE - INTERVAL '52 days', 3.0, 'echouee', 39, 4);

-- ---------- ATELIERS (4) — RG12 ----------
-- Chaque atelier est anime par un benevole ayant la competence adaptee.
INSERT INTO atelier (intitule, date_atelier, duree_heures, nb_places, id_benevole) VALUES
    ('Repare ton velo', CURRENT_DATE - INTERVAL '30 days', 3.0, 8, 6),
    ('Initiation couture', CURRENT_DATE - INTERVAL '18 days', 2.5, 6, 2),
    ('Retaper un meuble', CURRENT_DATE - INTERVAL '9 days', 4.0, 5, 3),
    ('Depannage electrique de base', CURRENT_DATE - INTERVAL '45 days', 2.0, 10, 4);

-- ---------- INSCRIPTION (21) — RG13, RG14 ----------
-- est_present = FALSE : les desistements evoques par Malika.
INSERT INTO inscription (id_atelier, id_personne, date_inscription, est_present) VALUES
    (1, 13, CURRENT_DATE - INTERVAL '35 days', TRUE),
    (1, 14, CURRENT_DATE - INTERVAL '34 days', TRUE),
    (1, 17, CURRENT_DATE - INTERVAL '33 days', FALSE),
    (1, 19, CURRENT_DATE - INTERVAL '32 days', TRUE),
    (1, 20, CURRENT_DATE - INTERVAL '31 days', FALSE),
    (1, 22, CURRENT_DATE - INTERVAL '30 days', TRUE),
    (2, 15, CURRENT_DATE - INTERVAL '22 days', TRUE),
    (2, 18, CURRENT_DATE - INTERVAL '21 days', TRUE),
    (2, 21, CURRENT_DATE - INTERVAL '20 days', FALSE),
    (2, 23, CURRENT_DATE - INTERVAL '19 days', TRUE),
    (2, 25, CURRENT_DATE - INTERVAL '18 days', FALSE),
    (3, 13, CURRENT_DATE - INTERVAL '14 days', TRUE),
    (3, 16, CURRENT_DATE - INTERVAL '13 days', TRUE),
    (3, 24, CURRENT_DATE - INTERVAL '12 days', FALSE),
    (3, 26, CURRENT_DATE - INTERVAL '11 days', TRUE),
    (4, 14, CURRENT_DATE - INTERVAL '50 days', TRUE),
    (4, 17, CURRENT_DATE - INTERVAL '49 days', TRUE),
    (4, 19, CURRENT_DATE - INTERVAL '48 days', TRUE),
    (4, 20, CURRENT_DATE - INTERVAL '47 days', FALSE),
    (4, 22, CURRENT_DATE - INTERVAL '46 days', FALSE),
    (4, 23, CURRENT_DATE - INTERVAL '45 days', TRUE);

COMMIT; 