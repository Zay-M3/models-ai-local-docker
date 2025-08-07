#!/bin/bash

# Script para gestionar modelos de IA locales con Docker Compose
# Uso: ./manage.sh [modelo] [acción]

set -e

MODELS=("llama3" "llama2" "codellama" "mistral" "gemma" "wizardlm")
ACTIONS=("start" "stop" "restart" "logs" "status" "clean")

show_help() {
    echo "🤖 Gestor de Modelos de IA Locales"
    echo ""
    echo "Uso: $0 [modelo] [acción]"
    echo ""
    echo "Modelos disponibles:"
    for model in "${MODELS[@]}"; do
        echo "  - $model"
    done
    echo ""
    echo "Acciones disponibles:"
    echo "  - start    : Inicia el modelo"
    echo "  - stop     : Detiene el modelo" 
    echo "  - restart  : Reinicia el modelo"
    echo "  - logs     : Muestra logs del modelo"
    echo "  - status   : Estado del modelo"
    echo "  - clean    : Elimina modelo y datos"
    echo ""
    echo "Ejemplos:"
    echo "  $0 llama3 start"
    echo "  $0 codellama logs"
    echo "  $0 mistral status"
}

check_model() {
    local model=$1
    if [[ ! " ${MODELS[@]} " =~ " ${model} " ]]; then
        echo "Error: Modelo '$model' no reconocido"
        echo "Modelos disponibles: ${MODELS[*]}"
        exit 1
    fi
}

check_action() {
    local action=$1
    if [[ ! " ${ACTIONS[@]} " =~ " ${action} " ]]; then
        echo "Error: Acción '$action' no reconocida"
        echo "Acciones disponibles: ${ACTIONS[*]}"
        exit 1
    fi
}

get_compose_file() {
    echo "docker-compose-$1.yml"
}

start_model() {
    local model=$1
    local compose_file=$(get_compose_file $model)
    local ollama_container="ollama-models"
    
    echo " Iniciando modelo $model..."
    docker compose -f "$compose_file" --project-name "$ollama_container" up -d

    docker exec -it "$ollama_container" ollama pull "$model"

    echo " Esperando que el modelo esté listo..."
    sleep 60
    
    echo " Verificando estado..."
    if curl -s http://localhost:11434/api/tags > /dev/null; then
        echo "¡Modelo $model iniciado correctamente!"
        echo "API disponible en: http://localhost:11434"
        echo "Verificar modelos: curl http://localhost:11434/api/tags"
    else
        echo "  El modelo puede estar iniciando aún. Verifica con: $0 $model logs"
    fi
}

stop_model() {
    local model=$1
    local compose_file=$(get_compose_file $model)
    
    echo " Deteniendo modelo $model..."
    docker compose -f "$compose_file" down
    echo " Modelo $model detenido"
}

restart_model() {
    local model=$1
    echo " Reiniciando modelo $model..."
    stop_model $model
    sleep 2
    start_model $model
}

show_logs() {
    local model=$1
    local compose_file=$(get_compose_file $model)
    
    echo " Logs del modelo $model:"
    docker compose -f "$compose_file" logs -f
}

show_status() {
    local model=$1
    local compose_file=$(get_compose_file $model)
    
    echo " Estado del modelo $model:"
    docker compose -f "$compose_file" ps
    
    echo ""
    echo " Verificando API..."
    if curl -s http://localhost:11434/api/tags > /dev/null; then
        echo " API disponible"
        echo " Modelos cargados:"
        curl -s http://localhost:11434/api/tags | jq '.models[].name' 2>/dev/null || curl -s http://localhost:11434/api/tags
    else
        echo "API no disponible"
    fi
}

clean_model() {
    local model=$1
    local compose_file=$(get_compose_file $model)
    
    echo "Limpiando modelo $model (esto eliminará los datos descargados)..."
    read -p "¿Estás seguro? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker compose -f "$compose_file" down -v
        echo "Modelo $model limpiado"
    else
        echo "Operación cancelada"
    fi
}

# Script principal
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

if [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

if [ $# -ne 2 ]; then
    echo " Error: Se requieren exactamente 2 argumentos"
    show_help
    exit 1
fi

MODEL=$1
ACTION=$2

check_model "$MODEL"
check_action "$ACTION"

case $ACTION in
    start)
        start_model "$MODEL"
        ;;
    stop)
        stop_model "$MODEL"
        ;;
    restart)
        restart_model "$MODEL"
        ;;
    logs)
        show_logs "$MODEL"
        ;;
    status)
        show_status "$MODEL"
        ;;
    clean)
        clean_model "$MODEL"
        ;;
esac
