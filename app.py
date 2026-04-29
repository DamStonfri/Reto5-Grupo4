from flask import Flask, render_template, request, redirect, url_for, session, flash
import mysql.connector
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import os
from datetime import datetime

app = Flask(__name__)
app.secret_key = "clave_secreta_cambiala"

UPLOAD_FOLDER = "static/uploads"
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "gif", "webp"}


def conectar():
    return mysql.connector.connect(
        user="aimar",
        password="1234ai",
        database="recetas_app"
    )


def extension_permitida(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


def guardar_imagen(imagen):
    print("ARCHIVO RECIBIDO:", imagen)
    print("NOMBRE ARCHIVO:", imagen.filename if imagen else "No llegó imagen")

    if imagen and imagen.filename != "":
        if not extension_permitida(imagen.filename):
            print("EXTENSIÓN NO PERMITIDA")
            return None

        os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)

        filename = secure_filename(imagen.filename)
        nombre_unico = datetime.now().strftime("%Y%m%d%H%M%S_") + filename
        ruta = os.path.join(app.config["UPLOAD_FOLDER"], nombre_unico)

        print("GUARDANDO EN:", ruta)

        imagen.save(ruta)

        print("IMAGEN GUARDADA:", nombre_unico)

        return nombre_unico

    print("NO SE GUARDÓ IMAGEN")
    return None


@app.route("/")
def index():
    if "usuario_id" not in session:
        return redirect(url_for("login"))

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

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        email = request.form["email"]
        password = request.form["password"]

        cnx = conectar()
        cursor = cnx.cursor(dictionary=True)

        cursor.execute("SELECT * FROM usuarios WHERE email = %s", (email,))
        usuario = cursor.fetchone()

        cursor.close()
        cnx.close()

        if usuario and check_password_hash(usuario["password_hash"], password):
            session["usuario_id"] = usuario["id"]
            session["usuario_nombre"] = usuario["nombre"]
            session["usuario_rol"] = usuario["rol"]
            return redirect(url_for("index"))
        else:
            flash("Email o contraseña incorrectos")

    return render_template("login.html")


@app.route("/registro", methods=["GET", "POST"])
def registro():
    if request.method == "POST":
        nombre = request.form["nombre"]
        email = request.form["email"]
        password = request.form["password"]

        password_hash = generate_password_hash(password)

        cnx = conectar()
        cursor = cnx.cursor()

        cursor.execute(
            "INSERT INTO usuarios (nombre, email, password_hash, rol) VALUES (%s, %s, %s, %s)",
            (nombre, email, password_hash, "usuario")
        )

        cnx.commit()
        cursor.close()
        cnx.close()

        flash("Usuario creado correctamente. Ahora inicia sesión.", "success")
        return redirect(url_for("login"))

    return render_template("registro.html")


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))


@app.route("/usuarios")
def usuarios():
    if "usuario_id" not in session:
        return redirect(url_for("login"))
    return render_template("usuarios.html")


@app.route("/recetas/nueva", methods=["GET", "POST"])
def nueva_receta():
    if "usuario_id" not in session:
        return redirect(url_for("login"))

    if request.method == "POST":
        titulo = request.form["titulo"]
        descripcion = request.form["descripcion"]
        usuario_id = session["usuario_id"]

        imagen = request.files.get("imagen")
        nombre_imagen = guardar_imagen(imagen)

        ingredientes_nombres = request.form.getlist("ingrediente_nombre[]")
        ingredientes_cantidades = request.form.getlist("ingrediente_cantidad[]")
        pasos_descripciones = request.form.getlist("paso_descripcion[]")

        db = conectar()
        cursor = db.cursor()

        cursor.execute("""
            INSERT INTO recetas (titulo, descripcion, usuario_id, imagen)
            VALUES (%s, %s, %s, %s)
        """, (titulo, descripcion, usuario_id, nombre_imagen))

        receta_id = cursor.lastrowid

        for nombre, cantidad in zip(ingredientes_nombres, ingredientes_cantidades):
            if nombre:
                cursor.execute(
                    "INSERT INTO ingredientes (receta_id, nombre, cantidad) VALUES (%s, %s, %s)",
                    (receta_id, nombre, cantidad)
                )

        for i, desc in enumerate(pasos_descripciones):
            if desc:
                cursor.execute(
                    "INSERT INTO pasos (receta_id, numero_paso, descripcion) VALUES (%s, %s, %s)",
                    (receta_id, i + 1, desc)
                )

        db.commit()
        cursor.close()
        db.close()

        flash("Receta publicada con éxito", "success")
        return redirect(url_for("recetas"))

    return render_template("crear_receta.html")


