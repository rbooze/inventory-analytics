# Business Requirements Document  
## Inventory Analytics Platform (SQL + Power BI)  
**Version:** 1.0  
**Author:** Rodney Booze  
**Date:** August 2026  

---

## Executive Summary  
NorthStar Distribution requires a dedicated Inventory Analytics Platform that provides accurate, real‑time visibility into product availability, stock levels, supplier performance, manufacturing quality, and transportation efficiency. Current reporting relies on fragmented spreadsheets and inconsistent data sources, making it difficult for managers and executives to identify risks, optimize inventory, and make timely operational decisions.

This project delivers a centralized SQL‑based data model and an interactive Power BI dashboard that consolidates inventory, supplier, manufacturing, and logistics data into a single analytical environment. The solution enables data‑driven decision‑making, reduces manual reporting, and provides actionable insights across the supply chain.

---

## Business Problem  
The organization faces several operational challenges:

- Limited visibility into inventory availability and stock levels  
- Difficulty identifying products at risk of stockout or overstock  
- Inconsistent supplier lead times and performance  
- Lack of insight into manufacturing throughput and defect rates  
- Inefficient transportation routes and rising shipping costs  
- Manual Excel‑based reporting that delays decision‑making  
- No unified platform for analyzing inventory, suppliers, manufacturing, and logistics together  

---

## Project Objectives  
The Inventory Analytics Platform will:

- Consolidate inventory, supplier, manufacturing, and logistics data into a SQL database  
- Provide a unified Power BI dashboard for real‑time inventory visibility  
- Identify stockouts, overstock, and slow‑moving products  
- Monitor supplier lead times, defect rates, and reliability  
- Track manufacturing volumes, costs, and quality issues  
- Analyze transportation modes, carriers, routes, and shipping costs  
- Reduce manual reporting and improve operational efficiency  
- Enable executives and managers to make informed, data‑driven decisions  

---

## Stakeholders

### Executive Leadership  
Needs:  
- High‑level KPIs  
- Trend analysis  
- Strategic insights into inventory health and supply chain performance  

### Inventory & Supply Chain Managers  
Needs:  
- Stock levels  
- Inventory turnover  
- DOH  
- Stockout and overstock alerts  
- Supplier lead time and defect trends  

### Procurement Team  
Needs:  
- Supplier scorecards  
- Lead time variability  
- Cost trends  
- Defect and inspection results  

### Manufacturing & Operations Managers  
Needs:  
- Production volumes  
- Manufacturing lead times  
- Quality metrics  
- Defect rates  

### Logistics & Transportation Team  
Needs:  
- Carrier performance  
- Route efficiency  
- Shipping times  
- Transportation cost analysis  

---

## Source Systems / Data Inputs  
This project uses a consolidated dataset containing:

- Product attributes (type, SKU, price)  
- Inventory availability and stock levels  
- Sales quantities and revenue  
- Supplier names, locations, lead times  
- Manufacturing volumes, costs, defect rates  
- Shipping carriers, modes, routes, times, and costs  

Data will be stored in a SQL database and refreshed as needed.

---

## Key Business Questions  
The platform must answer:

- Which products are at risk of stockout?  
- Which SKUs are overstocked or slow‑moving?  
- What is the current inventory value and turnover rate?  
- How do supplier lead times and defect rates impact inventory?  
- Which manufacturing processes produce the most defects?  
- Which transportation modes and carriers are most cost‑effective?  
- Where are shipping delays occurring?  
- How do inventory, supplier, manufacturing, and logistics trends change over time?  

---

## Executive KPIs  
- Inventory Value  
- Inventory Turnover  
- Days of Inventory on Hand (DOH)  
- Stockout Rate  
- Overstock Volume  
- Supplier Lead Time  
- Supplier Defect Rate  
- Manufacturing Throughput  
- Manufacturing Cost per Unit  
- Transportation Cost per Unit  
- On‑Time Delivery %  

---

## Success Criteria  
The project will be considered successful if:

- Inventory risks (stockouts, overstock) can be identified within one minute  
- Supplier, manufacturing, and logistics performance can be analyzed in a single dashboard  
- SQL data refreshes reliably and supports Power BI  
- Manual Excel reporting is significantly reduced  
- Stakeholders trust the data and use the dashboard for decision‑making  
- Insights lead to measurable improvements in inventory efficiency and cost reduction  

---

## Assumptions  
- Data provided is accurate and complete  
- SQL database refresh schedules are maintained  
- KPI definitions are agreed upon across departments  
- Power BI has access to all required SQL tables  

---

## Constraints  
- Initial version uses downloaded sample data  
- Future versions may integrate live ERP, WMS, TMS, and supplier systems  
- Row‑level security may be added later  
- Manufacturing and logistics data may expand as new sources become available