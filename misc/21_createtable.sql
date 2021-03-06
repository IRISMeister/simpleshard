
CREATE TABLE tx_table_sub1 (
    JANCD VARCHAR(13), 
    StoreCode VARCHAR(2), 
    TxDate Date, 
    TxYYMM VARCHAR(6), 
    Price numeric(18,2), 
    NumOfItems Integer,
    shard key (JANCD)
)
GO
CREATE BITMAP INDEX idx_JANCD ON tx_table_sub1(JANCD)
GO
CREATE BITMAP INDEX idx_StoreCode ON tx_table_sub1(StoreCode)
GO
CREATE BITMAP INDEX idx_TxDate ON tx_table_sub1(TxDate)
GO