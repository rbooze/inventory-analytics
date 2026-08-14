-- Inventory Analytics Platform - SQL Warehouse Schema
-- Author: Rodney Booze
-- Version: 1.0
-- Date: August 2026

------------------------------------------------------------
-- 1. Dimension Tables
------------------------------------------------------------

-- DimDate
CREATE TABLE DimDate (
    DateKey        INT           NOT NULL PRIMARY KEY, -- YYYYMMDD
    [Date]         DATE          NOT NULL,
    [Year]         INT           NOT NULL,
    [Quarter]      INT           NOT NULL,
    [Month]        INT           NOT NULL,
    [Day]          INT           NOT NULL,
    [Week]         INT           NULL,
    FiscalPeriod   VARCHAR(20)   NULL
);

-- DimProduct
CREATE TABLE DimProduct (
    ProductKey     INT           IDENTITY(1,1) PRIMARY KEY,
    SKU            VARCHAR(50)   NOT NULL,
    ProductName    VARCHAR(200)  NOT NULL,
    ProductType    VARCHAR(100)  NULL,
    Category       VARCHAR(100)  NULL,
    Price          DECIMAL(18,2) NULL
);

-- DimWarehouse
CREATE TABLE DimWarehouse (
    WarehouseKey   INT           IDENTITY(1,1) PRIMARY KEY,
    WarehouseName  VARCHAR(200)  NOT NULL,
    Location       VARCHAR(200)  NULL,
    Region         VARCHAR(100)  NULL
);

-- DimSupplier
CREATE TABLE DimSupplier (
    SupplierKey    INT           IDENTITY(1,1) PRIMARY KEY,
    SupplierName   VARCHAR(200)  NOT NULL,
    Location       VARCHAR(200)  NULL,
    Region         VARCHAR(100)  NULL
);

-- DimCarrier
CREATE TABLE DimCarrier (
    CarrierKey     INT           IDENTITY(1,1) PRIMARY KEY,
    CarrierName    VARCHAR(200)  NOT NULL,
    Mode           VARCHAR(50)   NULL -- Air, Ground, LTL, FTL, Rail, Sea
);

-- DimRoute
CREATE TABLE DimRoute (
    RouteKey       INT           IDENTITY(1,1) PRIMARY KEY,
    Origin         VARCHAR(200)  NOT NULL,
    Destination    VARCHAR(200)  NOT NULL,
    Distance       DECIMAL(18,2) NULL
);

-- DimTransportMode
CREATE TABLE DimTransportMode (
    TransportModeKey INT         IDENTITY(1,1) PRIMARY KEY,
    ModeName         VARCHAR(50) NOT NULL -- Air, Ground, Rail, Sea
);

-- DimCustomer
CREATE TABLE DimCustomer (
    CustomerKey    INT           IDENTITY(1,1) PRIMARY KEY,
    CustomerName   VARCHAR(200)  NOT NULL,
    Segment        VARCHAR(100)  NULL,
    Region         VARCHAR(100)  NULL
);

------------------------------------------------------------
-- 2. Fact Tables
------------------------------------------------------------

-- FactInventory
CREATE TABLE FactInventory (
    InventoryId    INT           IDENTITY(1,1) PRIMARY KEY,
    DateKey        INT           NOT NULL,
    ProductKey     INT           NOT NULL,
    WarehouseKey   INT           NOT NULL,
    OnHandQty      DECIMAL(18,2) NOT NULL DEFAULT 0,
    AvailableQty   DECIMAL(18,2) NULL,
    BackorderQty   DECIMAL(18,2) NULL,
    UnitCost       DECIMAL(18,4) NOT NULL,
    InventoryValue DECIMAL(18,2) NULL,
    CONSTRAINT FK_FactInventory_DimDate
        FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_FactInventory_DimProduct
        FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey),
    CONSTRAINT FK_FactInventory_DimWarehouse
        FOREIGN KEY (WarehouseKey) REFERENCES DimWarehouse(WarehouseKey)
);

-- FactSales
CREATE TABLE FactSales (
    SalesId        INT           IDENTITY(1,1) PRIMARY KEY,
    DateKey        INT           NOT NULL,
    ProductKey     INT           NOT NULL,
    CustomerKey    INT           NOT NULL,
    CarrierKey     INT           NULL,
    QuantitySold   DECIMAL(18,2) NOT NULL,
    Revenue        DECIMAL(18,2) NOT NULL,
    OrderQty       DECIMAL(18,2) NULL,
    ShippingCost   DECIMAL(18,2) NULL,
    ShippingTime   INT           NULL, -- days
    CONSTRAINT FK_FactSales_DimDate
        FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_FactSales_DimProduct
        FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey),
    CONSTRAINT FK_FactSales_DimCustomer
        FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey),
    CONSTRAINT FK_FactSales_DimCarrier
        FOREIGN KEY (CarrierKey) REFERENCES DimCarrier(CarrierKey)
);

