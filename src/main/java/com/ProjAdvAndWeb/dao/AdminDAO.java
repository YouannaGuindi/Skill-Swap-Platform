package com.ProjAdvAndWeb.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement; // Import Statement
import com.ProjAdvAndWeb.model.Admin;
import com.ProjAdvAndWeb.model.Skill;
import com.ProjAdvAndWeb.model.Swap;
import com.ProjAdvAndWeb.model.SwapStatus;
import com.ProjAdvAndWeb.model.User;
import com.ProjAdvAndWeb.util.DBConnectionUtil;
import com.ProjAdvAndWeb.util.PasswordUtil;
import java.sql.Connection;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Date;



public class AdminDAO {

     private SkillDAO skillDAO;

     public AdminDAO() {
        try {
            this.skillDAO = new SkillDAO();
        } catch (Exception e) {
             System.err.println("AdminDAO: Failed to initialize SkillDAO dependency: " + e.getMessage());
             // Log the error. Methods that require skillDAO will need to handle the case where it's null.
        }
     }


     public boolean addAdmin(Admin admin) throws SQLException {
         String sql = "INSERT INTO admins (phoneNumber, username, passwordHash, email, firstName, lastName, dateRegistered) VALUES (?, ?, ?, ?, ?, ?, ?)";
         Connection con = null;
         PreparedStatement pstmt = null;
         boolean success = false;

         try {
             con = DBConnectionUtil.getConnection();
             if (con == null) {
                 System.err.println("AdminDAO.addAdmin: Failed to get database connection.");
                 throw new SQLException("Failed to get database connection for addAdmin.");
             }
             pstmt = con.prepareStatement(sql);
             pstmt.setInt(1, admin.getPhoneNumber());
             pstmt.setString(2, admin.getUsername());
             pstmt.setString(3, admin.getPasswordHash());
             pstmt.setString(4, admin.getEmail());
             pstmt.setString(5, admin.getFirstName());
             pstmt.setString(6, admin.getLastName());

             if (admin.getDateRegistered() != null) {
                 pstmt.setTimestamp(7, admin.getDateRegistered());
             } else {
                 pstmt.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
             }

             int rowsAffected = pstmt.executeUpdate();
             if (rowsAffected > 0) {
                 success = true;
             }
         } finally {
             closeStatement(pstmt);
             DBConnectionUtil.closeConnection(con);
         }
         return success;
     }


    // --- Admin Account Validation ---
    // (Essential for admin login, queries the 'admins' table)

