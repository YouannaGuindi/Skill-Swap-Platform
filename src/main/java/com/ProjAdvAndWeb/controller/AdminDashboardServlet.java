package com.ProjAdvAndWeb.controller;

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
import com.ProjAdvAndWeb.model.Admin;
import com.ProjAdvAndWeb.model.Swap;
import com.ProjAdvAndWeb.model.SwapStatus;
import com.ProjAdvAndWeb.model.User;


// Admin Dashboard Servlet - ONLY for Overview Stats and recent lists (read-only)
@WebServlet("/AdminDashboardServlet")
public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AdminDAO adminDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        try {
             adminDAO = new AdminDAO();
        } catch (Exception e) {
            System.err.println("AdminDashboardServlet: Failed to initialize AdminDAO: " + e.getMessage());
            throw new ServletException("Failed to initialize AdminDAO", e);
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

        // Set common attributes for the sidebar and page header
        request.setAttribute("loggedInAdmin", loggedInAdmin);
        request.setAttribute("isUserLoggedIn", true); // Generic for sidebar
        request.setAttribute("isAdminLoggedIn", true); // Specific
        request.setAttribute("currentUsername", loggedInAdmin.getFirstName()); // For sidebar display
        request.setAttribute("profilePicUrl", ""); // Admins usually don't have one by default
        request.setAttribute("currentServletPath", request.getServletPath()); // For active sidebar link
        request.setAttribute("appContextPath", request.getContextPath());
        request.setAttribute("currentYear", new SimpleDateFormat("yyyy").format(new Date()));

        // Load main dashboard overview data
        try {
            int totalUserCount = adminDAO.getUserCount();
            request.setAttribute("totalUserCount", totalUserCount);

            // Fetching all users for the overview table (read-only list)
            List<User> allUsers = adminDAO.getAllUsersBasicInfo(); // This method includes skills
            request.setAttribute("allUsers", allUsers != null ? allUsers : new ArrayList<>());

            // Calculate date range for recent swaps (e.g., last 7 days)
            Calendar cal = Calendar.getInstance();
            Date endDate = cal.getTime();
            request.setAttribute("statsEndDate", new SimpleDateFormat("MMM dd, yyyy").format(endDate));

            cal.add(Calendar.DAY_OF_MONTH, -7);
            Date startDate = cal.getTime();
            request.setAttribute("statsStartDate", new SimpleDateFormat("MMM dd, yyyy").format(startDate));

            // Fetch swap counts for the stat cards
            int totalSwapsLast7Days = adminDAO.getSwapCountByDateRange(startDate, endDate);
            request.setAttribute("totalSwapsLast7Days", totalSwapsLast7Days);
            int pendingSwapsCount = adminDAO.getSwapCountByDateRangeAndStatus(SwapStatus.PROPOSED, startDate, endDate);
            request.setAttribute("pendingSwapsCount", pendingSwapsCount);
            int acceptedSwapsCount = adminDAO.getSwapCountByDateRangeAndStatus(SwapStatus.ACCEPTED, startDate, endDate);
            request.setAttribute("acceptedSwapsCount", acceptedSwapsCount);
            // int cancelledSwapsCount = adminDAO.getSwapCountByDateRangeAndStatus(SwapStatus.CANCELLED, startDate, endDate);
            // request.setAttribute("cancelledSwapsCount", cancelledSwapsCount);

            // Fetch recent swaps list for the overview table (read-only list)
            List<Swap> recentSwaps = adminDAO.getSwapsByDateRange(startDate, endDate);
            request.setAttribute("recentSwaps", recentSwaps != null ? recentSwaps : new ArrayList<>());

        } catch (SQLException e) {
            System.err.println("AdminDashboardServlet SQL ERROR (loading dashboard data): " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("dashboardError", "Error loading admin dashboard data: " + e.getMessage());
            setDefaultDashboardAttributesOnError(request);
        } catch (Exception e) {
             System.err.println("AdminDashboardServlet General ERROR (loading dashboard data): " + e.getMessage());
             e.printStackTrace();
             request.setAttribute("dashboardError", "An unexpected error occurred while loading dashboard data: " + e.getMessage());
             setDefaultDashboardAttributesOnError(request);
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("/adminDashboard.jsp");
        dispatcher.forward(request, response);
    }

    private void setDefaultDashboardAttributesOnError(HttpServletRequest request) {
        if (request.getAttribute("totalUserCount") == null) request.setAttribute("totalUserCount", 0);
        if (request.getAttribute("allUsers") == null) request.setAttribute("allUsers", new ArrayList<>());
        if (request.getAttribute("totalSwapsLast7Days") == null) request.setAttribute("totalSwapsLast7Days", 0);
        if (request.getAttribute("pendingSwapsCount") == null) request.setAttribute("pendingSwapsCount", 0);
        if (request.getAttribute("acceptedSwapsCount") == null) request.setAttribute("acceptedSwapsCount", 0);
        if (request.getAttribute("completedSwapsCount") == null) request.setAttribute("completedSwapsCount", 0);
        if (request.getAttribute("recentSwaps") == null) request.setAttribute("recentSwaps", new ArrayList<>());
        if (request.getAttribute("statsStartDate") == null) request.setAttribute("statsStartDate", "N/A");
        if (request.getAttribute("statsEndDate") == null) request.setAttribute("statsEndDate", "N/A");
    }

    // No POST method needed for a read-only dashboard
}