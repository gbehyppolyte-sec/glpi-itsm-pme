# INC-05 : fiche d'ordinateur incomplète après purge (inventaire partiel)

| | |
|---|---|
| Catégorie | Inventaire / Gestion de parc |
| Composants | GLPI Agent 1.21, GLPI 12 |
| Impact | Fiche sans système d'exploitation, sans logiciels, sans processeur |
| Priorité | Basse |
| Ticket GLPI | #_à compléter_ |

## Symptômes
Après suppression définitive du poste dans GLPI puis nouvel envoi, la fiche (ID 2) est recréée avec seulement des volumes, des processus et des ports réseau. Les colonnes **Système d'exploitation** et **Processeur** sont vides, et l'onglet Logiciels n'affiche aucun compteur.

## Diagnostic
1. Le journal de l'agent montre des envois réussis (`New inventory from PC-CLIENT01...`) : l'agent et l'authentification sont corrects.
2. La documentation de l'agent explique le comportement : par défaut (`--full-inventory-postpone=14`), l'agent n'envoie qu'un **inventaire partiel** (catégories modifiées) entre deux inventaires complets.
3. Le premier envoi était complet. Après la purge côté serveur, l'agent a continué en mode partiel : GLPI a recréé la fiche sans les catégories inchangées.

## Cause racine
Décalage d'état entre l'agent (qui croit que le serveur connaît déjà le poste) et GLPI (qui l'a supprimé).

## Correction
```powershell
& "C:\Program Files\GLPI-Agent\glpi-agent.bat" --force --full
```
- `--force` : envoyer même si le serveur ne le demande pas
- `--full` : inventaire complet, équivalent à `--full-inventory-postpone=0`

## Vérification
La fiche affiche : système d'exploitation, 23 composants, 181 logiciels, 127 processus, 3 volumes, antivirus.

## Prévention
- Ne pas purger un poste sans forcer un inventaire complet ensuite.
- Ajuster `full-inventory-postpone` si le contexte l'exige.
- Pour un poste supprimé par erreur, prévoir cette commande dans la procédure d'exploitation.

## Captures
`captures/XX-fiche-incomplete.png`, `captures/XX-journal-agent.png`, `captures/69-composants-ordinateur.png`
