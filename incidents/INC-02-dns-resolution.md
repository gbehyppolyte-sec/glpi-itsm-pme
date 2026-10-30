# INC-02 : résolution DNS erratique de `glpi.atelier.local`

| | |
|---|---|
| Catégorie | Réseau / DNS |
| Composants | DC01 (DNS intégré à l'AD), glpi-srv, postes clients |
| Impact | Le nom `glpi.atelier.local` ne s'ouvre pas ou pointe sur la mauvaise adresse |
| Priorité | Haute |
| Ticket GLPI | #_à compléter_ |

## Symptômes
- Depuis le navigateur du PC physique : `NXDOMAIN` sur `glpi.atelier.local`.
- Sur DC01, `Resolve-DnsName` renvoie aussi l'adresse NAT (192.168.44.x) en plus de l'adresse du réseau lab (192.168.50.x).

## Diagnostic
1. Le PC physique n'utilise pas le DNS du lab : la zone `atelier.local` n'existe que sur DC01. **Normal** : ce poste n'est pas dans le domaine. Le test pertinent se fait depuis PC-CLIENT01.
2. Sur DC01, interroger précisément le serveur DNS du lab :
   ```powershell
   Resolve-DnsName glpi.atelier.local -DnsOnly -Server 192.168.50.5
   ```
   - `-DnsOnly` : ignore le cache et les fichiers hosts, ne regarde que le DNS
   - `-Server` : serveur interrogé
3. DC01 a **deux cartes** (lab + NAT) : il enregistre ses deux adresses dans sa propre zone, ce qui fausse les réponses.

## Cause racine
Contrôleur de domaine **multi-homed** : la carte NAT enregistrait son IP dans le DNS, et le serveur DNS écoutait sur toutes ses interfaces.

## Correction
```powershell
# Ne plus enregistrer l'adresse de la carte NAT dans le DNS
Set-DnsClient -InterfaceAlias "Ethernet2" -RegisterThisConnectionsAddress $false

# Le serveur DNS n'écoute que sur l'adresse du réseau lab
dnscmd /ResetListenAddresses 192.168.50.5

# Supprimer l'enregistrement erroné, puis recréer le bon
Remove-DnsServerResourceRecord -ZoneName atelier.local -RRType A -Name dc01 -RecordData 192.168.44.135 -Force
Add-DnsServerResourceRecordA -ZoneName atelier.local -Name glpi -IPv4Address 192.168.50.10
ipconfig /registerdns
```
- `-RegisterThisConnectionsAddress $false` : cette carte ne s'enregistre plus
- `dnscmd /ResetListenAddresses <ip>` : limite l'écoute du DNS à cette IP
- `Remove-DnsServerResourceRecord ... -Force` : supprime sans confirmation
- `Add-DnsServerResourceRecordA` : crée l'enregistrement A

Sur glpi-srv, vérifier que le DNS du lab est bien utilisé :
```bash
resolvectl status ens34
```

## Vérification
Depuis PC-CLIENT01 : `Resolve-DnsName glpi.atelier.local -Type A` renvoie uniquement `192.168.50.10`.

## Prévention
- Sur un DC multi-homed, désactiver l'enregistrement DNS des cartes non internes et limiter les interfaces d'écoute.
- Tester la résolution depuis un poste du domaine, pas depuis l'hôte.
- Surveiller les enregistrements A de la zone après chaque changement réseau.

## Captures
`captures/XX-nxdomain.png`, `captures/XX-resolve-dnsonly.png`
