package com.ProjAdvAndWeb.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.ProjAdvAndWeb.dao.AdminDAO;
import com.ProjAdvAndWeb.dao.UserDAO;
import com.ProjAdvAndWeb.model.Admin;
import com.ProjAdvAndWeb.model.Swap;
import com.ProjAdvAndWeb.model.SwapStatus;
import com.ProjAdvAndWeb.model.User;



// Admin User Management Servlet - Handles both List and Details views
@WebServlet("/AdminUserManagementServlet")
public class AdminUserManagementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;
    private AdminDAO adminDAO; // For session check and potentially listing

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            userDAO = new UserDAO();
            adminDAO = new AdminDAO();
        } catch (Exception e) {
             System.err.println("AdminUserManagementServlet: Failed to initialize DAOs: " + e.getMessage());
             e.printStackTrace();
             throw new ServletException("Failed to initialize DAOs", e);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Admin loggedInAdmin = (session != null) ? (Admin) session.getAttribute("loggedInAdmin") : null;

        if (loggedInAdmin == null) {
            response.sendRedirect(request.getContextPath() + "/loginservlet?accountType=admin&message=admin_session_expired");
            return;
        }

        // Set common attributes for the sidebar etc.
        request.setAttribute("loggedInAdmin", loggedInAdmin);
        request.setAttribute("isUserLoggedIn", true); // Generic for sidebar consistency (assuming admin is a type of 'user')
        request.setAttribute("isAdminLoggedIn", true); // Specific admin flag
        request.setAttribute("currentUsername", loggedInAdmin.getFirstName()); // For sidebar display
        request.setAttribute("profilePicUrl", ""); // Admins usually don't have one by default
        request.setAttribute("currentServletPath", request.getServletPath()); // For active sidebar link
        request.setAttribute("appContextPath", request.getContextPath());
        // Consider adding current year attribute if your footer uses it


        String action = request.getParameter("action");
        String targetJsp ="/WEB-INF/jsp/adminuserList.jsp"; // Declare here

        try {
            if ("viewDetails".equals(action)) {
                // Handle viewing a single user's details
                 String username = request.getParameter("username");
                 if (username != null && !username.trim().isEmpty()) {
                     // Fetch the user using UserDAO
                     User user = userDAO.getUserByUsername(username); // Make sure this method exists and works!
                      if (user != null) {
                         request.setAttribute("user", user); // Set the single user attribute
                         targetJsp = "/WEB-INF/jsp/adminViewUserDetails.jsp"; // Go to the details page
                      } else {
                          request.setAttribute("errorMessage", "User not found with username: " + username);
                          // If user not found, forward to the details page anyway to show the error
                           targetJsp = "/WEB-INF/jsp/adminViewUserDetails.jsp";
                      }
                 } else {
                      request.setAttribute("errorMessage", "Username parameter missing for viewDetails action.");
                       // If username parameter is missing, forward to the details page anyway to show the error
                      targetJsp = "/WEB-INF/jsp/adminViewUserDetails.jsp";
                 }
            } else {
                // Default action: View list of users
                // Fetch ALL users for the list view
                List<User> allUsers = adminDAO.getAllUsersBasicInfo(); // Assuming this method exists and works!
                request.setAttribute("allUsers", allUsers != null ? allUsers : new ArrayList<>()); // Set the list attribute
                // --- FIX: Corrected target JSP for the list view ---
                targetJsp = "/WEB-INF/jsp/adminuserList.jsp"; // Go to the LIST page by default
            }

        } catch (SQLException e) { // Catch SQLException for database errors
            System.err.println("AdminUserManagementServlet SQL ERROR: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "A database error occurred: " + e.getMessage());
            // On SQL error, always go to the list page and show the error
            // Attempt to load the list again in case the error was specific to fetching one user
             List<User> allUsersOnError = new ArrayList<>();
             try {
                  // Re-fetch all users for the list view on error, just in case the error was specific
                  // to the details fetch or parameter handling, but let's keep the default view showing something.
                  // If getAllUsersBasicInfo also fails, the list will be empty as initialized.
                  allUsersOnError = adminDAO.getAllUsersBasicInfo();
             } catch (SQLException e2) {
                 // Ignore secondary error during list load, just show empty list and the primary error.
             }
             request.setAttribute("allUsers", allUsersOnError);
             // --- FIX: Corrected target JSP for error goes to the LIST page ---
             targetJsp = "/WEB-INF/jsp/adminuserList.jsp";
        }
        catch (Exception e) { // Catch broader Exception for other potential issues
            System.err.println("AdminUserManagementServlet General ERROR: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "An unexpected error occurred: " + e.getMessage());
             request.setAttribute("allUsers", new ArrayList<>()); // Ensure list is not null on error
             // --- FIX: Corrected target JSP for error goes to the LIST page ---
             targetJsp = "/WEB-INF/jsp/adminuserList.jsp";
        }

        // Forward to the determined target JSP
        RequestDispatcher dispatcher = request.getRequestDispatcher(targetJsp);
        dispatcher.forward(request, response);
    }

    // No POST method needed for read-only user management
}