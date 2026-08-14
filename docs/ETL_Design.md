# ETL Design  
## Inventory Analytics Platform (SQL + Power BI)

**Version:** 1.0  
**Author:** Rodney Booze  
**Date:** August 2026  

---

# Overview  
This document describes the Extract, Transform, Load (ETL) architecture for the Inventory Analytics Platform.  
The ETL pipeline consolidates inventory, sales, supplier, manufacturing, and logistics data into a structured SQL star schema optimized for Power BI reporting.

The ETL process ensures:

- Clean, validated, and standardized data  
- Consistent surrogate keys  
- Accurate fact/dimension relationships  
- Reliable refresh cycles  
- Full auditability and traceability  

---

# 1. ETL Architecture Summary

### Components  
- **Source Files:** CSV/Excel datasets for inventory, sales, suppliers, manufacturing, transportation  
- **Staging Layer:** Raw data loaded into staging tables  
- **Transformation Layer:** Data cleansing, normalization, key generation  
- **Warehouse Layer:** Final fact and dimension tables  
- **Power BI Layer:** Import mode with scheduled refresh  

### Flow  
Source → Staging → Transformation → Warehouse → Power BI

---

# 2. Extract Phase

### Source Types  
- Inventory CSV files  
- Supplier performance spreadsheets  
- Manufacturing logs  
- Transportation/shipping files  
- Product master data  
- Warehouse master data  
- Carrier and route reference files  

### Extraction Rules  
- Load all raw files into **stg_*** tables with no transformations  
- Preserve original column names  
- Capture load timestamp  
- Capture file name and batch ID  

### Staging Table Examples  
- `stg_inventory`  
- `stg_sales`  
- `stg_supplier_performance`  
- `stg_manufacturing`  
- `stg_transportation`  
- `stg_product`  
- `stg_warehouse`  
- `stg_supplier`  
- `stg_carrier`  
- `stg_route`  

---

# 3. Transform Phase

### Standard Transformations  
- Trim and clean text fields  
- Convert data types (dates, decimals, integers)  
- Remove duplicates  
- Normalize categorical values (e.g., “Air”, “AIR”, “air” → “Air”)  
- Validate numeric ranges (e.g., defect rate between 0 and 1)  
- Handle nulls using business rules  
- Generate surrogate keys for dimensions  
- Derive calculated fields (InventoryValue, DeliveryStatus, CPU, etc.)

### Business Rules  
- Negative inventory quantities → set to 0  
- Missing lead time → use supplier average  
- Missing shipping cost → flag for review  
- Defect rate > 1 → cap at 1  
- Manufacturing cost missing → use product average  

### Surrogate Key Generation  
Each dimension receives an integer surrogate key:

- `ProductKey`  
- `SupplierKey`  
- `WarehouseKey`  
- `CarrierKey`  
- `RouteKey`  
- `TransportModeKey`  
- `CustomerKey`  
- `DateKey`  

Keys are assigned using identity columns or hash-based mapping.

---

# 4. Load Phase

### Dimension Loads  
Dimensions are loaded first to ensure surrogate keys exist before fact loads.

Load order:

1. DimDate  
2. DimProduct  
3. DimSupplier  
4. DimWarehouse  
5. DimCarrier  
6. DimRoute  
7. DimTransportMode  
8. DimCustomer  

### Fact Loads  
Facts are loaded after dimensions:

1. FactInventory  
2. FactSales  
3. FactSupplierPerformance  
4. FactManufacturing  
5. FactTransportation  

### Fact Table Rules  
- Replace natural keys with surrogate keys  
- Enforce referential integrity  
- Reject rows with missing dimension references  
- Calculate derived fields (InventoryValue, CPU, DeliveryStatus)

---

# 5. Incremental Refresh Strategy

### Inventory  
- Daily incremental load  
- Partition by DateKey  
- Only reload last 7 days  

### Sales  
- Daily incremental load  
- Partition by DateKey  
- Reload last 30 days  

### Supplier Performance  
- Weekly refresh  

### Manufacturing  
- Daily refresh  

### Transportation  
- Daily refresh  

---

# 6. Error Handling & Logging

### Error Types  
- Missing required fields  
- Invalid data types  
- Out-of-range numeric values  
- Failed surrogate key lookups  
- Duplicate primary keys  

### Logging Tables  
- `etl_error_log`  
- `etl_batch_log`  
- `etl_file_log`  

### Error Actions  
- Critical errors → reject row  
- Non-critical errors → load with warning flag  
- All errors logged with batch ID and timestamp  

---

# 7. Data Quality Checks

### Daily Checks  
- Row counts vs prior day  
- Null rate thresholds  
- Duplicate detection  
- Lead time variance checks  
- Defect rate validation  

### Monthly Checks  
- Supplier performance trend validation  
- Manufacturing throughput consistency  
- Transportation cost anomalies  

---

# 8. Data Governance

### Standards  
- All tables use lowercase snake_case  
- Surrogate keys are integers  
- Dates stored as `DateKey` (YYYYMMDD)  
- All monetary values stored as DECIMAL(18,2)  
- All quantities stored as DECIMAL(18,2)  

### Documentation  
- Data dictionary maintained in `/docs`  
- KPI definitions stored in `KPI_Definitions.md`  
- Model documentation stored in `PowerBI_Model.md`  

---

# 9. ETL Diagram

