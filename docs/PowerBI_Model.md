# Power BI Data Model  
## Inventory Analytics Platform (SQL + Power BI)

**Version:** 1.0  
**Author:** Rodney Booze  
**Date:** August 2026  

---

# Overview  
This document describes the Power BI semantic model used for the Inventory Analytics Platform.  
The model is built on top of a SQL Server database containing fact and dimension tables for inventory, sales, supplier performance, manufacturing, and transportation.

The Power BI model follows a star‑schema design to ensure:

- High performance  
- Simple relationships  
- Accurate KPI calculations  
- Flexible slicing across products, suppliers, warehouses, carriers, and dates  

---

# 1. Data Sources

Power BI connects directly to the SQL database using:

**Connection Type:** Import  
**Source:** SQL Server  
**Tables Imported:**

### Fact Tables  
- FactInventory  
- FactSales  
- FactSupplierPerformance  
- FactManufacturing  
- FactTransportation  

### Dimension Tables  
- DimProduct  
- DimWarehouse  
- DimSupplier  
- DimCarrier  
- DimRoute  
- DimTransportMode  
- DimCustomer  
- DimDate  

All tables are imported into Power BI and stored in the VertiPaq engine for fast in‑memory analytics.

---

# 2. Table Transformations (Power Query)

Each table undergoes the following standard transformations:

### Applied Steps  
- Promote headers  
- Enforce correct data types  
- Remove duplicates  
- Trim and clean text fields  
- Validate surrogate keys  
- Add calculated columns where needed (e.g., InventoryValue)  

### Example: InventoryValue  
InventoryValue = FactInventory[OnHandQty] * FactInventory[UnitCost]

### Example: 
DeliveryStatus =
IF(FactTransportation[OnTimeDeliveryFlag] = 1, "On Time", "Late")

# 3. Relationships

The model uses one‑to‑many relationships from dimensions to facts.

### Relationship Summary

|Fact Table | Dimension Table(s) Linked To | 
FactInventory | DimProduct, DimWarehouse, DimDate | 
FactSales | DimProduct, DimCustomer, DimCarrier, DimDate | 
FactSupplierPerformance | DimSupplier, DimProduct, DimDate | 
FactManufacturing | DimProduct, DimDate | 
FactTransportation | DimCarrier, DimRoute, DimTransportMode, DimDate | 

### Relationship Type

- Single direction (dimension → fact)
- Star schema only
- No bidirectional filters unless explicitly required
- This ensures optimal performance and avoids circular dependencies.

# 4. Key Calculated Columns

### InventoryValue
InventoryValue = FactInventory[OnHandQty] * FactInventory[UnitCost]

### TotalCostPerUnit (Manufacturing)
TotalCostPerUnit = DIVIDE(FactManufacturing[ManufacturingCost], FactManufacturing[ProductionVolume])

### DeliveryStatus
DeliveryStatus = IF(FactTransportation[OnTimeDeliveryFlag] = 1, "On Time", "Late")

# 5. DAX Measures

All KPI measures are defined in the Measures folder.

### Inventory Measures
- Inventory Value
- Average Inventory
- Inventory Turnover
- Days of Inventory on Hand (DOH)
- Stockout Rate
- Overstock Rate
- Reorder Point
- Safety Stock

### Supplier Measures
- Avg Supplier Lead Time
- Supplier Defect Rate
- Supplier Score

### Manufacturing Measures
- Production Throughput
- Manufacturing Cost per Unit
- First Pass Yield

### Logistics Measures
- Transportation Cost per Unit
- On-Time Delivery %
- Average Shipping Time
- Carrier Performance Score

# 6. Model Folders (Power BI Organization)

To keep the model clean and professional, fields are grouped into folders:

### Dimensions
- Product
- Warehouse
- Supplier
- Carrier
- Route
- Transport Mode
- Customer
- Date

### Facts
- Inventory
- Sales
- Supplier Performance
- Manufacturing
- Transportation

### Measures
- Inventory KPIs
- Supplier KPIs
- Manufacturing KPIs
- Logistics KPIs

# 7. Report-Level Filters

### Global Filters
- Date range
- Product category
- Warehouse
- Supplier
- Carrier
- Transport mode

### Page-Level Filters

Used for specialized pages (Inventory, Supplier, Manufacturing, Logistics).

# 8. Performance Optimization

### Techniques Used
- Star schema only
- No bidirectional relationships
- All numeric columns encoded as whole numbers or decimals
- Dimension tables kept small and clean
- Measures optimized using DIVIDE() instead of /
- Avoided calculated columns where SQL can handle them
- Disabled auto-date/time
- Reduced cardinality in text fields
- Ensured surrogate keys are integers

### Notes

- All business logic is implemented in DAX, not SQL.
- SQL handles staging, cleansing, and transformations.
- Power BI handles KPIs, visuals, and user interaction.