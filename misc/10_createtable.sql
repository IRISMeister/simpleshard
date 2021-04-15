
CREATE TABLE master_table (
    JANCD VARCHAR(13), 
    MName VARCHAR(10), 
    MAddress VARCHAR(10)
)
GO
CREATE BITMAP INDEX idx_JANCD ON master_table(JANCD)
GO
