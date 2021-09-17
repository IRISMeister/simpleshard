CREATE TABLE dateomniture (datekey INTEGER, irisdate INTEGER, fulldatealternatekey VARCHAR(50), daynumberofweek INTEGER, englishdaynameofweek VARCHAR(50), daynumberofmonth INTEGER, weeknumberofyear INTEGER, englishmonthname VARCHAR(50), monthnumberofyear INTEGER, calendarquarter INTEGER, calendaryear INTEGER, PRIMARY KEY (datekey))
GO
CREATE INDEX idx_fulldatealternatekey ON dateomniture(fulldatealternatekey)
GO