---
name: security-check
description: Audit di sicurezza pre-lancio per siti e web app (anche fatte in vibe coding). Esegue 27 controlli (auth, segreti, accesso ai dati, HTTPS, password, validazione, XSS, SQL injection, CORS, header, cookie, CSRF, upload, pagamenti, dipendenze, cronologia git), corregge quello che trova, testa le protezioni e consegna un report. Usala quando l'utente chiede "security check", "controlla la sicurezza", "audit di sicurezza", "prima del lancio", "mettimi in sicurezza l'app" o simili.
---

# Security check: 27 controlli prima del lancio

Obiettivo: nessuno deve poter entrare nell'app, leggere dati altrui o trovare segreti. Si lavora sul codice del progetto corrente, si corregge e si consegna un report.

## Dove gira

La skill funziona sia con Claude Code (terminale, desktop, claude.ai/code) sia nella chat di claude.ai dal browser. Prima di iniziare capisci in che situazione sei:

- **Hai il codice del progetto in una cartella** (Claude Code, oppure claude.ai/code con la repo collegata): segui la procedura completa qui sotto e correggi direttamente i file.
- **Sei nella chat di claude.ai e il codice non c'è**: chiedi all'utente una di queste cose, in quest'ordine di preferenza:
  1. lo zip del progetto caricato in chat (senza `node_modules`; se vuole includere `.env`, avvisalo che non serve e che è meglio toglierlo);
  2. il link a una repo GitHub pubblica (prova `git clone`; se la rete del sandbox lo blocca, chiedi lo zip: GitHub ha "Code > Download ZIP");
  3. solo l'URL del sito online: in questo caso fai solo i controlli dall'esterno (20, 21, 22, 23, 12 e la parte "da fuori" del 27) e scrivi chiaramente nel report che gli altri controlli non sono stati fatti.
  Se il sandbox non ha accesso a internet, `check_live.sh` non funziona: dai all'utente il comando da lanciare lui oppure segnala i controlli come NON VERIFICATO.
  Se l'esecuzione di codice è disattivata, fai l'analisi leggendo i file e di' all'utente di attivare "Code execution" nelle impostazioni per avere anche gli script.
- **Nella chat non puoi modificare il progetto dell'utente.** Applica le correzioni a una copia, poi consegna come file scaricabili: lo zip del progetto corretto (oppure i soli file modificati) e `SECURITY-REPORT.md`. Nel report elenca ogni file cambiato, così l'utente sa cosa sostituire.

## Come procedere

1. **Mappa il progetto.** Individua stack (Next.js, Vite/React, Express, Django, Laravel, Supabase, Firebase...), dove gira il backend, dove sta il database, come si fa il login, quali endpoint esistono, dove si caricano file, dove si paga. Leggi `package.json` / `requirements.txt` / `composer.json`, la config del deploy e i file `.env*` (senza mai stampare i valori dei segreti nel report).
2. **Esegui gli script** in `scripts/` (dalla root del progetto):
   - `bash <skill>/scripts/scan_secrets.sh` cerca segreti nei file e in tutta la cronologia git.
   - `bash <skill>/scripts/check_deps.sh` controlla dipendenze vulnerabili e inutilizzate.
   - `bash <skill>/scripts/check_live.sh https://dominio.it` (solo se il sito è online) controlla HTTPS, header, cookie, CORS e file esposti.
3. **Passa i 27 controlli** qui sotto, uno per uno. Per ognuno: stato (OK / CORRETTO / DA FARE A MANO / NON APPLICABILE), file e riga, cosa hai cambiato.
4. **Correggi** direttamente nel codice tutto quello che si può correggere senza rompere l'app. Le azioni che richiedono l'utente (revocare una chiave, cambiare impostazioni del provider, DNS) vanno nel report come "DA FARE A MANO" con istruzioni precise.
5. **Testa le protezioni** (controllo 27).
6. **Scrivi il report** usando `report-template.md` e salvalo come `SECURITY-REPORT.md` nella root del progetto.

Regole: non stampare mai segreti completi (mostra solo i primi 4 caratteri + `...`). Non dire che un controllo è OK se non l'hai verificato nel codice. Se non sei sicuro, scrivi "NON VERIFICATO" e spiega perché.

## I 27 controlli

### Accesso e identità

**1. Login serio con autenticazione sul server.** La verifica di chi è l'utente avviene sul server (sessione o JWT verificato lato server, oppure provider come Supabase Auth, Clerk, Auth.js, Firebase Auth). Errore tipico: controllo `if (user)` solo nel frontend, oppure token decodificato senza verificare la firma. Ogni endpoint/API route che tocca dati privati deve verificare la sessione.

