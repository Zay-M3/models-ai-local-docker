# Proyecto: Modelos de IA Locales con Docker + Ollama

> Porque a veces uno quiere correr su modelo local, sin depender de la nube, ni de APIs con tokens raros.

Esto es básicamente un conjunto de scripts y archivos Docker Compose para correr modelos como LLaMA, CodeLlama, Mistral, Gemma y WizardLM, de forma local, sin complicarse mucho. Nada de cosas mágicas, solo containers.

<img alt="image" src="/banner.png" />

---

## Requisitos

* Docker
* Bash o GitBash
* curl (opcional, pero útil)

---

## Inicio Rápido

```bash
# Clona el repo (o copia los archivos, como prefieras)

# Ver modelos disponibles y acciones
./manage.sh

# Iniciar LLaMA 3
./manage.sh llama3 start

# Ver estado
./manage.sh llama3 status
```

---

## Modelos Soportados

* llama3
* llama2
* codellama
* mistral
* gemma
* wizardlm
* gpt-oss-20b (no diposible en la imagen de docker)
* gpt-oss-120b (no diposible en la imagen de docker)

Actualmente la imagen oficial de ollama para docker, no tiene soporte para los modelos de gpt nuevos, en cuanto salga una actualizacion, estoy seguro que los docker compose funcionaran, si no es el caso lo resolvere.

Cada uno tiene su propio archivo `docker-compose-<modelo>.yml`.

Te daras cuenta al inpeccionar cualquier de los docker compose, que las opciones de entrypoints y healcheck estan comentadas, esto es asi por que manage.sh ya lo gestiona, si quieres usar directamente el archivo, simplemente descomenta estas lineas y utiliza el archivo como se vio arriba.

---

## Lo que hace `manage.sh`

Es un script para automatizar el proceso:

* Levantar el contenedor
* Descargar el modelo (con `ollama pull`)
* Verificar que la API esté lista
* Mostrar logs, reiniciar, limpiar, etc.


---

## Ejemplos

Están todos en el archivo `examples.md`, pero te dejo algunos:

### Generar texto:

```bash
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3",
    "prompt": "Explica qué es Docker en 3 líneas",
    "stream": false
  }'
```

### Chat estilo ChatGPT

```bash
curl -X POST http://localhost:11434/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3",
    "messages": [
      {"role": "user", "content": "Hola, ¿qué puedes hacer?"}
    ]
  }'
```

---

## Python y la API

Esto está pensado para que puedas integrarlo fácilmente con tus scripts en Python, tambien puedes llamarlo usando FastApi, un ejemplo proximamente.

```python
import requests

def ask(model, prompt):
    response = requests.post("http://localhost:11434/api/generate", json={
        "model": model,
        "prompt": prompt,
        "stream": False
    })
    return response.json()

print(ask("llama3", "Dame 3 ventajas de usar contenedores"))
```

---

## Monitoreo rápido

```bash
# Ver consumo de recursos
docker stats ollama-models

# Ver espacio en disco usado
docker system df -v
```

---

## Problemas comunes

* **El puerto ya está en uso**

  * Cambia `11434:11434` en el docker-compose

* **No responde la API**

  * Dale un poco de tiempo
  * `./manage.sh <modelo> logs`

* **No se descarga el modelo**

  * Asegúrate de tener la versión más reciente de `ollama`

---

## Limpieza

```bash
# Para limpiar todo y volver a empezar:
./manage.sh llama3 clean

docker system prune -a --volumes
```

---

## Aportes

No soy experto en esto, solo quería hacerlo funcionar sin morir en el intento. Si ves algo que se puede mejorar, abrir un PR o un issue es bienvenido.

---

# Configuración de Recursos

Para un mejor rendimiento y control, revisa el archivo docker-config.md, donde se explican las variables de entorno y los límites de CPU y memoria que puedes personalizar para cada modelo.

## Disclaimer

Esto no es para producción ni pretende serlo. Solo quiero correr mis modelos local, probar cosas, y no depender de nadie. Si a ti también te sirve, bienvenido seas.
