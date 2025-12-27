package com.ProjAdvAndWeb.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.ProjAdvAndWeb.model.Skill;
import com.ProjAdvAndWeb.util.DBConnectionUtil;

public class SkillDAO {
    private static final Logger LOGGER = Logger.getLogger(SkillDAO.class.getName());
    private static final String TABLE_NAME = "skill"; // Your skill definition table

    // Maps a ResultSet row to a Skill object
    // IMPORTANT: Assumes your 'skill' table has 'id', 'name', 'category', 'description' columns.
    private Skill mapResultSetToSkill(ResultSet rs) throws SQLException {
        Skill skill = new Skill();
        skill.setId(rs.getInt("id"));
        try {
            skill.setName(rs.getString("name")); // <<<< CRITICAL: Ensure 'name' column exists
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Column 'name' might be missing in 'skill' table or data issue for skill id: " + rs.getInt("id"), e);
            skill.setName("Name N/A"); // Fallback if 'name' column is missing or error
        }
        skill.setCategory(rs.getString("category"));
        skill.setDescription(rs.getString("description"));
        return skill;
    }

    public boolean addSkill(Skill skill) throws SQLException {
        // IMPORTANT: Assumes 'skill' table has 'name', 'category', 'description'
        String sql = "INSERT INTO " + TABLE_NAME + " (name, category, description) VALUES (?, ?, ?)";
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean success = false;
        try {
            con = DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("Failed to get DB connection for addSkill.");
            pstmt = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, skill.getName());
            pstmt.setString(2, skill.getCategory());
            pstmt.setString(3, skill.getDescription());
            int affectedRows = pstmt.executeUpdate();
            if (affectedRows > 0) {
                success = true;
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        skill.setId(generatedKeys.getInt(1));
                    }
                }
            }
        } finally {
            closeStatement(pstmt);
            DBConnectionUtil.closeConnection(con);
        }
        return success;
    }

    public Skill getSkillById(int skillId) throws SQLException {
        String sql = "SELECT id, name, category, description FROM " + TABLE_NAME + " WHERE id = ?";
        Connection con = null; PreparedStatement pstmt = null; ResultSet rs = null; Skill skill = null;
        try {
            con = DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("DB connection failed in getSkillById");
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, skillId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                skill = mapResultSetToSkill(rs);
            } else {
                LOGGER.warning("No skill found with ID: " + skillId);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching skill by ID: " + skillId, e);
            throw e; // Re-throw to allow higher layers to handle
        } finally {
            closeResultSet(rs); closeStatement(pstmt); DBConnectionUtil.closeConnection(con);
        }
        return skill;
    }

    public Skill getSkillByName(String name) throws SQLException {
        String sql = "SELECT id, name, category, description FROM " + TABLE_NAME + " WHERE name = ?";
        Connection con = null; PreparedStatement pstmt = null; ResultSet rs = null; Skill skill = null;
        try {
            con = DBConnectionUtil.getConnection(); if (con == null) throw new SQLException("DB connection failed in getSkillByName");
            pstmt = con.prepareStatement(sql); pstmt.setString(1, name); rs = pstmt.executeQuery();
            if (rs.next()) { skill = mapResultSetToSkill(rs); }
        } finally { closeResultSet(rs); closeStatement(pstmt); DBConnectionUtil.closeConnection(con); }
        return skill;
    }

    public List<Skill> getAllSkills(String categoryFilter) throws SQLException {
        List<Skill> skills = new ArrayList<>();
        String sql = "SELECT id, name, category, description FROM " + TABLE_NAME;
        if (categoryFilter != null && !categoryFilter.trim().isEmpty() && !"all".equalsIgnoreCase(categoryFilter)) {
            sql += " WHERE category = ?";
        }
        sql += " ORDER BY category ASC, name ASC";

        Connection con = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            con = DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("Failed to get DB connection for getAllSkills.");
            pstmt = con.prepareStatement(sql);
            if (categoryFilter != null && !categoryFilter.trim().isEmpty() && !"all".equalsIgnoreCase(categoryFilter)) {
                pstmt.setString(1, categoryFilter);
            }
            rs = pstmt.executeQuery();
            while (rs.next()) {
                skills.add(mapResultSetToSkill(rs));
            }
        } finally {
            closeResultSet(rs); closeStatement(pstmt); DBConnectionUtil.closeConnection(con);
        }
        return skills;
    }

    public List<Skill> searchSkillsInDefinitionTable(String searchTerm, String categoryFilter) throws SQLException {
        List<Skill> skills = new ArrayList<>();
        String sql = "SELECT id, name, category, description FROM " + TABLE_NAME + " WHERE LOWER(name) LIKE LOWER(?)";
        if (categoryFilter != null && !categoryFilter.trim().isEmpty() && !"all".equalsIgnoreCase(categoryFilter)) {
            sql += " AND category = ?";
        }
        sql += " ORDER BY name ASC";
        Connection con = null; PreparedStatement pstmt = null; ResultSet rs = null;
        try {
            con = DBConnectionUtil.getConnection();
            if (con == null) throw new SQLException("DB connection failed in searchSkillsInDefinitionTable");
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, "%" + (searchTerm != null ? searchTerm : "") + "%");
            if (categoryFilter != null && !categoryFilter.trim().isEmpty() && !"all".equalsIgnoreCase(categoryFilter)) {
                pstmt.setString(2, categoryFilter);
            }
            rs = pstmt.executeQuery();
            while (rs.next()) {
                skills.add(mapResultSetToSkill(rs));
            }
        } finally { closeResultSet(rs); closeStatement(pstmt); DBConnectionUtil.closeConnection(con); }
        return skills;
    }

    public boolean updateSkill(Skill skill) throws SQLException {
        String sql = "UPDATE " + TABLE_NAME + " SET name = ?, category = ?, description = ? WHERE id = ?";
        Connection con = null; PreparedStatement pstmt = null; boolean success = false;
        try {
            con = DBConnectionUtil.getConnection(); if (con == null) throw new SQLException("DB connection failed in updateSkill");
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, skill.getName()); pstmt.setString(2, skill.getCategory());
            pstmt.setString(3, skill.getDescription()); pstmt.setInt(4, skill.getId());
            success = pstmt.executeUpdate() > 0;
        } finally { closeStatement(pstmt); DBConnectionUtil.closeConnection(con); }
        return success;
    }

    public boolean deleteSkill(int skillId) throws SQLException {
        String sql = "DELETE FROM " + TABLE_NAME + " WHERE id = ?";
        // Consider checking if skill is part of any active swaps before deleting
        Connection con = null; PreparedStatement pstmt = null; boolean success = false;
        try {
            con = DBConnectionUtil.getConnection(); if (con == null) throw new SQLException("DB connection failed in deleteSkill");
            pstmt = con.prepareStatement(sql); pstmt.setInt(1, skillId);
            success = pstmt.executeUpdate() > 0;
        } finally { closeStatement(pstmt); DBConnectionUtil.closeConnection(con); }
        return success;
    }

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
}