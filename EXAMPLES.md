# Ejemplos de Uso

Este archivo contiene ejemplos prácticos para usar los modelos de IA locales.
no soy un experto asi que podria equivocarme,si ves algo que le falta o no funciona, no dudes
en hacer tu contribuccion. 

## Inicio Rápido

### Linux/macOS
```bash
# Iniciar Llama 3
./manage.sh llama3 start

# Ver el estado
./manage.sh llama3 status

# Ver logs en tiempo real
./manage.sh llama3 logs
```

## Ejemplos de Interacción con la API

### Verificar que el modelo está funcionando
```bash
curl http://localhost:11434/api/tags
```

### Generar texto simple
```bash
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3",
    "prompt": "Explica qué es Docker en términos simples",
    "stream": false
  }'
```

### Chat interactivo
```bash
curl -X POST http://localhost:11434/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3",
    "messages": [
      {"role": "user", "content": "Hola, ¿puedes ayudarme con Python?"}
    ]
  }'
```

### Generación de código con CodeLlama
```bash
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "codellama",
    "prompt": "Crea una función en Python que calcule el factorial de un número",
    "stream": false
  }'
```

## Casos de Uso Específicos

### 1. Desarrollo de Software (CodeLlama)
```bash
# Iniciar CodeLlama
docker compose -f docker-compose-codellama.yml up -d

# Ejemplo: Revisar código
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "codellama",
    "prompt": "Revisa este código Python y sugiere mejoras:\n\ndef calculate(x, y):\n    return x + y",
    "stream": false
  }'
```

### 2. Análisis de Texto (Llama 3)
```bash
# Iniciar Llama 3
docker compose -f docker-compose-llama3.yml up -d

# Ejemplo: Resumir texto
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3",
    "prompt": "Resume este texto en 3 puntos clave: [tu texto aquí]",
    "stream": false
  }'
```

### 3. Tareas Rápidas (Gemma)
```bash
# Iniciar Gemma (modelo más ligero)
docker compose -f docker-compose-gemma.yml up -d

# Ejemplo: Traducción
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemma",
    "prompt": "Traduce al español: Hello, how are you today?",
    "stream": false
  }'
```

## Cambiar entre Modelos

```bash
# Detener modelo actual
docker compose -f docker-compose-llama3.yml down

# Iniciar otro modelo
docker compose -f docker-compose-mistral.yml up -d

# El puerto sigue siendo el mismo (11434)
curl http://localhost:11434/api/tags
```

## Integración con Python
```python
import requests
import json

def chat_with_model(model, message):
    url = "http://localhost:11434/api/chat"
    data = {
        "model": model,
        "messages": [{"role": "user", "content": message}],
        "stream": False
    }
    
    response = requests.post(url, json=data)
    return response.json()

# Uso
result = chat_with_model("llama3", "¿Cuál es la capital de Francia?")
print(result['message']['content'])
```

## Monitoreo de Recursos

### Verificar uso de memoria
```bash
docker stats ollama-llama3
```

### Ver espacio usado por los modelos
```bash
docker system df -v
```

## Troubleshooting

### El modelo no responde
```bash
# Verificar logs
docker compose -f docker-compose-llama3.yml logs

# Reiniciar el contenedor
docker compose -f docker-compose-llama3.yml restart
```

### Puerto ocupado
```bash
# Verificar qué está usando el puerto
netstat -tulpn | grep :11434

# Cambiar puerto en el archivo docker-compose
# Modificar "11434:11434" por "11435:11434"
```

### Limpiar todo y empezar de nuevo
```bash
# Detener todos los contenedores
docker compose -f docker-compose-llama3.yml down -v

# Limpiar imágenes y volúmenes no usados
docker system prune -a --volumes
```
