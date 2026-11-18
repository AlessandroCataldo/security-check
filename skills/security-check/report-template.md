# Security report: <nome progetto>

Data: <data>  ·  Stack: <stack>  ·  Commit analizzato: <hash>

## Riepilogo
- Controlli OK: X/27
- Corretti in questa sessione: X
- Da fare a mano: X (urgenti: X)
- Non applicabili: X

## Da fare subito a mano
1. <azione precisa, es. "Revoca la chiave sk_l... su dashboard.stripe.com/apikeys e mettine una nuova in STRIPE_SECRET_KEY su Vercel">

## Dettaglio dei 27 controlli
| # | Controllo | Stato | Dove | Cosa ho fatto |
|---|-----------|-------|------|---------------|
| 1 | Login con auth sul server | | | |
| 2 | Password solo hash | | | |
| 3 | Ognuno vede solo i suoi dati | | | |
| 4 | Area admin chiusa | | | |
| 5 | Reset password con scadenza | | | |
| 6 | Rate limit | | | |
| 7 | Avviso dopo 5 login falliti | | | |
| 8 | Log | | | |
| 9 | API key segrete nascoste | | | |
| 10 | Variabili d'ambiente | | | |
| 11 | Debug spento in produzione | | | |
| 12 | Nessun file privato scaricabile | | | |
| 13 | Scansione cronologia git | | | |
| 14 | Chiavi trovate revocate | | | |
| 15 | Validazione sul server | | | |
| 16 | XSS | | | |
| 17 | Query parametrizzate | | | |
| 18 | Upload: tipo e peso | | | |
| 19 | Prezzi e pagamenti lato server | | | |
| 20 | HTTPS | | | |
| 21 | CORS ristretto | | | |
| 22 | Security headers | | | |
| 23 | Cookie Secure/HttpOnly/SameSite | | | |
| 24 | CSRF | | | |
| 25 | Dipendenze vulnerabili | | | |
| 26 | Pacchetti inutilizzati | | | |
| 27 | Review e test delle protezioni | | | |

Stati: OK · CORRETTO · DA FARE A MANO · NON APPLICABILE · NON VERIFICATO

## Test eseguiti
| Test | Comando | Atteso | Risultato |
|------|---------|--------|-----------|

## File modificati
- `percorso/file`: cosa è cambiato
