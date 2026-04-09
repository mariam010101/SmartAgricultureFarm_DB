from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
from db import get_connection
from datetime import datetime, date

app = FastAPI()

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ==================== PYDANTIC MODELS ====================

class FarmCreate(BaseModel):
    FarmName: str
    Location: str


class CropCreate(BaseModel):
    CropName: str
    GrowthDuration: int


class WorkerCreate(BaseModel):
    Name: str


class FieldCreate(BaseModel):
    FarmID: int
    Area: float


class FieldCropCreate(BaseModel):
    FieldID: int
    CropID: int
    PlantingDate: date


class SensorCreate(BaseModel):
    FieldID: int
    SensorType: str


class SensorDataCreate(BaseModel):
    SensorID: int
    Value: float
    RecordedTime: datetime


class IrrigationSystemCreate(BaseModel):
    FieldID: int
    Status: str


class FieldWorkerCreate(BaseModel):
    FieldID: int
    WorkerID: int


class HarvestCreate(BaseModel):
    FieldID: int
    CropID: int
    Quantity: float
    HarvestDate: date


# ==================== UTILITY FUNCTIONS ====================

def dict_from_cursor(cursor, row):
    """Convert database row to dictionary"""
    columns = [col[0] for col in cursor.description]
    return dict(zip(columns, row))


def execute_query(query: str, params: tuple = ()):
    """Helper to execute SELECT queries"""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(query, params)
    result = [dict_from_cursor(cursor, row) for row in cursor.fetchall()]
    conn.close()
    return result


def execute_update(query: str, params: tuple = ()):
    """Helper to execute INSERT/UPDATE/DELETE queries"""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(query, params)
    conn.commit()
    row_count = cursor.rowcount
    conn.close()
    return row_count


# ==================== ROOT ====================

@app.get("/")
def root():
    return {"status": "API works", "version": "2.0"}


# =====================================================
# 👷 WORKERS (FULL CRUD)
# =====================================================

@app.get("/workers")
def get_workers(search: Optional[str] = None, limit: int = 100, offset: int = 0):
    """Get all workers with optional search and pagination"""
    if search:
        query = "SELECT * FROM Worker WHERE Name LIKE ? ORDER BY WorkerID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"
        return execute_query(query, (f"%{search}%", offset, limit))
    else:
        query = "SELECT * FROM Worker ORDER BY WorkerID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"
        return execute_query(query, (offset, limit))


@app.get("/workers/{worker_id}")
def get_worker(worker_id: int):
    """Get worker by ID"""
    result = execute_query("SELECT * FROM Worker WHERE WorkerID = ?", (worker_id,))
    if not result:
        raise HTTPException(status_code=404, detail="Worker not found")
    return result[0]


@app.post("/workers")
def add_worker(worker: WorkerCreate):
    """Add new worker"""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT ISNULL(MAX(WorkerID),0)+1 FROM Worker")
    new_id = cursor.fetchone()[0]
    conn.close()

    execute_update("INSERT INTO Worker (WorkerID, Name) VALUES (?, ?)",
                   (new_id, worker.Name))
    return {"status": "created", "id": new_id, "data": worker}


@app.put("/workers/{worker_id}")
def update_worker(worker_id: int, worker: WorkerCreate):
    """Update worker"""
    row_count = execute_update("UPDATE Worker SET Name = ? WHERE WorkerID = ?",
                               (worker.Name, worker_id))
    if row_count == 0:
        raise HTTPException(status_code=404, detail="Worker not found")
    return {"status": "updated", "id": worker_id, "data": worker}


@app.delete("/workers/{worker_id}")
def delete_worker(worker_id: int):
    """Delete worker"""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM FieldWorker WHERE WorkerID = ?", (worker_id,))
    cursor.execute("DELETE FROM Worker WHERE WorkerID = ?", (worker_id,))
    row_count = cursor.rowcount
    conn.commit()
    conn.close()

    if row_count == 0:
        raise HTTPException(status_code=404, detail="Worker not found")
    return {"status": "deleted"}


# =====================================================
# 🚜 FARMS (FULL CRUD)
# =====================================================

