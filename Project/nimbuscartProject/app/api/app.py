import os
import time
from decimal import Decimal
from flask import Flask, jsonify, request
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)
CORS(app)

DB_CONFIG = {
    "host": os.environ.get("DB_HOST", "127.0.0.1"),
    "port": int(os.environ.get("DB_PORT", "3306")),
    "user": os.environ.get("DB_USER", "nimbus"),
    "password": os.environ.get("DB_PASSWORD", "nimbuspass"),
    "database": os.environ.get("DB_NAME", "nimbuscart"),
}


def get_connection(retries=30, delay=2):
    last_error = None
    for _ in range(retries):
        try:
            return mysql.connector.connect(**DB_CONFIG)
        except mysql.connector.Error as exc:
            last_error = exc
            time.sleep(delay)
    raise last_error


def init_db():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS products (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            price DECIMAL(10,2) NOT NULL,
            stock INT NOT NULL
        )
    """)
    conn.commit()
    cur.close()
    conn.close()


@app.get("/health")
def health():
    return jsonify({"status": "ok"})


@app.get("/items")
def get_items():
    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    cur.execute("SELECT id, name, price, stock FROM products ORDER BY id")
    rows = cur.fetchall()
    cur.close()
    conn.close()
    for row in rows:
        if isinstance(row["price"], Decimal):
            row["price"] = float(row["price"])
    return jsonify(rows)


@app.post("/items")
def add_item():
    data = request.get_json(silent=True) or {}
    name = str(data.get("name", "")).strip()
    try:
        price = float(data["price"])
        stock = int(data["stock"])
    except (KeyError, TypeError, ValueError):
        return jsonify({"error": "price and stock must be valid numbers"}), 400
    if not name or price < 0 or stock < 0:
        return jsonify({"error": "name is required and price/stock must be non-negative"}), 400

    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    cur.execute("INSERT INTO products (name, price, stock) VALUES (%s, %s, %s)", (name, price, stock))
    conn.commit()
    item_id = cur.lastrowid
    cur.execute("SELECT id, name, price, stock FROM products WHERE id = %s", (item_id,))
    row = cur.fetchone()
    cur.close()
    conn.close()
    if isinstance(row["price"], Decimal):
        row["price"] = float(row["price"])
    return jsonify(row), 201


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000)
