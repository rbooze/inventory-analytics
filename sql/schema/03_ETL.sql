/******************************************************************************************
 ETL SQL SCRIPTS
 Inventory Analytics Platform (SQL + Power BI)
 Author: Rodney Booze
 Version: 1.0
 Date: August 2026
******************************************************************************************/

/******************************************************************************************
 1. STAGING TABLES (RAW LOAD)
******************************************************************************************/

-- Inventory
CREATE TABLE stg_inventory (
    SKU              VARCHAR(50),
    WarehouseName    VARCHAR(200),
    OnHandQty        DECIMAL(18,2),
    AvailableQty     DECIMAL(18,2),
    BackorderQty     DECIMAL(18,2),
    UnitCost         DECIMAL(18,4),
    Date             DATE,
    FileName         VARCHAR(200),
    LoadTimestamp    DATETIME DEFAULT GETDATE()
);

-- Sales
CREATE TABLE stg_sales (
    SKU              VARCHAR(50),
    CustomerName     VARCHAR(200),
    QuantitySold     DECIMAL(18,2),
    Revenue          DECIMAL(18,2),
    OrderQty         DECIMAL(18,2),
    ShippingCost     DECIMAL(18,2),
    ShippingTime     INT,
    CarrierName      VARCHAR(200),
    Date             DATE,
    FileName         VARCHAR(200),
    LoadTimestamp    DATETIME DEFAULT GETDATE()
);

-- Supplier Performance
CREATE TABLE stg_supplier_performance (
    SupplierName     VARCHAR(200),
    SKU              VARCHAR(50),
    LeadTimeDays     INT,
    DefectRate       DECIMAL(18,4),
    InspectionResult VARCHAR(100),
    ManufacturingCost DECIMAL(18,2),
    ProductionVolume DECIMAL(18,2),
    Date             DATE,
    FileName         VARCHAR(200),
    LoadTimestamp    DATETIME DEFAULT GETDATE()
);

-- Manufacturing
CREATE TABLE stg_manufacturing (
    SKU                  VARCHAR(50),
    ProductionVolume     DECIMAL(18,2),
    ManufacturingLeadTime INT,
    ManufacturingCost    DECIMAL(18,2),
    DefectRate           DECIMAL(18,4),
    Date                 DATE,
    FileName             VARCHAR(200),
    LoadTimestamp        DATETIME DEFAULT GETDATE()
);

-- Transportation
CREATE TABLE stg_transportation (
    CarrierName       VARCHAR(200),
    Origin            VARCHAR(200),
    Destination       VARCHAR(200),
    ModeName          VARCHAR(50),
    ShippingTime      INT,
    ShippingCost      DECIMAL(18,2),
    Distance          DECIMAL(18,2),
    OnTimeDeliveryFlag BIT,
    Date              DATE,
    FileName          VARCHAR(200),
    LoadTimestamp     DATETIME DEFAULT GETDATE()
);

/******************************************************************************************
 2. ERROR LOGGING TABLES
******************************************************************************************/

CREATE TABLE etl_error_log (
    ErrorId        INT IDENTITY(1,1) PRIMARY KEY,
    TableName      VARCHAR(200),
    ErrorMessage   VARCHAR(500),
    RowData        VARCHAR(MAX),
    BatchId        VARCHAR(100),
    ErrorTimestamp DATETIME DEFAULT GETDATE()
);

CREATE TABLE etl_batch_log (
    BatchId        VARCHAR(100) PRIMARY KEY,
    SourceFile     VARCHAR(200),
    LoadTimestamp  DATETIME DEFAULT GETDATE(),
    Status         VARCHAR(50)
);

/******************************************************************************************
 3. DIMENSION LOAD PROCEDURES
******************************************************************************************/

/* Load DimProduct */
CREATE OR ALTER PROCEDURE Load_DimProduct AS
BEGIN
    INSERT INTO DimProduct (SKU, ProductName, ProductType, Category, Price)
    SELECT DISTINCT
        SKU,
        SKU AS ProductName,       -- Placeholder if no master data
        NULL AS ProductType,
        NULL AS Category,
        NULL AS Price
    FROM stg_inventory
    WHERE SKU NOT IN (SELECT SKU FROM DimProduct);
