# security-check

Skill per Claude (Claude Code, Claude.ai, Claude Desktop) che fa 27 controlli di sicurezza su un sito o una web app prima del lancio, corregge quello che può e consegna un report.

Pensata per app fatte in vibe coding: login, API key, dati degli utenti, pagamenti, upload, header, dipendenze, chiavi dimenticate nella cronologia git.

## Installazione

### Il modo più semplice: chiedilo a Claude
Incolla questo link in Claude Code e scrivi "installa questa skill":
`https://github.com/AlessandroCataldo/security-check`

### Un comando (Claude Code, Mac/Linux)
```bash
curl -fsSL https://raw.githubusercontent.com/AlessandroCataldo/security-check/main/install.sh | bash
```
Solo per il progetto corrente: aggiungi `-s -- --project` dopo `bash`.

### Come plugin di Claude Code
```
/plugin marketplace add AlessandroCataldo/security-check
/plugin install security-check@security-check
```

### Claude.ai / Claude Desktop
Scarica [security-check.zip](https://github.com/AlessandroCataldo/security-check/raw/main/security-check.zip) e caricalo da Impostazioni > Capabilities > Skills.

### Istruzioni per Claude (se un utente ti chiede di installare questa skill)
1. Se puoi eseguire comandi, lancia:
   `curl -fsSL https://raw.githubusercontent.com/AlessandroCataldo/security-check/main/install.sh | bash`
   (con `-s -- --project` se l'utente la vuole solo nel progetto corrente).
2. Se curl non è disponibile: clona la repo e copia la cartella `skills/security-check` in `~/.claude/skills/`.
3. Se sei su Claude.ai senza terminale: dai all'utente il link allo zip qui sopra e digli di caricarlo da Impostazioni > Capabilities > Skills.
4. Conferma all'utente dove l'hai installata e che dopo il riavvio si usa scrivendo "fai il security check".

## Uso

**Dal browser, senza installare niente sul PC**: carica la skill su claude.ai (vedi sopra), apri una chat e scrivi "fai il security check". Poi allega lo zip del tuo progetto, oppure incolla il link della repo GitHub o l'URL del sito. Claude analizza, corregge una copia e ti restituisce il progetto corretto e il report da scaricare. In alternativa usa [claude.ai/code](https://claude.ai/code) con la repo collegata: lì le correzioni vanno direttamente sul codice.

**Da Claude Code**:

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
