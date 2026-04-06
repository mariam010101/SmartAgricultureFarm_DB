PRINT '================================================================';
PRINT 'DATABASE DEPLOYMENT SCRIPT';
PRINT '================================================================';
GO

USE master;
GO

IF DB_ID('SmartAgricultureDB') IS NOT NULL
BEGIN
    ALTER DATABASE SmartAgricultureDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SmartAgricultureDB;
END
GO

CREATE DATABASE SmartAgricultureDB;
GO

USE SmartAgricultureDB;
GO


-- ================================================================
-- CREATING TABLES (DDL)
-- ================================================================


PRINT '================================================================';
PRINT 'DDL — CREATING TABLES';
PRINT '================================================================';
GO


USE SmartAgricultureDB;
GO 

-- Drop tables if they exist (in reverse dependency order)
IF OBJECT_ID('Harvest', 'U') IS NOT NULL DROP TABLE Harvest;
IF OBJECT_ID('FieldWorker', 'U') IS NOT NULL DROP TABLE FieldWorker;
IF OBJECT_ID('IrrigationSystem', 'U') IS NOT NULL DROP TABLE IrrigationSystem;
IF OBJECT_ID('SensorData', 'U') IS NOT NULL DROP TABLE SensorData;
IF OBJECT_ID('Sensor', 'U') IS NOT NULL DROP TABLE Sensor;
IF OBJECT_ID('FieldCrop', 'U') IS NOT NULL DROP TABLE FieldCrop;
IF OBJECT_ID('Field', 'U') IS NOT NULL DROP TABLE Field;
IF OBJECT_ID('Worker', 'U') IS NOT NULL DROP TABLE Worker;
IF OBJECT_ID('Crop', 'U') IS NOT NULL DROP TABLE Crop;
IF OBJECT_ID('Farm', 'U') IS NOT NULL DROP TABLE Farm;
GO

CREATE TABLE Farm (
    FarmID INT PRIMARY KEY,
    FarmName VARCHAR(100),
    Location VARCHAR(100)
);
GO

CREATE TABLE Crop (
    CropID INT PRIMARY KEY,
    CropName VARCHAR(100),
    GrowthDuration INT
);
GO

CREATE TABLE Worker (
    WorkerID INT PRIMARY KEY,
    Name VARCHAR(100)
);
GO

CREATE TABLE Field (
    FieldID INT PRIMARY KEY,
    FarmID INT,
    Area DECIMAL(10,2),
    FOREIGN KEY (FarmID) REFERENCES Farm(FarmID)
);
GO

CREATE TABLE FieldCrop (
    FieldID INT,
    CropID INT,
    PlantingDate DATE,
    PRIMARY KEY (FieldID, CropID),
    FOREIGN KEY (FieldID) REFERENCES Field(FieldID),
    FOREIGN KEY (CropID) REFERENCES Crop(CropID)
);
GO

CREATE TABLE Sensor (
    SensorID INT PRIMARY KEY,
    FieldID INT,
    SensorType VARCHAR(50),
    FOREIGN KEY (FieldID) REFERENCES Field(FieldID)
);
GO

CREATE TABLE SensorData (
    DataID INT PRIMARY KEY,
    SensorID INT,
    Value DECIMAL(6,2),
    RecordedTime DATETIME,
    FOREIGN KEY (SensorID) REFERENCES Sensor(SensorID)
);
GO

CREATE TABLE IrrigationSystem (
    IrrigationID INT PRIMARY KEY,
    FieldID INT UNIQUE,
    Status VARCHAR(10) CHECK (Status IN ('ON','OFF')),
    LastUpdated DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (FieldID) REFERENCES Field(FieldID)
);
GO

CREATE TABLE FieldWorker (
    FieldID INT,
    WorkerID INT,
    PRIMARY KEY (FieldID, WorkerID),
    FOREIGN KEY (FieldID) REFERENCES Field(FieldID),
    FOREIGN KEY (WorkerID) REFERENCES Worker(WorkerID)
);
GO

CREATE TABLE Harvest (
    HarvestID INT PRIMARY KEY,
    FieldID INT,
    CropID INT,
    Quantity DECIMAL(10,2),
    HarvestDate DATE,
    FOREIGN KEY (FieldID) REFERENCES Field(FieldID),
    FOREIGN KEY (CropID) REFERENCES Crop(CropID)
);
GO

-- ================================================================
-- INSERTING DATA (DML)
-- ================================================================


PRINT '================================================================';
PRINT 'DML — INSERTING DATA';
PRINT '================================================================';
GO