@app.get("/farms")
def get_farms(search: Optional[str] = None, limit: int = 100, offset: int = 0):
    """Get all farms with optional search and pagination"""
    if search:
        query = "SELECT * FROM Farm WHERE FarmName LIKE ? OR Location LIKE ? ORDER BY FarmID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"
        return execute_query(query, (f"%{search}%", f"%{search}%", offset, limit))
    else:
        query = "SELECT * FROM Farm ORDER BY FarmID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"
        return execute_query(query, (offset, limit))


@app.get("/farms/{farm_id}")
def get_farm(farm_id: int):
    """Get farm by ID"""
    result = execute_query("SELECT * FROM Farm WHERE FarmID = ?", (farm_id,))
    if not result:
        raise HTTPException(status_code=404, detail="Farm not found")
    return result[0]


@app.post("/farms")
def add_farm(farm: FarmCreate):
    """Add new farm"""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT ISNULL(MAX(FarmID),0)+1 FROM Farm")
    new_id = cursor.fetchone()[0]
    conn.close()

    execute_update("INSERT INTO Farm (FarmID, FarmName, Location) VALUES (?, ?, ?)",
                   (new_id, farm.FarmName, farm.Location))
    return {"status": "created", "id": new_id, "data": farm}


@app.put("/farms/{farm_id}")
def update_farm(farm_id: int, farm: FarmCreate):
    """Update farm"""
    row_count = execute_update("UPDATE Farm SET FarmName = ?, Location = ? WHERE FarmID = ?",
                               (farm.FarmName, farm.Location, farm_id))
    if row_count == 0:
        raise HTTPException(status_code=404, detail="Farm not found")
    return {"status": "updated", "id": farm_id, "data": farm}


@app.delete("/farms/{farm_id}")
def delete_farm(farm_id: int):
    """Delete farm and related data"""
    conn = get_connection()
    cursor = conn.cursor()

    # Delete cascade
    cursor.execute("DELETE FROM FieldWorker WHERE FieldID IN (SELECT FieldID FROM Field WHERE FarmID = ?)", (farm_id,))
    cursor.execute("DELETE FROM Harvest WHERE FieldID IN (SELECT FieldID FROM Field WHERE FarmID = ?)", (farm_id,))
    cursor.execute(
        "DELETE FROM SensorData WHERE SensorID IN (SELECT SensorID FROM Sensor WHERE FieldID IN (SELECT FieldID FROM Field WHERE FarmID = ?))",
        (farm_id,))
    cursor.execute("DELETE FROM Sensor WHERE FieldID IN (SELECT FieldID FROM Field WHERE FarmID = ?)", (farm_id,))
    cursor.execute("DELETE FROM IrrigationSystem WHERE FieldID IN (SELECT FieldID FROM Field WHERE FarmID = ?)",
                   (farm_id,))
    cursor.execute("DELETE FROM FieldCrop WHERE FieldID IN (SELECT FieldID FROM Field WHERE FarmID = ?)", (farm_id,))
    cursor.execute("DELETE FROM Field WHERE FarmID = ?", (farm_id,))
    cursor.execute("DELETE FROM Farm WHERE FarmID = ?", (farm_id,))

    row_count = cursor.rowcount
    conn.commit()
    conn.close()

    if row_count == 0:
        raise HTTPException(status_code=404, detail="Farm not found")
    return {"status": "deleted"}


# =====================================================
# 🌾 CROPS (FULL CRUD)
# =====================================================

@app.get("/crops")
def get_crops(search: Optional[str] = None, limit: int = 100, offset: int = 0):
    """Get all crops"""
    if search:
        query = "SELECT * FROM Crop WHERE CropName LIKE ? ORDER BY CropID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"
        return execute_query(query, (f"%{search}%", offset, limit))
    else:
        query = "SELECT * FROM Crop ORDER BY CropID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"
        return execute_query(query, (offset, limit))


@app.get("/crops/{crop_id}")
def get_crop(crop_id: int):
    """Get crop by ID"""
    result = execute_query("SELECT * FROM Crop WHERE CropID = ?", (crop_id,))
    if not result:
        raise HTTPException(status_code=404, detail="Crop not found")
    return result[0]


@app.post("/crops")
def add_crop(crop: CropCreate):
    """Add new crop"""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT ISNULL(MAX(CropID),0)+1 FROM Crop")
    new_id = cursor.fetchone()[0]
    conn.close()

    execute_update("INSERT INTO Crop (CropID, CropName, GrowthDuration) VALUES (?, ?, ?)",
                   (new_id, crop.CropName, crop.GrowthDuration))
    return {"status": "created", "id": new_id, "data": crop}


