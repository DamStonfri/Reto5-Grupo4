from flask import Flask, render_template, request, redirect, url_for, session, flash
import mysql.connector
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import os
from datetime import datetime
import requests
import json
from dotenv import load_dotenv
load_dotenv()

app = Flask(__name__)
app.secret_key = "YUJUUUU0"

UPLOAD_FOLDER = "static/uploads"
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "gif", "webp"}
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER


# conexion bdd etc

# hecho por aimar

def conectar():
    """Devuelve una conexion a la base de datos."""
    return mysql.connector.connect(
        user="aimar",
        password="1234ai",
        database="recetas_app"
    )

def extension_permitida(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS

# hecho por aimar
# guarda la imagen en static
def guardar_imagen(imagen):
    """Guarda la imagen subida en uploads/ y devuelve el nombre unico del archivo."""
    if not imagen or imagen.filename == "":
        return None
    if not extension_permitida(imagen.filename):
        return None
    os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)
    nombre_unico = datetime.now().strftime("%Y%m%d%H%M%S_") + secure_filename(imagen.filename)
    imagen.save(os.path.join(app.config["UPLOAD_FOLDER"], nombre_unico))
    return nombre_unico

def login_requerido():
    """Redirige al login si el usuario no esta en sesion. Devuelve None si esta autenticado."""
    if "usuario_id" not in session:
        return redirect(url_for("login"))
    return None
# aqui se ayudo de ia ya que no conseguiamos su funcionamiento
def insertar_ingredientes_y_pasos(cursor, receta_id):
    """Inserta ingredientes y pasos desde el formulario para una receta dada."""
    for nombre, cantidad, categoria in zip(
        request.form.getlist("ingrediente_nombre[]"),
        request.form.getlist("ingrediente_cantidad[]"),
        request.form.getlist("ingrediente_categoria[]")
    # fin ayuda
    ):
        if nombre:
            cursor.execute(
                "INSERT INTO ingredientes (receta_id, nombre, cantidad, categoria) VALUES (%s, %s, %s, %s)",
                (receta_id, nombre, cantidad, categoria))
    for i, desc in enumerate(request.form.getlist("paso_descripcion[]")):
        if desc:
            cursor.execute(
                "INSERT INTO pasos (receta_id, numero_paso, descripcion) VALUES (%s, %s, %s)",
                (receta_id, i + 1, desc))


#  Autenticacion (login/registro/logout) 
# hecho por aimar

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        cnx = conectar()
        cursor = cnx.cursor(dictionary=True)
        cursor.execute("SELECT * FROM usuarios WHERE email = %s", (request.form["email"],))
        usuario = cursor.fetchone()
        cursor.close()
        cnx.close()
        if usuario and check_password_hash(usuario["password_hash"], request.form["password"]):
            session["usuario_id"]     = usuario["id"]
            session["usuario_nombre"] = usuario["nombre"]
            session["usuario_rol"]    = usuario["rol"]
            return redirect(url_for("index"))
        flash("Email o contraseña incorrectos")
    return render_template("login.html")


@app.route("/registro", methods=["GET", "POST"])
def registro():
    if request.method == "POST":
        cnx = conectar()
        cursor = cnx.cursor()
        cursor.execute(
            "INSERT INTO usuarios (nombre, email, password_hash, rol) VALUES (%s, %s, %s, %s)",
            (request.form["nombre"], request.form["email"],
             generate_password_hash(request.form["password"]), "usuario"))
        cnx.commit()
        cursor.close()
        cnx.close()
        flash("Usuario creado correctamente. Ahora inicia sesion.", "success")
        return redirect(url_for("login"))
    return render_template("registro.html")


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))

#  Paginas estaticas 
    # hecho por aimar, alex y andoni

@app.route("/quienes-somos")
def quienes_somos():
    return render_template("quienes_somos.html")

@app.route("/contacto")
def contacto():
    return render_template("contacto.html")

@app.route("/videos")
def videos():
    return render_template("videos.html")


#  Inicio 
# hecho por aimar

