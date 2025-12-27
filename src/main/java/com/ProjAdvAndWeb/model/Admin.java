package com.ProjAdvAndWeb.model;

import java.sql.Timestamp;

public class Admin {
	
	    private int phoneNumber;        
	    private String username;
	    private String passwordHash;    
	    private String email;
	    private String firstName;
	    private String lastName;       
	    private Timestamp dateRegistered;

	    // Default constructor
	    public Admin() {
	    }

	    
	    public Admin(int phoneNumber, String username, String passwordHash, String email, String firstName, String lastName) {
	        this.phoneNumber = phoneNumber;
	        this.username = username;
	        this.passwordHash = passwordHash;
	        this.email = email;
	        this.firstName = firstName;
	        this.lastName = lastName;
	    }

	    // Getters and Setters
	    public int getPhoneNumber() {
	        return phoneNumber;
	    }

	    public void setPhoneNumber(int phoneNumber) {
	        this.phoneNumber = phoneNumber;
	    }

	    public String getUsername() {
	        return username;
	    }

	    public void setUsername(String username) {
	        this.username = username;
	    }

	    public String getPasswordHash() {
	        return passwordHash;
	    }

	    public void setPasswordHash(String passwordHash) {
	        this.passwordHash = passwordHash;
	    }

	    public String getEmail() {
	        return email;
	    }

	    public void setEmail(String email) {
	        this.email = email;
	    }

	    public String getFirstName() {
	        return firstName;
	    }

	    public void setFirstName(String firstName) {
	        this.firstName = firstName;
	    }

	    public String getLastName() {
	        return lastName;
	    }

	    public void setLastName(String lastName) {
	        this.lastName = lastName;
	    }

	    public Timestamp getDateRegistered() {
	        return dateRegistered;
	    }

	    public void setDateRegistered(Timestamp dateRegistered) {
	        this.dateRegistered = dateRegistered;
	    }

	    @Override
	    public String toString() {
	        return "Admin{" +
	               "phoneNumber=" + phoneNumber +
	               ", username='" + username + '\'' +
	               ", email='" + email + '\'' +
	               ", firstName='" + firstName + '\'' +
	               ", lastName='" + lastName + '\'' +
	               ", dateRegistered=" + dateRegistered +
	               '}';
	    }
	}