INSERT INTO Farm (FarmID, FarmName, Location) VALUES
(1,'Green Farm','Armenia'),
(2,'Sunrise Farm','Armenia'),
(3,'Riverbend Farm','Armenia'),
(4,'Golden Field','Armenia'),
(5,'Valley Farm','Armenia'),
(6,'Highland Farm','Armenia'),
(7,'Blue Sky Farm','Armenia'),
(8,'Maple Farm','Armenia'),
(9,'Sunny Acres','Armenia'),
(10,'Evergreen Farm','Armenia'),
(11,'Silver Creek','Armenia'),
(12,'Red Oak Farm','Armenia'),
(13,'Golden Harvest','Armenia'),
(14,'Meadowlands','Armenia'),
(15,'Pine Hill Farm','Armenia'),
(16,'Autumn Farm','Armenia'),
(17,'Crystal Lake','Armenia'),
(18,'Cedar Grove','Armenia'),
(19,'Springfield Farm','Armenia'),
(20,'Hilltop Farm','Armenia'),
(21,'Willow Farm','Armenia'),
(22,'Cherry Blossom','Armenia'),
(23,'Sunset Farm','Armenia'),
(24,'River View','Armenia'),
(25,'Mountain Farm','Armenia'),
(26,'Oakwood Farm','Armenia'),
(27,'Blueberry Farm','Armenia'),
(28,'Golden Valley','Armenia'),
(29,'Maple Leaf Farm','Armenia'),
(30,'Silver Hill','Armenia'),
(31,'Everest Farm','Armenia'),
(32,'Pioneer Farm','Armenia'),
(33,'Harmony Farm','Armenia'),
(34,'Autumn Leaves','Armenia'),
(35,'Sunflower Farm','Armenia'),
(36,'Crystal Ridge','Armenia'),
(37,'Clover Field','Armenia'),
(38,'Oakridge Farm','Armenia'),
(39,'Riverbend South','Armenia'),
(40,'Maple Grove','Armenia'),
(41,'Green Valley','Armenia'),
(42,'Golden Meadow','Armenia'),
(43,'Blue Horizon','Armenia');
GO

INSERT INTO Crop (CropID, CropName, GrowthDuration) VALUES
(1,'Wheat',120),(2,'Corn',90),(3,'Potato',80),(4,'Rice',150),(5,'Barley',110),
(6,'Soybean',100),(7,'Tomato',75),(8,'Cucumber',60),(9,'Carrot',70),(10,'Onion',90),
(11,'Pea',60),(12,'Lettuce',50),(13,'Spinach',40),(14,'Pumpkin',100),(15,'Cabbage',85),
(16,'Strawberry',70),(17,'Blueberry',120),(18,'Apple',150),(19,'Pear',140),(20,'Cherry',130),
(21,'Plum',120),(22,'Grapes',110),(23,'Banana',200),(24,'Orange',180),(25,'Lemon',160),
(26,'Peach',140),(27,'Mango',150),(28,'Avocado',200),(29,'Broccoli',90),(30,'Cauliflower',85),
(31,'Radish',40),(32,'Beetroot',80),(33,'Sweet Potato',110),(34,'Cornflower',50),(35,'Melon',90),
(36,'Watermelon',100),(37,'Pumpkin Large',120),(38,'Sugarcane',200),(39,'Rye',100),(40,'Millet',85),
(41,'Quinoa',90),(42,'Oats',100),(43,'Sunflower',75);
GO

INSERT INTO Worker (WorkerID, Name) VALUES
(1,'Arman'),(2,'Anna'),(3,'David'),(4,'Karen'),(5,'Narek'),
(6,'Sofia'),(7,'Levon'),(8,'Tigran'),(9,'Mariam'),(10,'Hovhannes'),
(11,'Ani'),(12,'Vahan'),(13,'Lilit'),(14,'Garen'),(15,'Elena'),
(16,'Ruben'),(17,'Narine'),(18,'Vardan'),(19,'Susanna'),(20,'Artur'),
(21,'Emma'),(22,'Samvel'),(23,'Tamara'),(24,'Hayk'),(25,'Alina'),
(26,'Grigor'),(27,'Marine'),(28,'Arpi'),(29,'Lev'),(30,'Siranush'),
(31,'Ara'),(32,'Tatevik'),(33,'Karen S'),(34,'Hermine'),(35,'Raffi'),
(36,'Gayane'),(37,'Hrayr'),(38,'Elvina'),(39,'Sevak'),(40,'Armine'),
(41,'Shant'),(42,'Nana'),(43,'Vigen');
GO

INSERT INTO Field (FieldID, FarmID, Area) VALUES
(1,1,50.5),(2,1,30.0),(3,2,45.2),(4,2,60.0),(5,3,55.5),
(6,3,35.5),(7,4,40.0),(8,4,25.0),(9,5,70.0),(10,5,60.5),
(11,6,50.0),(12,6,45.0),(13,7,30.0),(14,7,40.0),(15,8,55.0),
(16,8,35.5),(17,9,60.0),(18,9,50.0),(19,10,45.0),(20,10,55.0),
(21,11,65.0),(22,11,50.5),(23,12,40.0),(24,12,30.0),(25,13,60.0),
(26,13,45.0),(27,14,35.0),(28,14,50.0),(29,15,55.0),(30,15,45.0),
(31,16,40.0),(32,16,35.5),(33,17,60.0),(34,17,50.0),(35,18,45.5),
(36,18,55.0),(37,19,40.0),(38,19,50.0),(39,20,60.0),(40,20,45.0),
(41,21,55.5),(42,21,50.0),(43,22,60.0);
GO

INSERT INTO FieldCrop (FieldID, CropID, PlantingDate) VALUES
(1,1,'2025-03-01'),(2,2,'2025-03-02'),(3,3,'2025-03-03'),(4,4,'2025-03-04'),(5,5,'2025-03-05'),
(6,6,'2025-03-06'),(7,7,'2025-03-07'),(8,8,'2025-03-08'),(9,9,'2025-03-09'),(10,10,'2025-03-10'),
(11,11,'2025-03-11'),(12,12,'2025-03-12'),(13,13,'2025-03-13'),(14,14,'2025-03-14'),(15,15,'2025-03-15'),
(16,16,'2025-03-16'),(17,17,'2025-03-17'),(18,18,'2025-03-18'),(19,19,'2025-03-19'),(20,20,'2025-03-20'),
(21,21,'2025-03-21'),(22,22,'2025-03-22'),(23,23,'2025-03-23'),(24,24,'2025-03-24'),(25,25,'2025-03-25'),
(26,26,'2025-03-26'),(27,27,'2025-03-27'),(28,28,'2025-03-28'),(29,29,'2025-03-29'),(30,30,'2025-03-30'),
(31,31,'2025-03-31'),(32,32,'2025-04-01'),(33,33,'2025-04-02'),(34,34,'2025-04-03'),(35,35,'2025-04-04'),
(36,36,'2025-04-05'),(37,37,'2025-04-06'),(38,38,'2025-04-07'),(39,39,'2025-04-08'),(40,40,'2025-04-09'),
(41,41,'2025-04-10'),(42,42,'2025-04-11'),(43,43,'2025-04-12');
GO

