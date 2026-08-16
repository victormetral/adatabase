# AdaDatabase — La Remise

Base de données de la ressourcerie associative La Remise.

## Initialiser la base en trois commandes

```bash
docker compose up -d
docker exec -i laremise_db psql -U remise -d laremise < migration_up.sql
docker exec -i laremise_db psql -U remise -d laremise < seed.sql
```

## Vérifier

```bash
docker exec -it laremise_db psql -U remise -d laremise -c "\dt"
```

## Réinitialiser

```bash
docker exec -i laremise_db psql -U remise -d laremise < migration_down.sql
```

## Stack
PostgreSQL 16 · Docker Compose