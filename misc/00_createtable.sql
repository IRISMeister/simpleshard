lines (27 sloc) 1 KB
CREATE TABLE sales (
    TempoID VARCHAR(10), 
    ItemID VARCHAR(10), 
    OrderDate TimeStamp, 
    price BigInt, 
    shard key (ItemID)
)
GO
CREATE INDEX idx_TempoID ON sales(TempoID)
GO
CREATE INDEX idx_ItemID ON sales(ItemID)
GO
CREATE INDEX idx_OrderDate ON sales(OrderDate)
GO