@app.put("/crops/{crop_id}")
def update_crop(crop_id: int, crop: CropCreate):
    """Update crop"""
    row_count = execute_update("UPDATE Crop SET CropName = ?, GrowthDuration = ? WHERE CropID = ?",
                               (crop.CropName, crop.GrowthDuration, crop_id))
    if row_count == 0:
        raise HTTPException(status_code=404, detail="Crop not found")
    return {"status": "updated", "id": crop_id, "data": crop}


@app.delete("/crops/{crop_id}")
def delete_crop(crop_id: int):
    """Delete crop"""
    row_count = execute_update("DELETE FROM Crop WHERE CropID = ?", (crop_id,))
    if row_count == 0:
        raise HTTPException(status_code=404, detail="Crop not found")
    return {"status": "deleted"}


# =====================================================
# 🌻 FIELDS (FULL CRUD)
# =====================================================

@app.get("/fields")
def get_fields(farm_id: Optional[int] = None, limit: int = 100, offset: int = 0):
    """Get all fields with optional farm filter"""
    if farm_id:
        query = "SELECT * FROM Field WHERE FarmID = ? ORDER BY FieldID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"
        return execute_query(query, (farm_id, offset, limit))
    else:
        query = "SELECT * FROM Field ORDER BY FieldID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"
        return execute_query(query, (offset, limit))


@app.get("/fields/{field_id}")
def get_field(field_id: int):
    """Get field by ID with related data"""
    result = execute_query("""
        SELECT F.*, Fa.FarmName
        FROM Field F
        JOIN Farm Fa ON F.FarmID = Fa.FarmID
        WHERE F.FieldID = ?
    """, (field_id,))
    if not result:
        raise HTTPException(status_code=404, detail="Field not found")
    return result[0]


@app.post("/fields")
def add_field(field: FieldCreate):
    """Add new field"""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT ISNULL(MAX(FieldID),0)+1 FROM Field")
    new_id = cursor.fetchone()[0]
    conn.close()

    execute_update("INSERT INTO Field (FieldID, FarmID, Area) VALUES (?, ?, ?)",
                   (new_id, field.FarmID, field.Area))
    return {"status": "created", "id": new_id, "data": field}


@app.put("/fields/{field_id}")
def update_field(field_id: int, field: FieldCreate):
    """Update field"""
    row_count = execute_update("UPDATE Field SET FarmID = ?, Area = ? WHERE FieldID = ?",
                               (field.FarmID, field.Area, field_id))
    if row_count == 0:
        raise HTTPException(status_code=404, detail="Field not found")
    return {"status": "updated", "id": field_id, "data": field}


@app.delete("/fields/{field_id}")
def delete_field(field_id: int):
    """Delete field and related data"""
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("DELETE FROM FieldWorker WHERE FieldID = ?", (field_id,))
    cursor.execute("DELETE FROM Harvest WHERE FieldID = ?", (field_id,))
    cursor.execute("DELETE FROM SensorData WHERE SensorID IN (SELECT SensorID FROM Sensor WHERE FieldID = ?)",
                   (field_id,))
    cursor.execute("DELETE FROM Sensor WHERE FieldID = ?", (field_id,))
    cursor.execute("DELETE FROM IrrigationSystem WHERE FieldID = ?", (field_id,))
    cursor.execute("DELETE FROM FieldCrop WHERE FieldID = ?", (field_id,))
    cursor.execute("DELETE FROM Field WHERE FieldID = ?", (field_id,))

    row_count = cursor.rowcount
    conn.commit()
    conn.close()

    if row_count == 0:
        raise HTTPException(status_code=404, detail="Field not found")
    return {"status": "deleted"}


# =====================================================
# 🌽 FIELD CROPS (FULL CRUD)
# =====================================================

@app.get("/field-crops")
def get_field_crops(field_id: Optional[int] = None):
    """Get field-crop relationships"""
    if field_id:
        query = """
            SELECT FC.*, C.CropName, F.Area, Fa.FarmName
            FROM FieldCrop FC
            JOIN Field F ON FC.FieldID = F.FieldID
            JOIN Farm Fa ON F.FarmID = Fa.FarmID
            JOIN Crop C ON FC.CropID = C.CropID
            WHERE FC.FieldID = ?
        """
        return execute_query(query, (field_id,))
    else:
        query = """
            SELECT FC.*, C.CropName, F.Area, Fa.FarmName
            FROM FieldCrop FC
            JOIN Field F ON FC.FieldID = F.FieldID
            JOIN Farm Fa ON F.FarmID = Fa.FarmID
            JOIN Crop C ON FC.CropID = C.CropID
        """
        return execute_query(query)