INSERT INTO Sensor (SensorID, FieldID, SensorType) VALUES
(1,1,'Moisture'),(2,1,'Temperature'),(3,2,'Humidity'),(4,2,'Moisture'),(5,3,'Temperature'),
(6,3,'Humidity'),(7,4,'Moisture'),(8,4,'Temperature'),(9,5,'Humidity'),(10,5,'Moisture'),
(11,6,'Temperature'),(12,6,'Humidity'),(13,7,'Moisture'),(14,7,'Temperature'),(15,8,'Humidity'),
(16,8,'Moisture'),(17,9,'Temperature'),(18,9,'Humidity'),(19,10,'Moisture'),(20,10,'Temperature'),
(21,11,'Humidity'),(22,11,'Moisture'),(23,12,'Temperature'),(24,12,'Humidity'),(25,13,'Moisture'),
(26,13,'Temperature'),(27,14,'Humidity'),(28,14,'Moisture'),(29,15,'Temperature'),(30,15,'Humidity'),
(31,16,'Moisture'),(32,16,'Temperature'),(33,17,'Humidity'),(34,17,'Moisture'),(35,18,'Temperature'),
(36,18,'Humidity'),(37,19,'Moisture'),(38,19,'Temperature'),(39,20,'Humidity'),(40,21,'Moisture'),
(41,22,'Temperature'),(42,23,'Humidity'),(43,24,'Moisture');
GO

INSERT INTO SensorData (DataID, SensorID, Value, RecordedTime) VALUES
(1,1,15.5,'2025-04-01 10:00:00'),
(2,2,23.0,'2025-04-01 10:05:00'),
(3,3,65.0,'2025-04-01 10:10:00'),
(4,4,30.0,'2025-04-01 10:15:00'),
(5,5,21.5,'2025-04-01 10:20:00'),
(6,6,62.0,'2025-04-01 10:25:00'),
(7,7,18.5,'2025-04-01 10:30:00'),
(8,8,24.0,'2025-04-01 10:35:00'),
(9,9,57.0,'2025-04-01 10:40:00'),
(10,10,19.5,'2025-04-01 10:45:00'),
(11,11,24.0,'2025-04-01 10:50:00'),
(12,12,59.5,'2025-04-01 10:55:00'),
(13,13,17.5,'2025-04-01 11:00:00'),
(14,14,22.5,'2025-04-01 11:05:00'),
(15,15,60.5,'2025-04-01 11:10:00'),
(16,16,20.5,'2025-04-01 11:15:00'),
(17,17,22.0,'2025-04-01 11:20:00'),
(18,18,62.5,'2025-04-01 11:25:00'),
(19,19,24.0,'2025-04-01 11:30:00'),
(20,20,22.5,'2025-04-01 11:35:00'),
(21,21,61.0,'2025-04-01 11:40:00'),
(22,22,23.5,'2025-04-01 11:45:00'),
(23,23,22.0,'2025-04-01 11:50:00'),
(24,24,60.5,'2025-04-01 11:55:00'),
(25,25,23.5,'2025-04-01 12:00:00'),
(26,26,22.0,'2025-04-01 12:05:00'),
(27,27,60.0,'2025-04-01 12:10:00'),
(28,28,19.5,'2025-04-01 12:15:00'),
(29,29,24.0,'2025-04-01 12:20:00'),
(30,30,22.5,'2025-04-01 12:25:00'),
(31,31,18.0,'2025-04-01 12:30:00'),
(32,32,22.0,'2025-04-01 12:35:00'),
(33,33,62.0,'2025-04-01 12:40:00'),
(34,34,23.0,'2025-04-01 12:45:00'),
(35,35,24.0,'2025-04-01 12:50:00'),
(36,36,22.5,'2025-04-01 12:55:00'),
(37,37,23.0,'2025-04-01 13:00:00'),
(38,38,21.5,'2025-04-01 13:05:00'),
(39,39,22.5,'2025-04-01 13:10:00'),
(40,40,24.0,'2025-04-01 13:15:00'),
(41,41,22.0,'2025-04-01 13:20:00'),
(42,42,23.5,'2025-04-01 13:25:00'),
(43,43,24.0,'2025-04-01 13:30:00');
GO

INSERT INTO IrrigationSystem (IrrigationID, FieldID, Status) VALUES
(1,1,'OFF'),(2,2,'ON'),(3,3,'OFF'),(4,4,'ON'),(5,5,'OFF'),
(6,6,'ON'),(7,7,'OFF'),(8,8,'ON'),(9,9,'OFF'),(10,10,'ON'),
(11,11,'OFF'),(12,12,'ON'),(13,13,'OFF'),(14,14,'ON'),(15,15,'OFF'),
(16,16,'ON'),(17,17,'OFF'),(18,18,'ON'),(19,19,'OFF'),(20,20,'ON'),
(21,21,'OFF'),(22,22,'ON'),(23,23,'OFF'),(24,24,'ON'),
(25,25,'OFF'),(26,26,'ON'),(27,27,'OFF'),(28,28,'ON'),
(29,29,'OFF'),(30,30,'ON'),(31,31,'OFF'),(32,32,'ON'),
(33,33,'OFF'),(34,34,'ON'),(35,35,'OFF'),(36,36,'ON'),
(37,37,'OFF'),(38,38,'ON'),(39,39,'OFF'),(40,40,'ON'),
(41,41,'OFF'),(42,42,'ON'),(43,43,'OFF');
GO

