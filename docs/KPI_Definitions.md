# KPI Definitions  
## Inventory Analytics Platform (SQL + Power BI)

**Version:** 1.0  
**Author:** Rodney Booze  
**Date:** August 2026  

---

# Overview  
This document defines all Key Performance Indicators (KPIs) used in the Inventory Analytics Platform.  
Each KPI includes:

- Business definition  
- Calculation logic  
- Purpose  
- Related SQL tables  

These KPIs support inventory visibility, supplier performance, manufacturing quality, and logistics optimization.

---

# Inventory KPIs

## Inventory Value
**Definition:** Total dollar value of inventory on hand.  
**Formula:**  
`Inventory Value = SUM(OnHandQty × UnitCost)`  
**Purpose:** Measures capital tied up in inventory.  
**Tables:** FactInventory

---

## Average Inventory
**Definition:** Average inventory value over a selected period.  
**Formula:**  
`Average Inventory = AVERAGE(OnHandQty × UnitCost)`  
**Purpose:** Used for turnover and DOH calculations.  
**Tables:** FactInventory

---

## Cost of Goods Sold (COGS)
**Definition:** Total cost of products sold.  
**Formula:**  
`COGS = SUM(CostAmount)`  
**Purpose:** Used for turnover and profitability analysis.  
**Tables:** FactSales

---

## Inventory Turnover
**Definition:** Number of times inventory is sold and replaced.  
**Formula:**  
`Inventory Turnover = COGS / Average Inventory`  
**Purpose:** Indicates inventory efficiency.  
**Tables:** FactSales, FactInventory

---

## Days of Inventory on Hand (DOH)
**Definition:** Number of days current inventory will last.  
**Formula:**  
`DOH = Average Inventory / Average Daily Demand`  
**Purpose:** Measures inventory coverage.  
**Tables:** FactInventory, FactSales

---

## Stockout Rate
**Definition:** Percentage of SKU‑days where available inventory is zero.  
**Formula:**  
`Stockout Rate = Stockout Events / Total SKU-Days`  
**Purpose:** Identifies service level risk.  
**Tables:** FactInventory

---

## Overstock Rate
**Definition:** Percentage of SKUs exceeding twice their reorder point.  
**Formula:**  
`Overstock Rate = Overstock Events / Total SKU-Days`  
**Purpose:** Identifies excess inventory.  
**Tables:** FactInventory, FactReplenishment

---

## Reorder Point
**Definition:** Inventory level that triggers replenishment.  
**Formula:**  
`Reorder Point = (Daily Demand × Lead Time) + Safety Stock`  
**Purpose:** Prevents stockouts.  
**Tables:** FactReplenishment

---

## Safety Stock
**Definition:** Extra inventory held to protect against variability.  
**Formula:**  
`Safety Stock = Z × Demand Std Dev × √Lead Time`  
**Purpose:** Reduces stockout risk.  
**Tables:** FactReplenishment

---

# Supplier KPIs

## Average Supplier Lead Time
**Definition:** Average number of days suppliers take to deliver.  
**Formula:**  
`Avg Lead Time = AVERAGE(LeadTimeDays)`  
**Purpose:** Measures supplier reliability.  
**Tables:** FactSupplierPerformance

---

## Supplier Defect Rate
**Definition:** Percentage of units failing inspection.  
**Formula:**  
`Supplier Defect Rate = AVERAGE(DefectRate)`  
**Purpose:** Measures supplier quality.  
**Tables:** FactSupplierPerformance

---

## Supplier Score
**Definition:** Composite score of quality and lead time.  
**Formula:**  
`Supplier Score = (Quality Score × 0.5) + (Lead Time Score × 0.5)`  
**Purpose:** Ranks suppliers for procurement decisions.  
**Tables:** FactSupplierPerformance

---

# Manufacturing KPIs

## Production Throughput
**Definition:** Total units produced.  
**Formula:**  
`Production Throughput = SUM(ProductionVolume)`  
**Purpose:** Measures manufacturing output.  
**Tables:** FactManufacturing

---

## Manufacturing Cost per Unit (CPU)
**Definition:** Cost to produce one unit.  
**Formula:**  
`CPU = Total Manufacturing Cost / Total Production Volume`  
**Purpose:** Identifies cost efficiency.  
**Tables:** FactManufacturing

---

## First Pass Yield (FPY)
**Definition:** Percentage of units produced without defects.  
**Formula:**  
`FPY = 1 - Average Defect Rate`  
**Purpose:** Measures manufacturing quality.  
**Tables:** FactManufacturing

---

# Logistics KPIs

## Transportation Cost per Unit
**Definition:** Average shipping cost per unit sold.  
**Formula:**  
`Transportation CPU = Total Shipping Cost / Total Units Sold`  
**Purpose:** Measures logistics cost efficiency.  
**Tables:** FactTransportation, FactSales

---

## On-Time Delivery %
**Definition:** Percentage of shipments delivered on time.  
**Formula:**  
`On-Time Delivery % = OnTimeDeliveries / Total Shipments`  
**Purpose:** Measures carrier performance.  
**Tables:** FactTransportation

---

## Average Shipping Time
**Definition:** Average number of days required to deliver shipments.  
**Formula:**  
`Avg Shipping Time = AVERAGE(ShippingTime)`  
**Purpose:** Identifies delivery speed.  
**Tables:** FactTransportation

---

## Carrier Performance Score
**Definition:** Composite score of delivery speed and reliability.  
**Formula:**  
`Carrier Score = (On-Time Delivery × 0.7) + (Speed Score × 0.3)`  
**Purpose:** Ranks carriers for logistics optimization.  
**Tables:** FactTransportation

---

# Notes  
- All KPIs are calculated in Power BI using DAX.  
- SQL tables provide raw data; Power BI handles aggregation and business logic.  
- KPIs are grouped by functional area for clarity.  

