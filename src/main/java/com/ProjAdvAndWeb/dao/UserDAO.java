package com.ProjAdvAndWeb.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level; // Correct import
import java.util.logging.Logger;
import java.util.stream.Collectors;

import com.ProjAdvAndWeb.util.PasswordUtil;
import com.ProjAdvAndWeb.util.DBConnectionUtil;
import com.ProjAdvAndWeb.model.Skill;
import com.ProjAdvAndWeb.model.User;

public class UserDAO {
    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());
    // Table names (ensure these match your actual DB schema)
    private static final String USER_TABLE = "users"; // As per your schema image for users table
    private static final String SKILL_DEFINITION_TABLE = "skill"; // As per your schema image for skill table
    // private static final String USER_SKILLS_TABLE = "user_skills"; // Not used if skills are in users.skills

    // Converts a list of Skill objects to a comma-separated string of their IDs.
    private String convertSkillsToSkillIdString(ArrayList<Skill> skills) {
        if (skills == null || skills.isEmpty()) {
            return "";
        }
        return skills.stream()
                     .map(skill -> String.valueOf(skill.getId()))
                     .collect(Collectors.joining(","));
    }

    // Converts a comma-separated string of skill IDs into a list of Skill objects.
    // This is critical for populating a User's offered skills.
    private ArrayList<Skill> convertSkillIdStringToSkills(String skillIdsString, SkillDAO skillDAO) throws SQLException {
        ArrayList<Skill> skillsList = new ArrayList<>();
        // ... (null checks for skillDAO and skillIdsString as before) ...

        String[] idsArray = skillIdsString.split("\\s*,\\s*");
        for (String idStr : idsArray) {
            // ... (idStr null/empty check) ...
            try {
                int skillId = Integer.parseInt(idStr.trim());
                Skill skillObject = skillDAO.getSkillById(skillId);
                if (skillObject != null) {
                    String originalName = skillObject.getName();
                    String originalCategory = skillObject.getCategory();

                    LOGGER.info("USER_DAO: Skill ID " + skillId + " fetched. Original Name: [" + originalName + "], Original Category: [" + originalCategory + "]");

                    boolean nameIsEmpty = (originalName == null || originalName.trim().isEmpty());
                    boolean categoryIsEmpty = (originalCategory == null || originalCategory.trim().isEmpty());

                    if (nameIsEmpty) {
                        skillObject.setName("Unnamed Skill (DAO)"); // Make default distinct
                        LOGGER.info("USER_DAO: Skill ID " + skillId + " - Name was empty, set to 'Unnamed Skill (DAO)'");
                    }
                    if (categoryIsEmpty) {
                        skillObject.setCategory("Uncategorized (DAO)"); // Make default distinct
                        LOGGER.info("USER_DAO: Skill ID " + skillId + " - Category was empty, set to 'Uncategorized (DAO)'");
                    }
                    
                    // Log the state *after* attempting to set defaults
                    LOGGER.info("USER_DAO: Skill ID " + skillId + " *after* defaulting. Final Name: [" + skillObject.getName() + "], Final Category: [" + skillObject.getCategory() + "]");

                    skillsList.add(skillObject);
                } else {
                    LOGGER.warning("USER_DAO: Skill definition not found for ID: " + skillId);
                }
            } catch (NumberFormatException e) {
                LOGGER.warning("USER_DAO: Invalid skill ID format: '" + idStr + "'");
            } // Catch SQLException already handled in previous version
        }
        return skillsList;
    }

    public User getUserByUsername(String username) throws SQLException {
        String sql = "SELECT * FROM " + USER_TABLE + " WHERE username = ?";
        User user = null;
        // It's better to create SkillDAO once if used multiple times, or pass as dependency.
        // For simplicity here, creating it locally.
        SkillDAO skillDAOInstance = new SkillDAO();

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement pstmt = (con != null) ? con.prepareStatement(sql) : null) {

            if (pstmt == null) {
                throw new SQLException("Failed to create PreparedStatement, connection might be null for getUserByUsername.");
            }
            pstmt.setString(1, username);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    user = new User();
                    user.setUsername(rs.getString("username"));
                    user.setFirstName(rs.getString("firstName"));
                    user.setLastName(rs.getString("lastName"));
                    user.setEmail(rs.getString("email"));
                    user.setPasswordHash(rs.getString("passwordHash"));
                    user.setPhoneNumber(rs.getInt("phoneNumber"));
                    user.setPoints(rs.getInt("points"));
                    user.setDateRegistered(rs.getTimestamp("dateRegistered"));
                    user.setEmailVerified(rs.getBoolean("isEmailVerified"));

                    // Populate the user's skills
                    String skillIdsStr = rs.getString("skills"); // Column in 'users' table
                    user.setSkills(convertSkillIdStringToSkills(skillIdsStr, skillDAOInstance));
                    LOGGER.info("User " + username + " loaded with " + user.getSkills().size() + " skills.");
                } else {
                    LOGGER.info("No user found with username: " + username);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error fetching user by username: " + username, e);
            throw e;
        }
        return user;
    }
     
    public boolean addUser(User user) throws SQLException {
        // Ensure 'users' table matches these columns
        String sql="INSERT INTO " + USER_TABLE + " (username, passwordHash, email, firstName, lastName, phoneNumber, dateRegistered, points, skills, isEmailVerified) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection con = null; PreparedStatement pstmt= null;
        try {
            con=DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("Failed to get DB connection for addUser.");
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getPasswordHash());
            pstmt.setString(3, user.getEmail());
            pstmt.setString(4, user.getFirstName());
            pstmt.setString(5, user.getLastName());
            pstmt.setInt(6, user.getPhoneNumber()); // Ensure correct order if schema differs
            if (user.getDateRegistered() == null) user.setDateRegistered(new Timestamp(System.currentTimeMillis()));
            pstmt.setTimestamp(7, user.getDateRegistered());
            pstmt.setInt(8, user.getPoints());
            pstmt.setString(9, convertSkillsToSkillIdString(user.getSkills()));
            pstmt.setBoolean(10, user.isEmailVerified());

            int isAffected = pstmt.executeUpdate();
            return isAffected > 0;
        } finally {
            closeStatement(pstmt);
            DBConnectionUtil.closeConnection(con);
        }
    }

    // ... (getAllUsers, getAllUsersExcept, getUserByEmail, etc. should also use the new SkillDAO and convertSkillIdStringToSkills pattern if they populate user skills)

    public List<User> getAllUsers() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM " + USER_TABLE;
        SkillDAO skillDAO = new SkillDAO();

        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement pstmt = (con != null) ? con.prepareStatement(sql) : null;
             ResultSet rs = (pstmt != null) ? pstmt.executeQuery() : null) {

            if (rs == null) {
                if (pstmt == null) LOGGER.severe("Connection or PreparedStatement null in getAllUsers");
                else LOGGER.severe("ResultSet null in getAllUsers");
                return users; // or throw exception
            }

            while (rs.next()) {
                User user = new User();
                user.setUsername(rs.getString("username"));
                user.setFirstName(rs.getString("firstName"));
                user.setLastName(rs.getString("lastName"));
                user.setEmail(rs.getString("email"));
                user.setPasswordHash(rs.getString("passwordHash"));
                user.setPhoneNumber(rs.getInt("phoneNumber"));
                user.setPoints(rs.getInt("points"));
                user.setDateRegistered(rs.getTimestamp("dateRegistered"));
                user.setEmailVerified(rs.getBoolean("isEmailVerified"));
                String skillIdsStr = rs.getString("skills");
                user.setSkills(convertSkillIdStringToSkills(skillIdsStr, skillDAO));
                users.add(user);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting all users", e);
            throw e;
        }
        return users;
    }
 
     public List<User> getAllUsersExcept(String excludeUsername) throws SQLException {
         List<User> users = new ArrayList<>();
         String sql = "SELECT username, firstName, lastName, email FROM " + USER_TABLE + " WHERE username != ?";
         // Note: This method, for performance, might not load full skills for each user.
         // The current request form loads skills dynamically via AJAX, so this list is mainly for names.
         try (Connection con = DBConnectionUtil.getConnection();
              PreparedStatement pstmt = (con != null) ? con.prepareStatement(sql) : null) {

             if (pstmt == null) {
                 throw new SQLException("Failed to create PreparedStatement, connection might be null for getAllUsersExcept.");
             }
             pstmt.setString(1, excludeUsername);
             try (ResultSet rs = pstmt.executeQuery()) {
                 while (rs.next()) {
                     User user = new User();
                     user.setUsername(rs.getString("username"));
                     user.setFirstName(rs.getString("firstName"));
                     user.setLastName(rs.getString("lastName"));
                     user.setEmail(rs.getString("email"));
                     // Skills are NOT typically loaded here to keep the list light.
                     // The form will fetch them dynamically for the selected provider.
                     users.add(user);
                 }
             }
         } catch (SQLException e) {
             LOGGER.log(Level.SEVERE, "Error in getAllUsersExcept", e);
             throw e;
         }
         return users;
     }


    // Method to update the 'skills' TEXT column in the 'users' table
    public boolean updateUserSkillsColumnString(String username, String skillsIdString) throws SQLException {
        String sql = "UPDATE " + USER_TABLE + " SET skills = ? WHERE username = ?";
        try (Connection con = DBConnectionUtil.getConnection();
             PreparedStatement pstmt = (con != null) ? con.prepareStatement(sql) : null) {
            if (pstmt == null) throw new SQLException("Connection or PreparedStatement null in updateUserSkillsColumnString");
            pstmt.setString(1, skillsIdString != null ? skillsIdString : ""); // Ensure empty string if null
            pstmt.setString(2, username);
            return pstmt.executeUpdate() > 0;
        }
    }
     
    // --- Note on getAllOfferedSkillsExcept ---
    // The original UserDAO.getAllOfferedSkillsExcept method used a direct SQL join assuming a 'user_skills'
    // junction table. This contradicts the 'users.skills' TEXT column approach.
    // If you need a method that returns all skills offered by users (excluding one),
    // it would involve fetching all users (except the one to exclude), then iterating their
    // getSkills() list. For now, I'm commenting out the old one as it's inconsistent.
    /*
    public List<Skill> getAllOfferedSkillsExcept(String excludeUsername) throws SQLException {
        // ... This method needs to be rewritten if you use the users.skills TEXT column approach
        // to be consistent. It would involve:
        // 1. Get all users (or all users except excludeUsername).
        // 2. For each user, get their skills (which are already parsed Skill objects).
        // 3. Aggregate these skills, potentially adding the provider's username to each Skill object.
        // This is complex and likely not needed if the AJAX call in newSwapForm.jsp is working correctly.
        LOGGER.warning("UserDAO.getAllOfferedSkillsExcept is based on a 'user_skills' table, which might be inconsistent with the 'users.skills' TEXT column approach.");
        return new ArrayList<>(); // Return empty or implement correctly based on users.skills
    }
    */


    // Keep other UserDAO methods as they are (validateUser, storeRememberMeToken, etc.)
    // Make sure to use closeStatement and closeResultSet helpers or try-with-resources.

    // Helper closing methods
    private void closeStatement(Statement stmt) {
        if (stmt != null) {
            try { stmt.close(); } catch (SQLException e) { LOGGER.log(Level.WARNING, "Error closing statement", e); }
        }
    }
    private void closeResultSet(ResultSet rs) {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { LOGGER.log(Level.WARNING, "Error closing result set", e); }
        }
    }
    // ... (The rest of your UserDAO methods: getUserByEmail, validateUser, updateUserSkillsString, etc.)
    // Ensure they are consistent with the changes, especially if they handle user skills.
     public User getUserByEmail(String email) throws SQLException {
         String sql = "SELECT * FROM " + USER_TABLE + " WHERE email = ?";
         User user = null;
         SkillDAO skillDAOInstance = new SkillDAO(); // Create once

         try (Connection con = DBConnectionUtil.getConnection();
              PreparedStatement pstmt = (con != null) ? con.prepareStatement(sql) : null) {
             if (pstmt == null) {
                 throw new SQLException("Failed to create PreparedStatement for getUserByEmail.");
             }
             pstmt.setString(1, email);
             try (ResultSet rs = pstmt.executeQuery()) {
                 if (rs.next()) {
                     user = new User();
                     user.setUsername(rs.getString("username"));
                     user.setFirstName(rs.getString("firstName"));
                     user.setLastName(rs.getString("lastName"));
                     user.setEmail(rs.getString("email"));
                     user.setPasswordHash(rs.getString("passwordHash"));
                     user.setPhoneNumber(rs.getInt("phoneNumber"));
                     user.setPoints(rs.getInt("points"));
                     user.setDateRegistered(rs.getTimestamp("dateRegistered"));
                     user.setEmailVerified(rs.getBoolean("isEmailVerified"));
                     String skillIdsStr = rs.getString("skills");
                     user.setSkills(convertSkillIdStringToSkills(skillIdsStr, skillDAOInstance));
                 }
             }
         } catch (SQLException e) {
             LOGGER.log(Level.SEVERE, "Database error fetching user by email: " + email, e);
             throw e;
         }
         return user;
     }

     public User validateUser(String username, String plainTextPassword) throws SQLException {
         User user = getUserByUsername(username); // This now correctly loads skills if needed later
         if (user != null) {
             if (PasswordUtil.checkPassword(plainTextPassword, user.getPasswordHash())) {
                 return user;
             } else {
                 LOGGER.warning("Password mismatch for user: " + username);
             }
         } else {
             LOGGER.info("User not found during validation: " + username);
         }
         return null;
     }

     public boolean updateUser(User user) throws SQLException {
         String sql = "UPDATE " + USER_TABLE + " SET email = ?, firstName = ?, lastName = ?, phoneNumber = ?, points = ?, skills = ?, isEmailVerified = ? " +
                      "WHERE username = ?";
         // Note: Added skills and isEmailVerified to update, adjust if not intended
         try (Connection con = DBConnectionUtil.getConnection();
              PreparedStatement pstmt = (con != null) ? con.prepareStatement(sql) : null) {
             if (pstmt == null) throw new SQLException("Connection or PreparedStatement null in updateUser");

             pstmt.setString(1, user.getEmail());
             pstmt.setString(2, user.getFirstName());
             pstmt.setString(3, user.getLastName());
             pstmt.setInt(4, user.getPhoneNumber());
             pstmt.setInt(5, user.getPoints());
             pstmt.setString(6, convertSkillsToSkillIdString(user.getSkills())); // Save skills
             pstmt.setBoolean(7, user.isEmailVerified());
             pstmt.setString(8, user.getUsername());

             return pstmt.executeUpdate() > 0;
         }
     }
     // ... other methods like storeRememberMeToken, clearRememberMeToken, updateUserPointsTransactional, etc.
     // ensure they use try-with-resources or manual close for PreparedStatement and Connection where appropriate.
     public boolean storeRememberMeToken(String username, String selector, String hashedValidator, Timestamp expiryDate) throws SQLException {
         String sql = "INSERT INTO remembertokens (username, selector, validatorHash, expiryDate) VALUES (?, ?, ?, ?)";
         try (Connection con = DBConnectionUtil.getConnection();
              PreparedStatement pstmt = (con != null) ? con.prepareStatement(sql) : null) {
             if (pstmt == null) throw new SQLException("Failed to get DB connection for storeRememberMeToken.");
             pstmt.setString(1, username);
             pstmt.setString(2, selector);
             pstmt.setString(3, hashedValidator);
             pstmt.setTimestamp(4, expiryDate);
             return pstmt.executeUpdate() > 0;
         }
     }

     public boolean clearRememberMeToken(String selector) throws SQLException {
         String sql = "DELETE FROM remembertokens WHERE selector = ?";
         try (Connection con = DBConnectionUtil.getConnection();
              PreparedStatement pstmt = (con != null) ? con.prepareStatement(sql) : null) {
             if (pstmt == null) throw new SQLException("Failed to get DB connection for clearRememberMeToken.");
             pstmt.setString(1, selector);
             return pstmt.executeUpdate() > 0;
         }
     }
     // This class should be a top-level or static nested class if public, or private static if only used here.
     // Making it public static for now.
     public static class RememberMeTokenData {
         public final String username;
         public final String storedValidatorHash;

         public RememberMeTokenData(String username, String storedValidatorHash) {
             this.username = username;
             this.storedValidatorHash = storedValidatorHash;
         }
     }
     public RememberMeTokenData getRememberMeTokenDataBySelector(String selector) throws SQLException {
         String sql = "SELECT username, validatorHash, expiryDate FROM remembertokens WHERE selector = ?";
         RememberMeTokenData tokenData = null;
         try (Connection con = DBConnectionUtil.getConnection();
              PreparedStatement pstmt = (con != null) ? con.prepareStatement(sql) : null) {
             if (pstmt == null) throw new SQLException("Failed to get DB connection for getRememberMeTokenDataBySelector.");
             pstmt.setString(1, selector);
             try (ResultSet rs = pstmt.executeQuery()) {
                 if (rs.next()) {
                     Timestamp expiryDate = rs.getTimestamp("expiryDate");
                     if (expiryDate != null && expiryDate.after(new Timestamp(System.currentTimeMillis()))) {
                         tokenData = new RememberMeTokenData(
                             rs.getString("username"),
                             rs.getString("validatorHash")
                         );
                     } else if (expiryDate != null) { // Token expired
                         LOGGER.info("Expired remember-me token found for selector: " + selector + ". Clearing it.");
                         // Call clearRememberMeToken within a new try-catch or ensure it handles its own connection.
                         // For simplicity here, assuming it will be cleared. This could be a separate cleanup task.
                         // clearRememberMeToken(selector); // Careful with nested operations needing new connections
                     }
                 }
             }
         }
         return tokenData;
     }
     public boolean updateUserPointsTransactional(String username, int newPointsTotal, Connection con) throws SQLException {
         // This method is special as it uses a passed-in connection for transactions.
         String sql = "UPDATE " + USER_TABLE + " SET points = ? WHERE username = ?";
         PreparedStatement pstmt = null; // Cannot use try-with-resources for pstmt if con is managed outside
         try {
             if (con == null || con.isClosed()) {
                 throw new SQLException("Connection is null or closed in updateUserPointsTransactional.");
             }
             pstmt = con.prepareStatement(sql);
             pstmt.setInt(1, newPointsTotal);
             pstmt.setString(2, username);
             return pstmt.executeUpdate() > 0;
         } finally {
             // Only close pstmt here; 'con' is managed by the caller.
             if (pstmt != null) {
                 try { pstmt.close(); } catch (SQLException e) { LOGGER.log(Level.WARNING, "Error closing pstmt in updateUserPointsTransactional", e); }
             }
         }
     }
     public boolean updateUserEmailVerificationStatus(String username, boolean isVerified) throws SQLException {
         String sql = "UPDATE " + USER_TABLE + " SET isEmailVerified = ? WHERE username = ?";
         try (Connection con = DBConnectionUtil.getConnection();
              PreparedStatement ps = (con != null) ? con.prepareStatement(sql) : null) {
             if (ps == null) throw new SQLException("Failed to get DB connection for updateUserEmailVerificationStatus.");
             ps.setBoolean(1, isVerified);
             ps.setString(2, username);
             return ps.executeUpdate() > 0;
         }
     }

     public boolean addSkillToUserList(String username, int skillId, SkillDAO skillDAO) throws SQLException {
         User user = getUserByUsername(username);
         if (user == null) {
             LOGGER.warning("UserDAO: User not found for adding skill: " + username);
             return false;
         }

         // Check if skill already exists for the user
         boolean skillExists = user.getSkills().stream().anyMatch(s -> s.getId() == skillId);
         if (skillExists) {
             LOGGER.info("UserDAO: Skill ID " + skillId + " already in list for user " + username);
             return true; // Or false if you consider it a "no operation" failure
         }

         Skill skillToAdd = skillDAO.getSkillById(skillId);
         if (skillToAdd == null) {
             LOGGER.warning("UserDAO: Skill ID " + skillId + " not found in skills table. Cannot add to user.");
             return false;
         }

         ArrayList<Skill> currentSkills = user.getSkills(); // Should be a mutable list from User object
         currentSkills.add(skillToAdd);
         // user.setSkills(currentSkills); // Not strictly necessary if getSkills() returns the actual list reference

         String newSkillsString = convertSkillsToSkillIdString(currentSkills);
         return updateUserSkillsColumnString(username, newSkillsString); // This method handles DB update
     }

     public boolean removeSkillFromUserList(String username, int skillIdToRemove) throws SQLException {
         User user = getUserByUsername(username);
         if (user == null) {
             LOGGER.warning("UserDAO: User not found for removing skill: " + username);
             return false;
         }

         ArrayList<Skill> currentSkills = user.getSkills();
         boolean removed = currentSkills.removeIf(skill -> skill.getId() == skillIdToRemove);

         if (!removed) {
             LOGGER.info("UserDAO: Skill ID " + skillIdToRemove + " not found in user " + username + "'s list. No change made.");
             return false; // Or true if "not found to remove" is considered success
         }
         // user.setSkills(currentSkills); // Not strictly necessary

         String newSkillsString = convertSkillsToSkillIdString(currentSkills);
         return updateUserSkillsColumnString(username, newSkillsString);
     }
     public boolean updatePassword(String userEmail, String hashedPassword) throws SQLException {
         String sql = "UPDATE " + USER_TABLE + " SET passwordHash = ? WHERE email = ?";
         try (Connection conn = DBConnectionUtil.getConnection();
              PreparedStatement ps = (conn != null) ? conn.prepareStatement(sql) : null) {
             if (ps == null) throw new SQLException("Failed to create PreparedStatement for updatePassword.");
             ps.setString(1, hashedPassword);
             ps.setString(2, userEmail);
             int rowsAffected = ps.executeUpdate();
             return rowsAffected == 1;
         }
     }
     // getUserOfferedGenericSkills and getUserRequestedGenericSkills used a JOIN with 'Swap' table which is incorrect
     // for getting a user's defined skills. A user's skills come from users.skills column.
     // These methods seem to be for a different purpose or are misnamed/misimplemented.
     // If they are intended to find skills involved in swaps, their names should reflect that.
     // For now, I'm commenting them out as they are not directly related to the "false (false)" bug
     // and their current implementation is confusing.
     /*
     public ArrayList<Skill> getUserOfferedGenericSkills(String username) { ... }
     public ArrayList<Skill> getUserRequestedGenericSkills(String username) { ... }
     */
}