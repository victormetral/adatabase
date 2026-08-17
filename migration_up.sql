-- ============================================================
-- migration_up.sql — La Remise
-- PostgreSQL 16
-- Ordre : ENUM, puis tables par niveau de l'arbre de dépendances
-- ============================================================

-- ---------- TYPES ENUM ----------
CREATE TYPE type_depot_enum          AS ENUM ('boutique', 'domicile');
CREATE TYPE etat_objet_enum          AS ENUM ('bon_etat', 'a_reparer', 'hors_service');
CREATE TYPE statut_objet_enum        AS ENUM ('arrive', 'en_reparation', 'en_rayon', 'vendu', 'recycle');
CREATE TYPE resultat_reparation_enum AS ENUM ('reussie', 'echouee');
CREATE TYPE mode_paiement_enum       AS ENUM ('especes', 'carte', 'cheque');


-- ============================================================
-- NIVEAU 0 — aucune dépendance
-- ============================================================

-- R1 sur l'entité PERSONNE (décision D1 : une seule population)
CREATE TABLE personne (
    id_personne  SERIAL       PRIMARY KEY,
    nom          VARCHAR(100) NOT NULL,
    prenom       VARCHAR(100) NOT NULL,
    telephone    VARCHAR(20),
    email        VARCHAR(255) UNIQUE,
    est_adherent BOOLEAN      NOT NULL DEFAULT FALSE
);

-- R1 sur l'entité CATEGORIE (RG4)
CREATE TABLE categorie (
    id_categorie SERIAL      PRIMARY KEY,
    libelle      VARCHAR(50) NOT NULL UNIQUE
);

-- R1 sur l'entité COMPETENCE (RG11, décision D7 : table de référence)
CREATE TABLE competence (
    id_competence SERIAL      PRIMARY KEY,
    libelle       VARCHAR(50) NOT NULL UNIQUE
);


-- ============================================================
-- NIVEAU 1 — dépend de personne
-- ============================================================

-- R1 + R2 sur EST AUSSI : PERSONNE (0,1) — (1,1) BENEVOLE
-- La clé de personne migre ET devient la clé primaire : spécialisation 1:1
CREATE TABLE benevole (
    id_personne INTEGER PRIMARY KEY
                REFERENCES personne(id_personne) ON DELETE CASCADE,
    date_entree DATE    NOT NULL,
    est_actif   BOOLEAN NOT NULL DEFAULT TRUE
);

-- R1 + R2 sur FAIT : PERSONNE (0,n) — (1,1) DEPOT
CREATE TABLE depot (
    id_depot    SERIAL          PRIMARY KEY,
    date_depot  DATE            NOT NULL DEFAULT CURRENT_DATE,
    type_depot  type_depot_enum NOT NULL,
    id_personne INTEGER         NOT NULL
                REFERENCES personne(id_personne) ON DELETE RESTRICT
);

-- R1 + R2 sur ACHETE LORS DE : PERSONNE (0,n) — (0,1) VENTE
-- id_personne nullable : client de passage non identifié (décision D11)
CREATE TABLE vente (
    id_vente      SERIAL             PRIMARY KEY,
    date_vente    DATE               NOT NULL DEFAULT CURRENT_DATE,
    mode_paiement mode_paiement_enum NOT NULL,
    id_personne   INTEGER
                  REFERENCES personne(id_personne) ON DELETE SET NULL
);

-- ============================================================
-- NIVEAU 2 — dépend de depot, categorie, vente, benevole, competence
-- ============================================================

