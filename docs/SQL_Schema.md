# SQL Schema  
## Inventory Analytics Platform (SQL + Power BI)

**Version:** 1.0  
**Author:** Rodney Booze  
**Date:** August 2026  

---

# Overview  
This SQL schema defines the relational data model for the Inventory Analytics Platform.  
It includes fact tables for inventory, sales, supplier performance, manufacturing, and transportation, along with conformed dimension tables used across the analytics environment.

The schema is optimized for:

- Fast Power BI import  
- Star‑schema modeling  
- Clear surrogate key relationships  
- Scalable future enhancements  

---

# Dimension Tables

## DimDate
CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    Date DATE NOT NULL,
    Year INT,
    Quarter INT,
    Month INT,
    Day INT,
    Week INT,
    FiscalPeriod VARCHAR(20)
);

## DimProduct
CREATE TABLE DimProduct (
    ProductKey INT IDENTITY PRIMARY KEY,
    SKU VARCHAR(50) NOT NULL,
    ProductName VARCHAR(200),
    ProductType VARCHAR(100),
    Category VARCHAR(100),
    Price DECIMAL(18,2)
);

##DimWarehouse
CREATE TABLE DimWarehouse (
    WarehouseKey INT IDENTITY PRIMARY KEY,
    WarehouseName VARCHAR(200),
    Location VARCHAR(200),
    Region VARCHAR(100)
);

## DimSupplier
CREATE TABLE DimSupplier (
    SupplierKey INT IDENTITY PRIMARY KEY,
    SupplierName VARCHAR(200),
    Location VARCHAR(200),
    Region VARCHAR(100)
);

## DimCarrier
CREATE TABLE DimCarrier (
    CarrierKey INT IDENTITY PRIMARY KEY,
    CarrierName VARCHAR(200),
    Mode VARCHAR(50)   -- Air, Ground, LTL, FTL, Rail, Sea
);

## DimRoute
CREATE TABLE DimRoute (
    RouteKey INT IDENTITY PRIMARY KEY,
    Origin VARCHAR(200),
    Destination VARCHAR(200),
    Distance DECIMAL(18,2)
);

## DimTransportMode
CREATE TABLE DimTransportMode (
    TransportModeKey INT IDENTITY PRIMARY KEY,
    ModeName VARCHAR(50)   -- Air, Ground, Rail, Sea
);

## DimCustomer
CREATE TABLE DimCustomer (
    CustomerKey INT IDENTITY PRIMARY KEY,
    CustomerName VARCHAR(200),
    Segment VARCHAR(100),
    Region VARCHAR(100)
);

# Fact Tables

## FactInventory
CREATE TABLE FactInventory (
    InventoryId INT IDENTITY PRIMARY KEY,
    DateKey INT NOT NULL,
    ProductKey INT NOT NULL,
    WarehouseKey INT NOT NULL,
    OnHandQty DECIMAL(18,2) NOT NULL,
    AvailableQty DECIMAL(18,2),
    BackorderQty DECIMAL(18,2),
    UnitCost DECIMAL(18,4),

    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey),
    FOREIGN KEY (WarehouseKey) REFERENCES DimWarehouse(WarehouseKey)
);

## FactSales
CREATE TABLE FactSales (
    SalesId INT IDENTITY PRIMARY KEY,
    DateKey INT NOT NULL,
    ProductKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    QuantitySold DECIMAL(18,2),
    Revenue DECIMAL(18,2),
    OrderQty DECIMAL(18,2),
    ShippingCost DECIMAL(18,2),
    ShippingTime INT,
    CarrierKey INT,

    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey),
    FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey),
    FOREIGN KEY (CarrierKey) REFERENCES DimCarrier(CarrierKey)
);

## FactSupplierPerformance
CREATE TABLE FactSupplierPerformance (
    SupplierPerfId INT IDENTITY PRIMARY KEY,
    DateKey INT NOT NULL,
    SupplierKey INT NOT NULL,
    ProductKey INT NOT NULL,
    LeadTimeDays INT,
    DefectRate DECIMAL(18,4),
    InspectionResult VARCHAR(100),
    ManufacturingCost DECIMAL(18,2),
    ProductionVolume DECIMAL(18,2),

    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (SupplierKey) REFERENCES DimSupplier(SupplierKey),
    FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey)
);

# FactManufacturing
CREATE TABLE FactManufacturing (
    ManufacturingId INT IDENTITY PRIMARY KEY,
    DateKey INT NOT NULL,
    ProductKey INT NOT NULL,
    ProductionVolume DECIMAL(18,2),
    ManufacturingLeadTime INT,
    ManufacturingCost DECIMAL(18,2),
    DefectRate DECIMAL(18,4),

    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (ProductKey) REFERENCES DimProduct(ProductKey)
);

# FactTransportation
CREATE TABLE FactTransportation (
    TransportationId INT IDENTITY PRIMARY KEY,
    DateKey INT NOT NULL,
    CarrierKey INT NOT NULL,
    RouteKey INT NOT NULL,
    TransportModeKey INT NOT NULL,
    ShippingTime INT,
    ShippingCost DECIMAL(18,2),
    Distance DECIMAL(18,2),
    OnTimeDeliveryFlag BIT,

    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (CarrierKey) REFERENCES DimCarrier(CarrierKey),
    FOREIGN KEY (RouteKey) REFERENCES DimRoute(RouteKey),
    FOREIGN KEY (TransportModeKey) REFERENCES DimTransportMode(TransportModeKey)
);