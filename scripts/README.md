# Scripts et exemples de configuration

| Fichier | Où il s'exécute | Rôle |
|---|---|---|
| `New-AtelierUsers.ps1` + `utilisateurs.csv` | DC01 (PowerShell administrateur) | Crée les 30 comptes AD dans l'OU de leur service |
| `glpi-backup.sh` | glpi-srv, installé dans `/usr/local/sbin/` | Sauvegarde base + fichiers, rotation 7 jours |
| `config-exemples/` | glpi-srv | Fichiers de configuration tels que déployés (aucun secret) |

Le fichier `config_db.php` (identifiants de la base) et la clé `glpicrypt.key` ne sont **jamais** versionnés.
