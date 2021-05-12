package com.example;
import java.sql.*;
import java.util.Properties;
import java.util.Random;

public class App 
{
    protected   static  String              namespace = "IRISDM";
    protected   static  String              host = "data-0.iris";
    protected   static  int                 port = 1972; 
    protected   static  String              url = "jdbc:IRIS://"+host+":" + port + "/"+namespace;
    protected   static  String              username = "SuperUser";
    protected   static  String              password = "SYS";
    
    public static void main( String[] args )
    {
        Connection dbconnection = null;
        PreparedStatement pstmt = null;
        int itemcnt;
        int cnt=0;

        System.out.println( "Connecting to IRIS server on "+host );

        try {
            Class.forName ("com.intersystems.jdbc.IRISDriver");
            Properties p = new Properties();
            p.setProperty("SharedMemory", "false");
            p.setProperty("user", username);
            p.setProperty("password", password);
            dbconnection = DriverManager.getConnection(url,p);
            dbconnection.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);
            dbconnection.setAutoCommit(true);

            java.sql.DatabaseMetaData meta = dbconnection.getMetaData();
            System.out.println (meta.getDriverName());
            System.out.println ("release " + meta.getDriverVersion() + "\n");

            Random rand = new Random();

            //TempoID,ItemID,OrderDate,price

            String isql = "insert into sales (TempoID,ItemID,OrderDate,price) values ( ?, ?, ?, ?)";
            pstmt = dbconnection.prepareStatement(isql);
            for (int i=1; i<=100; i++) {
                pstmt.setString(1, String.valueOf(i));
                itemcnt=1000;
                for (int j=1; j<=itemcnt; j++) {
                    pstmt.setString(2, String.valueOf(j));
                    pstmt.setString(3, "2021-01-01");
                    pstmt.setInt(4,(rand.nextInt(100)+1)*10 );
                    pstmt.execute();
                    cnt++;
                }
            }
            pstmt.close();
            System.out.println(cnt+" records inserted");

        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            try {
                dbconnection.close();
            } catch (Exception ex) {
            }
        }    

    }
}
