# Registro-Glacial
Tercer Challenge en The Huddle, base de datos.

## Descripción

Challenge de modelado de base de datos relacional a partir de un dataset crudo en CSV, sin diccionario de datos provisto. El objetivo fue actuar como diseñador de base de datos: inferir las entidades y relaciones del dominio, construir un esquema con integridad referencial real (PK, FK, NOT NULL), y usar SQL para detectar y demostrar las inconsistencias presentes en los datos originales.

No se trata de que los datos entren sin errores, sino de que el modelo tenga criterio suficiente para señalar sus propias fallas.

---


## Tecnologías utilizadas

- Python 3
- PostgreSQL
- Docker / Docker Compose
- Pandas
- SQLAlchemy
- psycopg2
- python-dotenv

---

## Estructura del proyecto

```
├── csv/                       # Datasets originales provistos por la Academia
├── docker/
│   └── init.sql                # Dump completo de la base (estructura + datos) para levantar el contenedor
├── creacion_tablas.sql        # DDL de las 7 tablas del modelo: PK, FK, tipos de datos
├── control.sql                 # Verificaciones de carga (COUNT, TRUNCATE) y actualización de secuencias SERIAL post-import
├── analisis.sql                 # Consultas de detección de inconsistencias, JOINs estructurales e índices
├── import_data.py             # Carga y transforma los CSV con Pandas antes de insertarlos en PostgreSQL
├── docker-compose.yml         # Configuración del contenedor PostgreSQL
├── .env                        # Variables de conexión (no versionado)
├── .gitignore
└── README.md
```

---

## Cómo correr el proyecto

### Opción 1 — Docker (recomendada)

1. Tener Docker instalado y corriendo.
2. Crear un archivo `.env` en la raíz del proyecto:
   ```
   DB_USER=postgres
   DB_PASSWORD=tu_contraseña
   DB_NAME=registro_glacial
   DB_HOST=localhost
   ```
3. Levantar el contenedor:
   ```bash
   docker-compose up -d
   ```
   El contenedor levanta con la base ya cargada (estructura, datos e índices), ya que `docker/init.sql` se ejecuta automáticamente la primera vez que se crea el volumen.

### Opción 2 — Manual (PostgreSQL local)

1. Crear una base de datos PostgreSQL llamada `registro_glacial`.
2. Ejecutar `creacion_tablas.sql` para crear el esquema.
3. Instalar las dependencias de Python:
   ```bash
   pip install pandas sqlalchemy psycopg2 python-dotenv
   ```
4. Configurar el `.env` (igual que en la opción Docker).
5. Ejecutar la carga de datos:
   ```bash
   python import_data.py
   ```
6. Ejecutar `control.sql` para actualizar las secuencias SERIAL.

---

## Modelo de datos

7 tablas: `customers`, `products`, `orders`, `order_items`, `payments`, `order_status_history`, `order_audit`.

**Relaciones principales:**
- `customers` → `orders`: 1:N
- `orders` → `payments`: 1:N
- `orders` → `order_items`: 1:N
- `orders` → `order_status_history`: 1:N
- `orders` → `order_audit`: 1:N
- `order_items` → `products`: N:1 (resuelve el N:N entre `orders` y `products`)

---

## Decisiones técnicas

**Elección de PostgreSQL.**
Se descartó SQLite por no ser representativo de un entorno de producción real. Se descartó MySQL porque su integridad referencial depende del motor de almacenamiento de cada tabla (InnoDB la soporta, MyISAM la ignora silenciosamente). PostgreSQL aplica integridad referencial estricta sin depender de configuración adicional, además de soportar `COPY`/importación nativa de CSV.

**CHECK constraints removidos del modelo final.**
Por indicación de los coaches, se decidió permitir el ingreso de datos inconsistentes (en vez de bloquearlos con CHECK) para poder demostrarlos posteriormente mediante consultas SQL. Se mantuvieron PK, FK, NOT NULL y UNIQUE, que sí garantizan la integridad estructural mínima del modelo.

**`payment_method` sin restricción de valores.**
Aunque los datos actuales solo contienen 4 métodos de pago consistentes, se dejó sin CHECK bajo el criterio de que el negocio puede incorporar nuevos métodos de pago en el futuro.

**Carga de datos vía Python/Pandas en lugar de `COPY`.**
Los CSV traían campos como `is_active` en formato `0/1` (integer) que debían convertirse a `boolean`, entre otras inconsistencias de tipos. Pandas permitió transformar los datos antes de insertarlos, evitando errores de tipo que `COPY` no resuelve por sí solo.

**Actualización de secuencias SERIAL post-carga.**
Como los CSV ya traían sus propios IDs, se insertaron directamente sin depender de SERIAL. Tras la carga, se actualizó cada secuencia con `setval()` para evitar colisiones de ID en futuras inserciones manuales.

**Índices en columnas de FK.**
Se crearon índices en todas las columnas de FK utilizadas en JOINs frecuentes (`orders.customer_id`, `payments.order_id`, `order_items.order_id`, `order_items.product_id`, `order_status_history.order_id`, `order_audit.order_id`), ya que PostgreSQL no las indexa automáticamente (solo indexa PKs por defecto).

---

## Inconsistencias detectadas

Todas detectadas mediante `LEFT JOIN` + `WHERE ... IS NULL` (ausencias/relaciones rotas) o `WHERE` con condiciones de rango (valores inválidos):

| Inconsistencia | Cantidad | Detección |
|---|---|---|
| Órdenes sin pago asociado | 37,384 | LEFT JOIN `orders` → `payments` |
| Órdenes sin items | 5,934 | LEFT JOIN `orders` → `order_items` |
| Órdenes con `order_total` ≤ 0 | 5,934 | WHERE `order_total <= 0` |
| Pagos con `amount` ≤ 0 | 6,911 | WHERE `amount <= 0` |
| Clientes con `segment` inválido (`online_only`, `vip`) | 4,471 | WHERE `segment NOT IN (...)` |
| Órdenes con `current_status = 'paid'` (estado que no corresponde al dominio de `orders`) | — | WHERE `current_status NOT IN (...)` |

No se detectaron relaciones rotas entre `payments`/`orders`, `order_items`/`products`, `order_audit`/`orders` ni `order_status_history`/`orders` — las FK garantizaron esa integridad desde la carga.

---

## Seguridad — SQL Injection

El proyecto no expone una interfaz de usuario, por lo que no hay vector de ataque directo. De todas formas, toda interacción programática con la base (`import_data.py`) usa consultas parametrizadas a través de SQLAlchemy/psycopg2, evitando la concatenación directa de strings en SQL — la causa raíz de la vulnerabilidad de SQL Injection.

---

## Autor

**Fede Alarcón Scura** — Estudiante de Penguin Academy
Challenge desarrollado como parte del programa de formación.