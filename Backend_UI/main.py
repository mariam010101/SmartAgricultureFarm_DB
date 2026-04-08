from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from db import get_connection

app = FastAPI()

# CORS (чтобы UI работал)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ------------------- ROOT -------------------
@app.get("/")
def root():
    return {"status": "API works"}

# =====================================================
# 👷 WORKERS (CRUD-lite)
# =====================================================

# 🔎 GET + поиск
@app.get("/workers")
def workers(search: str = None):
    conn = get_connection()
    cursor = conn.cursor()

    if search:
        cursor.execute("""
            SELECT * FROM WorkerAssignmentSummary
            WHERE WorkerName LIKE ?
        """, (f"%{search}%",))
    else:
        cursor.execute("SELECT * FROM WorkerAssignmentSummary")

    columns = [col[0] for col in cursor.description]
    result = [dict(zip(columns, row)) for row in cursor.fetchall()]

    conn.close()
    return result


# ➕ ADD
@app.post("/workers")
def add_worker(worker: dict):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT ISNULL(MAX(WorkerID),0)+1 FROM Worker")
    new_id = cursor.fetchone()[0]

    cursor.execute("""
        INSERT INTO Worker (WorkerID, Name)
        VALUES (?, ?)
    """, (new_id, worker["name"]))

    conn.commit()
    conn.close()

    return {"status": "worker added", "id": new_id}


# ❌ DELETE
@app.delete("/workers/{worker_id}")
def delete_worker(worker_id: int):
    conn = get_connection()
    cursor = conn.cursor()

    # удаляем связи сначала
    cursor.execute("DELETE FROM FieldWorker WHERE WorkerID = ?", (worker_id,))
    cursor.execute("DELETE FROM Worker WHERE WorkerID = ?", (worker_id,))

    if cursor.rowcount == 0:
        conn.close()
        raise HTTPException(status_code=404, detail="Worker not found")

    conn.commit()
    conn.close()

    return {"status": "deleted"}


# =====================================================
# 🚜 FARMS (CRUD-lite)
# =====================================================

# 🔎 GET + поиск
@app.get("/farms")
def farms(search: str = None):
    conn = get_connection()
    cursor = conn.cursor()

    if search:
        cursor.execute("""
            SELECT * FROM Farm
            WHERE FarmName LIKE ?
        """, (f"%{search}%",))
    else:
        cursor.execute("SELECT * FROM Farm")

    columns = [col[0] for col in cursor.description]
    result = [dict(zip(columns, row)) for row in cursor.fetchall()]

    conn.close()
    return result


# ➕ ADD
@app.post("/farms")
def add_farm(farm: dict):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT ISNULL(MAX(FarmID),0)+1 FROM Farm")
    new_id = cursor.fetchone()[0]

    cursor.execute("""
        INSERT INTO Farm (FarmID, FarmName, Location)
        VALUES (?, ?, ?)
    """, (new_id, farm["name"], farm["location"]))

    conn.commit()
    conn.close()

    return {"status": "farm added", "id": new_id}


# ❌ DELETE
@app.delete("/farms/{farm_id}")
def delete_farm(farm_id: int):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("DELETE FROM Farm WHERE FarmID = ?", (farm_id,))

    if cursor.rowcount == 0:
        conn.close()
        raise HTTPException(status_code=404, detail="Farm not found")

    conn.commit()
    conn.close()

    return {"status": "deleted"}


# =====================================================
# 📊 ANALYTICS (твои VIEW — не трогаем)
# =====================================================

@app.get("/field-summary")
def field_summary():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM FieldSensorSummary")

    columns = [col[0] for col in cursor.description]
    result = [dict(zip(columns, row)) for row in cursor.fetchall()]

    conn.close()
    return result


@app.get("/top-farms")
def top_farms():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT TOP 5 * 
        FROM FarmTotalHarvest
        ORDER BY TotalHarvest DESC
    """)

    columns = [col[0] for col in cursor.description]
    result = [dict(zip(columns, row)) for row in cursor.fetchall()]

    conn.close()
    return result


@app.get("/irrigation")
def irrigation():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM IrrigationStatus")

    columns = [col[0] for col in cursor.description]
    result = [dict(zip(columns, row)) for row in cursor.fetchall()]

    conn.close()
    return result


@app.get("/alerts")
def alerts():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM CriticalFieldConditions")

    columns = [col[0] for col in cursor.description]
    result = [dict(zip(columns, row)) for row in cursor.fetchall()]

    conn.close()
    return result