# prod-snapshots/

Snapshots **non-secrets** d'assets utilisés par la prod Xeinoria, centralisés
ici pour référence et réutilisation. Aucun secret (token, password, IP privée)
n'est censé apparaître dans ce dossier — si vous repérez quelque chose, ouvrez
une issue.

## Contenu

### `server-icons/`

Les `server-icon.png` (64×64 px, lus par Paper à la racine du dossier serveur)
de chaque instance du réseau :

| Fichier | Serveur back-end |
|---|---|
| `crea.png` | Créatif |
| `hub.png` | Hub / lobby |
| `nwland.png` | Norath World (events) |
| `survie.png` | Survie |
| `proxy.png` | Velocity (icône affichée tant qu'aucune config MiniMOTD ne le surcharge) |

Pour les déposer en local :

```bash
cp prod-snapshots/server-icons/<server>.png <server>/server-icon.png
```

### `minimotd-velocity/`

Configuration complète de [MiniMOTD](https://github.com/jpenilla/MiniMOTD)
côté proxy Velocity (`proxy/plugins/minimotd-velocity/`) :

- `main.conf` — MOTD par défaut (gradient « Xeinoria — Tiny Takeover » + ligne
  d'annonce de version), max-players, etc.
- `plugin_settings.conf` — mapping `virtual-host → config` (les hôtes
  d'exemple `*.example.com` sont à remplacer par les vrais domaines en prod).
- `extra-configs/skyblock.conf`, `extra-configs/survival.conf` — MOTD par mode
  de jeu, activés via le mapping ci-dessus.
- `icons/` — dossier d'icônes optionnelles référencées par `icon=<nom>` dans
  les configs ci-dessus. Vide pour l'instant (les MOTD utilisent `icon=random`
  qui ne fait rien tant qu'il n'y a aucun fichier).

Pour réinjecter en prod :

```bash
cp -r prod-snapshots/minimotd-velocity/. proxy/plugins/minimotd-velocity/
```

ou côté proxy, `/velocity reload` après remplacement.
