# Gastrolab 

Esta es nuestra aplicacion web de recetas desarrollada con Flask y MySQL por el **Grupo 4(pantera)**.

---
## ¿Qué es esta aplicación?

**Gastrolab** es una comunidad gastronomica online donde los usuarios pueden publicar, descubrir y comentar recetas de cocina. La plataforma incluye un sistema de autenticacion, gestion de recetas con ingredientes y pasos, menus del dia, videos formativos y una calculadora de dieta personalizada hecha por inteligencia artificial(huggingface).
---

## Funcionalidades principales

- **Registro e inicio de sesion** con contraseñas hasheadas 
- **Publicar recetas** con titulo, descripcion, imagen, ingredientes categorizados y pasos de preparacion
- **Editar y eliminar** las propias recetas (o cualquiera si eres admin)
- **Detalle de receta** con comentarios, contador de recetas del autor y total de comentarios
- **Filtros y busqueda** de recetas: todas, veganas o fitness
- **Menus del dia** — solo los administradores pueden crearlos y eliminarlos
- **Calculadora de dieta IA** — genera un plan nutricional personalizado (calorías, macros y comidas) usando el modelo **Qwen/Qwen2.5-72B-Instruct** de HuggingFace
- **Videos** de recetas españolas desde YouTube
- **Contacto** mediante formulario conectado a Formspree (llega al gmail de Aimar)
- **Perfil de usuario** con edicion de nombre y email
---

##  Estructura del proyecto y y reparto de tareas

```
Reto5-Grupo4/
│
├── app.py                  # Backend Flask (rutas, lógica, conexión a BDD) - [Aimar,Alex,Andoni](en el documento pone las partes de cada uno)
├── BDD_RETO_5_P.sql        # Base de datos MySQL (tablas, triggers, stored procedures, funciones) - [Aimar]
├── Test_app.py             # Prueba de errores del codigo [Alex]
│
├── templates/
│   ├── base.html           # Plantilla base con navbar y footer                        - [Aimar]
│   ├── index.html          # Pagina de inicio (ultimas recetas)                        - [Aimar]
│   ├── login.html          # Inicio de sesion                                          - [Aimar]
│   ├── registro.html       # Registro de usuario                                       - [Aimar]
│   ├── recetas.html        # Listado de recetas con filtros                            - [Aimar y Andoni boton buscar]
│   ├── crear_receta.html   # Formulario para nueva receta                              - [Aimar]
│   ├── editar_receta.html  # Formulario de edicion de receta                           - [Aimar]
│   ├── detalle_receta.html # Vista detallada + comentarios                             - [Aimar]
│   ├── perfil.html         # Perfil del usuario y sus recetas                          - [Andoni]
│   ├── editar_perfil.html  # Edicion de datos del perfil                               - [Andoni]
│   ├── menus.html          # Menus del dia                                             - [Aimar]
│   ├── nuevo_menu.html     # Creacion de un menu (solo admin)                          - [Aimar]
│   ├── dieta.html          # Calculadora de dieta IA                                   - [Alex]
│   ├── videos.html         # Videos de recetas                                         - [Alex]
│   ├── quienes_somos.html  # Pagina informativa + Instagram                            - [Andoni]
│   └── contacto.html       # Formulario de contacto                                    - [Aimar]
│
└── static/
    ├── style.css           # Estilos globales de la aplicacion                         - [Aimar,Alex,Andoni]
    └── uploads/            # Imagenes subidas por los usuarios
```

---

## Cómo funciona (arquitectura)

El proyecto sigue una arquitectura con Flask como app web:

1. El usuario accede a una ruta → Flask ejecuta la funcion correspondiente en **app.py**
2. La función consulta o modifica la base de datos **MySQL** mediante **mysql-connector-python**
3. Flask usa la plantilla HTML correspondiente usando **Jinja2** y devuelve la pagina

La base de datos incluye:
- Tablas: `usuarios`, `recetas`, `ingredientes`, `pasos`, `comentarios`, `menus`, `menu_recetas`
- Un **trigger** (trg_validar_comentario) que valida que los comentarios tengan al menos 3 caracteres
- **Stored procedures** y **funciones** para obtener contadores de recetas y comentarios

Para la **calculadora de dieta**, el backend llama a la API de HuggingFace con el modelo **Qwen/Qwen2.5-72B-Instruct**, que devuelve un JSON con calorias, macronutrientes y un plan de comidas personalizado segun los datos del usuario.

---

## Instalacion y puesta en marcha

### 1. Instalar dependencias

pip install flask mysql-connector-python werkzeug requests python-dotenv

### 2. Configurar las variables de entorno (token)
Crea un fichero `.env` en la raiz del proyecto(viene sin hacer):

HF_TOKEN=tu_token_de_huggingface

### 3. Ajustar la conexion a la BDD
En **app.py**, edita la funcion **conectar()** con tus credenciales MySQL:
python
return mysql.connector.connect(
    user="tu_usuario",
    password="tu_contraseña",
    database="recetas_app"
)


### 4. Ejecutar la aplicacion

python app.py

Accede en el navegador a: http://localhost:5000(copia y pegalo en tu navegador)

---

## Uso de la Inteligencia Artificial en el proyecto

La IA se utilizo en varios puntos del desarrollo, **siempre como apoyo** y no como sustituto del trabajo del equipo:

### 1. Funcionalidad central — Calculadora de dieta (**dieta.html** + **app.py**)
La IA es el producto en este caso. El **/api/calcular-dieta** envia los datos del usuario (edad, peso, altura, actividad, objetivo y restricciones) al modelo **Qwen/Qwen2.5-72B-Instruct** de HuggingFace, que devuelve un plan nutricional completo en formato JSON. El estilo y script de la seccion de dieta tambien se desarrollaron con ayuda de IA, tal como se indica en el comentario del propio codigo.

### 2. Script de clasificacion de ingredientes (**crear_receta.html**, **editar_receta.html**)
El script JavaScript que detecta automaticamente la categoria de un ingrediente (proteina, vegetal, carbohidrato)(una lista) al escribir su nombre, fue desarrollado con ayuda de IA para ahorrar tiempo y no tener que escribir los alimentos manualmente. 

### 3. Resolucion de errores en el backend (**app.py**)
En la funcion **nueva_receta**, la logica de inserciopn de ingredientes y pasos en la BDD no nos funcionaba y al final se resolvio con ayuda de IA 

En la funcion **detalle_receta**, generaba errores por sintaxis incorrecta y tambien se corrigio con ayuda de IA (comentario: *"ayudado ia (nos daba error por cosas mal puestas)"*).

---

## Tecnologías utilizadas

| Tecnología | Uso |
|---|---|
| Python + Flask | Backend y servidor web |
| MySQL | Base de datos relacional |
| Jinja2 | Motor de plantillas HTML |
| HTML5 + CSS | Frontend |
| JavaScript | Interactividad en el cliente |
| Werkzeug | Hash de contraseñas y gestión de archivos |
| HuggingFace API | Modelo de IA para la calculadora de dieta |
| Formspree | Envío del formulario de contacto |

---

Aimar, Alex y Andoni*
