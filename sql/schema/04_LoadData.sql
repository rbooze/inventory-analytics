BULK INSERT stg_inventory
FROM 'C:\Projects\inventory-analytics\data\supply_chain_data.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
