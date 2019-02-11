package util.Data;


import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.microsoft.sqlserver.jdbc.*;

public class MSSQL 
{
	Connection con;
	SQLServerDataSource ds = new SQLServerDataSource();
	
	public MSSQL(String server, String instance, int port)
	{
		ds.setServerName(server);
		ds.setDatabaseName(instance);
		ds.setPortNumber(port);
		ds.setIntegratedSecurity(true);
	}
	
	public boolean Connect()
	{
		try {
			con = ds.getConnection();
			return true;
		} catch (SQLServerException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public ResultSet ExecuteSQL(String SQL)
	{
		try {
			return con.createStatement().executeQuery(SQL);
		} catch (SQLException e) {
			e.printStackTrace();
			return null;
		}
	}
	
	
}