INSERT INTO FieldWorker (FieldID, WorkerID) VALUES
(1,1),(1,2),(2,3),(2,4),(3,5),(3,6),(4,7),(4,8),(5,9),(5,10),
(6,11),(6,12),(7,13),(7,14),(8,15),(8,16),(9,17),(9,18),(10,19),(10,20),
(11,21),(11,22),(12,23),(12,24),(13,25),(13,26),(14,27),(14,28),(15,29),(15,30),
(16,31),(16,32),(17,33),(17,34),(18,35),(18,36),(19,37),(19,38),(20,39),(20,40),
(21,41),(21,42),(22,43);
GO

INSERT INTO Harvest (HarvestID, FieldID, CropID, Quantity, HarvestDate) VALUES
(1,1,1,200.5,'2025-07-01'),(2,2,2,150.0,'2025-07-02'),(3,3,3,180.0,'2025-07-03'),
(4,4,4,220.0,'2025-07-04'),(5,5,5,160.0,'2025-07-05'),(6,6,6,190.0,'2025-07-06'),
(7,7,7,175.0,'2025-07-07'),(8,8,8,200.0,'2025-07-08'),(9,9,9,185.0,'2025-07-09'),
(10,10,10,195.0,'2025-07-10'),(11,11,11,180.0,'2025-07-11'),(12,12,12,170.0,'2025-07-12'),
(13,13,13,160.0,'2025-07-13'),(14,14,14,155.0,'2025-07-14'),(15,15,15,165.0,'2025-07-15'),
(16,16,16,175.0,'2025-07-16'),(17,17,17,185.0,'2025-07-17'),(18,18,18,190.0,'2025-07-18'),
(19,19,19,195.0,'2025-07-19'),(20,20,20,200.0,'2025-07-20'),(21,21,21,205.0,'2025-07-21'),
(22,22,22,210.0,'2025-07-22'),(23,23,23,215.0,'2025-07-23'),(24,24,24,220.0,'2025-07-24'),
(25,25,25,225.0,'2025-07-25'),(26,26,26,230.0,'2025-07-26'),(27,27,27,235.0,'2025-07-27'),
(28,28,28,240.0,'2025-07-28'),(29,29,29,245.0,'2025-07-29'),(30,30,30,250.0,'2025-07-30'),
(31,31,31,255.0,'2025-07-31'),(32,32,32,260.0,'2025-08-01'),(33,33,33,265.0,'2025-08-02'),
(34,34,34,270.0,'2025-08-03'),(35,35,35,275.0,'2025-08-04'),(36,36,36,280.0,'2025-08-05'),
(37,37,37,285.0,'2025-08-06'),(38,38,38,290.0,'2025-08-07'),(39,39,39,295.0,'2025-08-08'),
(40,40,40,300.0,'2025-08-09'),(41,41,41,305.0,'2025-08-10'),(42,42,42,310.0,'2025-08-11'),
(43,43,43,315.0,'2025-08-12');
GO




-- ================================================================
-- DQL — RELATIONAL QUERIES
-- ================================================================


PRINT '================================================================';
PRINT 'DQL — RELATIONAL QUERIES';
PRINT '================================================================';
GO

-- 1. View all farms
SELECT * FROM Farm;
GO

-- 2. Crops with growth duration > 100
SELECT CropName, GrowthDuration 
FROM Crop 
WHERE GrowthDuration > 100;
GO

-- 3. Farms with their fields
SELECT F.FarmName, Fi.FieldID, Fi.Area
FROM Farm F
JOIN Field Fi ON F.FarmID = Fi.FarmID;
GO

-- 4. Crops with long growth duration (>120)
SELECT CropName, GrowthDuration
FROM Crop
WHERE GrowthDuration > 120;
GO

-- 5. Sensor data with high temperature
SELECT SD.SensorID, SD.Value, SD.RecordedTime
FROM SensorData SD
JOIN Sensor S ON SD.SensorID = S.SensorID
WHERE S.SensorType = 'Temperature' AND SD.Value > 23;
GO

-- 6. Total harvest per farm
SELECT F.FarmName, SUM(H.Quantity) AS TotalHarvest
FROM Harvest H
JOIN Field Fi ON H.FieldID = Fi.FieldID
JOIN Farm F ON Fi.FarmID = F.FarmID
GROUP BY F.FarmName;
GO

-- 7. Average sensor readings per field 
SELECT S.FieldID,
       AVG(CASE WHEN S.SensorType = 'Temperature' THEN SD.Value END) AS AvgTemp,
       AVG(CASE WHEN S.SensorType = 'Moisture' THEN SD.Value END) AS AvgMoisture,
       AVG(CASE WHEN S.SensorType = 'Humidity' THEN SD.Value END) AS AvgHumidity
FROM SensorData SD
JOIN Sensor S ON SD.SensorID = S.SensorID
GROUP BY S.FieldID;
GO

