#!/bin/bash
# =============================================================================
# Script: kido_transfer.sh
# Copia objetos S3 de un bucket origen a destino, hace backup y borra el origen.
# El _SUCCESS se transfiere al final y, si la categoría es Antenas, en destino
# se mapea a "cells".
# =============================================================================

# --- Configuración ------------------------------------------------------------
-----
BASE_DIR="/home/sop_prod/kido"
LOG_FILE="$BASE_DIR/logs/proceso.log"
CSV_LOG_FILE="$BASE_DIR/logs/transferencias_$(date +'%Y%m%d').csv"
SECRET_NAME="Kido"
AWS_REGION="us-east-1"
TMP_DIR="$BASE_DIR/tmp"
MAX_PARALLEL_JOBS=25
AWS_CLI="/usr/local/bin/aws"

# --- Utilidades ---------------------------------------------------------------
-----
log() { echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"; }

init_csv_log() {
  [[ -f "$CSV_LOG_FILE" ]] && return
  echo "Fecha de la Transferencia,Ruta de Origen,Ruta de Destino,Peso (MB),Estad
o" >"$CSV_LOG_FILE"
}

get_json_array() { echo "$1" | grep -oP '"'$2'":\[\K[^\]]+' | tr -d '"' | tr ','
 '\n'; }

get_codigo_pais() {
  case "$1" in
    502) echo "GT" ;; 503) echo "SV" ;; 504) echo "HN" ;;
    505) echo "NI" ;; 506) echo "CR" ;; *) echo "XX" ;;
  esac
}

# --- Lista de países a excluir -----------------------------------------------
PAISES_EXCLUIR=("idpais=506")  # Ejemplo: Honduras y Costa Rica

# ------------------------------------------------------------------------
#  Copia segura con reintentos + back-off exponencial.  Evita 404 cuando
#  otro hilo ya borró o el objeto todavía no es consistente.
#  Devuelve 0 si consigue copiar, 2 si el objeto YA NO EXISTE,
#  1 si agotó reintentos por otras razones.
# ------------------------------------------------------------------------
safe_cp() {
  local src="$1" tmp="$2"
  local max=5 back=1 t=0

  while (( t < max )); do
    # HEAD: ¿el objeto existe?
    $AWS_CLI s3api head-object \
      --bucket "$(echo "$src" | cut -d/ -f3)" \
      --key    "$(echo "$src" | cut -d/ -f4-)" \
      --region "$AWS_REGION" &>/dev/null
    if [[ $? -ne 0 ]]; then
      return 2         # No existe (probablemente ya procesado)
    fi

    # Intentar la copia real
    if $AWS_CLI s3 cp "$src" "$tmp" --only-show-errors --region "$AWS_REGION"; t
hen
      return 0
    fi

    (( t++ ))
    sleep "$back"
    back=$(( back*2 ))
  done
  return 1             # agotó reintentos
}

# --- Inicio -------------------------------------------------------------------
-----
mkdir -p "$TMP_DIR"
init_csv_log
log "🚀 Iniciando proceso de COPIA de archivos en S3 (con backup)"
log "🔐 Obteniendo configuración desde Secrets Manager..."

SECRET_JSON=$($AWS_CLI secretsmanager get-secret-value \
  --secret-id "$SECRET_NAME" \
  --region "$AWS_REGION" \
  --query SecretString --output text)

[[ -z "$SECRET_JSON" ]] && { log "❌ ERROR: No se pudo obtener el secreto."; exi
t 1; }

# --- Parseo de secreto --------------------------------------------------------
-----
DEST_ACCESS_KEY=$(echo "$SECRET_JSON" | grep -o '"aws_access_key_id":"[^"]*"'
 | cut -d':' -f2 | tr -d '"')
