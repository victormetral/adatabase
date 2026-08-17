-- ============================================================
-- migration_down.sql — La Remise
-- Inverse exact de migration_up.sql
-- Ordre : tables du niveau 3 au niveau 0, puis les ENUM
-- Rejouable : IF EXISTS partout
-- ============================================================

-- ---------- NIVEAU 3 ----------
DROP TABLE IF EXISTS inscription;
DROP TABLE IF EXISTS reparation;

-- ---------- NIVEAU 2 ----------
DROP TABLE IF EXISTS atelier;
DROP TABLE IF EXISTS benevole_competence;
DROP TABLE IF EXISTS objet;

-- ---------- NIVEAU 1 ----------
DROP TABLE IF EXISTS vente;
DROP TABLE IF EXISTS depot;
DROP TABLE IF EXISTS benevole;

-- ---------- NIVEAU 0 ----------
DROP TABLE IF EXISTS competence;
DROP TABLE IF EXISTS categorie;
DROP TABLE IF EXISTS personne;

-- ---------- TYPES ENUM ----------
DROP TYPE IF EXISTS mode_paiement_enum;
DROP TYPE IF EXISTS resultat_reparation_enum;
DROP TYPE IF EXISTS statut_objet_enum;
DROP TYPE IF EXISTS etat_objet_enum;
DROP TYPE IF EXISTS type_depot_enum;