-- 8. Top 5 farms by total harvest
SELECT TOP 5 F.FarmName, SUM(H.Quantity) AS TotalHarvest
FROM Harvest H
JOIN Field Fi ON H.FieldID = Fi.FieldID
JOIN Farm F ON Fi.FarmID = F.FarmID
GROUP BY F.FarmName
ORDER BY TotalHarvest DESC;
GO

-- 9. Fields with no irrigation system ON
SELECT FieldID
FROM IrrigationSystem
GROUP BY FieldID
HAVING SUM(CASE WHEN Status = 'ON' THEN 1 ELSE 0 END) = 0;
GO

-- 10. Crops planted but not yet harvested
SELECT FC.FieldID, FC.CropID
FROM FieldCrop FC
LEFT JOIN Harvest H 
ON FC.FieldID = H.FieldID AND FC.CropID = H.CropID
WHERE H.HarvestID IS NULL;
GO

-- 11. Workers assigned to multiple fields
SELECT WorkerID, COUNT(FieldID) AS FieldCount
FROM FieldWorker
GROUP BY WorkerID
HAVING COUNT(FieldID) > 1;
GO



-- 12. Highest temperature recorded per field
SELECT S.FieldID, MAX(SD.Value) AS MaxTemp
FROM SensorData SD
JOIN Sensor S ON SD.SensorID = S.SensorID
WHERE S.SensorType = 'Temperature'
GROUP BY S.FieldID;
GO

-- 13. Daily average temperature
SELECT CAST(SD.RecordedTime AS DATE) AS Date,
       AVG(SD.Value) AS AvgTemp
FROM SensorData SD
JOIN Sensor S ON SD.SensorID = S.SensorID
WHERE S.SensorType = 'Temperature'
GROUP BY CAST(SD.RecordedTime AS DATE);
GO

-- 14. Farms with largest total field area
SELECT F.FarmName, SUM(Fi.Area) AS TotalArea
FROM Farm F
JOIN Field Fi ON F.FarmID = Fi.FarmID
GROUP BY F.FarmName
ORDER BY TotalArea DESC;
GO

-- 15. Sensors that recorded abnormal conditions
SELECT DISTINCT SD.SensorID
FROM SensorData SD
JOIN Sensor S ON SD.SensorID = S.SensorID
WHERE 
    (S.SensorType = 'Temperature' AND SD.Value > 30)
    OR
    (S.SensorType = 'Moisture' AND SD.Value < 15);
GO

-- 16. Crop count per farm
SELECT F.FarmName, COUNT(DISTINCT FC.CropID) AS CropCount
FROM FieldCrop FC
JOIN Field Fi ON FC.FieldID = Fi.FieldID
JOIN Farm F ON Fi.FarmID = F.FarmID
GROUP BY F.FarmName;
GO

-- 17. Worker assignment details
SELECT W.Name, FW.FieldID
FROM Worker W
JOIN FieldWorker FW ON W.WorkerID = FW.WorkerID;
GO

--18. Irrigation current status
SELECT FieldID, Status
FROM IrrigationSystem;
GO




-- ================================================================
-- VIEWS
-- ================================================================


PRINT '================================================================';
PRINT 'VIEWS';
PRINT '================================================================';
GO

-- 1. Field Sensor Summary View
IF OBJECT_ID('FieldSensorSummary', 'V') IS NOT NULL
    DROP VIEW FieldSensorSummary;
GO
CREATE VIEW FieldSensorSummary AS
SELECT 
    S.FieldID,
    AVG(CASE WHEN S.SensorType = 'Temperature' THEN SD.Value END) AS AvgTemp,
    AVG(CASE WHEN S.SensorType = 'Moisture' THEN SD.Value END) AS AvgMoisture,
    AVG(CASE WHEN S.SensorType = 'Humidity' THEN SD.Value END) AS AvgHumidity
FROM SensorData SD
JOIN Sensor S ON SD.SensorID = S.SensorID
GROUP BY S.FieldID;
GO

-- 2. Farm Total Harvest View
IF OBJECT_ID('FarmTotalHarvest', 'V') IS NOT NULL
    DROP VIEW FarmTotalHarvest;
GO
CREATE VIEW FarmTotalHarvest AS
SELECT 
    F.FarmName,
    SUM(H.Quantity) AS TotalHarvest
FROM Harvest H
JOIN Field Fi ON H.FieldID = Fi.FieldID
JOIN Farm F ON Fi.FarmID = F.FarmID
GROUP BY F.FarmName;
GO

-- 3. Irrigation Status View
IF OBJECT_ID('IrrigationStatus', 'V') IS NOT NULL
    DROP VIEW IrrigationStatus;
GO
CREATE VIEW IrrigationStatus AS
SELECT 
    Fi.FieldID,
    Fi.Area,
    I.Status,
    I.LastUpdated
FROM Field Fi
JOIN IrrigationSystem I ON Fi.FieldID = I.FieldID;
GO

-- 4. Worker Assignment Summary View
IF OBJECT_ID('WorkerAssignmentSummary', 'V') IS NOT NULL
    DROP VIEW WorkerAssignmentSummary;
GO
CREATE VIEW WorkerAssignmentSummary AS
SELECT 
    W.Name AS WorkerName,
    COUNT(FW.FieldID) AS AssignedFields,
    STRING_AGG(CAST(FW.FieldID AS VARCHAR(10)), ', ') AS FieldIDs
FROM Worker W
JOIN FieldWorker FW ON W.WorkerID = FW.WorkerID
GROUP BY W.Name;
GO

-- 5. Critical Field Conditions View
IF OBJECT_ID('CriticalFieldConditions', 'V') IS NOT NULL
    DROP VIEW CriticalFieldConditions;
