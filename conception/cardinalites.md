# Phrases de lecture des cardinalités

---

**EST AUSSI — PERSONNE (0,1) — (1,1) BENEVOLE**
- Une personne est aussi bénévole zéro ou une fois.
- Un bénévole est une et une seule personne. *(D1)*

**FAIT — PERSONNE (0,n) — (1,1) DEPOT**
- Une personne fait zéro ou plusieurs dépôts. *(RG2)*
- Un dépôt est fait par une et une seule personne. *(RG1)*

**CONTIENT — DEPOT (1,n) — (1,1) OBJET**
- Un dépôt contient un ou plusieurs objets. *(RG3)*
- Un objet est contenu dans un et un seul dépôt. *(RG3)*

**APPARTIENT A — OBJET (1,1) — (0,n) CATEGORIE**
- Un objet appartient à une et une seule catégorie. *(RG4)*
- Une catégorie regroupe zéro ou plusieurs objets.

**CONCERNE — OBJET (0,n) — (1,1) REPARATION**
- Un objet est concerné par zéro ou plusieurs réparations. *(RG7)*
- Une réparation concerne un et un seul objet. *(RG8)*

**EFFECTUE — BENEVOLE (0,n) — (1,1) REPARATION**
- Un bénévole effectue zéro ou plusieurs réparations.
- Une réparation est effectuée par un et un seul bénévole. *(RG8)*

**ACHETE LORS DE — PERSONNE (0,n) — (0,1) VENTE**
- Une personne achète lors de zéro ou plusieurs ventes.
- Une vente est faite par zéro ou une personne. *(D11 : client de passage non identifié)*

**COMPORTE — VENTE (1,n) — (0,1) OBJET** · porte `prix_paye`
- Une vente comporte un ou plusieurs objets. *(RG9)*
- Un objet est comporté dans zéro ou une vente. *(RG9)*

**POSSEDE — BENEVOLE (0,n) — (0,n) COMPETENCE**
- Un bénévole possède zéro ou plusieurs compétences. *(RG11)*
- Une compétence est possédée par zéro ou plusieurs bénévoles. *(RG11)*

**ANIME — BENEVOLE (0,n) — (1,1) ATELIER**
- Un bénévole anime zéro ou plusieurs ateliers.
- Un atelier est animé par un et un seul bénévole. *(RG12)*

**S'INSCRIT A — PERSONNE (0,n) — (0,n) ATELIER** · porte `date_inscription`, `est_present`
- Une personne s'inscrit à zéro ou plusieurs ateliers. *(RG14)*
- Un atelier reçoit zéro ou plusieurs inscriptions. *(RG13, RG14)*

---