END;

/* Load DimWarehouse */
CREATE OR ALTER PROCEDURE Load_DimWarehouse AS
BEGIN
    INSERT INTO DimWarehouse (WarehouseName, Location, Region)
    SELECT DISTINCT
        WarehouseName,
        NULL AS Location,
        NULL AS Region
    FROM stg_inventory
    WHERE WarehouseName NOT IN (SELECT WarehouseName FROM DimWarehouse);
END;

/* Load DimSupplier */
CREATE OR ALTER PROCEDURE Load_DimSupplier AS
BEGIN
    INSERT INTO DimSupplier (SupplierName, Location, Region)
    SELECT DISTINCT
        SupplierName,
        NULL AS Location,
        NULL AS Region
    FROM stg_supplier_performance
    WHERE SupplierName NOT IN (SELECT SupplierName FROM DimSupplier);
END;

/* Load DimCarrier */
CREATE OR ALTER PROCEDURE Load_DimCarrier AS
BEGIN
    INSERT INTO DimCarrier (CarrierName, Mode)
    SELECT DISTINCT
        CarrierName,
        NULL AS Mode
    FROM stg_sales
    WHERE CarrierName NOT IN (SELECT CarrierName FROM DimCarrier);
END;

/* Load DimRoute */
CREATE OR ALTER PROCEDURE Load_DimRoute AS
BEGIN
    INSERT INTO DimRoute (Origin, Destination, Distance)
    SELECT DISTINCT
        Origin,
        Destination,
        Distance
    FROM stg_transportation
    WHERE NOT EXISTS (
        SELECT 1 FROM DimRoute
        WHERE Origin = stg_transportation.Origin
          AND Destination = stg_transportation.Destination
    );
END;

/* Load DimTransportMode */
CREATE OR ALTER PROCEDURE Load_DimTransportMode AS
BEGIN
    INSERT INTO DimTransportMode (ModeName)
    SELECT DISTINCT ModeName
    FROM stg_transportation
    WHERE ModeName NOT IN (SELECT ModeName FROM DimTransportMode);
END;

/* Load DimCustomer */
CREATE OR ALTER PROCEDURE Load_DimCustomer AS
BEGIN
    INSERT INTO DimCustomer (CustomerName, Segment, Region)
    SELECT DISTINCT
        CustomerName,
        NULL AS Segment,
        NULL AS Region
    FROM stg_sales
    WHERE CustomerName NOT IN (SELECT CustomerName FROM DimCustomer);
END;

/******************************************************************************************
 4. FACT LOAD PROCEDURES
******************************************************************************************/

/* Load FactInventory */
CREATE OR ALTER PROCEDURE Load_FactInventory AS
BEGIN
    INSERT INTO FactInventory (
        DateKey, ProductKey, WarehouseKey,
        OnHandQty, AvailableQty, BackorderQty,
        UnitCost, InventoryValue
    )
    SELECT
        CONVERT(INT, FORMAT(Date, 'yyyyMMdd')) AS DateKey,
        p.ProductKey,
        w.WarehouseKey,
        ISNULL(OnHandQty, 0),
        AvailableQty,
        BackorderQty,
        UnitCost,
        OnHandQty * UnitCost AS InventoryValue
    FROM stg_inventory s
    JOIN DimProduct p ON s.SKU = p.SKU
    JOIN DimWarehouse w ON s.WarehouseName = w.WarehouseName;
END;

/* Load FactSales */
CREATE OR ALTER PROCEDURE Load_FactSales AS
BEGIN
    INSERT INTO FactSales (
        DateKey, ProductKey, CustomerKey, CarrierKey,
        QuantitySold, Revenue, OrderQty, ShippingCost, ShippingTime
    )
    SELECT
        CONVERT(INT, FORMAT(Date, 'yyyyMMdd')),
        p.ProductKey,
        c.CustomerKey,
        ca.CarrierKey,
        QuantitySold,
        Revenue,
        OrderQty,
        ShippingCost,
        ShippingTime
    FROM stg_sales s
    JOIN DimProduct p ON s.SKU = p.SKU
    JOIN DimCustomer c ON s.CustomerName = c.CustomerName
    LEFT JOIN DimCarrier ca ON s.CarrierName = ca.CarrierName;