@app.route("/")
def index():
    redir = login_requerido()
    if redir: return redir
    cnx = conectar()
    cursor = cnx.cursor(dictionary=True)
    cursor.execute("""
        SELECT r.id, r.titulo, r.descripcion, r.creada_en, r.imagen, u.nombre AS autor
        FROM recetas r
        JOIN usuarios u ON r.usuario_id = u.id
        ORDER BY r.creada_en DESC
        LIMIT 9
    """)
    recetas = cursor.fetchall()
    cursor.close()
    cnx.close()
    return render_template("index.html", recetas=recetas)


#  Recetas (tuvimos algun probema de funcionamiento y nos ayudamos de IA para solucionarlo(abajo digo donde))
# hecho por aimar

@app.route("/recetas")
def recetas():
    redir = login_requerido()
    if redir: return redir
    filtro = request.args.get("categoria", "todas")
    buscar = request.args.get("buscar", "")
    cnx = conectar()
    cursor = cnx.cursor(dictionary=True)
    if filtro == "vegana":
        cursor.execute("""
            SELECT r.id, r.titulo, r.descripcion, r.usuario_id, r.imagen, u.nombre AS autor, r.creada_en
            FROM recetas r JOIN usuarios u ON r.usuario_id = u.id
            WHERE r.id IN (SELECT receta_id FROM ingredientes WHERE categoria = 'vegetal')
                AND r.id NOT IN (SELECT receta_id FROM ingredientes WHERE categoria IN ('proteina', 'carbohidrato'))
            ORDER BY r.creada_en DESC
        """)
    elif filtro == "fitness":
        cursor.execute("""
            SELECT r.id, r.titulo, r.descripcion, r.usuario_id, r.imagen, u.nombre AS autor, r.creada_en
            FROM recetas r JOIN usuarios u ON r.usuario_id = u.id
            WHERE r.id IN (SELECT receta_id FROM ingredientes WHERE categoria = 'proteina')
                AND r.id IN (SELECT receta_id FROM ingredientes WHERE categoria = 'vegetal')
            ORDER BY r.creada_en DESC
        """)
    elif buscar:
        cursor.execute("""
            SELECT r.id, r.titulo, r.descripcion, r.usuario_id, r.imagen, u.nombre AS autor
            FROM recetas r JOIN usuarios u ON r.usuario_id = u.id
            WHERE r.titulo LIKE %s
            ORDER BY r.creada_en DESC
        """, (f"%{buscar}%",))
    else:
        cursor.execute("""
            SELECT r.id, r.titulo, r.descripcion, r.usuario_id, r.imagen, u.nombre AS autor
            FROM recetas r JOIN usuarios u ON r.usuario_id = u.id
            ORDER BY r.creada_en DESC
        """)
    lista_recetas = cursor.fetchall()
    cursor.close()
    cnx.close()
    return render_template("recetas.html", recetas=lista_recetas, filtro_activo=filtro)


@app.route("/recetas/nueva", methods=["GET", "POST"])
def nueva_receta():
    redir = login_requerido()
    if redir: return redir
    if request.method == "POST":
        db = conectar()
        cursor = db.cursor()
        cursor.execute(
            "INSERT INTO recetas (titulo, descripcion, usuario_id, imagen) VALUES (%s, %s, %s, %s)",
            (request.form["titulo"], request.form["descripcion"],
             session["usuario_id"], guardar_imagen(request.files.get("imagen"))))
        receta_id = cursor.lastrowid
# aqui se ayudo de ia ya que no conseguiamos su funcionamiento
        insertar_ingredientes_y_pasos(cursor, receta_id)
# fin ayuda
        db.commit()
        cursor.close()
        db.close()
        flash("Receta publicada con exito", "success")
        return redirect(url_for("recetas"))
    return render_template("crear_receta.html")

