# INC-03 : articles de la base de connaissances invisibles pour les employés

| | |
|---|---|
| Catégorie | Logiciel / Base de connaissances |
| Composants | GLPI 12 (interface Self-Service) |
| Impact | Les employés ne voient aucun article d'aide, donc ouvrent plus de tickets |
| Priorité | Moyenne |
| Ticket GLPI | #_à compléter_ |

## Symptômes
- Connecté en Super-Admin, les 3 articles apparaissent. Connecté en employé (`henri.morel`), la **FAQ** est vide.
- L'onglet « Visibilité » attendu n'existe pas dans le formulaire de l'article (GLPI 12).

## Diagnostic
1. Vérifier côté employé : interface Self-Service > FAQ vide, donc c'est bien un problème de **publication**, pas de connexion.
2. Dans GLPI 12, la cible de diffusion se règle avec **Autorisations** (menu Actions de l'article) et non plus l'onglet Visibilité. Le profil Self-Service n'y est pas proposé comme cible : il faut cibler l'**entité**.
3. Un article n'est visible dans l'interface Self-Service que s'il est marqué **FAQ**.
4. Contrôle en base (lecture seule) :
   ```sql
   SELECT id, name, is_faq FROM glpi_knowbaseitems;
   ```

## Cause racine
Deux conditions manquantes : article non autorisé sur l'entité Atelier Morel, et option **FAQ** désactivée (`is_faq = 0`).

## Correction
1. Sur chaque article : **Actions > Autorisations > Entité Atelier Morel** (avec sous-entités).
2. Cocher **Ajouter à la FAQ** (ou, en secours et sur sauvegarde préalable) :
   ```sql
   UPDATE glpi_knowbaseitems SET is_faq = 1 WHERE id <> 1;
   ```
   - `UPDATE ... SET ... WHERE` : modifie uniquement les lignes ciblées. Toujours tester le `WHERE` avec un `SELECT` d'abord.

## Vérification
Connecté en employé : les 3 articles apparaissent dans la FAQ.

## Prévention
- Checklist de publication d'un article : autorisation + option FAQ + test avec un compte Self-Service.
- Toujours tester avec le profil réellement utilisé par les utilisateurs finaux.

## Captures
`captures/XX-faq-vide.png`, `captures/XX-autorisations.png`, `captures/XX-faq-3-articles.png`
