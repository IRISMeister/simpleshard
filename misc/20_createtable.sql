
CREATE TABLE tx_table_main (
    JANCD VARCHAR(13), 
    StoreCode VARCHAR(2), 
    OrderDate Date, 
    OrderYYMM VARCHAR(6), 
    Price1 numeric(18,2), 
    Price2 numeric(18,2), 
    Price3 numeric(18,2), 
    NumOfItems Integer,
    shard key (JANCD)
)
GO
CREATE BITMAP INDEX idx_JANCD ON tx_table_main(JANCD)
GO
CREATE BITMAP INDEX idx_StoreCode ON tx_table_main(StoreCode)
GO
CREATE BITMAP INDEX idx_OrderDate ON tx_table_main(OrderDate)
GO