**2. Password: solo l'hash.** Mai password in chiaro o cifrate in modo reversibile. Usa argon2id o bcrypt (cost >= 12). Mai MD5/SHA1/SHA256 semplice. Se usi un provider di auth, verifica che le password non vengano salvate anche in una tua tabella.

**3. Ognuno vede solo i suoi dati.** Ogni query su dati privati filtra per l'utente autenticato preso dalla sessione, mai da un id passato dal client (IDOR). Con Supabase: RLS attiva su tutte le tabelle e policy `auth.uid() = user_id`. Con Firebase: regole Firestore/Storage che controllano `request.auth.uid`. Prova a cambiare l'id nell'URL/body: deve dare 403/404.

**4. Area admin chiusa a chi non è admin.** Il ruolo si controlla sul server (middleware, policy, RLS), non nascondendo il bottone. Il ruolo non deve stare in un campo modificabile dall'utente (es. `user_metadata` di Supabase, localStorage, cookie non firmato).

**5. Link di reset password che scadono.** Token casuale crittograficamente sicuro, salvato hashato, monouso, scadenza breve (15-60 minuti). Dopo il reset invalida le sessioni attive. La risposta a "password dimenticata" è identica sia che l'email esista sia che non esista.

**6. Rate limit.** Su login, registrazione, reset password, invio email/SMS, endpoint costosi (AI, upload) e API pubbliche. Usa `express-rate-limit`, `@upstash/ratelimit`, il rate limit del provider o del CDN.

**7. Avviso dopo 5 password sbagliate di fila.** Conta i tentativi falliti per account e per IP. Al quinto: blocco temporaneo o captcha, log di sicurezza e notifica al proprietario (email, Slack, webhook). Se manca un canale di notifica, implementa il log e segnala nel report cosa collegare.

**8. Log tenuti d'occhio.** Logga login riusciti/falliti, cambi password, accessi negati, azioni admin, errori 5xx. Mai loggare password, token, numeri di carta o dati sanitari. Indica dove si leggono i log (Vercel, Render, Supabase, Sentry...).

### Segreti e configurazione

**9. API key segrete nascoste.** Tutto quello che va nel browser lo vede ogni visitatore. Le chiavi segrete (Stripe secret, OpenAI, service_role di Supabase, chiavi admin Firebase, SMTP, database URL) si usano solo sul server. Cerca nel codice client e nel bundle buildato (`dist/`, `.next/static`, `build/`).

**10. Variabili d'ambiente controllate, niente segreti in quelle pubbliche.** Le variabili con prefisso `NEXT_PUBLIC_`, `VITE_`, `REACT_APP_`, `PUBLIC_`, `EXPO_PUBLIC_`, `NUXT_PUBLIC_` finiscono nel browser: dentro solo valori pubblici (es. anon key di Supabase con RLS attiva, publishable key di Stripe). `.env*` deve stare in `.gitignore`. Serve un `.env.example` senza valori veri.

**11. Debug spento in produzione.** `DEBUG=False` (Django), `APP_DEBUG=false` (Laravel), `NODE_ENV=production`, niente stack trace nelle risposte, niente source map pubbliche, niente endpoint di test o seed esposti, niente `console.log` con dati sensibili.

**12. Nessun file privato scaricabile dal sito.** Non devono essere raggiungibili: `.env`, `.git/`, backup (`*.sql`, `*.zip`, `*.bak`), `config.*`, log, la cartella `uploads` con file privati. Verifica cosa finisce nella cartella pubblica (`public/`, `static/`, `dist/`) e controlla con `check_live.sh`.

**13. Scansione della cronologia git.** Una chiave finita in un vecchio commit è ancora lì anche se il file è stato cancellato. Usa `scan_secrets.sh` (gitleaks se presente, altrimenti grep su `git log -p --all`).

**14. Chiavi trovate: revoca e sostituisci.** Cancellare il commit non basta: chiunque abbia clonato o visto la repo ce l'ha. Per ogni chiave trovata: revocarla dal pannello del provider, generarne una nuova, metterla solo nelle variabili d'ambiente del server. Riscrivere la cronologia (`git filter-repo`) è un passo in più, non sostituisce la revoca. Questo va sempre nel report come "DA FARE A MANO" con il link al pannello del provider.

### Dati in ingresso