    // KEEPING THE ORIGINAL METHOD in case it's used elsewhere, but validateAdmin will use the new one
    /**
     * Retrieves an Admin user by their username from the 'admins' table.
     * @param username The username of the admin.
     * @return The Admin object if found, null otherwise.
     * @throws SQLException If a database error occurs.
     */
    public Admin getAdminByUsername(String username) throws SQLException {
        String sql = "SELECT phoneNumber, username, passwordHash, email, firstName, lastName, dateRegistered FROM admins WHERE username = ?";
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Admin admin = null;

        try {
            con = DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("Failed to get DB connection for getAdminByUsername.");
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                admin = mapResultSetToAdmin(rs); // Use mapping helper
            }
        } finally {
            closeResultSet(rs);
            closeStatement(pstmt);
            DBConnectionUtil.closeConnection(con);
        }
        return admin;
    }

    // NEW METHOD: Find Admin by Username OR Email
    /**
     * Retrieves an Admin user by their username or email from the 'admins' table.
     * @param identifier The username or email of the admin.
     * @return The Admin object if found, null otherwise.
     * @throws SQLException If a database error occurs.
     */
    public Admin getAdminByUsernameOrEmail(String identifier) throws SQLException {
        // Query both username and email columns
        String sql = "SELECT phoneNumber, username, passwordHash, email, firstName, lastName, dateRegistered FROM admins WHERE username = ? OR email = ?";
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Admin admin = null;

        try {
            con = DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("Failed to get DB connection for getAdminByUsernameOrEmail.");
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, identifier); // Set the identifier for the username check
            pstmt.setString(2, identifier); // Set the identifier for the email check
            rs = pstmt.executeQuery();

            if (rs.next()) {
                 admin = mapResultSetToAdmin(rs); // Use mapping helper
            }
        } finally {
            closeResultSet(rs);
            closeStatement(pstmt);
            DBConnectionUtil.closeConnection(con);
        }
        return admin;
    }


    /**
     * Validates admin login credentials using username/email and password.
     * Now searches by either username or email.
     * @param identifier The admin username or email.
     * @param plainTextPassword The plain text password provided by the admin.
     * @return The authenticated Admin object if credentials are valid, null otherwise.
     * @throws SQLException If a database error occurs during admin lookup.
     */
    public Admin validateAdmin(String identifier, String plainTextPassword) throws SQLException {
        // Use the new method to find the admin by either username or email
        Admin admin = getAdminByUsernameOrEmail(identifier);
        if (admin != null) {
            if (PasswordUtil.checkPassword(plainTextPassword, admin.getPasswordHash())) {
                return admin;
            } else {
                // Log password mismatch specifically for the found admin
                System.out.println("AdminDAO.validateAdmin: Password mismatch for admin: " + admin.getUsername() + " (email: " + admin.getEmail() + ")");
            }
        } else {
            // Log that no admin was found for the provided identifier
            System.out.println("AdminDAO.validateAdmin: Admin not found for identifier: " + identifier);
        }
        return null;
    }


    // --- Methods for User Monitoring (Including Skills in the List View) ---
    // These methods fetch user data using available User model fields and usernames,
    // including mapping skills when getting the full list.
    // User identification uses username (String).

    /**
     * Retrieves a list of all registered users with full details, including skills,
     * for administrative monitoring overview.
     * NOTE: This method fetches all users and then performs potentially multiple
     * additional queries per user to retrieve their skills based on the comma-separated
     * string. It might be less efficient for a very large number of users compared to
     * a list without skills.
     * Renamed from getAllUsersWithSkillsForAdminView to getAllUsersBasicInfo as requested.
     * @return A List of User objects with full details, or an empty list if none found.
     * @throws SQLException If a database error occurs (including during skill lookup).
     */
    public List<User> getAllUsersBasicInfo() throws SQLException { // <-- Renamed method
        // Select all user columns needed to create a User object, including 'skills' string and 'passwordHash'
        String sql = "SELECT phoneNumber, username, passwordHash, email, firstName, lastName, dateRegistered, points, skills, isEmailVerified FROM users ORDER BY dateRegistered DESC";
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<User> userList = new ArrayList<>();

        // Check if SkillDAO was initialized successfully before using it
        if (this.skillDAO == null) {
             throw new SQLException("SkillDAO dependency not initialized in AdminDAO. Cannot retrieve user skills for list.");
        }

        try {
            con = DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("Failed to get DB connection for getAllUsersBasicInfo.");
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                // Use a mapping helper that maps the full User object, including skills
                User user = mapResultSetToFullUserWithSkills(rs); // Uses helper that calls convertSkillIdStringToSkills
                userList.add(user);
            }
        } finally {
            closeResultSet(rs);
            closeStatement(pstmt);
            DBConnectionUtil.closeConnection(con);
        }
        return userList;
    }


     // Removed getUserByUsernameWithSkillsForAdminView as requested.
     // If you need details of a single user with skills, you would use UserDAO.getUserByUsername()


    /**
     * Gets the total count of registered users.
     * This is efficient as it's a simple count query and doesn't involve skills.
     * @return The number of users, or 0 if none exist.
     * @throws SQLException If a database error occurs.
     */
    public int getUserCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM users"; // SQL to get the total number of rows
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            con = DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("Failed to get DB connection for getUserCount.");
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }
        } finally {
            closeResultSet(rs);
            closeStatement(pstmt);
            DBConnectionUtil.closeConnection(con);
        }
        return count;
    }


    // --- Efficient Methods for Swap Monitoring ---
    // These methods query the 'swap' table and efficiently join with the 'skills' table
    // to include skill details associated with the swap (separate from user skills lists).

    /**
     * Retrieves a list of swaps created or last updated within a specific date range for admin review.
     * Uses an efficient JOIN query to include joined skill details from the 'skills' table.
     * @param startDate The start date (inclusive).
     * @param endDate The end date (inclusive).
     * @return A List of Swap objects, or an empty list if none found.
     * @throws SQLException If a database error occurs.
     */
    public List<Swap> getSwapsByDateRange(Date startDate, Date endDate) throws SQLException {
        String sql = "SELECT se.*, s.id AS generic_skill_id, s.name AS skill_name, s.category AS skill_category, s.description AS skill_description " +
                     // --- FIX: Changed FROM skill se to FROM swap se ---
                     "FROM swap se " +
                     "JOIN skill s ON se.offeredSkillId = s.id " +
                     // --- FIX: Changed se.requestDate back to se.lastUpdatedDate ---
                     "WHERE se.lastUpdatedDate BETWEEN ? AND ? " +
                     // --- FIX: Changed se.requestDate back to se.lastUpdatedDate in ORDER BY ---
                     "ORDER BY se.lastUpdatedDate DESC, se.requestDate DESC";
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Swap> swapList = new ArrayList<>();

        try {
            con = DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("Failed to get DB connection for getSwapsByDateRange.");
            pstmt = con.prepareStatement(sql);
            pstmt.setTimestamp(1, new Timestamp(startDate.getTime()));
            pstmt.setTimestamp(2, new Timestamp(endDate.getTime()));
            rs = pstmt.executeQuery();

            while (rs.next()) {
                swapList.add(mapResultSetToSwapForAdminView(rs));
            }
        } finally {
            closeResultSet(rs);
            closeStatement(pstmt);
            DBConnectionUtil.closeConnection(con);
        }
        return swapList;
    }

     /**
     * Retrieves a list of swaps with a specific status created or last updated within a date range for admin review.
     * Includes joined skill details using an efficient JOIN query.
     * @param status The SwapStatus enum value to filter by.
     * @param startDate The start date (inclusive).
     * @param endDate The end date (inclusive).
     * @return A List of Swap objects, or an empty list if none found.
     * @throws SQLException If a database error occurs.
     */
    public List<Swap> getSwapsByDateRangeAndStatus(SwapStatus status, Date startDate, Date endDate) throws SQLException {
        String sql = "SELECT se.*, s.id AS generic_skill_id, s.name AS skill_name, s.category AS skill_category, s.description AS skill_description " +
                     // --- FIX: Changed FROM skill se to FROM swap se ---
                     "FROM swap se " +
                     "JOIN skill s ON se.offeredSkillId = s.id " +
                     // --- FIX: Changed se.requestDate back to se.lastUpdatedDate ---
                     "WHERE se.status = ? AND se.lastUpdatedDate BETWEEN ? AND ? " +
                     // --- FIX: Changed se.requestDate back to se.lastUpdatedDate in ORDER BY ---
                     "ORDER BY se.lastUpdatedDate DESC, se.requestDate DESC";
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Swap> swapList = new ArrayList<>();

        try {
            con = DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("Failed to get DB connection for getSwapsByDateRangeAndStatus.");
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, status.name());
            pstmt.setTimestamp(2, new Timestamp(startDate.getTime()));
            pstmt.setTimestamp(3, new Timestamp(endDate.getTime()));
            rs = pstmt.executeQuery();

            while (rs.next()) {
                swapList.add(mapResultSetToSwapForAdminView(rs));
            }
        } finally {
            closeResultSet(rs);
            closeStatement(pstmt);
            DBConnectionUtil.closeConnection(con);
        }
        return swapList;
    }


     /**
     * Gets the total count of swaps created or last updated within a specific date range.
     * This is an efficient operation using a simple count query.
     * @param startDate The start date (inclusive).
     * @param endDate The end date (inclusive).
     * @return The number of swaps, or 0 if none exist.
     * @throws SQLException If a database error occurs.
     */
    public int getSwapCountByDateRange(Date startDate, Date endDate) throws SQLException {
        // --- FIX: Changed FROM skill back to FROM swap AND lastUpdatedDate back ---
        String sql = "SELECT COUNT(*) FROM swap WHERE lastUpdatedDate BETWEEN ? AND ?";
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            con = DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("Failed to get DB connection for getSwapCountByDateRange.");
            pstmt = con.prepareStatement(sql);
            pstmt.setTimestamp(1, new Timestamp(startDate.getTime()));
            pstmt.setTimestamp(2, new Timestamp(endDate.getTime()));
            rs = pstmt.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }
        } finally {
            closeResultSet(rs);
            closeStatement(pstmt);
            DBConnectionUtil.closeConnection(con);
        }
        return count;
    }

    /**
     * Gets the count of swaps with a specific status created or last updated within a date range.
     * This is an efficient operation using a simple count query.
     * @param status The SwapStatus enum value to filter by.
     * @param startDate The start date (inclusive).
     * @param endDate The end date (inclusive).
     * @return The number of swaps with that status, or 0 if none exist.
     * @throws SQLException If a database error occurs.
     */
    public int getSwapCountByDateRangeAndStatus(SwapStatus status, Date startDate, Date endDate) throws SQLException {
        // --- FIX: Changed FROM skill back to FROM swap AND lastUpdatedDate back ---
        String sql = "SELECT COUNT(*) FROM swap WHERE status = ? AND lastUpdatedDate BETWEEN ? AND ?";
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            con = DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("Failed to get DB connection for getSwapCountByDateRangeAndStatus.");
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, status.name());
            pstmt.setTimestamp(2, new Timestamp(startDate.getTime()));
            pstmt.setTimestamp(3, new Timestamp(endDate.getTime()));
            rs = pstmt.executeQuery();

            if (rs.next()) {
                count = rs.getInt(1);
            }
        } finally {
            closeResultSet(rs);
            closeStatement(pstmt);
            DBConnectionUtil.closeConnection(con);
        }
        return count;
    }


    // --- Mapping Helpers ---
    // These help convert database result rows into Java objects using available data.

    // NEW Helper: Map ResultSet to Admin object
    /**
     * Helper method to map admin columns from a ResultSet to an Admin object.
     * Assumes the query selects all necessary admin columns (phoneNumber, username, etc.).
     */
    private Admin mapResultSetToAdmin(ResultSet rs) throws SQLException {
        Admin admin = new Admin();
        admin.setPhoneNumber(rs.getInt("phoneNumber"));
        admin.setUsername(rs.getString("username"));
        admin.setPasswordHash(rs.getString("passwordHash"));
        admin.setEmail(rs.getString("email"));
        admin.setFirstName(rs.getString("firstName"));
        admin.setLastName(rs.getString("lastName"));
        admin.setDateRegistered(rs.getTimestamp("dateRegistered"));
        return admin;
    }


    /**
     * Helper method to map user columns from a ResultSet to a User object,
     * including converting the skills string to a list of Skill objects.
     * This method is intended for use when you specifically need the user's skill list.
     * It requires the AdminDAO's SkillDAO instance to look up each skill ID.
     * Assumes the query selects all necessary user columns (phoneNumber, username, etc. AND skills, passwordHash).
     */
    private User mapResultSetToFullUserWithSkills(ResultSet rs) throws SQLException {
         User user = new User();
         // Map fields available in the User model based on the query results
         user.setPhoneNumber(rs.getInt("phoneNumber")); // Assuming this column exists in DB & model
         user.setUsername(rs.getString("username"));
         user.setPasswordHash(rs.getString("passwordHash")); // Include password hash from DB
         user.setEmail(rs.getString("email"));
         user.setFirstName(rs.getString("firstName"));
         user.setLastName(rs.getString("lastName"));
         user.setDateRegistered(rs.getTimestamp("dateRegistered"));
         user.setPoints(rs.getInt("points"));

         // Map skills list by converting the comma-separated string using the helper method
         String skillIdsStr = rs.getString("skills"); // Get the comma-separated string
         // Check if SkillDAO was initialized before using it
         if (this.skillDAO == null) {
              System.err.println("AdminDAO.mapResultSetToFullUserWithSkills: SkillDAO dependency is null. Cannot map skills.");
             user.setSkills(new ArrayList<>()); // Set empty list to avoid NullPointerException
         } else {
             user.setSkills(convertSkillIdStringToSkills(skillIdsStr)); // Convert string to list using helper
         }

         user.setEmailVerified(rs.getBoolean("isEmailVerified"));
         return user;
    }

     /**
      * Helper method to convert the comma-separated skill ID string into a list of Skill objects.
      * Requires the AdminDAO's SkillDAO instance to look up each skill by ID.
      * This helper is used by mapResultSetToFullUserWithSkills.
      */
     private ArrayList<Skill> convertSkillIdStringToSkills(String skillIdsString) throws SQLException {
         ArrayList<Skill> skills = new ArrayList<>();
         if (skillIdsString == null || skillIdsString.trim().isEmpty()) {
             return skills;
         }
         String[] idsArray = skillIdsString.split(",");
         for (String idStr : idsArray) {
             if (idStr == null || idStr.trim().isEmpty()) continue;
             try {
                 int skillId = Integer.parseInt(idStr.trim());
                 // Use the SkillDAO instance initialized in AdminDAO's constructor
                 Skill skill = this.skillDAO.getSkillById(skillId); // Assumes SkillDAO.getSkillById exists and returns Skill or null
                 if (skill != null) {
                     skills.add(skill);
                 } else {
                     System.err.println("AdminDAO.convertSkillIdStringToSkills: Skill not found for ID: " + skillId + " while parsing user skills string '" + skillIdsString + "'.");
                 }
             } catch (NumberFormatException e) {
                 System.err.println("AdminDAO.convertSkillIdStringToSkills: Invalid skill ID format '" + idStr + "' in skills string: '" + skillIdsString + "'. " + e.getMessage());
             }
         }
         return skills;
     }


    /**
     * Helper method to map swap and joined skill columns from a ResultSet to a Swap object
     * specifically for admin viewing (includes joined skill details from the join).
     * Assumes the query selects columns aliased like: se.id, se.requesterUsername, ..., s.id AS generic_skill_id, s.name AS skill_name, etc.
     */
    private Swap mapResultSetToSwapForAdminView(ResultSet rs) throws SQLException {
        Swap swap = new Swap();
        // Map Swap columns from the 'swap' table data (se.*)
        swap.setSwapId(rs.getInt("id")); // 'id' from swap is the swap ID
        swap.setRequesterUsername(rs.getString("requesterUsername"));
        swap.setProviderUsername(rs.getString("providerUsername"));
        swap.setOfferedSkillId(rs.getInt("offeredSkillId")); // ID of the skill involved in the swap
        swap.setPointsExchanged(rs.getInt("pointsExchanged"));
        swap.setStatus(SwapStatus.valueOf(rs.getString("status").toUpperCase())); // Convert status string to enum
        swap.setRequestDate(rs.getTimestamp("requestDate"));
        // Based on your schema, this column exists and should be mapped
        swap.setLastUpdatedDate(rs.getTimestamp("lastUpdatedDate"));


        // Map joined Skill columns (s.*) and set the Skill object in the Swap
        // This relies on the query joining with the 'skills' table.
        Skill skill = new Skill();
        // Assuming the query aliases the skill columns correctly (e.g., s.id AS generic_skill_id)
        skill.setId(rs.getInt("generic_skill_id")); // ID from the 'skills' table
        skill.setName(rs.getString("skill_name"));
        skill.setCategory(rs.getString("skill_category"));
        skill.setDescription(rs.getString("skill_description"));
        swap.setSkillOffered(skill); // Set the populated Skill object in the Swap model

        return swap;
    }


    // --- Helper Methods for Closing Resources ---
    // Standard practice to clean up JDBC resources

    private void closeStatement(Statement stmt) {
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                System.err.println("AdminDAO: Error closing statement: " + e.getMessage());
            }
        }
    }

    private void closeResultSet(ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                System.err.println("AdminDAO: Error closing result set: " + e.getMessage());
            }
        }
    }
}