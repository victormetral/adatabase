# Décisions de conception — La Remise

Chaque ambiguïté relevée dans l'entretien de Malika, le choix retenu, et sa justification.

---

## D1 — Une seule table Personne, avec spécialisation Bénévole

**Ambiguïté :** donateurs, acheteurs, inscrits aux ateliers et bénévoles sont-ils quatre populations distinctes ?

**Décision :** une entité `personne` unique. `benevole` est une spécialisation reliée à `personne` en 1:1 (identifiant hérité).

**Justification :** une même personne cumule souvent plusieurs rôles — elle donne un meuble, achète un vaisselier, s'inscrit à un atelier. Quatre tables créeraient quatre fois le même individu et rendraient impossible la question 6 (« qui nous a fait plus de 3 dépôts »). Les attributs propres au bénévolat (date d'entrée, compétences) n'ont aucun sens pour un simple acheteur : ils vont dans `benevole`, pas dans `personne`.

---

## D2 — Le statut de l'objet est un attribut, pas un historique

**Ambiguïté :** « à tout moment on doit savoir où il en est » — faut-il tracer toutes les transitions ?

**Décision :** un attribut `statut` (ENUM) sur `objet`, complété par `date_mise_en_rayon` et `date_sortie_rayon`.

**Justification :** RG6 dit « un statut unique ». Les questions 2 et 10 (« depuis combien de temps en rayon ») n'exigent qu'une date d'entrée en rayon, pas un journal complet des transitions. Un historique serait de la sur-conception.

---

## D3 — Le type de dépôt est un attribut du dépôt

**Ambiguïté :** dépôt en boutique et collecte à domicile : deux entités ?

**Décision :** attribut `type_depot` ENUM (`boutique`, `domicile`) sur `depot`.

**Justification :** RG1 les traite comme deux cas d'un même événement, sans aucun attribut différenciant. Deux tables dupliqueraient les mêmes colonnes.

---

## D4 — La contrainte « au moins un objet par dépôt » n'est pas en SQL pur

**Ambiguïté :** RG3 impose une cardinalité minimale 1 côté dépôt.

**Décision :** modélisée dans le schéma E-A (1,n), non implémentée en contrainte SQL déclarative ; garantie applicativement.

**Justification :** une cardinalité minimale 1 nécessiterait un trigger ou une contrainte différée. Choix de simplicité assumé et documenté.

---

## D5 — Adhérent : booléen sur personne

**Ambiguïté :** « si la personne est adhérente ou pas » — statut permanent ou par année ?

**Décision :** booléen `est_adherent` sur `personne`, valeur courante.

**Justification :** aucune notion d'année d'adhésion dans l'entretien, et la comptabilité des cotisations est explicitement hors périmètre.

---

## D6 — Deux prix distincts : affiché et payé

**Ambiguïté :** l'objet a « un prix » en rayon, et la vente a « le prix réellement payé ».

**Décision :** `prix_affiche` et `prix_paye`, tous deux portés par `objet`.

**Justification :** RG10 impose le prix payé pour chaque objet vendu. Conserver les deux permet de mesurer les gestes commerciaux faits aux adhérents, que Malika mentionne explicitement. Le rattachement de `prix_paye` à `objet` n'est pas un choix arbitraire : c'est le résultat de R2 appliqué à l'association COMPORTE, qui fait migrer la clé de `vente` **et** l'attribut porté par l'association — voir D13.

---

## D7 — Compétence = table de référence

**Ambiguïté :** compétences saisies en texte libre ?

**Décision :** table `competence` avec libellé UNIQUE, liée à `benevole` par une table d'association.

**Justification :** RG11 est un n:n. Une table de référence évite « éléctricité » vs « électricité » et rend la question 9 fiable.

---

## D8 — « Disponible pour animer un atelier » (question 9)

**Ambiguïté :** aucune notion de disponibilité dans l'entretien, et les plannings de bénévoles sont hors périmètre.

**Décision :** interprété comme « bénévole actif n'animant pas déjà un atelier à cette date ». Attribut `est_actif` sur `benevole`.

**Justification :** sans modéliser un planning (hors périmètre), c'est la seule lecture possible de la question.

---

## D9 — Poids en grammes, entier

**Ambiguïté :** unité non précisée.

**Décision :** `poids_g INTEGER`, en grammes.

**Justification :** évite les flottants et leurs arrondis cumulés. La mairie demande des tonnes, la base stocke la donnée la plus fine ; la conversion se fait à l'affichage.

---

## D10 — Atelier reproposé = nouvelle ligne

**Ambiguïté :** « un même atelier peut être reproposé plus tard dans l'année ».

**Décision :** chaque session est une ligne de `atelier` (même intitulé, autre date). Pas de table `type_atelier`.

**Justification :** RG12 attache date, durée, places et animateur à l'atelier lui-même. Un catalogue séparé serait de la sur-conception pour le besoin exprimé.

---

## D11 — La vente peut être anonyme

**Ambiguïté :** Malika parle de l'acheteur, mais la boutique reçoit aussi des clients de passage.

**Décision :** `vente.id_personne` est nullable.

**Justification :** exiger l'identité de chaque acheteur serait irréaliste en caisse et bloquerait la saisie. NULL = client non identifié.

---

## D12 — Réparation modélisée en entité, pas en association

**Ambiguïté :** RG7 autorise plusieurs réparations successives sur un même objet.

**Décision :** `reparation` est une entité avec son propre identifiant, reliée à `objet` et `benevole` par deux associations.

**Justification :** une association binaire porteuse de données ne peut pas stocker deux fois le même couple (objet, bénévole). Or un même bénévole peut réparer deux fois le même objet. L'entité est la seule modélisation correcte.

---

## D13 — La vente est rattachée à l'objet par R2, sans table de liaison

**Ambiguïté :** faut-il une table `ligne_vente` comme dans un logiciel de caisse classique ?

**Décision :** non. `objet` reçoit `#id_vente` et `prix_paye`, tous deux nullables.

**Justification :** RG9 pose une association **1:n**, pas n:n — un objet est vendu lors d'une seule vente. Une patte de l'association a donc une cardinalité maximale de 1, ce qui déclenche **R2** et non R3 : la clé de `vente` migre dans `objet`, accompagnée de l'attribut porté par l'association. Une table de liaison serait justifiée si un objet pouvait apparaître dans plusieurs ventes, ou si la vente portait des quantités — ce n'est pas le cas d'une ressourcerie où chaque objet est une pièce unique.

**Conséquence assumée :** `objet.id_vente` et `objet.prix_paye` sont NULL tant que l'objet n'est pas vendu. La contrainte `chk_vente_coherente` garantit que `statut = 'vendu'` et ces deux colonnes sont toujours cohérents.