# hecho por aimar
@app.route("/receta/<int:id>")
def detalle_receta(id):
    db = conectar()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT r.*, u.nombre AS autor, u.id AS autor_id
        FROM recetas r JOIN usuarios u ON r.usuario_id = u.id
        WHERE r.id = %s
    """, (id,))
    receta = cursor.fetchone()
    cursor.execute("SELECT * FROM ingredientes WHERE receta_id = %s", (id,))
    ingredientes = cursor.fetchall()
    cursor.execute("SELECT * FROM pasos WHERE receta_id = %s ORDER BY numero_paso", (id,))
    pasos = cursor.fetchall()
    cursor.execute("""
        SELECT c.*, u.nombre FROM comentarios c
        JOIN usuarios u ON c.usuario_id = u.id
        WHERE receta_id = %s ORDER BY creado_en DESC
    """, (id,))
    comentarios = cursor.fetchall()
# ayudado ia (nos daba error por cosas mal puestas)
    cursor2 = db.cursor()
    cursor2.callproc("obtener_totales_usuario_y_receta", [receta["usuario_id"], id, 0, 0])
    for _ in cursor2.stored_results():
        pass
    cursor2.execute(
        "SELECT contar_recetas_usuario(%s), contar_comentarios_receta(%s)",
        (receta["usuario_id"], id))
    totales = cursor2.fetchone()
    cursor.close()
    cursor2.close()
    db.close()
# fin ayuda ia
    return render_template(
        "detalle_receta.html",
        receta=receta, ingredientes=ingredientes, pasos=pasos,
        comentarios=comentarios,
        total_recetas_autor=totales[0], total_comentarios=totales[1]
    )

# hecho por aimar

@app.route("/recetas/editar/<int:receta_id>", methods=["GET", "POST"])
def editar_receta(receta_id):
    redir = login_requerido()
    if redir: return redir
    cnx = conectar()
    cursor = cnx.cursor(dictionary=True)
    cursor.execute("SELECT * FROM recetas WHERE id = %s", (receta_id,))
    receta = cursor.fetchone()
    if not receta or (receta["usuario_id"] != session["usuario_id"] and session.get("usuario_rol") != "admin"):
        flash("No tienes permiso para editar esta receta.")
        cursor.close()
        cnx.close()
        return redirect(url_for("recetas"))
    if request.method == "POST":
        nombre_imagen = guardar_imagen(request.files.get("imagen"))
        campos = ["titulo=%s", "descripcion=%s"]
        valores = [request.form["titulo"], request.form["descripcion"]]
        if nombre_imagen:
            campos.append("imagen=%s")
            valores.append(nombre_imagen)
        valores.append(receta_id)
        cursor.execute(f"UPDATE recetas SET {', '.join(campos)} WHERE id=%s", valores)
        cursor.execute("DELETE FROM ingredientes WHERE receta_id = %s", (receta_id,))
        cursor.execute("DELETE FROM pasos WHERE receta_id = %s", (receta_id,))
        # ayudado con ia aqui tambien(no nos funcionaba)
        insertar_ingredientes_y_pasos(cursor, receta_id)
        cnx.commit()
        cursor.close()
        cnx.close()
        flash("Receta actualizada correctamente.")
        return redirect(url_for("recetas"))
    cursor.execute("SELECT * FROM ingredientes WHERE receta_id = %s", (receta_id,))
    ingredientes = cursor.fetchall()
    cursor.execute("SELECT * FROM pasos WHERE receta_id = %s ORDER BY numero_paso", (receta_id,))
    pasos = cursor.fetchall()
    cursor.close()
    cnx.close()
    return render_template("editar_receta.html", receta=receta, ingredientes=ingredientes, pasos=pasos)

# hecho por aimar

@app.route("/recetas/eliminar/<int:receta_id>", methods=["POST"])
def eliminar_receta(receta_id):
    redir = login_requerido()
    if redir: return redir
    cnx = conectar()
    cursor = cnx.cursor(dictionary=True)
    cursor.execute("SELECT usuario_id FROM recetas WHERE id = %s", (receta_id,))
    receta = cursor.fetchone()
    if not receta or (receta["usuario_id"] != session["usuario_id"] and session.get("usuario_rol") != "admin"):
        flash("No tienes permiso para eliminar esta receta.")
        cursor.close()
        cnx.close()
        return redirect(url_for("recetas"))
    cursor.execute("DELETE FROM recetas WHERE id = %s", (receta_id,))
    cnx.commit()
    cursor.close()
    cnx.close()
    flash("Receta eliminada correctamente.")
    return redirect(url_for("recetas"))

#  Comentarios 

# hecho por aimar

@app.route("/comentar/<int:receta_id>", methods=["POST"])
def añadir_comentario(receta_id):
    redir = login_requerido()
    if redir: return redir
    db = conectar()
    cursor = db.cursor()
    cursor.execute(
        "INSERT INTO comentarios (receta_id, usuario_id, contenido) VALUES (%s, %s, %s)",
        (receta_id, session["usuario_id"], request.form["contenido"]))
    db.commit()
    cursor.close()
    db.close()
    return redirect(url_for("detalle_receta", id=receta_id))

# hecho por aimar

@app.route("/comentario/eliminar/<int:comentario_id>/<int:receta_id>", methods=["POST"])
def eliminar_comentario(comentario_id, receta_id):
    redir = login_requerido()
    if redir: return redir
    db = conectar()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT usuario_id FROM comentarios WHERE id = %s", (comentario_id,))
    comentario = cursor.fetchone()
    if not comentario or (
        comentario["usuario_id"] != session["usuario_id"]
        and session.get("usuario_rol") != "admin"
    ):
        flash("No tienes permiso para eliminar este comentario.", "error")
        cursor.close()
        db.close()
        return redirect(url_for("detalle_receta", id=receta_id))
    cursor.execute("DELETE FROM comentarios WHERE id = %s", (comentario_id,))
    db.commit()
    cursor.close()
    db.close()
    flash("Comentario eliminado correctamente.", "success")
    return redirect(url_for("detalle_receta", id=receta_id))

#  Menus 

# hecho por aimar

@app.route("/menus")
def menus():
    redir = login_requerido()
    if redir: return redir
    db = conectar()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT m.*, u.nombre AS autor
        FROM menus m JOIN usuarios u ON m.usuario_id = u.id
        ORDER BY m.id DESC
    """)
    lista_menus = cursor.fetchall()
    for menu in lista_menus:
        cursor.execute("""
            SELECT r.id, r.titulo, r.descripcion, r.imagen, u.nombre AS autor
            FROM recetas r
            JOIN menu_recetas mr ON r.id = mr.receta_id
            JOIN usuarios u ON r.usuario_id = u.id
            WHERE mr.menu_id = %s
        """, (menu["id"],))
        menu["recetas"] = cursor.fetchall()
    cursor.close()
    db.close()
    return render_template("menus.html", menus=lista_menus)

