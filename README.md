# security-check

Skill per Claude (Claude Code, Claude.ai, Claude Desktop) che fa 27 controlli di sicurezza su un sito o una web app prima del lancio, corregge quello che può e consegna un report.

Pensata per app fatte in vibe coding: login, API key, dati degli utenti, pagamenti, upload, header, dipendenze, chiavi dimenticate nella cronologia git.

## Installazione

**Claude Code (tutti i progetti)**
```bash
git clone https://github.com/AlessandroCataldo/security-check.git /tmp/security-check
mkdir -p ~/.claude/skills && cp -r /tmp/security-check/skills/security-check ~/.claude/skills/
```

**Claude Code (solo un progetto)**: copia `skills/security-check` in `.claude/skills/` dentro il progetto.

**Claude.ai / Claude Desktop**: scarica lo zip della repo, comprimi la cartella `skills/security-check` in `security-check.zip` e caricala da Impostazioni > Capabilities > Skills.

## Uso

Apri il progetto e scrivi: `fai il security check` oppure `/security-check`.

Claude mappa il progetto, lancia gli script, passa i 27 controlli, corregge, testa e scrive `SECURITY-REPORT.md` nella root.

Gli script funzionano anche da soli:
```bash
bash scripts/scan_secrets.sh          # segreti nei file e nella cronologia git
bash scripts/check_deps.sh            # dipendenze vulnerabili e inutilizzate
bash scripts/check_live.sh https://tuosito.it   # HTTPS, header, cookie, CORS, file esposti
```

## I 27 controlli

Login con auth sul server · password solo hash · ognuno vede solo i suoi dati · area admin chiusa · reset password con scadenza · rate limit · avviso dopo 5 login falliti · log · API key nascoste · variabili d'ambiente pubbliche senza segreti · debug spento · nessun file privato scaricabile · scansione cronologia git · revoca delle chiavi trovate · validazione sul server · XSS · query parametrizzate · upload limitati · prezzi e pagamenti confermati dal server · HTTPS · CORS ristretto · security headers · cookie Secure/HttpOnly/SameSite · CSRF · dipendenze aggiornate · pacchetti inutili rimossi · review e test finali.

## Limiti

Una skill non sostituisce un penetration test professionale. Le chiavi trovate vanno revocate a mano dal pannello del provider: cancellare il commit non basta.

## Licenza

MIT
