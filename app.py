# app.py — ФІКС для 4 аргументів
from flask import Flask, render_template, request
import psycopg2
import time

app = Flask(__name__)

conn = psycopg2.connect(
    dbname="fake_users",
    user="postgres",
    password="Programer123",
    host="localhost",
    port="5432"
)

@app.route("/", methods=["GET", "POST"])
def index():
    locale = request.form.get("locale", "en_US")
    seed = int(request.form.get("seed", "12345"))
    batch_index = int(request.form.get("batch_index", "0"))

    if request.form.get("next"):
        batch_index += 1

    start_time = time.time()

    cur = conn.cursor()
    cur.execute("SELECT user_json FROM generate_batch(%s, %s, %s, %s)", (locale, seed, batch_index, 10))
    users = [row[0] for row in cur.fetchall()]
    cur.close()

    duration = time.time() - start_time
    speed = 10 / duration if duration > 0 else 0

    return render_template(
        "index.html",
        users=users,
        locale=locale,
        seed=seed,
        batch_index=batch_index,
        speed=round(speed, 2)
    )

if __name__ == "__main__":
    app.run(debug=True)