@app.post("/field-crops")
def add_field_crop(field_crop: FieldCropCreate):
    """Add crop to field"""
    execute_update(
        "INSERT INTO FieldCrop (FieldID, CropID, PlantingDate) VALUES (?, ?, ?)",
        (field_crop.FieldID, field_crop.CropID, field_crop.PlantingDate)
    )
    return {"status": "created", "data": field_crop}


@app.put("/field-crops/{field_id}/{crop_id}")
def update_field_crop(field_id: int, crop_id: int, field_crop: FieldCropCreate):
    """Update field-crop"""
    row_count = execute_update(
        "UPDATE FieldCrop SET PlantingDate = ? WHERE FieldID = ? AND CropID = ?",
        (field_crop.PlantingDate, field_id, crop_id)
    )
    if row_count == 0:
        raise HTTPException(status_code=404, detail="Field-Crop relationship not found")
    return {"status": "updated"}


@app.delete("/field-crops/{field_id}/{crop_id}")
def delete_field_crop(field_id: int, crop_id: int):
    """Delete field-crop"""
    row_count = execute_update(
        "DELETE FROM FieldCrop WHERE FieldID = ? AND CropID = ?",
        (field_id, crop_id)
    )
    if row_count == 0:
        raise HTTPException(status_code=404, detail="Field-Crop relationship not found")
    return {"status": "deleted"}


# =====================================================
# 📡 SENSORS (FULL CRUD)
# =====================================================

@app.get("/sensors")
def get_sensors(field_id: Optional[int] = None):
    """Get all sensors"""
    if field_id:
        query = "SELECT * FROM Sensor WHERE FieldID = ? ORDER BY SensorID"
        return execute_query(query, (field_id,))
    else:
        query = "SELECT * FROM Sensor ORDER BY SensorID"
        return execute_query(query)


@app.get("/sensors/{sensor_id}")
def get_sensor(sensor_id: int):
    """Get sensor by ID"""
    result = execute_query("SELECT * FROM Sensor WHERE SensorID = ?", (sensor_id,))
    if not result:
        raise HTTPException(status_code=404, detail="Sensor not found")
    return result[0]


@app.post("/sensors")
def add_sensor(sensor: SensorCreate):
    """Add new sensor"""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT ISNULL(MAX(SensorID),0)+1 FROM Sensor")
    new_id = cursor.fetchone()[0]
    conn.close()

    execute_update(
        "INSERT INTO Sensor (SensorID, FieldID, SensorType) VALUES (?, ?, ?)",
        (new_id, sensor.FieldID, sensor.SensorType)
    )
    return {"status": "created", "id": new_id, "data": sensor}


@app.put("/sensors/{sensor_id}")
def update_sensor(sensor_id: int, sensor: SensorCreate):
    """Update sensor"""
    row_count = execute_update(
        "UPDATE Sensor SET FieldID = ?, SensorType = ? WHERE SensorID = ?",
        (sensor.FieldID, sensor.SensorType, sensor_id)
    )
    if row_count == 0:
        raise HTTPException(status_code=404, detail="Sensor not found")
    return {"status": "updated", "id": sensor_id, "data": sensor}


@app.delete("/sensors/{sensor_id}")
def delete_sensor(sensor_id: int):
    """Delete sensor"""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM SensorData WHERE SensorID = ?", (sensor_id,))
    cursor.execute("DELETE FROM Sensor WHERE SensorID = ?", (sensor_id,))
    row_count = cursor.rowcount
    conn.commit()
    conn.close()

    if row_count == 0:
        raise HTTPException(status_code=404, detail="Sensor not found")
    return {"status": "deleted"}


# =====================================================
# 📊 SENSOR DATA (FULL CRUD)
# =====================================================