# hecho por aimar

@app.route("/menus/nuevo", methods=["GET", "POST"])
def nuevo_menu():
    redir = login_requerido()
    if redir: return redir
    if session.get("usuario_rol") != "admin":
        flash("No tienes permiso para crear menus.", "error")
        return redirect(url_for("menus"))
    db = conectar()
    cursor = db.cursor(dictionary=True)
    if request.method == "POST":
        cursor.execute(
            "INSERT INTO menus (nombre, dia_semana, usuario_id) VALUES (%s, %s, %s)",
            (request.form["nombre"], request.form["dia_semana"], session["usuario_id"]))
        menu_id = cursor.lastrowid
        for receta_id in request.form.getlist("recetas[]"):
            cursor.execute(
                "INSERT INTO menu_recetas (menu_id, receta_id) VALUES (%s, %s)",
                (menu_id, receta_id))
        db.commit()
        cursor.close()
        db.close()
        flash("Menu creado correctamente.", "success")
        return redirect(url_for("menus"))
    cursor.execute("""
        SELECT r.id, r.titulo, r.imagen, u.nombre AS autor
        FROM recetas r JOIN usuarios u ON r.usuario_id = u.id
        ORDER BY r.creada_en DESC
    """)
    recetas = cursor.fetchall()
    cursor.close()
    db.close()
    return render_template("nuevo_menu.html", recetas=recetas)

# hecho por aimar

@app.route("/menus/eliminar/<int:menu_id>", methods=["POST"])
def eliminar_menu(menu_id):
    redir = login_requerido()
    if redir: return redir
    if session.get("usuario_rol") != "admin":
        flash("No tienes permiso para eliminar menus.", "error")
        return redirect(url_for("menus"))
    db = conectar()
    cursor = db.cursor()
    cursor.execute("DELETE FROM menu_recetas WHERE menu_id = %s", (menu_id,))
    cursor.execute("DELETE FROM menus WHERE id = %s", (menu_id,))
    db.commit()
    cursor.close()
    db.close()
    flash("Menu eliminado correctamente.", "success")
    return redirect(url_for("menus"))


#  Calculadora de dieta IA 

