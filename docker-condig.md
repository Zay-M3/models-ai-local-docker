## Configuración avanzada de contenedores para modelos Ollama

Este archivo documenta configuraciones opcionales que puedes agregar a los servicios de modelos en tu `docker-compose.yml`, para optimizar el comportamiento de Ollama y controlar mejor el uso de recursos del sistema.

---

### Variables de entorno

Estas variables afectan directamente cómo Ollama gestiona los modelos dentro del contenedor:

```yaml
environment:
  - OLLAMA_CONTEXT_LENGTH=4096       # Tamaño del contexto para el modelo (tokens)
  - OLLAMA_LOAD_TIMEOUT=10m          # Tiempo máximo de espera para cargar el modelo
  - OLLAMA_KEEP_ALIVE=30m            # Tiempo que el modelo permanece en memoria sin uso
  - OLLAMA_NUM_PARALLEL=1            # Número de peticiones paralelas permitidas
```

**Notas:**

* Puedes modificar `OLLAMA_CONTEXT_LENGTH` según la capacidad del modelo o del host.
* Si un modelo es muy pesado, aumentar `OLLAMA_LOAD_TIMEOUT` puede evitar errores al cargar.
* `OLLAMA_KEEP_ALIVE` ayuda a mantener el modelo cargado en memoria entre usos.
* `OLLAMA_NUM_PARALLEL` en 1 evita saturar la RAM o la CPU si el host es limitado.

---

### Restricciones de recursos (`deploy.resources`)

Estas opciones le dicen a Docker cuánta RAM y CPU puede usar el contenedor.

```yaml
deploy:
  resources:
    limits:
      memory: 6G      # Límite máximo de memoria
      cpus: '4.0'     # Límite máximo de CPU
    reservations:
      memory: 4G      # Mínimo garantizado de memoria
      cpus: '2.0'     # Mínimo garantizado de CPU
```

**Notas:**

* Estas restricciones solo se aplican si usas Docker Swarm o tienes configurado un entorno que respete `deploy`.
* Si ejecutas `docker-compose` en modo tradicional (sin Swarm), estas restricciones no se aplican.
* Asegúrate de no sobrepasar los recursos físicos del host.

---

### Uso recomendado

Guarda este bloque como plantilla y agrégalo a cada servicio de modelo cuando necesites:

* Afinar la experiencia de carga o rendimiento
* Proteger tu sistema de consumo excesivo
* Trabajar con modelos grandes o de respuesta lenta

Puedes mantener este archivo como referencia para personalizar futuros modelos en el proyecto.
