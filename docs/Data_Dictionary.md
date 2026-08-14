# Data Dictionary  
## Inventory Analytics Platform (SQL + Power BI)

**Version:** 1.0  
**Author:** Rodney Booze  
**Date:** August 2026  

---

# Overview  
This data dictionary defines all fields used in the Inventory Analytics Platform.  
It covers:

- Dimension tables  
- Fact tables  
- Keys and relationships  
- Business definitions  
- Data types  
- Usage in Power BI  

This document ensures consistent understanding across analytics, engineering, and operations teams.

---

# 1. Dimension Tables

## DimDate  
| Column | Type | Description |
|--------|------|-------------|
| DateKey | INT | Surrogate key (YYYYMMDD). |
| Date | DATE | Calendar date. |
| Year | INT | Calendar year. |
| Quarter | INT | Quarter (1–4). |
| Month | INT | Month number (1–12). |
| Day | INT | Day of month. |
| Week | INT | Week number. |
| FiscalPeriod | VARCHAR(20) | Fiscal period label. |

---

## DimProduct  
| Column | Type | Description |
|--------|------|-------------|
| ProductKey | INT | Surrogate key. |
| SKU | VARCHAR(50) | Stock Keeping Unit. |
| ProductName | VARCHAR(200) | Product description. |
| ProductType | VARCHAR(100) | Type/category grouping. |
| Category | VARCHAR(100) | Product category. |
| Price | DECIMAL(18,2) | Standard unit price. |

---

## DimWarehouse  
| Column | Type | Description |
|--------|------|-------------|
| WarehouseKey | INT | Surrogate key. |
| WarehouseName | VARCHAR(200) | Warehouse or DC name. |
| Location | VARCHAR(200) | City/state/country. |
| Region | VARCHAR(100) | Operational region. |

---

## DimSupplier  
| Column | Type | Description |
|--------|------|-------------|
| SupplierKey | INT | Surrogate key. |
| SupplierName | VARCHAR(200) | Supplier name. |
| Location | VARCHAR(200) | Supplier location. |
| Region | VARCHAR(100) | Supplier region. |

---

## DimCarrier  
| Column | Type | Description |
|--------|------|-------------|
| CarrierKey | INT | Surrogate key. |
| CarrierName | VARCHAR(200) | Shipping carrier. |
| Mode | VARCHAR(50) | Air, Ground, LTL, FTL, Rail, Sea. |

---

## DimRoute  
| Column | Type | Description |
|--------|------|-------------|
| RouteKey | INT | Surrogate key. |
| Origin | VARCHAR(200) | Starting location. |
| Destination | VARCHAR(200) | Ending location. |
| Distance | DECIMAL(18,2) | Route distance (miles/km). |

---

## DimTransportMode  
| Column | Type | Description |
|--------|------|-------------|
| TransportModeKey | INT | Surrogate key. |
| ModeName | VARCHAR(50) | Air, Ground, Rail, Sea. |

---

## DimCustomer  
| Column | Type | Description |
|--------|------|-------------|
| CustomerKey | INT | Surrogate key. |
| CustomerName | VARCHAR(200) | Customer name. |
| Segment | VARCHAR(100) | Retail, wholesale, etc. |
| Region | VARCHAR(100) | Customer region. |

---

# 2. Fact Tables

## FactInventory  
| Column | Type | Description |
|--------|------|-------------|
| InventoryId | INT | Surrogate key. |
| DateKey | INT | FK → DimDate. |
| ProductKey | INT | FK → DimProduct. |
| WarehouseKey | INT | FK → DimWarehouse. |
| OnHandQty | DECIMAL(18,2) | Units physically on hand. |
| AvailableQty | DECIMAL(18,2) | Units available for sale. |
| BackorderQty | DECIMAL(18,2) | Units committed but not available. |
| UnitCost | DECIMAL(18,4) | Cost per unit. |
| InventoryValue | DECIMAL(18,2) | OnHandQty × UnitCost. |

---

## FactSales  
| Column | Type | Description |
|--------|------|-------------|
| SalesId | INT | Surrogate key. |
| DateKey | INT | FK → DimDate. |
| ProductKey | INT | FK → DimProduct. |
| CustomerKey | INT | FK → DimCustomer. |
| QuantitySold | DECIMAL(18,2) | Units sold. |
| Revenue | DECIMAL(18,2) | Sales revenue. |
| OrderQty | DECIMAL(18,2) | Ordered quantity. |
| ShippingCost | DECIMAL(18,2) | Cost of shipping. |
| ShippingTime | INT | Transit time (days). |
| CarrierKey | INT | FK → DimCarrier. |

---

## FactSupplierPerformance  
| Column | Type | Description |
|--------|------|-------------|
| SupplierPerfId | INT | Surrogate key. |
| DateKey | INT | FK → DimDate. |
| SupplierKey | INT | FK → DimSupplier. |
| ProductKey | INT | FK → DimProduct. |
| LeadTimeDays | INT | Days from order to delivery. |
| DefectRate | DECIMAL(18,4) | % defective units. |
| InspectionResult | VARCHAR(100) | Pass/Fail/Notes. |
| ManufacturingCost | DECIMAL(18,2) | Cost of production. |
| ProductionVolume | DECIMAL(18,2) | Units produced. |

---

## FactManufacturing  
| Column | Type | Description |
|--------|------|-------------|
| ManufacturingId | INT | Surrogate key. |
| DateKey | INT | FK → DimDate. |
| ProductKey | INT | FK → DimProduct. |
| ProductionVolume | DECIMAL(18,2) | Units produced. |
| ManufacturingLeadTime | INT | Time to manufacture. |
| ManufacturingCost | DECIMAL(18,2) | Total cost. |
| DefectRate | DECIMAL(18,4) | % defective units. |

---

## FactTransportation  
| Column | Type | Description |
|--------|------|-------------|
| TransportationId | INT | Surrogate key. |
| DateKey | INT | FK → DimDate. |
| CarrierKey | INT | FK → DimCarrier. |
| RouteKey | INT | FK → DimRoute. |
| TransportModeKey | INT | FK → DimTransportMode. |
| ShippingTime | INT | Transit time (days). |
| ShippingCost | DECIMAL(18,2) | Cost of shipment. |
| Distance | DECIMAL(18,2) | Route distance. |
| OnTimeDeliveryFlag | BIT | 1 = On time, 0 = Late. |

---

# 3. Keys & Relationships

### Surrogate Keys  
All dimension tables use integer surrogate keys.  
All fact tables reference these keys.

### Relationship Type  
- One‑to‑many  
- Single‑direction (dimension → fact)  
- No bidirectional filters  

### Example  
DimProduct(ProductKey) → FactInventory(ProductKey)

---

# 4. Business Rules

### Inventory  
- InventoryValue = OnHandQty × UnitCost  
- Negative quantities → set to 0  
- BackorderQty > OnHandQty triggers exception flag  

### Supplier  
- DefectRate capped at 1.0  
- Missing lead time → supplier average  

### Manufacturing  
- CPU = ManufacturingCost / ProductionVolume  

### Logistics  
- DeliveryStatus derived from OnTimeDeliveryFlag  

---

# 5. Usage in Power BI

### Dimensions  
Used for slicing, filtering, grouping.

### Facts  
Used for aggregations, KPIs, trends.

### DAX Measures  
Defined in `KPI_Definitions.md` and used across dashboards.

---

# Summary  
This data dictionary provides a complete reference for all fields in the Inventory Analytics Platform.  
It ensures consistent understanding across engineering, analytics, and business teams.

