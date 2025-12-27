package com.ProjAdvAndWeb.util;
import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {
	public static String hashPassword(String plainTextPassword) {
		if(plainTextPassword==null || plainTextPassword.isEmpty()) {
			return null;
		}
		return BCrypt.hashpw(plainTextPassword,BCrypt.gensalt());
	}

	public static boolean checkPassword(String plainTextPassword, String hashedPassword) {
		if(plainTextPassword==null||hashedPassword==null||plainTextPassword.isEmpty()||hashedPassword.isEmpty()) {
			return false;
		}
		try {
			return BCrypt.checkpw(plainTextPassword, hashedPassword);
		} catch (IllegalArgumentException e) {
            System.err.println("Error checking password: Invalid hash provided. " + e.getMessage());
			return false; // Hash format is invalid
		}
	}
}