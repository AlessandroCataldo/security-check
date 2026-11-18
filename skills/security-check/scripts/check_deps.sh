#!/usr/bin/env bash
# Dipendenze vulnerabili e inutilizzate. Uso: bash check_deps.sh [cartella_progetto]
set -u
cd "${1:-.}" || exit 1
if [ -f package.json ]; then
  if [ -f pnpm-lock.yaml ]; then pnpm audit --audit-level=high || true
  elif [ -f yarn.lock ]; then yarn npm audit 2>/dev/null || yarn audit --level high || true
  else npm audit --audit-level=high || true; fi
  echo; echo "== Pacchetti non usati (depcheck) =="
  npx --yes depcheck 2>/dev/null || echo "depcheck non disponibile"
fi
if [ -f requirements.txt ] || [ -f pyproject.toml ]; then
  command -v pip-audit >/dev/null && pip-audit || echo "installa pip-audit: pip install pip-audit"
fi
[ -f composer.json ] && { composer audit || true; }
[ -f Gemfile.lock ] && { command -v bundle-audit >/dev/null && bundle-audit check --update || echo "installa bundler-audit"; }
exit 0