-- R1 + R2 ×3 : CONTIENT (RG3), APPARTIENT A (RG4), COMPORTE (RG9/RG10, D13)
CREATE TABLE objet (
    id_objet           SERIAL            PRIMARY KEY,
    etiquette          VARCHAR(20)       NOT NULL UNIQUE,
    designation        VARCHAR(255)      NOT NULL,
    poids_g            INTEGER           NOT NULL,
    etat_arrivee       etat_objet_enum   NOT NULL,
    statut             statut_objet_enum NOT NULL DEFAULT 'arrive',
    prix_affiche       NUMERIC(8,2),
    date_mise_en_rayon DATE,
    date_sortie_rayon  DATE,
    prix_paye          NUMERIC(8,2),
    id_depot           INTEGER           NOT NULL
                       REFERENCES depot(id_depot)         ON DELETE RESTRICT,
    id_categorie       INTEGER           NOT NULL
                       REFERENCES categorie(id_categorie) ON DELETE RESTRICT,
    id_vente           INTEGER
                       REFERENCES vente(id_vente)         ON DELETE SET NULL,

    CONSTRAINT chk_poids        CHECK (poids_g > 0),
    CONSTRAINT chk_prix_affiche CHECK (prix_affiche IS NULL OR prix_affiche >= 0),
    CONSTRAINT chk_prix_paye    CHECK (prix_paye    IS NULL OR prix_paye    >= 0),
    CONSTRAINT chk_vente_coherente CHECK (
        (statut = 'vendu'  AND id_vente IS NOT NULL AND prix_paye IS NOT NULL)
     OR (statut <> 'vendu' AND id_vente IS NULL     AND prix_paye IS NULL)
    )
);

-- R3 sur POSSEDE : BENEVOLE (0,n) — (0,n) COMPETENCE
-- Table de liaison pure : aucun attribut propre (RG11)
CREATE TABLE benevole_competence (
    id_benevole   INTEGER NOT NULL
                  REFERENCES benevole(id_personne)    ON DELETE CASCADE,
    id_competence INTEGER NOT NULL
                  REFERENCES competence(id_competence) ON DELETE CASCADE,
    PRIMARY KEY (id_benevole, id_competence)
);

-- R1 + R2 sur ANIME : BENEVOLE (0,n) — (1,1) ATELIER (RG12)
CREATE TABLE atelier (
    id_atelier   SERIAL       PRIMARY KEY,
    intitule     VARCHAR(150) NOT NULL,
    date_atelier DATE         NOT NULL,
    duree_heures NUMERIC(4,2) NOT NULL,
    nb_places    INTEGER      NOT NULL,
    id_benevole  INTEGER      NOT NULL
                 REFERENCES benevole(id_personne) ON DELETE RESTRICT,

    CONSTRAINT chk_duree_atelier CHECK (duree_heures > 0),
    CONSTRAINT chk_nb_places     CHECK (nb_places    > 0)
);


-- ============================================================
-- NIVEAU 3 — dépend de objet, benevole, atelier, personne
-- ============================================================

-- R1 + R2 ×2 : CONCERNE et EFFECTUE (RG7, RG8)
-- Entité et non association : décision D12
CREATE TABLE reparation (
    id_reparation   SERIAL                   PRIMARY KEY,
    date_reparation DATE                     NOT NULL,
    duree_heures    NUMERIC(5,2)             NOT NULL,
    resultat        resultat_reparation_enum NOT NULL,
    id_objet        INTEGER                  NOT NULL
                    REFERENCES objet(id_objet)       ON DELETE CASCADE,
    id_benevole     INTEGER                  NOT NULL
                    REFERENCES benevole(id_personne) ON DELETE RESTRICT,

    CONSTRAINT chk_duree_reparation CHECK (duree_heures > 0)
);

-- R3 sur S'INSCRIT A : PERSONNE (0,n) — (0,n) ATELIER (RG13, RG14)
-- Association porteuse de données : date_inscription et est_present
CREATE TABLE inscription (
    id_atelier       INTEGER NOT NULL
                     REFERENCES atelier(id_atelier)   ON DELETE CASCADE,
    id_personne      INTEGER NOT NULL
                     REFERENCES personne(id_personne) ON DELETE CASCADE,
    date_inscription DATE    NOT NULL DEFAULT CURRENT_DATE,
    est_present      BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (id_atelier, id_personne)
);