-- FactSupplierPerformance
CREATE TABLE FactSupplierPerformance (
    SupplierPerfId   INT           IDENTITY(1,1) PRIMARY KEY,
    DateKey          INT           NOT NULL,
    SupplierKey      INT           NOT NULL,
    ProductKey       INT           NOT NULL,
    LeadTimeDays     INT           NULL,
    DefectRate       DECIMAL(18,4) NULL,
    InspectionResult VARCHAR(100)  NULL,
    ManufacturingCost DECIMAL(18,2) NULL,
    ProductionVolume DECIMAL(18,2) NULL,
    CONSTRAINT FK_FactSupplierPerf_DimDate
        FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_FactSupplierPerf_DimSupplier
        FOREIGN KEY (SupplierKey) REFERENCES DimSupplier(SupplierKey),
    CONSTRAINT FK_FactSupplierPerf_DimProduct
        FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey)
);

-- FactManufacturing
CREATE TABLE FactManufacturing (
    ManufacturingId     INT           IDENTITY(1,1) PRIMARY KEY,
    DateKey             INT           NOT NULL,
    ProductKey          INT           NOT NULL,
    ProductionVolume    DECIMAL(18,2) NOT NULL,
    ManufacturingLeadTime INT        NULL,
    ManufacturingCost   DECIMAL(18,2) NOT NULL,
    DefectRate          DECIMAL(18,4) NULL,
    CONSTRAINT FK_FactManufacturing_DimDate
        FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_FactManufacturing_DimProduct
        FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey)
);

-- FactTransportation
CREATE TABLE FactTransportation (
    TransportationId  INT           IDENTITY(1,1) PRIMARY KEY,
    DateKey           INT           NOT NULL,
    CarrierKey        INT           NOT NULL,
    RouteKey          INT           NOT NULL,
    TransportModeKey  INT           NOT NULL,
    ShippingTime      INT           NULL, -- days
    ShippingCost      DECIMAL(18,2) NULL,
    Distance          DECIMAL(18,2) NULL,
    OnTimeDeliveryFlag BIT          NOT NULL DEFAULT 1,
    CONSTRAINT FK_FactTransportation_DimDate
        FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_FactTransportation_DimCarrier
        FOREIGN KEY (CarrierKey) REFERENCES DimCarrier(CarrierKey),
    CONSTRAINT FK_FactTransportation_DimRoute
        FOREIGN KEY (RouteKey) REFERENCES DimRoute(RouteKey),
    CONSTRAINT FK_FactTransportation_DimTransportMode
        FOREIGN KEY (TransportModeKey) REFERENCES DimTransportMode(TransportModeKey)
);

------------------------------------------------------------
-- 3. Indexes (basic performance tuning)
------------------------------------------------------------

-- Common dimension key indexes
CREATE INDEX IX_FactInventory_DateKey    ON FactInventory(DateKey);
CREATE INDEX IX_FactInventory_ProductKey ON FactInventory(ProductKey);
CREATE INDEX IX_FactInventory_WarehouseKey ON FactInventory(WarehouseKey);

CREATE INDEX IX_FactSales_DateKey        ON FactSales(DateKey);
CREATE INDEX IX_FactSales_ProductKey     ON FactSales(ProductKey);
CREATE INDEX IX_FactSales_CustomerKey    ON FactSales(CustomerKey);

CREATE INDEX IX_FactSupplierPerf_DateKey   ON FactSupplierPerformance(DateKey);
CREATE INDEX IX_FactSupplierPerf_SupplierKey ON FactSupplierPerformance(SupplierKey);
CREATE INDEX IX_FactSupplierPerf_ProductKey  ON FactSupplierPerformance(ProductKey);

CREATE INDEX IX_FactManufacturing_DateKey ON FactManufacturing(DateKey);
CREATE INDEX IX_FactManufacturing_ProductKey ON FactManufacturing(ProductKey);

CREATE INDEX IX_FactTransportation_DateKey ON FactTransportation(DateKey);
CREATE INDEX IX_FactTransportation_CarrierKey ON FactTransportation(CarrierKey);
CREATE INDEX IX_FactTransportation_RouteKey ON FactTransportation(RouteKey);

------------------------------------------------------------
-- 4. Notes
------------------------------------------------------------
-- 1. DimDate should be pre-populated for the full reporting horizon.
-- 2. Surrogate keys are identity columns except DateKey.
-- 3. InventoryValue can be computed in ETL or via Power BI DAX.
-- 4. Additional constraints (CHECK, UNIQUE) can be added as needed.