@app.route("/receta/<int:id>")
def detalle_receta(id):
    db = conectar()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT r.*, u.nombre AS autor
        FROM recetas r
        JOIN usuarios u ON r.usuario_id = u.id
        WHERE r.id = %s
    """, (id,))
    receta = cursor.fetchone()

    cursor.execute("SELECT * FROM ingredientes WHERE receta_id = %s", (id,))
    ingredientes = cursor.fetchall()

    cursor.execute("SELECT * FROM pasos WHERE receta_id = %s ORDER BY numero_paso", (id,))
    pasos = cursor.fetchall()

    cursor.execute("""
        SELECT c.*, u.nombre
        FROM comentarios c
        JOIN usuarios u ON c.usuario_id = u.id
        WHERE receta_id = %s
        ORDER BY creado_en DESC
    """, (id,))
    comentarios = cursor.fetchall()

    cursor.close()
    db.close()

    return render_template(
        "detalle_receta.html",
        receta=receta,
        ingredientes=ingredientes,
        pasos=pasos,
        comentarios=comentarios
    )


@app.route("/receta/borrar/<int:id>", methods=["POST"])
def borrar_receta(id):
    db = conectar()
    cursor = db.cursor(dictionary=True)

    cursor.execute("SELECT usuario_id FROM recetas WHERE id = %s", (id,))
    receta = cursor.fetchone()

    if receta and receta["usuario_id"] == session.get("usuario_id"):
        cursor.execute("DELETE FROM recetas WHERE id = %s", (id,))
        db.commit()
        flash("Receta eliminada", "success")
    else:
        flash("No tienes permiso para borrar esta receta", "error")

    cursor.close()
    db.close()
    return redirect(url_for("recetas"))


@app.route("/comentar/<int:receta_id>", methods=["POST"])
def añadir_comentario(receta_id):
    if "usuario_id" not in session:
        return redirect(url_for("login"))

    contenido = request.form["contenido"]
    usuario_id = session["usuario_id"]

    db = conectar()
    cursor = db.cursor()
    cursor.execute(
        "INSERT INTO comentarios (receta_id, usuario_id, contenido) VALUES (%s, %s, %s)",
        (receta_id, usuario_id, contenido)
    )
    db.commit()
    cursor.close()
    db.close()

    return redirect(url_for("detalle_receta", id=receta_id))

@app.route("/comentario/eliminar/<int:comentario_id>/<int:receta_id>", methods=["POST"])
def eliminar_comentario(comentario_id, receta_id):
    if "usuario_id" not in session:
        return redirect(url_for("login"))

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

@app.route("/quienes-somos")
def quienes_somos():
    return render_template("quienes_somos.html")


@app.route("/contacto")
def contacto():
    return render_template("contacto.html")


@app.route("/videos")
def videos():
    return render_template("videos.html")


@app.route("/recetas")
def recetas():
    if "usuario_id" not in session:
        return redirect(url_for("login"))

    cnx = conectar()
    cursor = cnx.cursor(dictionary=True)
    cursor.execute("""
        SELECT r.id, r.titulo, r.descripcion, r.usuario_id, r.imagen, u.nombre AS autor
        FROM recetas r
        JOIN usuarios u ON r.usuario_id = u.id
        ORDER BY r.creada_en DESC
    """)
    lista_recetas = cursor.fetchall()

    cursor.close()
    cnx.close()

    return render_template("recetas.html", recetas=lista_recetas)


@app.route("/recetas/eliminar/<int:receta_id>", methods=["POST"])
def eliminar_receta(receta_id):
    if "usuario_id" not in session:
        return redirect(url_for("login"))

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


@app.route("/recetas/editar/<int:receta_id>", methods=["GET", "POST"])
def editar_receta(receta_id):
    if "usuario_id" not in session:
        return redirect(url_for("login"))

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
        titulo = request.form["titulo"]
        descripcion = request.form["descripcion"]

        imagen = request.files.get("imagen")
        nombre_imagen = guardar_imagen(imagen)

        if nombre_imagen:
            cursor.execute("""
                UPDATE recetas
                SET titulo = %s, descripcion = %s, imagen = %s
                WHERE id = %s
            """, (titulo, descripcion, nombre_imagen, receta_id))
        else:
            cursor.execute("""
                UPDATE recetas
                SET titulo = %s, descripcion = %s
                WHERE id = %s
            """, (titulo, descripcion, receta_id))

        ingredientes_nombres = request.form.getlist("ingrediente_nombre[]")
        ingredientes_cantidades = request.form.getlist("ingrediente_cantidad[]")
        pasos_descripciones = request.form.getlist("paso_descripcion[]")

        cursor.execute("DELETE FROM ingredientes WHERE receta_id = %s", (receta_id,))
        cursor.execute("DELETE FROM pasos WHERE receta_id = %s", (receta_id,))

        for nombre, cantidad in zip(ingredientes_nombres, ingredientes_cantidades):
            if nombre:
                cursor.execute(
                    "INSERT INTO ingredientes (receta_id, nombre, cantidad) VALUES (%s, %s, %s)",
                    (receta_id, nombre, cantidad)
                )

        for i, desc in enumerate(pasos_descripciones):
            if desc:
                cursor.execute(
                    "INSERT INTO pasos (receta_id, numero_paso, descripcion) VALUES (%s, %s, %s)",
                    (receta_id, i + 1, desc)
                )

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

    return render_template(
        "editar_receta.html",
        receta=receta,
        ingredientes=ingredientes,
        pasos=pasos
    )


@app.route("/menus")
def menus():
    if "usuario_id" not in session:
        return redirect(url_for("login"))

    db = conectar()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT m.*, u.nombre AS autor
        FROM menus m
        JOIN usuarios u ON m.usuario_id = u.id
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


@app.route("/menus/nuevo", methods=["GET", "POST"])
def nuevo_menu():
    if "usuario_id" not in session:
        return redirect(url_for("login"))

    if session.get("usuario_rol") != "admin":
        flash("No tienes permiso para crear menús.", "error")
        return redirect(url_for("menus"))

    db = conectar()
    cursor = db.cursor(dictionary=True)

    if request.method == "POST":
        nombre = request.form["nombre"]
        dia_semana = request.form["dia_semana"]
        usuario_id = session["usuario_id"]
        recetas_ids = request.form.getlist("recetas[]")

        cursor.execute("""
            INSERT INTO menus (nombre, dia_semana, usuario_id)
            VALUES (%s, %s, %s)
        """, (nombre, dia_semana, usuario_id))

        menu_id = cursor.lastrowid

        for receta_id in recetas_ids:
            cursor.execute("""
                INSERT INTO menu_recetas (menu_id, receta_id)
                VALUES (%s, %s)
            """, (menu_id, receta_id))

        db.commit()
        cursor.close()
        db.close()

        flash("Menú creado correctamente.", "success")
        return redirect(url_for("menus"))

    cursor.execute("""
        SELECT r.id, r.titulo, r.imagen, u.nombre AS autor
        FROM recetas r
        JOIN usuarios u ON r.usuario_id = u.id
        ORDER BY r.creada_en DESC
    """)
    recetas = cursor.fetchall()

    cursor.close()
    db.close()

    return render_template("nuevo_menu.html", recetas=recetas)


@app.route("/menus/eliminar/<int:menu_id>", methods=["POST"])
def eliminar_menu(menu_id):
    if "usuario_id" not in session:
        return redirect(url_for("login"))

    if session.get("usuario_rol") != "admin":
        flash("No tienes permiso para eliminar menús.", "error")
        return redirect(url_for("menus"))

    db = conectar()
    cursor = db.cursor()

    cursor.execute("DELETE FROM menu_recetas WHERE menu_id = %s", (menu_id,))
    cursor.execute("DELETE FROM menus WHERE id = %s", (menu_id,))

    db.commit()
    cursor.close()
    db.close()

    flash("Menú eliminado correctamente.", "success")
    return redirect(url_for("menus"))


if __name__ == "__main__":
    app.run(debug=True)