package com.ProjAdvAndWeb.dao;

import com.ProjAdvAndWeb.model.Skill;
import com.ProjAdvAndWeb.model.Swap;
import com.ProjAdvAndWeb.model.SwapStatus;
import com.ProjAdvAndWeb.model.User;
import com.ProjAdvAndWeb.util.DBConnectionUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SwapDAO {

    // --- POINT LOGIC: Saving the points defined by the requester ---
    public boolean createSwapRequest(Swap exchange) throws SQLException {
        String sql = "INSERT INTO swap (requesterUsername, providerUsername, offeredSkillId, pointsExchanged, status, requestDate, lastUpdatedDate) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)"; // <-- pointsExchanged column in SQL
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            con = DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("Failed to get DB connection for createSwapRequest.");
            pstmt = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

            pstmt.setString(1, exchange.getRequesterUsername());
            pstmt.setString(2, exchange.getProviderUsername());
            pstmt.setInt(3, exchange.getOfferedSkillId());
            pstmt.setInt(4, exchange.getPointsExchanged()); // <-- Get the points value from the Swap object and set it in the SQL INSERT
            pstmt.setString(5, exchange.getStatus() != null ? exchange.getStatus().name() : SwapStatus.PROPOSED.name());
            pstmt.setTimestamp(6, exchange.getRequestDate() != null ? exchange.getRequestDate() : new Timestamp(System.currentTimeMillis()));
            pstmt.setTimestamp(7, exchange.getLastUpdatedDate() != null ? exchange.getLastUpdatedDate() : new Timestamp(System.currentTimeMillis()));

            int affectedRows = pstmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        exchange.setSwapId(generatedKeys.getInt(1));
                    }
                }
                success = true;
            }
        } finally {
            closeStatement(pstmt);
            DBConnectionUtil.closeConnection(con);
        }
        return success;
    }
    // --- END POINT LOGIC (Saving) ---

    public Swap getSwapById(int exchangeId) throws SQLException {
        // --- POINT LOGIC: Selecting pointsExchanged from the database ---
        // CORRECTED SQL: se.* instead of se.
        String sql = "SELECT se.*, " +
                     "s.id as genericSkillId, s.name as skillName, s.category as skillCategory, s.description as skillDescription " +
                     "FROM swap se " +
                     "JOIN skill s ON se.offeredSkillId = s.id "
                     + "WHERE se.id = ?";
        // --- END POINT LOGIC (Selecting) ---
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Swap exchange = null;

        try {
            con = DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("Failed to get DB connection for getSwapById.");
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, exchangeId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                // Mapping method reads the pointsExchanged from the ResultSet
                exchange = mapResultSetToSwap(rs);
            }
        } finally {
            closeResultSet(rs);
            closeStatement(pstmt);
            DBConnectionUtil.closeConnection(con);
        }
        return exchange;
    }

    /**
     * Retrieves all swaps where the given username is either the requester or the provider.
     * (Implemented as identified as missing functionality)
     * @param username The username of the user.
     * @return A list of Swap objects related to the user.
     * @throws SQLException
     */
    public List<Swap> getSwapsByUsername(String username) throws SQLException {
         // --- POINT LOGIC: Selecting pointsExchanged is included via se.* ---
        List<Swap> exchanges = new ArrayList<>();
        // CORRECTED SQL: se.* instead of se.
        String sql = "SELECT se.*, "
                + "s.id AS genericSkillId, s.name AS skillName, s.category AS skillCategory, s.description AS skillDescription "
                + "FROM swap se "
                + "JOIN skill s ON se.offeredSkillId = s.id "
                + "WHERE (se.requesterUsername = ? OR se.providerUsername = ?) "
                + "ORDER BY se.lastUpdatedDate DESC, se.requestDate DESC";
         // --- END POINT LOGIC (Selecting) ---
        Connection con=null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            con = DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("Failed to get DB connection for getSwapsByUsername.");
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, username);
            rs = pstmt.executeQuery(); // This is line 111 where the original error occurred
            while (rs.next()) {
                 // Mapping method reads the pointsExchanged from the ResultSet for each row
                exchanges.add(mapResultSetToSwap(rs));
            }
        } finally {
            closeResultSet(rs);
            closeStatement(pstmt);
            DBConnectionUtil.closeConnection(con);
        }
        return exchanges;
    }

    // --- POINT LOGIC: Handling point transfer on ACCEPTED status update ---
    public boolean updateSwapStatusAndPoints(int exchangeId, SwapStatus newStatus, UserDAO userDAO) throws SQLException {
        // SQL to get details, including pointsExchanged
        String selectSql = "SELECT id, requesterUsername, providerUsername, pointsExchanged, status FROM swap WHERE id = ?"; // <-- Selecting pointsExchanged
        String updateStatusSql = "UPDATE swap SET status = ?, lastUpdatedDate = ? WHERE id = ?";

        Connection con = null;
        PreparedStatement selectPstmt = null;
        PreparedStatement updateStatusPstmt = null;
        ResultSet rs = null;
        boolean overallSuccess = false;

        try {
            con = DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("Failed to get DB connection for updateSwapStatusAndPoints.");
            con.setAutoCommit(false); // Start transaction

            // 1. Get current swap details
            selectPstmt = con.prepareStatement(selectSql);
            selectPstmt.setInt(1, exchangeId);
            rs = selectPstmt.executeQuery();

            if (!rs.next()) {
                System.err.println("SwapDAO: Exchange not found with ID: " + exchangeId);
                con.rollback();
                return false;
            }
            String requesterUsernameFromDB = rs.getString("requesterUsername");
            String providerUsernameFromDB = rs.getString("providerUsername");
            int pointsExchanged = rs.getInt("pointsExchanged"); // <-- Reading the SAVED points value from the DB
            SwapStatus currentStatus = SwapStatus.valueOf(rs.getString("status").toUpperCase());

            // 2. Validate status transition
            // TODO: Add your status validation logic here if needed
            // Example:
            // if (!isValidTransition(currentStatus, newStatus)) {
            //    con.rollback();
            //    System.err.println("SwapDAO: Invalid status transition from " + currentStatus + " to " + newStatus);
            //    return false;
            // }


            // 3. Update swap status
            updateStatusPstmt = con.prepareStatement(updateStatusSql);
            updateStatusPstmt.setString(1, newStatus.name());
            updateStatusPstmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            updateStatusPstmt.setInt(3, exchangeId);

            int statusUpdatedRows = updateStatusPstmt.executeUpdate();
            if (statusUpdatedRows == 0) {
                con.rollback();
                System.err.println("SwapDAO: Failed to update status for exchange ID: " + exchangeId);
                return false;
            }

            // 4. Handle point transfer: ONLY when status changes TO ACCEPTED
            if (newStatus == SwapStatus.ACCEPTED && currentStatus != SwapStatus.ACCEPTED) {
                User requester = userDAO.getUserByUsername(requesterUsernameFromDB); // Get requester user
                User provider = userDAO.getUserByUsername(providerUsernameFromDB); // Get provider user

                if (requester == null || provider == null) {
                    con.rollback();
                    throw new SQLException("Requester ('" + requesterUsernameFromDB + "') or Provider ('" + providerUsernameFromDB + "') user not found for point transfer. Exchange ID: " + exchangeId);
                }

                 // --- CHECK: Ensure requester has enough points (using the saved points value) ---
                 if (requester.getPoints() < pointsExchanged) { // <-- Use the points value read from the DB
                    con.rollback();
                    System.err.println("SwapDAO: Requester (" + requesterUsernameFromDB + ") has insufficient points (" + requester.getPoints() + ") to pay " + pointsExchanged + ". Rolling back. Exchange ID: " + exchangeId);
                    return false; // Indicate failure
                }
                 // --- END CHECK ---

                // --- TRANSFER POINTS (using the saved points value) ---
                // Use the userDAO to update points within the same transaction 'con'
                boolean requesterPointUpdateSuccess = userDAO.updateUserPointsTransactional(requester.getUsername(), requester.getPoints() - pointsExchanged, con); // Deduct points
                boolean providerPointUpdateSuccess = userDAO.updateUserPointsTransactional(provider.getUsername(), provider.getPoints() + pointsExchanged, con); // Add points

                if (!requesterPointUpdateSuccess || !providerPointUpdateSuccess) {
                    con.rollback();
                    throw new SQLException("Failed to update user points during exchange acceptance. Rolling back. Exchange ID: " + exchangeId);
                }
                 System.out.println("SwapDAO: Points transferred for Swap ID " + exchangeId + ": " + pointsExchanged + " deducted from " + requester.getUsername() + ", added to " + provider.getUsername()); // Log the amount transferred
                // --- END TRANSFER ---
            }

            // 5. Commit the transaction if all steps succeeded
            con.commit();
            overallSuccess = true;

        } catch (SQLException e) {
            if (con != null) { try { con.rollback(); } catch (SQLException ex) { System.err.println("SwapDAO: Error during rollback: " + ex.getMessage()); } }
            throw e;
        } finally {
            if (con != null) { try { con.setAutoCommit(true); } catch (SQLException ex) { System.err.println("SwapDAO: Error setting auto-commit back to true: " + ex.getMessage()); } }
            closeResultSet(rs);
            closeStatement(selectPstmt);
            closeStatement(updateStatusPstmt);
            DBConnectionUtil.closeConnection(con);
        }
        return overallSuccess;
    }
    // --- END POINT LOGIC (Transfer) ---


    // --- POINT LOGIC: Mapping the pointsExchanged from the ResultSet to the Swap object ---
    private Swap mapResultSetToSwap(ResultSet rs) throws SQLException {
        Swap exchange = new Swap();
        exchange.setSwapId(rs.getInt("id")); // Assuming 'id' is the primary key column for 'swap' table
        exchange.setRequesterUsername(rs.getString("requesterUsername"));
        exchange.setProviderUsername(rs.getString("providerUsername"));
        exchange.setOfferedSkillId(rs.getInt("offeredSkillId"));
        exchange.setPointsExchanged(rs.getInt("pointsExchanged")); // <-- Read the points value from the ResultSet and set it on the Swap object
        exchange.setStatus(SwapStatus.valueOf(rs.getString("status").toUpperCase()));
        exchange.setRequestDate(rs.getTimestamp("requestDate"));
        exchange.setLastUpdatedDate(rs.getTimestamp("lastUpdatedDate"));

        Skill skill = new Skill();
        skill.setId(rs.getInt("genericSkillId")); // Alias from your JOIN
        skill.setName(rs.getString("skillName")); // Alias from your JOIN
        skill.setCategory(rs.getString("skillCategory")); // Alias from your JOIN
        skill.setDescription(rs.getString("skillDescription")); // Alias from your JOIN
        exchange.setSkillOffered(skill); // Set the full Skill object on the Swap

        return exchange;
    }
     // --- END POINT LOGIC (Mapping) ---


    // Helper closing methods...
    private void closeStatement(Statement stmt) {
        if (stmt != null) try { stmt.close(); } catch (SQLException e) { System.err.println("SwapDAO: Error closing statement: " + e.getMessage()); }
    }
    private void closeResultSet(ResultSet rs) {
        if (rs != null) try { rs.close(); } catch (SQLException e) { System.err.println("SwapDAO: Error closing result set: " + e.getMessage()); }
    }

     // Keep other SkillDAO methods (addSkill, getSkillByName, etc.) as they were in your original SkillDAO
     // ... (Assuming they are in a separate SkillDAO.java file as per your initial structure) ...
}