DEST_SECRET_KEY=$(echo "$SECRET_JSON" | grep -o '"aws_secret_access_key":"[^"]*"
' | cut -d':' -f2 | tr -d '"')
DEST_REGION=$(    echo "$SECRET_JSON" | grep -o '"region":"[^"]*"'
  | cut -d':' -f2 | tr -d '"')
BUCKET_ORIGEN=$( echo "$SECRET_JSON" | grep -o '"origen":"[^"]*"'
 | cut -d':' -f2- | tr -d '"')
BUCKET_DESTINO=$(echo "$SECRET_JSON" | grep -o '"destino":"[^"]*"'
 | cut -d':' -f2- | tr -d '"')
BUCKET_BACKUP=$( echo "$SECRET_JSON" | grep -o '"backup":"[^"]*"'
 | cut -d':' -f2- | tr -d '"')

DESTINO_BUCKET_NAME=$(echo "$BUCKET_DESTINO" | sed -E 's|s3://([^/]+)/?.*|\1|')
DESTINO_BUCKET_PREFIX=$(echo "$BUCKET_DESTINO" | sed -E 's|s3://[^/]+/?||')

log "✅ Buckets obtenidos:"
log "   - Origen : $BUCKET_ORIGEN"
log "   - Destino: $BUCKET_DESTINO"
log "   - Backup : $BUCKET_BACKUP"

# --- Fecha de proceso (5 días atrás) ------------------------------------------
----
ANIO=$(date -d "-5 days" +"%Y")
MES=$(date  -d "-5 days" +"%-m"); MES_CON_CERO=$(printf "%02d" "$MES")
DIA=$(date  -d "-5 days" +"%-d"); DIA_CON_CERO=$(printf "%02d" "$DIA")

# --- Categorías ---------------------------------------------------------------
-----
RUTAS=()
while IFS= read -r cat; do [[ -n "$cat" ]] && RUTAS+=("$cat"); done < <(get_json
_array "$SECRET_JSON" "categorias")

# =============================================================================
# PROCESO PRINCIPAL
# =============================================================================
for RUTA in "${RUTAS[@]}"; do
  log "📁 Procesando categoría: $RUTA"
  PAISES=$($AWS_CLI s3 ls "${BUCKET_ORIGEN%/}/$RUTA/" | awk '{print $2}' | grep
'^idpais=' | sed 's|/||')

  for PAIS in $PAISES; do
    IDPAIS_NUM=${PAIS#idpais=}; CODIGO_PAIS=$(get_codigo_pais "$IDPAIS_NUM")

    # Saltar si el país está en la lista de exclusión
    # Saltar si el país está en la lista de exclusión
    EXCLUIR_P=false
    for P_EXCLUIR in "${PAISES_EXCLUIR[@]}"; do
        if [[ "$PAIS" == "$P_EXCLUIR" ]]; then
            EXCLUIR_P=true
            break
        fi
    done
    if $EXCLUIR_P; then
        log "⛔ País excluido manualmente: $PAIS – se omite."
        continue
    fi


    ORIGEN_PATH="${BUCKET_ORIGEN%/}/$RUTA/$PAIS/anio=$ANIO/mes=$MES/dia=$DIA/"
    # --- mapeo de nombre en destino -------------------------------------------
-----
    if [[ "${RUTA,,}" == "antenas" ]]; then
      RUTA_DEST="cells"
    else
      RUTA_DEST=$(echo "$RUTA" | tr '[:upper:]' '[:lower:]')
    fi
    DESTINO_PATH="s3://${DESTINO_BUCKET_NAME}/${DESTINO_BUCKET_PREFIX%/}/claro/$
RUTA_DEST/country=$CODIGO_PAIS/date=$ANIO-$MES_CON_CERO-$DIA_CON_CERO/"

    log "🌍 País: $PAIS ($CODIGO_PAIS)"
    log "   Origen : $ORIGEN_PATH"
    log "   Destino: $DESTINO_PATH"

    # ------------------------------------------------------------------
    # 1) Listado S3 y separación de _SUCCESS
    # ------------------------------------------------------------------
    ARCHIVOS=$($AWS_CLI s3 ls "$ORIGEN_PATH" --recursive)

    SUCCESS_LINE=""; declare -a LINEAS
    while IFS= read -r linea; do
      key=$(awk '{print $4}' <<<"$linea")
      [[ -z $key || $key == */ ]] && continue
      if [[ $(basename "$key") == "_SUCCESS" ]]; then
        SUCCESS_LINE="$linea"
      else
        LINEAS+=("$linea")
      fi
    done <<<"$ARCHIVOS"

    # ------------------------------------------------------------------
    # 2) Proceso paralelo para objetos normales
    # ------------------------------------------------------------------
    for line in "${LINEAS[@]}"; do
      while [[ $(jobs -r | wc -l) -ge $MAX_PARALLEL_JOBS ]]; do sleep 1; done
      (
        SIZE_BYTES=$(awk '{print $3}' <<<"$line")
        FULL_PATH=$(awk '{print $4}' <<<"$line")
        [[ -z "$FULL_PATH" || "$FULL_PATH" == */ ]] && exit 0

        FILE_SIZE_MB=$(awk -v b="$SIZE_BYTES" 'BEGIN {printf "%.2f", b/1024/1024
}')
        FILE_PATH=${FULL_PATH#Kido/$RUTA/}; FILE_PATH=${FILE_PATH#/}

        ORIGEN_FILE="s3://${BUCKET_ORIGEN#s3://}/$RUTA/$FILE_PATH"
        DESTINO_FILE="${DESTINO_PATH}$(basename "$FILE_PATH")"
        TMP_FILE="$TMP_DIR/$(basename "$FILE_PATH")"

        log "📂 Descargando: $ORIGEN_FILE"
        safe_cp "$ORIGEN_FILE" "$TMP_FILE"
        EXIT_DL=$?

        if [[ $EXIT_DL -eq 2 ]]; then
          # Ya fue procesado y borrado por otro hilo
          log "⚠️  Ya procesado por otro hilo: $ORIGEN_FILE"
          echo "$(date '+%F %T'),$ORIGEN_FILE, ,$FILE_SIZE_MB,Ya-Procesado" >>"$
CSV_LOG_FILE"
          exit 0
        elif [[ $EXIT_DL -ne 0 ]]; then
          log "❌ ERROR descarga (reintentos agotados) de $ORIGEN_FILE"
          echo "$(date '+%F %T'),$ORIGEN_FILE,$TMP_FILE,$FILE_SIZE_MB,Error-Desc
arga-Retry" >>"$CSV_LOG_FILE"
          rm -f "$TMP_FILE"; exit 0
        fi

        log "📤 Subiendo   : $DESTINO_FILE"
        AWS_ACCESS_KEY_ID="$DEST_ACCESS_KEY" \
        AWS_SECRET_ACCESS_KEY="$DEST_SECRET_KEY" \
        AWS_DEFAULT_REGION="$DEST_REGION" \
        $AWS_CLI s3 cp "$TMP_FILE" "$DESTINO_FILE" --acl bucket-owner-full-contr
ol >>"$LOG_FILE" 2>&1
        EXIT_UP=$?
        rm -f "$TMP_FILE"

        ORIGEN_FILE_NO_PREFIX=${ORIGEN_FILE#s3://}
        ORIGEN_STRIP=$(echo "$BUCKET_ORIGEN" | sed 's|^s3://||; s|/$||')
        ORIGEN_FILE_NO_BUCKET=${ORIGEN_FILE_NO_PREFIX#$ORIGEN_STRIP/}
        BACKUP_FILE="${BUCKET_BACKUP%/}/Kido/$ORIGEN_FILE_NO_BUCKET"

        log "📀 Backup     : $BACKUP_FILE"
        $AWS_CLI s3 cp "$ORIGEN_FILE" "$BACKUP_FILE" --acl bucket-owner-full-con
trol >>"$LOG_FILE" 2>&1
        EXIT_BK=$?

        [[ $EXIT_UP -eq 0 ]] && estado="Éxito" || estado="Error-Subida"
        [[ $EXIT_BK -eq 0 ]] && estado_bk="Éxito-Backup" || estado_bk="Error-Bac
kup"
        echo "$(date '+%F %T'),$ORIGEN_FILE,$DESTINO_FILE,$FILE_SIZE_MB,$estado"
 >>"$CSV_LOG_FILE"
        echo "$(date '+%F %T'),$ORIGEN_FILE,$BACKUP_FILE,$FILE_SIZE_MB,$estado_b
k" >>"$CSV_LOG_FILE"

        if [[ $EXIT_UP -eq 0 && $EXIT_BK -eq 0 ]]; then
          log "🪟 Borrando   : $ORIGEN_FILE"
          $AWS_CLI s3 rm "$ORIGEN_FILE" >>"$LOG_FILE" 2>&1
        fi
      ) &
    done
    wait   # ------- 🔴 espera a que terminen las copias normales ------------

    # ------------------------------------------------------------------
    # 3) Procesar el _SUCCESS (si existe)
    # ------------------------------------------------------------------
    if [[ -n $SUCCESS_LINE ]]; then
      SIZE_BYTES=$(awk '{print $3}' <<<"$SUCCESS_LINE")
      FULL_PATH=$(awk '{print $4}' <<<"$SUCCESS_LINE")
      FILE_SIZE_MB=$(awk -v b="$SIZE_BYTES" 'BEGIN {printf "%.2f", b/1024/1024}'
)
      FILE_PATH=${FULL_PATH#Kido/$RUTA/}; FILE_PATH=${FILE_PATH#/}

      ORIGEN_FILE="s3://${BUCKET_ORIGEN#s3://}/$RUTA/$FILE_PATH"
      DESTINO_FILE="${DESTINO_PATH}$(basename "$FILE_PATH")"
      TMP_FILE="$TMP_DIR/$(basename "$FILE_PATH")"

      log "📂 Descargando (ctrl): $ORIGEN_FILE"
      if safe_cp "$ORIGEN_FILE" "$TMP_FILE"; then
        log "📤 Subiendo (ctrl):   $DESTINO_FILE"
        AWS_ACCESS_KEY_ID="$DEST_ACCESS_KEY" \
        AWS_SECRET_ACCESS_KEY="$DEST_SECRET_KEY" \
        AWS_DEFAULT_REGION="$DEST_REGION" \
        $AWS_CLI s3 cp "$TMP_FILE" "$DESTINO_FILE" --acl bucket-owner-full-contr
ol >>"$LOG_FILE" 2>&1
        EXIT_UP=$?

        BACKUP_FILE="${BUCKET_BACKUP%/}/Kido/$FILE_PATH"
        log "📀 Backup (ctrl):     $BACKUP_FILE"
        $AWS_CLI s3 cp "$TMP_FILE" "$BACKUP_FILE" --acl bucket-owner-full-contro
l >>"$LOG_FILE" 2>&1
        EXIT_BK=$?

        rm -f "$TMP_FILE"

        [[ $EXIT_UP -eq 0 ]] && estado_up="Éxito" || estado_up="Error-Subida-CTR
L"
        [[ $EXIT_BK -eq 0 ]] && estado_bk="Éxito-Backup-CTRL" || estado_bk="Erro
r-Backup-CTRL"
        echo "$(date '+%F %T'),$ORIGEN_FILE,$DESTINO_FILE,$FILE_SIZE_MB,$estado_
up" >>"$CSV_LOG_FILE"
        echo "$(date '+%F %T'),$ORIGEN_FILE,$BACKUP_FILE,$FILE_SIZE_MB,$estado_b
k" >>"$CSV_LOG_FILE"

        if [[ $EXIT_UP -eq 0 && $EXIT_BK -eq 0 ]]; then
          log "🪟 Borrando _SUCCESS del origen"
          $AWS_CLI s3 rm "$ORIGEN_FILE" >>"$LOG_FILE" 2>&1
        fi
      else
        log "⚠️  _SUCCESS ausente (otro hilo lo eliminó)"
        echo "$(date '+%F %T'),$ORIGEN_FILE, ,$FILE_SIZE_MB,Ya-Procesado" >>"$CS
V_LOG_FILE"
        rm -f "$TMP_FILE"
      fi
    fi

    log "✅ Finalizada partición: $PAIS ($ORIGEN_PATH)"
  done
  log "✅ Finalizada categoría: $RUTA"
done

log "🎉 Proceso finalizado para todas las rutas y países."




