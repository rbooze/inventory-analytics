# Data Model  
## Inventory Analytics Platform (SQL + Power BI)

**Version:** 1.0  
**Author:** Rodney Booze  
**Date:** August 2026  

---

## Overview  
The Inventory Analytics Platform uses a star‑schema data model designed to support inventory visibility, supplier performance, manufacturing quality, and transportation analytics. The model is optimized for SQL storage and Power BI reporting, enabling fast queries, flexible slicing, and reliable KPI calculations.

The data model consists of multiple fact tables representing measurable business processes and dimension tables providing descriptive attributes.

---

# Fact Tables

## FactInventory  
Captures daily inventory levels for each SKU at each warehouse.

**Grain:** One row per Product × Warehouse × Date.

**Columns:**  
- DateKey  
- ProductKey  
- WarehouseKey  
- OnHandQty  
- AvailableQty  
- BackorderQty  
- UnitCost  
- InventoryValue (calculated as OnHandQty × UnitCost)

**Purpose:**  
Supports inventory value, DOH, turnover, stockout rate, overstock analysis, and SKU/location visibility.

---

## FactSales  
Tracks units sold and revenue generated.

**Grain:** One row per Product × Date × Customer.

**Columns:**  
- DateKey  
- ProductKey  
- CustomerKey  
- QuantitySold  
- Revenue  
- OrderQty  
- ShippingCost  
- ShippingTime  
- CarrierKey  

**Purpose:**  
Supports demand analysis, sales trends, revenue insights, and transportation cost allocation.

---

## FactSupplierPerformance  
Captures supplier reliability, lead times, and quality metrics.

**Grain:** One row per Supplier × Product × Date.

**Columns:**  
- DateKey  
- SupplierKey  
- ProductKey  
- LeadTimeDays  
- DefectRate  
- InspectionResult  
- ManufacturingCost  
- ProductionVolume  

**Purpose:**  
Supports supplier scorecards, defect analysis, cost trends, and lead time variability.

---

## FactManufacturing  
Tracks production throughput and quality.

**Grain:** One row per Product × Date.

**Columns:**  
- DateKey  
- ProductKey  
- ProductionVolume  
- ManufacturingLeadTime  
- ManufacturingCost  
- DefectRate  

**Purpose:**  
Supports throughput analysis, cost per unit, defect trends, and bottleneck identification.

---

## FactTransportation  
Captures logistics performance and cost efficiency.

**Grain:** One row per Shipment × Route × Date.

**Columns:**  
- DateKey  
- CarrierKey  
- RouteKey  
- TransportModeKey  
- ShippingTime  
- ShippingCost  
- Distance  
- OnTimeDeliveryFlag  

**Purpose:**  
Supports carrier performance, route optimization, mode comparison, and transportation cost KPIs.

---

# Dimension Tables

## DimProduct  
Contains product attributes.

**Columns:**  
- ProductKey  
- SKU  
- ProductName  
- ProductType  
- Category  
- Price  

**Purpose:**  
Used for slicing inventory, sales, supplier, and manufacturing metrics.

---

## DimWarehouse  
Contains warehouse and distribution center attributes.

**Columns:**  
- WarehouseKey  
- WarehouseName  
- Location  
- Region  

**Purpose:**  
Supports warehouse comparison, regional analysis, and stock visibility.

---

## DimSupplier  
Contains supplier attributes.

**Columns:**  
- SupplierKey  
- SupplierName  
- Location  
- Region  

**Purpose:**  
Used for supplier scorecards and lead time/defect analysis.

---

## DimCarrier  
Contains shipping carrier attributes.

**Columns:**  
- CarrierKey  
- CarrierName  
- Mode (Air, Ground, LTL, FTL)  

**Purpose:**  
Supports transportation cost and performance analysis.

---

## DimRoute  
Contains transportation route attributes.

**Columns:**  
- RouteKey  
- Origin  
- Destination  
- Distance  

**Purpose:**  
Used for route optimization and cost analysis.

---

## DimTransportMode  
Contains transportation mode attributes.

**Columns:**  
- TransportModeKey  
- ModeName (Air, Ground, Rail, Sea)  

**Purpose:**  
Supports mode comparison and cost/time analysis.

---

## DimCustomer  
Contains customer attributes.

**Columns:**  
- CustomerKey  
- CustomerName  
- Segment  
- Region  

**Purpose:**  
Supports sales and demand analysis.

---

## DimDate  
Standard calendar dimension.

**Columns:**  
- DateKey  
- Date  
- Year  
- Quarter  
- Month  
- Day  
- Week  
- FiscalPeriod  

**Purpose:**  
Supports time‑series analysis across all fact tables.

---

# Relationships  
The star schema uses surrogate keys to link fact tables to dimensions:

- FactInventory → DimProduct, DimWarehouse, DimDate  
- FactSales → DimProduct, DimCustomer, DimCarrier, DimDate  
- FactSupplierPerformance → DimSupplier, DimProduct, DimDate  
- FactManufacturing → DimProduct, DimDate  
- FactTransportation → DimCarrier, DimRoute, DimTransportMode, DimDate  

This structure ensures high performance in SQL and Power BI while supporting complex supply chain analytics.

---

# Notes  
- All fact tables use numeric surrogate keys for consistency.  
- All dimensions are conformed across the model.  
- InventoryValue may be calculated in SQL or Power BI depending on performance needs.  
- Additional attributes may be added as the dataset expands.