**15. Validazione dei form sul server.** La validazione nel browser serve solo alla UX. Sul server valida tipo, lunghezza, formato e valori ammessi di ogni input (zod, yup, joi, pydantic, validator di Laravel/Django). Rifiuta i campi non previsti (mass assignment: es. `role` o `isAdmin` nel body).

**16. Protezione XSS: un commento non diventa mai codice.** Niente `dangerouslySetInnerHTML`, `v-html`, `innerHTML`, `{!! !!}`, `|safe`, `document.write` con dati dell'utente. Se serve HTML (es. editor rich text) sanifica con DOMPurify o equivalente. Attenzione a link `javascript:` negli href.

**17. Query parametrizzate: quello che scrive l'utente resta un dato.** Niente SQL costruito concatenando stringhe o template literal con input utente. Usa parametri (`$1`, `?`), ORM/query builder. Controlla anche `raw()`, `$queryRawUnsafe`, `exec`, `eval`, comandi di shell e filtri NoSQL (`$where`, oggetti passati diretti a MongoDB).

**18. Upload: limita tipo e peso.** Limite di dimensione lato server, whitelist di tipi verificata sul contenuto (magic bytes) e non solo sull'estensione, nome file rigenerato, file salvati fuori dalla cartella eseguibile o su storage esterno, niente SVG/HTML serviti inline dallo stesso dominio.

**19. Prezzi e pagamenti li conferma il server.** Il client manda solo l'id del prodotto e la quantità, il prezzo lo legge il server dal database. L'ordine diventa "pagato" solo dal webhook del provider (Stripe, PayPal) con firma verificata, mai da un redirect di "successo" o da una chiamata del browser. Controlla anche coupon, sconti e quantità negative.

### Trasporto e browser

**20. HTTPS sempre.** Redirect da HTTP a HTTPS, header `Strict-Transport-Security: max-age=31536000; includeSubDomains`, niente risorse caricate in http (mixed content), niente URL `http://` hardcoded verso API.

**21. CORS ristretto al tuo dominio.** Niente `Access-Control-Allow-Origin: *` su API che usano cookie o dati privati, niente origin riflesso senza controllo. Whitelist esplicita dei domini di produzione (e localhost solo in sviluppo).

**22. Security headers.** `Content-Security-Policy` (almeno `default-src 'self'`, poi aperta solo dove serve), `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY` o `frame-ancestors 'none'`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy` minima. Rimuovi `X-Powered-By`. Configurali in `next.config.js`, `vercel.json`, `netlify.toml`, `_headers`, helmet (Express) o nel server web.

**23. Cookie di sessione con Secure, HttpOnly e SameSite.** `Secure` (solo HTTPS), `HttpOnly` (JavaScript non li legge), `SameSite=Lax` o `Strict`. Token di sessione mai in localStorage se evitabile.

**24. Protezione CSRF.** Per azioni che modificano dati con autenticazione via cookie: token CSRF oppure `SameSite` + controllo dell'header `Origin`. Le azioni che cambiano dati non devono mai essere GET.

### Dipendenze

**25. Aggiorna le dipendenze vulnerabili.** `npm audit` / `pnpm audit` / `pip-audit` / `composer audit`. Aggiorna le vulnerabilità high e critical, poi verifica che il build passi.

**26. Togli i pacchetti che non usi.** `npx depcheck` (JS) o analisi degli import. Ogni pacchetto in più è codice di terzi che gira nella tua app. Rimuovi solo quelli che sei sicuro non siano usati (attenzione a plugin caricati da config).

### Verifica finale

**27. Review completa e test delle protezioni.** Rileggi le modifiche fatte cercando regressioni. Poi prova davvero le protezioni, dove possibile in locale:
- endpoint privato senza login: deve rispondere 401;
- dati di un altro utente cambiando l'id: 403/404;
- pagina/endpoint admin con utente normale: 403;
- input `<script>alert(1)</script>` in un campo che viene mostrato: deve apparire come testo;
- input `' OR '1'='1` nei campi di ricerca/login: nessun effetto;
- 6 login sbagliati di fila: blocco/avviso;
- raffica di richieste: 429;
- upload di file troppo grande o di tipo non ammesso: rifiutato;
- modifica del prezzo nel body della richiesta di checkout: ignorata;
- richiesta da un origin non autorizzato: bloccata dal CORS;
- `/.env` e `/.git/config` sul sito: 404.
Riporta per ogni test il comando usato e il risultato.

## Report

Usa `report-template.md`. Il report dice cosa hai trovato, cosa hai sistemato (con file modificati), cosa resta da fare a mano e in che ordine. Niente frasi generiche: ogni riga punta a un file, un endpoint o un comando.
