

from flask import Flask, render_template, request
import psycopg2
import os
import time

app = Flask(__name__)


DATABASE_URL = os.environ.get('DATABASE_URL') or \
               'postgresql://postgres:Programer123@localhost:5432/fake_users'

conn = psycopg2.connect(DATABASE_URL, sslmode='require' if 'neon.tech' in DATABASE_URL else 'prefer')

@app.route("/", methods=["GET", "POST"])
def index():
    locale = request.form.get("locale", "en_US")
    seed = int(request.form.get("seed", "12345"))
    batch_index = int(request.form.get("batch_index", "0"))

    if request.form.get("next"):
        batch_index += 1

    start_time = time.time()

    cur = conn.cursor()
    cur.execute("SELECT user_json FROM generate_batch(%s, %s, %s, 10)",
                (locale, seed, batch_index))
    users = [row[0] for row in cur.fetchall()]
    cur.close()

    duration = time.time() - start_time
    speed = round(10 / duration if duration > 0 else 0, 1)

    return render_template("index.html",
                           users=users,
                           locale=locale,
                           seed=seed,
                           batch_index=batch_index,
                           speed=speed)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=int(os.environ.get("PORT", 5000)))