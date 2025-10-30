from flask import Flask, jsonify
import psycopg2
import os

app = Flask(__name__)

def get_db_conn():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "postgres"),
        database=os.getenv("DB_NAME", "cna_assignment"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASS", "pranavsol")
    )

@app.route('/')
def home():
    try:
        conn = get_db_conn()
        cursor = conn.cursor()
        
        # Fetch all data from sales table
        cursor.execute("SELECT * FROM inveentory.sales")
        rows = cursor.fetchall()
        
        # Get column names
        column_names = [desc[0] for desc in cursor.description]
        
        # Convert to list of dictionaries for better JSON output
        sales_data = []
        for row in rows:
            sales_data.append(dict(zip(column_names, row)))
        
        cursor.close()
        conn.close()
        
        return jsonify({
            "status": "success",
            "service": "Service B",
            "database": os.getenv("DB_NAME", "cna_assignment"),
            "table": "inveentory.sales",
            "total_records": len(sales_data),
            "data": sales_data
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "service": "Service B",
            "error": str(e)
        }), 500

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "service": "Service B"})

@app.route('/count')
def count():
    try:
        conn = get_db_conn()
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM inveentory.sales")
        count = cursor.fetchone()[0]
        cursor.close()
        conn.close()
        return jsonify({
            "status": "success",
            "total_sales": count
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "error": str(e)
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)