GO
CREATE VIEW CriticalFieldConditions AS
SELECT 
    S.FieldID,
    S.SensorType,
    SD.Value,
    SD.RecordedTime
FROM SensorData SD
JOIN Sensor S ON SD.SensorID = S.SensorID
WHERE 
    (S.SensorType = 'Temperature' AND SD.Value > 30)
    OR
    (S.SensorType = 'Moisture' AND SD.Value < 15);
GO





-- ================================================================
-- INDEXES
-- ================================================================


PRINT '================================================================';
PRINT 'INDEXES';
PRINT '================================================================';
GO

-- Index on SensorData for faster sensor queries
CREATE INDEX IDX_SensorData_SensorID ON SensorData(SensorID);
CREATE INDEX IDX_SensorData_RecordedTime ON SensorData(RecordedTime);

-- Index on Harvest for faster farm/field aggregation
CREATE INDEX IDX_Harvest_FieldID ON Harvest(FieldID);
CREATE INDEX IDX_Harvest_CropID ON Harvest(CropID);

-- Index on FieldWorker for quicker worker-field lookups
CREATE INDEX IDX_FieldWorker_WorkerID ON FieldWorker(WorkerID);

-- Index on IrrigationSystem for status queries
CREATE INDEX IDX_Irrigation_FieldID ON IrrigationSystem(FieldID);
CREATE INDEX IDX_Irrigation_Status ON IrrigationSystem(Status);

-- Index on FieldCrop for unharvested crop queries
CREATE INDEX IDX_FieldCrop_FieldID_CropID ON FieldCrop(FieldID, CropID);
GO



-- ================================================================
-- TRIGGERS
-- ================================================================


PRINT '================================================================';
PRINT 'TRIGGERS';
PRINT '================================================================';
GO

--Trigger 1: Automatically update LastUpdated in IrrigationSystem when Status changes
CREATE TRIGGER TR_UpdateIrrigationLastUpdated
ON IrrigationSystem
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Update only rows where Status changed
    UPDATE I
    SET LastUpdated = GETDATE()
    FROM IrrigationSystem I
    INNER JOIN inserted ins
        ON I.IrrigationID = ins.IrrigationID
    WHERE I.Status <> ins.Status;
END;
GO

