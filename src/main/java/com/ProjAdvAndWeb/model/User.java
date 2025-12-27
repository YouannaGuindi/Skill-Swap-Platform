package com.ProjAdvAndWeb.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
// Skill model will be used again
// import com.ProjAdvAndWeb.model.Skill; // Already have this if Skill.java exists

public class User {
    private int phoneNumber;
    private String username;
    private String passwordHash;
    private String email;
    private String firstName;
    private String lastName;
    private Timestamp dateRegistered;
    private int points;
    private ArrayList<Skill> skills; // <<<< THIS IS BACK
    // private String skillsString;      // <<<< REMOVE THIS
    private boolean isEmailVerified;
    // private String profilePicPath;

    public User() {
        this.skills = new ArrayList<>(); // <<<< INITIALIZE THIS
        this.dateRegistered = new Timestamp(new Date().getTime());
    }

    // Constructor (adjust if needed)
    public User(int phoneNumber, String username, String passwordHash, String email,
                String firstName, String lastName, int points, /* String skillsString, */ boolean isEmailVerified) {
        this.phoneNumber = phoneNumber;
        this.username = username;
        this.passwordHash = passwordHash;
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.dateRegistered = new Timestamp(new Date().getTime());
        this.points = points;
        this.skills = new ArrayList<>(); // Initialize
        // this.skillsString = skillsString != null ? skillsString : ""; // REMOVE
        this.isEmailVerified = isEmailVerified;
    }

    // Getters and Setters
    public int getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(int phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public Timestamp getDateRegistered() { return dateRegistered; }
    public void setDateRegistered(Timestamp dateRegistered) { this.dateRegistered = dateRegistered; }
    public void setDateRegistered() { this.dateRegistered = new Timestamp(new Date().getTime());}


    public int getPoints() { return points; }
    public void setPoints(int points) { this.points = points; }

    // RESTORED Skill list methods
    public ArrayList<Skill> getSkills() {
        if (this.skills == null) { // Defensive coding
            this.skills = new ArrayList<>();
        }
        return skills;
    }
    public void setSkills(ArrayList<Skill> skills) {
        this.skills = skills;
    }
    public void addSkill(Skill skill) {
        if (this.skills == null) {
            this.skills = new ArrayList<>();
        }
        // Optional: Check if skill (by ID) already exists before adding
        if (skill != null && this.skills.stream().noneMatch(s -> s.getId() == skill.getId())) {
            this.skills.add(skill);
        }
    }


    // REMOVE skillsString getter/setter
    /*
    public String getSkillsString() { ... }
    public void setSkillsString(String skillsString) { ... }
    */
    // REMOVE getSkillListFromString() - user.getSkills() will provide List<Skill>

    public boolean isEmailVerified() { return isEmailVerified; }
    public void setEmailVerified(boolean isEmailVerified) { this.isEmailVerified = isEmailVerified; }

    // public String getProfilePicPath() { return profilePicPath; }
    // public void setProfilePicPath(String profilePicPath) { this.profilePicPath = profilePicPath; }

    @Override
    public String toString() {
        // Adjust to show number of skills or skill names if desired
        return "User [phoneNumber=" + phoneNumber + ", username=" + username + ", email=" + email +
               ", firstName=" + firstName + ", lastName=" + lastName + ", dateRegistered=" + dateRegistered +
               ", points=" + points + ", skillsCount=" + (skills != null ? skills.size() : 0) + ", isEmailVerified=" + isEmailVerified + "]";
    }
}