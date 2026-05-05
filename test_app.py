import pytest
from unittest.mock import patch, MagicMock
from app import app, extension_permitida, guardar_imagen
import json


@pytest.fixture
def client():
    app.config["TESTING"] = True
    app.config["SECRET_KEY"] = "test"
    with app.test_client() as client:
        yield client

def sesion_usuario(client, rol="usuario"):
    with client.session_transaction() as sess:
        sess["usuario_id"] = 1
        sess["usuario_nombre"] = "Test"
        sess["usuario_rol"] = rol


# ---- Cuando pones tu email y contraseña en el login, comprueba que la app busca ese email en la base de datos. ----

@patch("app.conectar")
def test_sql_login_select_usuario(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_cursor.fetchone.return_value = None
    mock_conectar.return_value.cursor.return_value = mock_cursor

    client.post("/login", data={"email": "a@a.com", "password": "1234"})

    sql = mock_cursor.execute.call_args[0][0]
    assert "SELECT" in sql
    assert "usuarios" in sql
    assert "email" in sql


# ---- Cuando te registras, comprueba que tus datos se guardan en la base de datos. ----

@patch("app.conectar")
def test_sql_registro_insert_usuario(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_conectar.return_value.cursor.return_value = mock_cursor

    client.post("/registro", data={
        "nombre": "Ana",
        "email": "ana@test.com",
        "password": "1234"
    })

    sql = mock_cursor.execute.call_args[0][0]
    assert "INSERT" in sql
    assert "usuarios" in sql


# ---- Cuando entras a la página de inicio, comprueba que se cargan las recetas junto con el nombre de su autor. ----

@patch("app.conectar")
def test_sql_index_select_recetas(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = []
    mock_conectar.return_value.cursor.return_value = mock_cursor
    sesion_usuario(client)

    client.get("/")

    sql = mock_cursor.execute.call_args[0][0]
    assert "SELECT" in sql
    assert "recetas" in sql
    assert "usuarios" in sql


# ---- Cuando entras a /recetas sin filtrar, comprueba que se traen todas las recetas. ----

@patch("app.conectar")
def test_sql_recetas_select_todas(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = []
    mock_conectar.return_value.cursor.return_value = mock_cursor
    sesion_usuario(client)

    client.get("/recetas?categoria=todas")

    sql = mock_cursor.execute.call_args[0][0]
    assert "SELECT" in sql
    assert "recetas" in sql


# ---- Cuando buscas una receta por nombre, comprueba que la búsqueda filtra por el título correctamente. ----

@patch("app.conectar")
def test_sql_recetas_busqueda(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = []
    mock_conectar.return_value.cursor.return_value = mock_cursor
    sesion_usuario(client)

    client.get("/recetas?buscar=tortilla")

    sql = mock_cursor.execute.call_args[0][0]
    assert "LIKE" in sql
    assert "titulo" in sql


# ---- Cuando filtras por "vegana", comprueba que solo se buscan recetas con ingredientes de categoría vegetal. ----

@patch("app.conectar")
def test_sql_recetas_filtro_vegana(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = []
    mock_conectar.return_value.cursor.return_value = mock_cursor
    sesion_usuario(client)

    client.get("/recetas?categoria=vegana")

    sql = mock_cursor.execute.call_args[0][0]
    assert "vegetal" in sql


# ---- Cuando filtras por fitness, comprueba que solo se buscan recetas con ingredientes de categoría proteína. ----

@patch("app.conectar")
def test_sql_recetas_filtro_fitness(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = []
    mock_conectar.return_value.cursor.return_value = mock_cursor
    sesion_usuario(client)

    client.get("/recetas?categoria=fitness")

    sql = mock_cursor.execute.call_args[0][0]
    assert "proteina" in sql


# ---- Cuando creas una receta, comprueba que se guardan en la base de datos la receta, sus ingredientes y sus pasos. ----

@patch("app.conectar")
def test_sql_nueva_receta_insert(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_cursor.lastrowid = 99
    mock_conectar.return_value.cursor.return_value = mock_cursor
    sesion_usuario(client)

    client.post("/recetas/nueva", data={
        "titulo": "Tortilla",
        "descripcion": "Rica tortilla",
        "ingrediente_nombre[]": ["Huevo"],
        "ingrediente_cantidad[]": ["3"],
        "ingrediente_categoria[]": ["proteina"],
        "paso_descripcion[]": ["Batir huevos"]
    })

    calls = [str(c) for c in mock_cursor.execute.call_args_list]
    assert any("INSERT" in c and "recetas" in c for c in calls)
    assert any("INSERT" in c and "ingredientes" in c for c in calls)
    assert any("INSERT" in c and "pasos" in c for c in calls)


# ---- Cuando abres una receta, comprueba que se cargan sus ingredientes, sus pasos y sus comentarios. ----

@patch("app.conectar")
def test_sql_detalle_receta_selects(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_cursor.fetchone.return_value = {
        "id": 1, "titulo": "Tortilla", "descripcion": "Rica",
        "imagen": None, "autor": "Ana", "autor_id": 1,
        "usuario_id": 1, "creada_en": "2024-01-01"
    }
    mock_cursor.fetchall.return_value = []
    mock_cursor.stored_results.return_value = iter([])

    mock_cursor2 = MagicMock()
    mock_cursor2.fetchone.return_value = (5, 3)
    mock_cursor2.stored_results.return_value = iter([])

    mock_conectar.return_value.cursor.side_effect = [mock_cursor, mock_cursor2]

    sesion_usuario(client)

    client.get("/receta/1")

    calls = [str(c) for c in mock_cursor.execute.call_args_list]
    assert any("ingredientes" in c for c in calls)
    assert any("pasos" in c for c in calls)
    assert any("comentarios" in c for c in calls)


# ---- Cuando editas una receta, comprueba que se actualiza la receta y se reemplazan sus ingredientes y pasos antiguos por los nuevos. ----

@patch("app.conectar")
def test_sql_editar_receta_update(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_cursor.fetchone.return_value = {"id": 1, "usuario_id": 1, "imagen": None}
    mock_conectar.return_value.cursor.return_value = mock_cursor
    sesion_usuario(client)

    client.post("/recetas/editar/1", data={
        "titulo": "Nueva tortilla",
        "descripcion": "Mejorada",
        "ingrediente_nombre[]": ["Huevo"],
        "ingrediente_cantidad[]": ["2"],
        "ingrediente_categoria[]": ["proteina"],
        "paso_descripcion[]": ["Batir"]
    })

    calls = [str(c) for c in mock_cursor.execute.call_args_list]
    assert any("UPDATE" in c and "recetas" in c for c in calls)
    assert any("DELETE" in c and "ingredientes" in c for c in calls)
    assert any("DELETE" in c and "pasos" in c for c in calls)
    assert any("INSERT" in c and "ingredientes" in c for c in calls)


# ---- Cuando eliminas una receta, comprueba que se borra de la base de datos. ----

@patch("app.conectar")
def test_sql_eliminar_receta_delete(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_cursor.fetchone.return_value = {"usuario_id": 1}
    mock_conectar.return_value.cursor.return_value = mock_cursor
    sesion_usuario(client)

    client.post("/recetas/eliminar/1")

    calls = [str(c) for c in mock_cursor.execute.call_args_list]
    assert any("DELETE" in c and "recetas" in c for c in calls)


# ---- Cuando escribes un comentario en una receta, comprueba que se guarda en la base de datos. ----

@patch("app.conectar")
def test_sql_añadir_comentario_insert(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_conectar.return_value.cursor.return_value = mock_cursor
    sesion_usuario(client)

    client.post("/comentar/1", data={"contenido": "Qué rica!"})

    sql = mock_cursor.execute.call_args[0][0]
    assert "INSERT" in sql
    assert "comentarios" in sql


# ---- Cuando eliminas un comentario, comprueba que se borra de la base de datos. ----

@patch("app.conectar")
def test_sql_eliminar_comentario_delete(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_cursor.fetchone.return_value = {"usuario_id": 1}
    mock_conectar.return_value.cursor.return_value = mock_cursor
    sesion_usuario(client)

    client.post("/comentario/eliminar/1/1")

    calls = [str(c) for c in mock_cursor.execute.call_args_list]
    assert any("DELETE" in c and "comentarios" in c for c in calls)


# ---- Cuando entras a la página de menús, comprueba que se cargan todos los menús. ----

@patch("app.conectar")
def test_sql_menus_select(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = []
    mock_conectar.return_value.cursor.return_value = mock_cursor
    sesion_usuario(client)

    client.get("/menus")

    sql = mock_cursor.execute.call_args[0][0]
    assert "SELECT" in sql
    assert "menus" in sql


# ---- Cuando un admin crea un menú, comprueba que se guarda el menú y las recetas que contiene. ----

@patch("app.conectar")
def test_sql_nuevo_menu_insert(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_cursor.lastrowid = 5
    mock_cursor.fetchall.return_value = []
    mock_conectar.return_value.cursor.return_value = mock_cursor
    sesion_usuario(client, rol="admin")

    client.post("/menus/nuevo", data={
        "nombre": "Menu semanal",
        "dia_semana": "Lunes",
        "recetas[]": ["1", "2"]
    })

    calls = [str(c) for c in mock_cursor.execute.call_args_list]
    assert any("INSERT" in c and "menus" in c for c in calls)
    assert any("INSERT" in c and "menu_recetas" in c for c in calls)


# ---- Cuando un admin elimina un menú, comprueba que se borran primero las recetas del menú y luego el menú en sí. ----

@patch("app.conectar")
def test_sql_eliminar_menu_delete(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_conectar.return_value.cursor.return_value = mock_cursor
    sesion_usuario(client, rol="admin")

    client.post("/menus/eliminar/1")

    calls = [str(c) for c in mock_cursor.execute.call_args_list]
    assert any("DELETE" in c and "menu_recetas" in c for c in calls)
    assert any("DELETE" in c and "menus" in c for c in calls)


# ---- Cuando entras a tu perfil, comprueba que se cargan solo tus recetas. ----

@patch("app.conectar")
def test_sql_perfil_select_mis_recetas(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_cursor.fetchall.return_value = []
    mock_conectar.return_value.cursor.return_value = mock_cursor
    sesion_usuario(client)

    client.get("/perfil")

    sql = mock_cursor.execute.call_args[0][0]
    assert "SELECT" in sql
    assert "recetas" in sql
    assert "usuario_id" in sql


# ---- Cuando editas tu perfil, comprueba que se cargan tus datos actuales y que los cambios se guardan correctamente. ----

@patch("app.conectar")
def test_sql_editar_perfil_select_usuario(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_cursor.fetchone.return_value = {
        "id": 1, "nombre": "Test", "email": "test@test.com", "rol": "usuario"
    }
    mock_conectar.return_value.cursor.return_value = mock_cursor
    sesion_usuario(client)

    client.get("/perfil/editar")

    sql = mock_cursor.execute.call_args[0][0]
    assert "SELECT" in sql
    assert "usuarios" in sql


# ---- Cuando editas tu perfil, comprueba que se cargan tus datos actuales y que los cambios se guardan correctamente. ----

@patch("app.conectar")
def test_sql_editar_perfil_update(mock_conectar, client):
    mock_cursor = MagicMock()
    mock_conectar.return_value.cursor.return_value = mock_cursor
    sesion_usuario(client)

    client.post("/perfil/editar", data={
        "nombre": "Nuevo Nombre",
        "email": "nuevo@test.com"
    })

    sql = mock_cursor.execute.call_args[0][0]
    assert "UPDATE" in sql
    assert "usuarios" in sql


# ---- CALCULAR DIETA: sin login devuelve 401 ----

def test_calcular_dieta_sin_login(client):
    response = client.post("/api/calcular-dieta",
        data=json.dumps({}),
        content_type="application/json"
    )
    assert response.status_code == 401