END;

/* Load FactSupplierPerformance */
CREATE OR ALTER PROCEDURE Load_FactSupplierPerformance AS
BEGIN
    INSERT INTO FactSupplierPerformance (
        DateKey, SupplierKey, ProductKey,
        LeadTimeDays, DefectRate, InspectionResult,
        ManufacturingCost, ProductionVolume
    )
    SELECT
        CONVERT(INT, FORMAT(Date, 'yyyyMMdd')),
        sup.SupplierKey,
        p.ProductKey,
        LeadTimeDays,
        CASE WHEN DefectRate > 1 THEN 1 ELSE DefectRate END,
        InspectionResult,
        ManufacturingCost,
        ProductionVolume
    FROM stg_supplier_performance s
    JOIN DimSupplier sup ON s.SupplierName = sup.SupplierName
    JOIN DimProduct p ON s.SKU = p.SKU;
END;

/* Load FactManufacturing */
CREATE OR ALTER PROCEDURE Load_FactManufacturing AS
BEGIN
    INSERT INTO FactManufacturing (
        DateKey, ProductKey,
        ProductionVolume, ManufacturingLeadTime,
        ManufacturingCost, DefectRate
    )
    SELECT
        CONVERT(INT, FORMAT(Date, 'yyyyMMdd')),
        p.ProductKey,
        ProductionVolume,
        ManufacturingLeadTime,
        ManufacturingCost,
        DefectRate
    FROM stg_manufacturing s
    JOIN DimProduct p ON s.SKU = p.SKU;
END;

/* Load FactTransportation */
CREATE OR ALTER PROCEDURE Load_FactTransportation AS
BEGIN
    INSERT INTO FactTransportation (
        DateKey, CarrierKey, RouteKey, TransportModeKey,
        ShippingTime, ShippingCost, Distance, OnTimeDeliveryFlag
    )
    SELECT
        CONVERT(INT, FORMAT(s.Date, 'yyyyMMdd')),
        ca.CarrierKey,
        r.RouteKey,
        tm.TransportModeKey,
        s.ShippingTime,
        s.ShippingCost,
        s.Distance,               -- Fully qualified to remove ambiguity
        s.OnTimeDeliveryFlag
    FROM stg_transportation s
    JOIN DimCarrier ca 
        ON s.CarrierName = ca.CarrierName
    JOIN DimRoute r 
        ON s.Origin = r.Origin 
       AND s.Destination = r.Destination
    JOIN DimTransportMode tm 
        ON s.ModeName = tm.ModeName;
END;

/******************************************************************************************
 5. MASTER ETL RUN PROCEDURE
******************************************************************************************/

CREATE OR ALTER PROCEDURE Run_ETL AS
BEGIN
    DECLARE @BatchId VARCHAR(100) = CONCAT('BATCH_', FORMAT(GETDATE(), 'yyyyMMdd_HHmmss'));

    INSERT INTO etl_batch_log (BatchId, SourceFile, Status)
    VALUES (@BatchId, 'ALL', 'STARTED');

    BEGIN TRY
        EXEC Load_DimProduct;
        EXEC Load_DimWarehouse;
        EXEC Load_DimSupplier;
        EXEC Load_DimCarrier;
        EXEC Load_DimRoute;
        EXEC Load_DimTransportMode;
        EXEC Load_DimCustomer;

        EXEC Load_FactInventory;
        EXEC Load_FactSales;
        EXEC Load_FactSupplierPerformance;
        EXEC Load_FactManufacturing;
        EXEC Load_FactTransportation;

        UPDATE etl_batch_log SET Status = 'SUCCESS' WHERE BatchId = @BatchId;
    END TRY
    BEGIN CATCH
        INSERT INTO etl_error_log (TableName, ErrorMessage, RowData, BatchId)
        VALUES ('ETL', ERROR_MESSAGE(), NULL, @BatchId);

        UPDATE etl_batch_log SET Status = 'FAILED' WHERE BatchId = @BatchId;
    END CATCH
END;
