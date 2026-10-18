#!/bin/sh
if [ -z "$SKY_SHELL" ] && command -v bash >/dev/null 2>&1; then SKY_SHELL=bash; export SKY_SHELL; exec bash "$0" "$@"; fi
cd /home/container || exit 1
HOME=/home/container
TERM=xterm-256color
export HOME TERM
G='\033[1;32m'; B='\033[1;34m'; Y='\033[1;33m'; R='\033[1;31m'; N='\033[0m'
FIFO=/tmp/.app.stdin
STOP=/tmp/.app.stop
APP_PID=""
if command -v bash >/dev/null 2>&1; then RUNNER=bash; else RUNNER=sh; fi
export RUNNER

say() { printf '%b\n' "$*"; }

rm -f "$FIFO" "$STOP"
mkfifo "$FIFO"
exec 3<>"$FIFO"

SUPERVISOR='while true; do
  $RUNNER -c "$COMANDO"
  code=$?
  printf "\033[1;33m» La app terminó (código %s)\033[0m\n" "$code"
  if [ "$AUTO_RESTART" = "1" ] && [ ! -f /tmp/.app.stop ]; then
    printf "\033[1;33m» Reiniciando en 5 s...\033[0m\n"
    sleep 5
  else
    break
  fi
done'

app_running() {
  [ -n "$APP_PID" ] && kill -0 "$APP_PID" 2>/dev/null
}

app_start() {
  if [ -z "$COMANDO" ]; then
    say "${R}» No hay comando de inicio configurado (variable COMANDO).${N}"
    return
  fi
  if app_running; then
    say "${Y}» La app ya está corriendo (PID $APP_PID).${N}"
    return
  fi
  rm -f "$STOP"
  say "${Y}» Iniciando: ${COMANDO}${N}"
  setsid sh -c "$SUPERVISOR" <&3 &
  APP_PID=$!
}

app_stop() {
  if ! app_running; then
    say "${Y}» La app no está corriendo.${N}"
    APP_PID=""
    return
  fi
  touch "$STOP"
  say "${Y}» Deteniendo la app...${N}"
  kill -TERM "-$APP_PID" 2>/dev/null
  n=0
  while [ $n -lt 20 ] && app_running; do
    sleep 0.5
    n=$((n + 1))
  done
  app_running && kill -KILL "-$APP_PID" 2>/dev/null
  APP_PID=""
  say "${Y}» App detenida.${N}"
}

app_status() {
  if app_running; then
    say "${G}» App corriendo${N} (PID $APP_PID) · comando: ${COMANDO}"
  else
    say "${R}» App detenida.${N} Usa ${Y}app iniciar${N} para arrancarla."
  fi
}

help_text() {
  say "${B}Comandos de la terminal:${N}"
  say "  ${Y}app iniciar${N} · ${Y}app parar${N} · ${Y}app reiniciar${N} · ${Y}app estado${N}"
  say "  ${Y}> texto${N}        envía texto a la app (ej: el número que pide al vincular)"
  say "  ${Y}ayuda${N}          muestra esta ayuda"
  say "  ${Y}exit${N}           detiene la app y apaga el servidor"
  say "  Cualquier otro texto se ejecuta como comando: ls, cd, git pull, npm i, pip install, node -v..."
}

shutdown() {
  app_running && app_stop
  exit 0
}
trap shutdown TERM INT

run_user() {
  say "${B}\$ $1${N}"
  started=$(date +%s)
  (
    while sleep 15; do
      say "${Y}» Sigue trabajando ($(( $(date +%s) - started )) s)...${N}"
    done
  ) &
  beat=$!
  eval "$1"
  code=$?
  kill "$beat" 2>/dev/null
  wait "$beat" 2>/dev/null
  took=$(( $(date +%s) - started ))
  if [ "$code" -ne 0 ]; then
    say "${R}» Terminó con error (código $code, ${took} s).${N}"
  elif [ "$took" -ge 3 ]; then
    say "${G}» Listo (${took} s).${N}"
  fi
}

run_step() {
  say "${Y}» $1${N}"
  eval "$1"
}

if [ -d .git ] && [ "$AUTO_UPDATE" = "1" ]; then
  run_step "git pull --ff-only"
fi

if [ "$INSTALL_DEPS" = "1" ]; then
  [ -f package.json ] && command -v npm >/dev/null 2>&1 && run_step "npm install --omit=dev"
  [ -f requirements.txt ] && command -v pip >/dev/null 2>&1 && run_step "pip install --user -r requirements.txt"
fi

[ "$MODO" = "comando" ] && app_start

say "${G}Terminal lista.${N} Escribe ${Y}ayuda${N} para ver los comandos."
while true; do
  case "$PWD" in
    "$HOME") where="~" ;;
    "$HOME"/*) where="~${PWD#"$HOME"}" ;;
    *) where="$PWD" ;;
  esac
  printf '%b%s%b:%b%s%b$ ' "$G" "container" "$N" "$B" "$where" "$N"
  IFS= read -r line || shutdown
  case "$line" in
    "") continue ;;
    exit) shutdown ;;
    ayuda|help) help_text ;;
    "app iniciar"|"app start") app_start ;;
    "app parar"|"app stop") app_stop ;;
    "app reiniciar"|"app restart") app_stop; app_start ;;
    "app estado"|"app status") app_status ;;
    ">"*) printf '%s\n' "${line#>}" | sed 's/^ //' >&3 ;;
    *) run_user "$line" ;;
  esac
done