@app.get("/sensor-data")
def get_sensor_data(sensor_id: Optional[int] = None, field_id: Optional[int] = None,
                    limit: int = 100, offset: int = 0):
    """Get sensor data with filters"""
    if sensor_id:
        query = """
            SELECT SD.* FROM SensorData SD
            WHERE SD.SensorID = ?
            ORDER BY SD.RecordedTime DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        return execute_query(query, (sensor_id, offset, limit))
    elif field_id:
        query = """
            SELECT SD.* FROM SensorData SD
            JOIN Sensor S ON SD.SensorID = S.SensorID
            WHERE S.FieldID = ?
            ORDER BY SD.RecordedTime DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        return execute_query(query, (field_id, offset, limit))
    else:
        query = """
            SELECT * FROM SensorData
            ORDER BY RecordedTime DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        return execute_query(query, (offset, limit))


@app.get("/sensor-data/{data_id}")
def get_sensor_data_record(data_id: int):
    """Get single sensor data record"""
    result = execute_query("SELECT * FROM SensorData WHERE DataID = ?", (data_id,))
    if not result:
        raise HTTPException(status_code=404, detail="Sensor data not found")
    return result[0]


@app.post("/sensor-data")
def add_sensor_data(sensor_data: SensorDataCreate):
    """Add new sensor data"""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT ISNULL(MAX(DataID),0)+1 FROM SensorData")
    new_id = cursor.fetchone()[0]
    conn.close()

    execute_update(
        "INSERT INTO SensorData (DataID, SensorID, Value, RecordedTime) VALUES (?, ?, ?, ?)",
        (new_id, sensor_data.SensorID, sensor_data.Value, sensor_data.RecordedTime)
    )
    return {"status": "created", "id": new_id, "data": sensor_data}


@app.put("/sensor-data/{data_id}")
def update_sensor_data(data_id: int, sensor_data: SensorDataCreate):
    """Update sensor data"""
    row_count = execute_update(
        "UPDATE SensorData SET SensorID = ?, Value = ?, RecordedTime = ? WHERE DataID = ?",
        (sensor_data.SensorID, sensor_data.Value, sensor_data.RecordedTime, data_id)
    )
    if row_count == 0:
        raise HTTPException(status_code=404, detail="Sensor data not found")
    return {"status": "updated", "id": data_id}


@app.delete("/sensor-data/{data_id}")
def delete_sensor_data(data_id: int):
    """Delete sensor data"""
    row_count = execute_update("DELETE FROM SensorData WHERE DataID = ?", (data_id,))
    if row_count == 0:
        raise HTTPException(status_code=404, detail="Sensor data not found")
    return {"status": "deleted"}


# =====================================================
# 💧 IRRIGATION SYSTEMS (FULL CRUD)
# =====================================================

@app.get("/irrigation")
def get_irrigation(status: Optional[str] = None):
    """Get irrigation systems with optional status filter"""
    if status:
        query = "SELECT * FROM IrrigationSystem WHERE Status = ?"
        return execute_query(query, (status,))
    else:
        query = "SELECT * FROM IrrigationSystem"
        return execute_query(query)


@app.get("/irrigation/{field_id}")
def get_irrigation_by_field(field_id: int):
    """Get irrigation system for specific field"""
    result = execute_query(
        "SELECT * FROM IrrigationSystem WHERE FieldID = ?",
        (field_id,)
    )
    if not result:
        raise HTTPException(status_code=404, detail="Irrigation system not found")
    return result[0]


@app.post("/irrigation")
def add_irrigation(irrigation: IrrigationSystemCreate):
    """Add new irrigation system"""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT ISNULL(MAX(IrrigationID),0)+1 FROM IrrigationSystem")
    new_id = cursor.fetchone()[0]
    conn.close()

    execute_update(
        "INSERT INTO IrrigationSystem (IrrigationID, FieldID, Status) VALUES (?, ?, ?)",
        (new_id, irrigation.FieldID, irrigation.Status)
    )
    return {"status": "created", "id": new_id, "data": irrigation}


@app.put("/irrigation/{field_id}")
def update_irrigation(field_id: int, irrigation: IrrigationSystemCreate):
    """Update irrigation system"""
    row_count = execute_update(
        "UPDATE IrrigationSystem SET Status = ?, LastUpdated = GETDATE() WHERE FieldID = ?",
        (irrigation.Status, field_id)
    )
    if row_count == 0:
        raise HTTPException(status_code=404, detail="Irrigation system not found")
    return {"status": "updated"}


@app.delete("/irrigation/{field_id}")
def delete_irrigation(field_id: int):
    """Delete irrigation system"""
    row_count = execute_update(
        "DELETE FROM IrrigationSystem WHERE FieldID = ?",
        (field_id,)
    )
    if row_count == 0:
        raise HTTPException(status_code=404, detail="Irrigation system not found")
    return {"status": "deleted"}


# =====================================================
# 👥 FIELD WORKERS (FULL CRUD)
# =====================================================

@app.get("/field-workers")
def get_field_workers(field_id: Optional[int] = None, worker_id: Optional[int] = None):
    """Get field-worker relationships"""
    if field_id:
        query = """
            SELECT FW.*, W.Name, F.Area, Fa.FarmName
            FROM FieldWorker FW
            JOIN Worker W ON FW.WorkerID = W.WorkerID
            JOIN Field F ON FW.FieldID = F.FieldID
            JOIN Farm Fa ON F.FarmID = Fa.FarmID
            WHERE FW.FieldID = ?
        """
        return execute_query(query, (field_id,))
    elif worker_id:
        query = """
            SELECT FW.*, W.Name, F.Area, Fa.FarmName
            FROM FieldWorker FW
            JOIN Worker W ON FW.WorkerID = W.WorkerID
            JOIN Field F ON FW.FieldID = F.FieldID
            JOIN Farm Fa ON F.FarmID = Fa.FarmID
            WHERE FW.WorkerID = ?
        """
        return execute_query(query, (worker_id,))
    else:
        query = """
            SELECT FW.*, W.Name, F.Area, Fa.FarmName
            FROM FieldWorker FW
            JOIN Worker W ON FW.WorkerID = W.WorkerID
            JOIN Field F ON FW.FieldID = F.FieldID
            JOIN Farm Fa ON F.FarmID = Fa.FarmID
        """
        return execute_query(query)


@app.post("/field-workers")
def add_field_worker(field_worker: FieldWorkerCreate):
    """Assign worker to field"""
    execute_update(
        "INSERT INTO FieldWorker (FieldID, WorkerID) VALUES (?, ?)",
        (field_worker.FieldID, field_worker.WorkerID)
    )
    return {"status": "created", "data": field_worker}


@app.delete("/field-workers/{field_id}/{worker_id}")
def delete_field_worker(field_id: int, worker_id: int):
    """Remove worker from field"""
    row_count = execute_update(
        "DELETE FROM FieldWorker WHERE FieldID = ? AND WorkerID = ?",
        (field_id, worker_id)
    )
    if row_count == 0:
        raise HTTPException(status_code=404, detail="Field-Worker relationship not found")
    return {"status": "deleted"}


# =====================================================
# 🌾 HARVEST (FULL CRUD)
# =====================================================

@app.get("/harvest")
def get_harvest(field_id: Optional[int] = None, crop_id: Optional[int] = None,
                limit: int = 100, offset: int = 0):
    """Get harvest records with optional filters"""
    if field_id and crop_id:
        query = """
            SELECT H.*, C.CropName, F.Area, Fa.FarmName
            FROM Harvest H
            JOIN Crop C ON H.CropID = C.CropID
            JOIN Field F ON H.FieldID = F.FieldID
            JOIN Farm Fa ON F.FarmID = Fa.FarmID
            WHERE H.FieldID = ? AND H.CropID = ?
            ORDER BY H.HarvestDate DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        return execute_query(query, (field_id, crop_id, offset, limit))
    elif field_id:
        query = """
            SELECT H.*, C.CropName, F.Area, Fa.FarmName
            FROM Harvest H
            JOIN Crop C ON H.CropID = C.CropID
            JOIN Field F ON H.FieldID = F.FieldID
            JOIN Farm Fa ON F.FarmID = Fa.FarmID
            WHERE H.FieldID = ?
            ORDER BY H.HarvestDate DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        return execute_query(query, (field_id, offset, limit))
    else:
        query = """
            SELECT H.*, C.CropName, F.Area, Fa.FarmName
            FROM Harvest H
            JOIN Crop C ON H.CropID = C.CropID
            JOIN Field F ON H.FieldID = F.FieldID
            JOIN Farm Fa ON F.FarmID = Fa.FarmID
            ORDER BY H.HarvestDate DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        return execute_query(query, (offset, limit))


