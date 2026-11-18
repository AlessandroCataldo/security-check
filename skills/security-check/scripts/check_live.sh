#!/usr/bin/env bash
# Controlli sul sito online. Uso: bash check_live.sh https://tuodominio.it
set -u
URL="${1:?Uso: check_live.sh https://dominio}"; URL="${URL%/}"
HOST="${URL#*://}"; HOST="${HOST%%/*}"
echo "== HTTP -> HTTPS =="
curl -sI -o /dev/null -w "http://$HOST risponde %{http_code}, redirect a: %{redirect_url}\n" "http://$HOST" || true
echo; echo "== Security headers =="
H=$(curl -sI "$URL")
for h in strict-transport-security content-security-policy x-content-type-options x-frame-options referrer-policy permissions-policy; do
  if echo "$H" | grep -qi "^$h:"; then echo "OK      $h"; else echo "MANCA   $h"; fi
done
echo "$H" | grep -iE '^(x-powered-by|server):' | sed 's/^/INFO    /'
echo; echo "== Cookie =="
echo "$H" | grep -i '^set-cookie:' | while read -r c; do
  n=$(echo "$c" | cut -d= -f1 | cut -d: -f2 | tr -d ' ')
  for f in Secure HttpOnly SameSite; do echo "$c" | grep -qi "$f" || echo "cookie $n: manca $f"; done
done
echo "(nessun avviso = ok o nessun cookie in homepage; controlla anche la risposta del login)"
echo; echo "== CORS =="
curl -sI -H "Origin: https://evil.example" "$URL" | grep -i '^access-control-allow' || echo "nessun header CORS per origin estraneo (ok)"
echo; echo "== File che NON devono essere scaricabili =="
for p in .env .env.local .env.production .git/config .git/HEAD .DS_Store backup.sql dump.sql db.sqlite database.sqlite config.json wp-config.php.bak package.json composer.json .npmrc docker-compose.yml; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$URL/$p")
  [ "$code" = "200" ] && echo "ESPOSTO ($code)  $URL/$p"
done
echo "(controlla a mano i 200 su package.json: a volte sono pagine SPA di fallback)"
echo; echo "== Source map pubbliche =="
js=$(curl -s "$URL" | grep -oE 'src="[^"]+\.js"' | head -3 | sed -E 's/src="([^"]+)"/\1/')
for j in $js; do case "$j" in http*) u="$j";; *) u="$URL/${j#/}";; esac
  code=$(curl -s -o /dev/null -w "%{http_code}" "$u.map"); [ "$code" = "200" ] && echo "source map esposta: $u.map"; done
echo "fatto"
