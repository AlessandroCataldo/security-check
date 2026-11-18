#!/usr/bin/env bash
# Installa la skill security-check in Claude Code.
# Uso: curl -fsSL https://raw.githubusercontent.com/AlessandroCataldo/security-check/main/install.sh | bash
#      aggiungi "-s -- --project" per installarla solo nel progetto corrente
set -euo pipefail
DEST="$HOME/.claude/skills"
[ "${1:-}" = "--project" ] && DEST="$(pwd)/.claude/skills"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
curl -fsSL https://github.com/AlessandroCataldo/security-check/archive/refs/heads/main.tar.gz | tar -xz -C "$TMP"
mkdir -p "$DEST"; rm -rf "$DEST/security-check"
cp -r "$TMP"/security-check-main/skills/security-check "$DEST/"
chmod +x "$DEST/security-check/scripts/"*.sh
echo "Skill installata in $DEST/security-check"
echo "Riavvia Claude Code e scrivi: fai il security check"
