package com.ProjAdvAndWeb.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.ProjAdvAndWeb.dao.SkillDAO;
import com.ProjAdvAndWeb.dao.UserDAO;
import com.ProjAdvAndWeb.dao.SwapDAO;
import com.ProjAdvAndWeb.model.Skill;
import com.ProjAdvAndWeb.model.User;
import com.ProjAdvAndWeb.model.Swap;
import com.ProjAdvAndWeb.model.SwapStatus;

@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(DashboardServlet.class.getName());

    private UserDAO userDAO;
    private SkillDAO skillDAO;
    private SwapDAO swapDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        // Initialize DAOs. Consider handling potential exceptions during DAO instantiation
        // more gracefully if they can throw checked exceptions here (e.g., related to db connection pool)
        userDAO = new UserDAO();
        skillDAO = new SkillDAO();
        swapDAO = new SwapDAO();
        LOGGER.info("DashboardServlet initialized.");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=session_expired_dashboard_access");
            return;
        }
        // Make user available for JSPs, especially for actualDashboard.jsp stats
        request.setAttribute("dashboardUser", loggedInUser);
        String action = request.getParameter("action");
        LOGGER.info("DashboardServlet doGet - Received action: " + action); // ADD THIS LINE
        System.out.println("DashboardServlet doGet - Received action: " + action); // ADD THIS LINE for console output

 
        if ("showAddSkillPage".equals(action)) {
            try {
            	LOGGER.info("DashboardServlet doGet - Matched action: showAddSkillPage"); // ADD THIS LINE
                System.out.println("DashboardServlet doGet - Matched action: showAddSkillPage"); // ADD THIS LINE
            
                List<Skill> allGenericSkills = skillDAO.getAllSkills(null); // Fetch all available skills
                request.setAttribute("allGenericSkills", allGenericSkills);
                // User's current skills are in loggedInUser.getSkills(), which addSkill.jsp can access via sessionScope.loggedInUser.skills
                RequestDispatcher dispatcher = request.getRequestDispatcher("/jsp/addSkill.jsp");
                dispatcher.forward(request, response);
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error fetching data for addSkill page", e);
                session.setAttribute("dashboardErrorMessage", "Error loading skills management page: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/DashboardServlet"); // Redirect to main dashboard on error
            }
            return; // Important: stop further processing for this action
        }else {
            LOGGER.info("DashboardServlet doGet - Action did NOT match showAddSkillPage. Proceeding to default dashboard."); // ADD THIS LINE
            System.out.println("DashboardServlet doGet - Action did NOT match showAddSkillPage. Proceeding to default dashboard."); // ADD THIS LINE
        }

        // Default action: display main dashboard
        try {
            // 1. Skills Offered Count
            // Assuming loggedInUser.getSkills() returns a non-null list (possibly empty)
            int skillsOfferedCount = (loggedInUser.getSkills() != null) ? loggedInUser.getSkills().size() : 0;
            request.setAttribute("skillsOfferedCount", skillsOfferedCount);

            // 2. Active Swaps & Pending Requests Count
            List<Swap> allUserSwaps = swapDAO.getSwapsByUsername(loggedInUser.getUsername());
            int activeSwapsCount = 0;
            int pendingRequestsCount = 0;

            if (allUserSwaps != null) {
                activeSwapsCount = (int) allUserSwaps.stream()
                    .filter(swap -> swap.getStatus() == SwapStatus.ACCEPTED || swap.getStatus() == SwapStatus.IN_PROGRESS)
                    .count();
                // Pending requests are those PROPOSED where the loggedInUser is the PROVIDER
                pendingRequestsCount = (int) allUserSwaps.stream()
                    .filter(swap -> swap.getStatus() == SwapStatus.PROPOSED &&
                                   swap.getProviderUsername().equals(loggedInUser.getUsername()))
                    .count();
            }
            request.setAttribute("activeSwapsCount", activeSwapsCount);
            request.setAttribute("pendingRequestsCount", pendingRequestsCount);
            // User points are directly available from loggedInUser.getPoints() via ${dashboardUser.points} in JSP

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error loading dashboard statistics", e);
            request.setAttribute("dashboardError", "Error loading dashboard statistics: " + e.getMessage());
        }
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/actualDashboard.jsp"); // Forward to the main dashboard JSP
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (loggedInUser == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Session expired or not logged in.");
            return;
        }

        String action = request.getParameter("action");
        String redirectURL = request.getContextPath() + "/DashboardServlet"; // Default redirect to main dashboard

        try {
            if ("addOfferedSkill".equals(action)) {
                redirectURL = request.getContextPath() + "/DashboardServlet?action=showAddSkillPage"; // Redirect back to skill management page
                String skillIdStr = request.getParameter("genericSkillId");
                if (skillIdStr != null && !skillIdStr.isEmpty()) {
                    int skillId = Integer.parseInt(skillIdStr);
                    
                    // Ensure loggedInUser.getSkills() is not null before streaming, or handle it
                    List<Skill> currentSkills = loggedInUser.getSkills();
                    boolean alreadyOffered = (currentSkills != null) && currentSkills.stream().anyMatch(s -> s.getId() == skillId);
                    
                    if (!alreadyOffered) {
                        // Ensure userDAO.addSkillToUserList is implemented and handles DB updates
                        boolean success = userDAO.addSkillToUserList(loggedInUser.getUsername(), skillId, skillDAO);
                        if (success) {
                            User updatedUser = userDAO.getUserByUsername(loggedInUser.getUsername()); // Refresh user from DB
                            session.setAttribute("loggedInUser", updatedUser); // Update session
                            session.setAttribute("dashboardSuccessMessage", "Skill added to your offerings successfully!");
                        } else {
                            session.setAttribute("dashboardErrorMessage", "Failed to add skill to your offerings. Database update may have failed.");
                        }
                    } else {
                         session.setAttribute("dashboardWarningMessage", "You already offer this skill.");
                    }
                } else {
                    session.setAttribute("dashboardErrorMessage", "No skill selected to add.");
                }
            } else if ("removeOfferedSkill".equals(action)) {
                redirectURL = request.getContextPath() + "/DashboardServlet?action=showAddSkillPage"; // Redirect back to skill management page
                String skillIdStr = request.getParameter("genericSkillId");
                if (skillIdStr != null && !skillIdStr.isEmpty()) {
                    int skillId = Integer.parseInt(skillIdStr);
                    // Ensure userDAO.removeSkillFromUserList is implemented and handles DB updates
                    boolean success = userDAO.removeSkillFromUserList(loggedInUser.getUsername(), skillId);
                    if (success) {
                        User updatedUser = userDAO.getUserByUsername(loggedInUser.getUsername()); // Refresh user from DB
                        session.setAttribute("loggedInUser", updatedUser); // Update session
                        session.setAttribute("dashboardSuccessMessage", "Skill removed from your offerings successfully!");
                    } else {
                        session.setAttribute("dashboardErrorMessage", "Failed to remove skill from your offerings. Database update may have failed.");
                    }
                } else {
                    session.setAttribute("dashboardErrorMessage", "No skill selected for removal.");
                }
            } else if ("updateProfile".equals(action)) {
                // Placeholder for profile update logic
                session.setAttribute("dashboardWarningMessage", "Profile update functionality is not yet fully implemented.");
                // redirectURL = request.getContextPath() + "/jsp/profile.jsp"; // Or wherever profile page is
            } else {
                session.setAttribute("dashboardErrorMessage", "Unknown action: " + action);
            }if ("showAddSkillPage".equals(action)) {
                LOGGER.info("Redirecting showAddSkillPage to ProfileServlet#manage-skills");
                response.sendRedirect(request.getContextPath() + "/ProfileServlet#manage-skills");
                return;
            }
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid number format in POST action " + action + " for skillId: " + request.getParameter("genericSkillId"), e);
            session.setAttribute("dashboardErrorMessage", "Invalid ID format provided for skill.");
            if ("addOfferedSkill".equals(action) || "removeOfferedSkill".equals(action)) {
                 redirectURL = request.getContextPath() + "/DashboardServlet?action=showAddSkillPage";
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error during POST action " + action, e);
            session.setAttribute("dashboardErrorMessage", "A database error occurred while processing your request: " + e.getMessage());
             if ("addOfferedSkill".equals(action) || "removeOfferedSkill".equals(action)) {
                 redirectURL = request.getContextPath() + "/DashboardServlet?action=showAddSkillPage";
            }
        }
        response.sendRedirect(redirectURL); // Post-Redirect-Get pattern
    }
}