@app.get("/harvest/{harvest_id}")
def get_harvest_record(harvest_id: int):
    """Get single harvest record"""
    result = execute_query(
        """
        SELECT H.*, C.CropName, F.Area, Fa.FarmName
        FROM Harvest H
        JOIN Crop C ON H.CropID = C.CropID
        JOIN Field F ON H.FieldID = F.FieldID
        JOIN Farm Fa ON F.FarmID = Fa.FarmID
        WHERE H.HarvestID = ?
        """,
        (harvest_id,)
    )
    if not result:
        raise HTTPException(status_code=404, detail="Harvest record not found")
    return result[0]


@app.post("/harvest")
def add_harvest(harvest: HarvestCreate):
    """Add harvest record"""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT ISNULL(MAX(HarvestID),0)+1 FROM Harvest")
    new_id = cursor.fetchone()[0]
    conn.close()

    execute_update(
        "INSERT INTO Harvest (HarvestID, FieldID, CropID, Quantity, HarvestDate) VALUES (?, ?, ?, ?, ?)",
        (new_id, harvest.FieldID, harvest.CropID, harvest.Quantity, harvest.HarvestDate)
    )
    return {"status": "created", "id": new_id, "data": harvest}


@app.put("/harvest/{harvest_id}")
def update_harvest(harvest_id: int, harvest: HarvestCreate):
    """Update harvest record"""
    row_count = execute_update(
        "UPDATE Harvest SET FieldID = ?, CropID = ?, Quantity = ?, HarvestDate = ? WHERE HarvestID = ?",
        (harvest.FieldID, harvest.CropID, harvest.Quantity, harvest.HarvestDate, harvest_id)
    )
    if row_count == 0:
        raise HTTPException(status_code=404, detail="Harvest record not found")
    return {"status": "updated", "id": harvest_id, "data": harvest}


