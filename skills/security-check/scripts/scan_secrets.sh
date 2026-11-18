#!/usr/bin/env bash
# Cerca segreti nei file del progetto e in tutta la cronologia git.
# Uso: bash scan_secrets.sh [cartella_progetto]
set -u
DIR="${1:-.}"; cd "$DIR" || exit 1
PATTERN='(sk_live_[0-9a-zA-Z]{20,}|rk_live_[0-9a-zA-Z]{20,}|sk-[A-Za-z0-9_-]{20,}|sk-ant-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|ghp_[0-9A-Za-z]{36}|github_pat_[0-9A-Za-z_]{40,}|xox[baprs]-[0-9A-Za-z-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|eyJhbGciOi[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}|(postgres|postgresql|mysql|mongodb(\+srv)?)://[^:/ ]+:[^@ ]+@|SG\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}|whsec_[A-Za-z0-9]{20,}|(service_role|SUPABASE_SERVICE_ROLE_KEY)[^\n]{0,5}[=:])'
mask() { sed -E 's/([A-Za-z0-9_+.-]{4})[A-Za-z0-9_+./-]{8,}/\1.../g'; }

echo "== 1. File .env tracciati da git =="
git ls-files 2>/dev/null | grep -E '(^|/)\.env($|\.)' | grep -vE '\.example$|\.sample$|\.template$' || echo "nessuno"
echo
echo "== 2. .gitignore copre .env? =="
if [ -f .gitignore ] && grep -qE '^\.env' .gitignore; then echo "si"; else echo "NO: aggiungi .env* a .gitignore"; fi
echo
echo "== 3. Segreti nei file attuali =="
grep -rInE "$PATTERN" . --exclude-dir={node_modules,.git,.next,dist,build,vendor,.venv,venv} 2>/dev/null | mask | head -50 || true
echo
echo "== 4. Segreti nelle variabili pubbliche (finiscono nel browser) =="
grep -rInE '(NEXT_PUBLIC_|VITE_|REACT_APP_|EXPO_PUBLIC_|NUXT_PUBLIC_|PUBLIC_)[A-Z_]*(SECRET|SERVICE_ROLE|PRIVATE|PASSWORD|TOKEN|SK_)' . --exclude-dir={node_modules,.git,.next,dist,build} 2>/dev/null | mask | head -30 || echo "nessuno"
echo
echo "== 5. Cronologia git =="
if ! git rev-parse --git-dir >/dev/null 2>&1; then echo "non e' una repo git"; exit 0; fi
if command -v gitleaks >/dev/null 2>&1; then
  gitleaks detect --source . --redact --no-banner -v 2>&1 | head -80
else
  echo "(gitleaks non installato, uso git log; per una scansione migliore: https://github.com/gitleaks/gitleaks)"
  git log -p --all --no-color 2>/dev/null | grep -nE "^\+.*$PATTERN" | mask | head -50 || true
  echo "-- file .env mai committati nella storia --"
  git log --all --name-only --pretty=format: 2>/dev/null | grep -E '(^|/)\.env($|\.)' | grep -vE 'example|sample|template' | sort -u || true
fi
echo
echo "Se trovi una chiave: REVOCALA dal pannello del provider e generane una nuova. Cancellare il commit non basta."
