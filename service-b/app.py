from flask import Flask
import psycopg2, os

app = Flask(__name__)

def get_db_conn():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "postgres"),
        database=os.getenv("DB_NAME", "mydb"),
        user=os.getenv("DB_USER", "user"),
        password=os.getenv("DB_PASS", "password")
    )

@app.route('/')
def home():
    try:
        conn = get_db_conn()
        data = conn.cursor().fetchall()
        return {"data": data}
    except Exception as e:
        return f"Database connection failed: {e}"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