@app.delete("/harvest/{harvest_id}")
def delete_harvest(harvest_id: int):
    """Delete harvest record"""
    row_count = execute_update(
        "DELETE FROM Harvest WHERE HarvestID = ?",
        (harvest_id,)
    )
    if row_count == 0:
        raise HTTPException(status_code=404, detail="Harvest record not found")
    return {"status": "deleted"}


# =====================================================
# 📊 ANALYTICS ENDPOINTS
# =====================================================

@app.get("/analytics/field-summary")
def field_summary():
    """Get sensor summary for all fields"""
    return execute_query("SELECT * FROM FieldSensorSummary")


@app.get("/analytics/top-farms")
def top_farms(limit: int = 5):
    """Get top farms by total harvest"""
    query = f"""
        SELECT TOP {limit} * 
        FROM FarmTotalHarvest
        ORDER BY TotalHarvest DESC
    """
    return execute_query(query)


@app.get("/analytics/critical-conditions")
def critical_conditions():
    """Get fields with critical sensor conditions"""
    return execute_query("SELECT * FROM CriticalFieldConditions")


@app.get("/analytics/worker-assignments")
def worker_assignments():
    """Get worker assignment summary"""
    return execute_query("SELECT * FROM WorkerAssignmentSummary")


@app.get("/analytics/farm-area")
def farm_area_analysis():
    """Get total area per farm"""
    return execute_query("""
        SELECT F.FarmName, SUM(Fi.Area) AS TotalArea, COUNT(Fi.FieldID) AS FieldCount
        FROM Farm F
        LEFT JOIN Field Fi ON F.FarmID = Fi.FarmID
        GROUP BY F.FarmName
        ORDER BY TotalArea DESC
    """)


@app.get("/analytics/harvest-summary")
def harvest_summary():
    """Get harvest summary by farm and crop"""
    return execute_query("""
        SELECT Fa.FarmName, C.CropName, SUM(H.Quantity) AS TotalQuantity, COUNT(H.HarvestID) AS HarvestCount
        FROM Harvest H
        JOIN Field F ON H.FieldID = F.FieldID
        JOIN Farm Fa ON F.FarmID = Fa.FarmID
        JOIN Crop C ON H.CropID = C.CropID
        GROUP BY Fa.FarmName, C.CropName
        ORDER BY TotalQuantity DESC
    """)


# =====================================================
# ERROR HANDLERS
# =====================================================

@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    return {
        "error": str(exc),
        "detail": "An unexpected error occurred"
    }