--Trigger 2: Prevent inserting negative harvest quantities
CREATE TRIGGER TR_ValidateHarvestQuantity
ON Harvest
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE Quantity < 0)
    BEGIN
        RAISERROR('Harvest quantity cannot be negative.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    INSERT INTO Harvest(HarvestID, FieldID, CropID, Quantity, HarvestDate)
    SELECT HarvestID, FieldID, CropID, Quantity, HarvestDate FROM inserted;
END;
GO

--Trigger 3: Automatically turn ON irrigation if moisture sensor reading is below 20
CREATE TRIGGER TR_AutoIrrigation
ON SensorData
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Turn ON irrigation if a new moisture reading is below 20
    UPDATE I
    SET I.Status = 'ON',
        I.LastUpdated = GETDATE()
    FROM IrrigationSystem I
    INNER JOIN Sensor S ON I.FieldID = S.FieldID
    INNER JOIN inserted ins ON S.SensorID = ins.SensorID
    WHERE S.SensorType = 'Moisture'
      AND ins.Value < 20
      AND I.Status <> 'ON'; -- optional: update only if it's not already ON
END;
GO 

--Trigger 4: Create SensorAlerts table if it doesn't exist
IF OBJECT_ID('SensorAlerts', 'U') IS NOT NULL
    DROP TABLE SensorAlerts;
GO

CREATE TABLE SensorAlerts (
    AlertID INT IDENTITY(1,1) PRIMARY KEY,
    SensorID INT,
    Value DECIMAL(6,2),
    RecordedTime DATETIME,
    AlertType VARCHAR(50),
    CONSTRAINT FK_SensorAlerts_Sensor FOREIGN KEY (SensorID) REFERENCES Sensor(SensorID)
);
GO

CREATE TRIGGER TR_LogSensorAnomalies
ON SensorData
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO SensorAlerts (SensorID, Value, RecordedTime, AlertType)
    SELECT i.SensorID, i.Value, i.RecordedTime,
           CASE 
               WHEN S.SensorType = 'Temperature' AND i.Value > 30 THEN 'High Temp'
               WHEN S.SensorType = 'Moisture' AND i.Value < 15 THEN 'Low Moisture'
               WHEN S.SensorType = 'Humidity' AND i.Value > 80 THEN 'High Humidity'
           END
    FROM inserted i
    JOIN Sensor S ON i.SensorID = S.SensorID
    WHERE (S.SensorType = 'Temperature' AND i.Value > 30)
       OR (S.SensorType = 'Moisture' AND i.Value < 15)
       OR (S.SensorType = 'Humidity' AND i.Value > 80);
END;
GO 

--Trigger 5: Prevent assigning a worker to more than 3 fields
CREATE TRIGGER TR_WorkerFieldLimit
ON FieldWorker
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FieldWorker(FieldID, WorkerID)
    SELECT FW.FieldID, FW.WorkerID
    FROM inserted FW
    WHERE (
        SELECT COUNT(*) 
        FROM FieldWorker 
        WHERE WorkerID = FW.WorkerID
    ) < 3;

    IF EXISTS (
        SELECT 1
        FROM inserted FW
        WHERE (
            SELECT COUNT(*) 
            FROM FieldWorker 
            WHERE WorkerID = FW.WorkerID
        ) >= 3
    )
    BEGIN
        RAISERROR('A worker cannot be assigned to more than 3 fields!', 16, 1);
    END
END;
GO



-- ================================================================
-- STORED PROCEDURES
-- ================================================================


PRINT '================================================================';
PRINT 'STORED PROCEDURES';
PRINT '================================================================';
GO

IF OBJECT_ID('GetFarmHarvest', 'P') IS NOT NULL DROP PROCEDURE GetFarmHarvest;
GO
CREATE PROCEDURE GetFarmHarvest
AS
BEGIN
    SELECT F.FarmName, SUM(H.Quantity) AS TotalHarvest
    FROM Harvest H
    JOIN Field Fi ON H.FieldID = Fi.FieldID
    JOIN Farm F ON Fi.FarmID = F.FarmID
    GROUP BY F.FarmName;
END
GO

IF OBJECT_ID('GetFieldSensorData', 'P') IS NOT NULL DROP PROCEDURE GetFieldSensorData;
GO
CREATE PROCEDURE GetFieldSensorData
    @FieldID INT
AS
BEGIN
    SELECT S.SensorID, S.SensorType, SD.Value, SD.RecordedTime
    FROM Sensor S
    JOIN SensorData SD ON S.SensorID = SD.SensorID
    WHERE S.FieldID = @FieldID
    ORDER BY SD.RecordedTime;
END
GO

IF OBJECT_ID('GetWorkerFields', 'P') IS NOT NULL DROP PROCEDURE GetWorkerFields;
GO
CREATE PROCEDURE GetWorkerFields
    @WorkerID INT
AS
BEGIN
    SELECT FW.FieldID, F.Area, F.FarmID, Fa.FarmName
    FROM FieldWorker FW
    JOIN Field F ON FW.FieldID = F.FieldID
    JOIN Farm Fa ON F.FarmID = Fa.FarmID
    WHERE FW.WorkerID = @WorkerID;
END
GO

IF OBJECT_ID('GetIrrigationStatus', 'P') IS NOT NULL DROP PROCEDURE GetIrrigationStatus;
GO
CREATE PROCEDURE GetIrrigationStatus
AS
BEGIN
    SELECT FieldID, Status, LastUpdated
    FROM IrrigationSystem;
END
GO

IF OBJECT_ID('AddHarvest', 'P') IS NOT NULL DROP PROCEDURE AddHarvest;
GO
CREATE PROCEDURE AddHarvest
    @FieldID INT,
    @CropID INT,
    @Quantity DECIMAL(10,2),
    @HarvestDate DATE
AS
BEGIN
    INSERT INTO Harvest (FieldID, CropID, Quantity, HarvestDate)
    VALUES (@FieldID, @CropID, @Quantity, @HarvestDate);
END
GO

IF OBJECT_ID('AddSensorData', 'P') IS NOT NULL DROP PROCEDURE AddSensorData;
GO
CREATE PROCEDURE AddSensorData
    @SensorID INT,
    @Value DECIMAL(6,2),
    @RecordedTime DATETIME
AS
BEGIN
    INSERT INTO SensorData (SensorID, Value, RecordedTime)
    VALUES (@SensorID, @Value, @RecordedTime);
END
GO

IF OBJECT_ID('UpdateIrrigationStatus', 'P') IS NOT NULL DROP PROCEDURE UpdateIrrigationStatus;
GO
CREATE PROCEDURE UpdateIrrigationStatus
    @FieldID INT,
    @NewStatus VARCHAR(10)
AS
BEGIN
    DECLARE @Moisture DECIMAL(6,2);

    SELECT @Moisture = AVG(SD.Value)
    FROM Sensor S
    JOIN SensorData SD ON S.SensorID = SD.SensorID
    WHERE S.FieldID = @FieldID AND S.SensorType = 'Moisture';

    IF @NewStatus = 'ON' AND @Moisture > 60
    BEGIN
        PRINT 'Irrigation cannot be turned ON: soil moisture too high.';
    END
    ELSE
    BEGIN
        UPDATE IrrigationSystem
        SET Status = @NewStatus,
            LastUpdated = GETDATE()
        WHERE FieldID = @FieldID;
    END
END
GO

IF OBJECT_ID('GetUnharvestedCrops', 'P') IS NOT NULL DROP PROCEDURE GetUnharvestedCrops;
GO
CREATE PROCEDURE GetUnharvestedCrops
AS
BEGIN
    SELECT FC.FieldID, FC.CropID, C.CropName, FC.PlantingDate
    FROM FieldCrop FC
    JOIN Crop C ON FC.CropID = C.CropID
    LEFT JOIN Harvest H
    ON FC.FieldID = H.FieldID AND FC.CropID = H.CropID
    WHERE H.HarvestID IS NULL;
END
GO

IF OBJECT_ID('GetTopFarms', 'P') IS NOT NULL DROP PROCEDURE GetTopFarms;
GO
CREATE PROCEDURE GetTopFarms
    @TopN INT
AS
BEGIN
    SELECT TOP (@TopN) F.FarmName, SUM(H.Quantity) AS TotalHarvest
    FROM Harvest H
    JOIN Field Fi ON H.FieldID = Fi.FieldID
    JOIN Farm F ON Fi.FarmID = F.FarmID
    GROUP BY F.FarmName
    ORDER BY TotalHarvest DESC;
END
GO


-- ================================================================
-- DCL — ACCESS CONTROL
-- ================================================================


PRINT '================================================================';
PRINT 'DCL — ACCESS CONTROL';
PRINT '================================================================';
GO
-- Drop logins if exist
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'FarmAdmin')
    DROP LOGIN FarmAdmin;