# hecho por alex

@app.route("/dieta")
def dieta():
    redir = login_requerido()
    if redir: return redir
    return render_template("dieta.html")


@app.route("/api/calcular-dieta", methods=["POST"])
def calcular_dieta():
    redir = login_requerido()
    if redir: return ("No autorizado", 401)

    datos = request.get_json()
    restricciones = datos.get("restricciones", [])
    restricciones_texto = ", ".join(restricciones) if restricciones else "ninguna"

    mensaje = f"""Genera un plan nutricional personalizado para:
- Edad: {datos.get('edad')} años, Sexo: {datos.get('sexo')}
- Peso: {datos.get('peso')} kg, Altura: {datos.get('altura')} cm
- Actividad: {datos.get('actividad')}, Objetivo: {datos.get('objetivo')}
- Restricciones: {restricciones_texto}

Responde ÚNICAMENTE con JSON válido, sin texto extra ni markdown:
{{
  "calorias": 2000,
  "proteinas": 150,
  "carbohidratos": 200,
  "grasas": 70,
  "resumen": "descripción breve del plan",
  "comidas": [
    {{"nombre": "Desayuno", "items": ["alimento con cantidad", "alimento con cantidad"]}},
    {{"nombre": "Almuerzo", "items": ["alimento con cantidad", "alimento con cantidad"]}},
    {{"nombre": "Merienda", "items": ["alimento con cantidad"]}},
    {{"nombre": "Cena", "items": ["alimento con cantidad", "alimento con cantidad"]}}
  ],
  "consejo": "consejo práctico"
}}"""

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {os.environ.get('HF_TOKEN', '')}"
    }
    payload = {
        "model": "Qwen/Qwen2.5-72B-Instruct",
        "messages": [
            {"role": "system", "content": "Eres un nutricionista experto. Responde solo con JSON válido, sin texto extra ni markdown."},
            {"role": "user",   "content": mensaje}
        ],
        "max_tokens": 800,
        "temperature": 0.3
    }

    try:
        response = requests.post(
            "https://router.huggingface.co/v1/chat/completions",
            headers=headers, json=payload, timeout=60
        )
        response.raise_for_status()
        texto = response.json()["choices"][0]["message"]["content"]
        texto = texto.replace("```json", "").replace("```", "").strip()
        inicio = texto.find("{")
        fin    = texto.rfind("}") + 1
        if inicio == -1 or fin == 0:
            raise ValueError("No se encontró JSON en la respuesta")
        plan = json.loads(texto[inicio:fin])
        return json.dumps(plan), 200, {"Content-Type": "application/json"}
    except Exception as e:
        print(f"Error HuggingFace: {e}")
        return json.dumps({"error": str(e)}), 500, {"Content-Type": "application/json"}


#  Perfil 

# hecho por andoni

@app.route("/perfil")
def perfil():
    redir = login_requerido()
    if redir: return redir
    cnx = conectar()
    cursor = cnx.cursor(dictionary=True)
    cursor.execute("""
        SELECT * FROM recetas 
        WHERE usuario_id = %s 
        ORDER BY creada_en DESC
    """, (session["usuario_id"],))
    mis_recetas = cursor.fetchall()
    cursor.close()
    cnx.close()
    return render_template("perfil.html", recetas=mis_recetas)

 # hecho por andoni

@app.route("/perfil/editar", methods=["GET", "POST"])
def editar_perfil():
    redir = login_requerido()
    if redir: return redir
    cnx = conectar()
    cursor = cnx.cursor(dictionary=True)
    if request.method == "POST":
        cursor.execute(
            "UPDATE usuarios SET nombre=%s, email=%s WHERE id=%s",
            (request.form["nombre"], request.form["email"], session["usuario_id"]))
        cnx.commit()
        session["usuario_nombre"] = request.form["nombre"]
        flash("Perfil actualizado correctamente.", "success")
        cursor.close()
        cnx.close()
        return redirect(url_for("perfil"))
    cursor.execute("SELECT * FROM usuarios WHERE id = %s", (session["usuario_id"],))
    usuario = cursor.fetchone()
    cursor.close()
    cnx.close()
    return render_template("editar_perfil.html", usuario=usuario)


if __name__ == "__main__":
    app.run(debug=True)
