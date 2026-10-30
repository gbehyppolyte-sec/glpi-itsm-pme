# INC-04 : poste inventorié dans la mauvaise entité

| | |
|---|---|
| Catégorie | Inventaire / Gestion de parc |
| Composants | GLPI Agent 1.21 (PC-CLIENT01), GLPI 12 |
| Impact | Le poste atterrit dans l'Entité racine : mauvais périmètre de droits, pas de SLA ni de routage |
| Priorité | Moyenne |
| Ticket GLPI | #_à compléter_ |

## Symptômes
Après la première remontée de l'agent, **Parc > Ordinateurs** affiche PC-CLIENT01 avec la colonne **Entité = Entité racine**.

## Diagnostic
1. Journal de l'agent : l'envoi réussit.
   ```powershell
   Get-Content "C:\Program Files\GLPI-Agent\logs\glpi-agent.log" -Tail 15
   ```
   - `Get-Content <fichier> -Tail 15` : affiche les 15 dernières lignes
2. Configuration de l'agent :
   ```powershell
   Get-ItemProperty "HKLM:\SOFTWARE\GLPI-Agent" | Select-Object server, user, tag
   ```
3. Côté GLPI, aucune règle ne dit dans quelle entité ranger un nouveau poste : par défaut, c'est la racine.

## Cause racine
Absence de **règle d'affectation à une entité** pour les inventaires.

## Correction
1. Poser un identifiant sur l'agent : `TAG=Atelier-Morel` (installation MSI ou valeur `tag` du registre).
2. Administration > Règles > **Règles d'affectation d'un élément à une entité** > nouvelle règle :
   - Critère : **Tag** *est* `Atelier-Morel`
   - Action : **Entité** *Affecter* **Atelier Morel**
3. Test : purger le poste, puis relancer l'envoi :
   ```powershell
   & "C:\Program Files\GLPI-Agent\glpi-agent.bat" --force --full
   ```
   - `--force` : envoie même sans demande du serveur
   - `--full` : inventaire complet (voir INC-05)

## Vérification
Le poste apparaît dans **Entité racine > Atelier Morel**.

## Prévention
- Définir la règle d'affectation avant le déploiement des agents.
- Un tag par entité cliente, imposé dans le paquet de déploiement.

## Captures
`captures/XX-poste-entite-racine.png`, `captures/70-regle-affectation-entite.png`, `captures/67-parc-ordinateurs.png`
