package com.ProjAdvAndWeb.util;

import java.sql.*;

public class DBConnectionUtil {
	
	private static final String jdbcUrl ="jdbc:mysql://localhost:3306/skillswap";
	private static final String dbUser="root";
	private static final String dbPassword="";
	private static final String jdbcDriver="com.mysql.cj.jdbc.Driver";
	
	public static Connection getConnection() {
		Connection con=null;
		try {
			Class.forName(jdbcDriver);
			con=DriverManager.getConnection(jdbcUrl,dbUser,dbPassword);
			System.out.println("Database connection established successfully!");
		} catch (ClassNotFoundException e) {
			 System.err.println("Error: JDBC Driver not found.");
			e.printStackTrace();
		} catch (SQLException e) {
			System.err.println("Error: Database connection failed.");
			e.printStackTrace();
		}
		return con;
	}
	
	public static void closeConnection(Connection con) {
		if(con!=null) {
			try {
				con.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}

}
