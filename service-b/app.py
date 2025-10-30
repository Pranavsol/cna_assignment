from flask import Flask
import psycopg2
import os

app = Flask(__name__)

def get_db_conn():
    return psycopg2.connect(
        host="postgres",
        database="cna_assignment",
        user="postgres",
        password="pranavsol"
    )

@app.route('/')
def home():
    try:
        conn = get_db_conn()
        cursor = conn.cursor()
        
        # Fetch and display data
        cursor.execute("SELECT * FROM sales")
        data = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return {
            "status": "success",
            "service": "Service B",
            "database": "cna_assignment",
            "data": data
        }
    except Exception as e:
        return {
            "status": "error",
            "service": "Service B",
            "error": str(e)
        }, 500

@app.route('/health')
def health():
    return {"status": "healthy", "service": "Service B"}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)