GO
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'FarmWorker')
    DROP LOGIN FarmWorker;
GO
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'FarmViewer')
    DROP LOGIN FarmViewer;
GO

-- Create Logins
CREATE LOGIN FarmAdmin WITH PASSWORD = 'Admin@123';
CREATE LOGIN FarmWorker WITH PASSWORD = 'Worker@123';
CREATE LOGIN FarmViewer WITH PASSWORD = 'Viewer@123';
GO

USE SmartAgricultureDB;
GO

-- Drop users if exist
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdminUser')
    DROP USER AdminUser;
GO
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'WorkerUser')
    DROP USER WorkerUser;
GO
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ViewerUser')
    DROP USER ViewerUser;
GO

-- Create Users
CREATE USER AdminUser FOR LOGIN FarmAdmin;
CREATE USER WorkerUser FOR LOGIN FarmWorker;
CREATE USER ViewerUser FOR LOGIN FarmViewer;
GO

-- ================================================================
-- DQL —RELATIONAL ALGEBRA QUERIES
-- ================================================================

PRINT '================================================================';
PRINT 'DQL — RELATIONAL ALGEBRA QUERIES ';
PRINT '================================================================';
GO

-- ── SELECTION σ ───────────────────────────────────────────────
PRINT '';
PRINT '--- SELECTION (sigma) ---';
GO

-- Q1: Fields with area > 50
SELECT FieldID, Area 
FROM Field 
WHERE Area > 50;
GO

-- Q2: Crops with long growth duration (>120)
SELECT CropName, GrowthDuration 
FROM Crop 
WHERE GrowthDuration > 120;
GO

-- Q3: Irrigation systems that are ON
SELECT FieldID, Status 
FROM IrrigationSystem 
WHERE Status = 'ON';
GO


-- ── PROJECTION π ─────────────────────────────────────────────
PRINT '';
PRINT '--- PROJECTION (pi) ---';
GO

-- Q4: Only farm names
SELECT FarmName FROM Farm;
GO

-- Q5: Worker names only
SELECT Name FROM Worker;
GO

-- Q6: Sensor types only
SELECT SensorType FROM Sensor;
GO


-- ── JOIN ⋈ ───────────────────────────────────────────────────
PRINT '';
PRINT '--- JOIN ---';
GO

-- Q7: Farms with their fields
SELECT F.FarmName, Fi.FieldID, Fi.Area
FROM Farm F
JOIN Field Fi ON F.FarmID = Fi.FarmID;
GO

-- Q8: Fields with crops
SELECT FC.FieldID, C.CropName
FROM FieldCrop FC
JOIN Crop C ON FC.CropID = C.CropID;
GO

-- Q9: Sensor data with sensor type
SELECT S.SensorType, SD.Value, SD.RecordedTime
FROM SensorData SD
JOIN Sensor S ON SD.SensorID = S.SensorID;
GO


-- ── AGGREGATION γ ────────────────────────────────────────────
PRINT '';
PRINT '--- AGGREGATION (gamma) ---';
GO

-- Q10: Total harvest per farm
SELECT F.FarmName, SUM(H.Quantity) AS TotalHarvest
FROM Harvest H
JOIN Field Fi ON H.FieldID = Fi.FieldID
JOIN Farm F ON Fi.FarmID = F.FarmID
GROUP BY F.FarmName;
GO

-- Q11: Average sensor value per field
SELECT S.FieldID, AVG(SD.Value) AS AvgValue
FROM SensorData SD
JOIN Sensor S ON SD.SensorID = S.SensorID
GROUP BY S.FieldID;
GO

-- Q12: Number of workers per field
SELECT FieldID, COUNT(WorkerID) AS WorkerCount
FROM FieldWorker
GROUP BY FieldID;
GO


-- ── UNION ∪ ─────────────────────────────────────────────────
PRINT '';
PRINT '--- UNION ---';
GO

-- Q13: All IDs from Farm and Worker
SELECT FarmID AS ID FROM Farm
UNION
SELECT WorkerID FROM Worker;
GO


-- ── INTERSECTION ∩ ──────────────────────────────────────────
PRINT '';
PRINT '--- INTERSECTION ---';
GO

-- Q14: Fields that exist in both Field and IrrigationSystem
SELECT FieldID FROM Field
INTERSECT
SELECT FieldID FROM IrrigationSystem;
GO


-- ── DIFFERENCE − ────────────────────────────────────────────
PRINT '';
PRINT '--- DIFFERENCE ---';
GO

-- Q15: Fields without irrigation
SELECT FieldID FROM Field
WHERE FieldID NOT IN (SELECT FieldID FROM IrrigationSystem);
GO


-- ── SUBQUERIES ──────────────────────────────────────────────
PRINT '';
PRINT '--- SUBQUERIES ---';
GO

-- Q16: Crops with above-average growth duration
SELECT CropName, GrowthDuration
FROM Crop
WHERE GrowthDuration > (SELECT AVG(GrowthDuration) FROM Crop);
GO

-- Q17: Fields with highest harvest
SELECT FieldID, Quantity
FROM Harvest
WHERE Quantity = (SELECT MAX(Quantity) FROM Harvest);
GO

-- Q18: Sensors with values above average
SELECT SensorID, Value
FROM SensorData
WHERE Value > (SELECT AVG(Value) FROM SensorData);
GO


PRINT '';
PRINT '[DONE] Relational Algebra Queries Executed Successfully';
GO

