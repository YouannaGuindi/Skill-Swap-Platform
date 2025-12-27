package com.ProjAdvAndWeb.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.EnumSet;
import java.util.List;

import javax.security.auth.login.AccountException;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.ProjAdvAndWeb.dao.AdminDAO;
import com.ProjAdvAndWeb.dao.SwapDAO;
import com.ProjAdvAndWeb.model.Admin;
import com.ProjAdvAndWeb.model.Swap;
import com.ProjAdvAndWeb.model.SwapStatus;
import com.ProjAdvAndWeb.model.User;


// Admin Swap Management Servlet - ONLY for viewing swap list and details (read-only)
@WebServlet("/AdminSwapManagementServlet")
public class AdminSwapManagementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private SwapDAO swapDAO; // Needed for specific swap actions like viewDetails
    private AdminDAO adminDAO; // Needed for session check and potentially listing swaps

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            // Assumes you have a SwapDAO and AdminDAO that can be initialized
            swapDAO = new SwapDAO();
            adminDAO = new AdminDAO();
        } catch (Exception e) {
             System.err.println("AdminSwapManagementServlet: Failed to initialize DAOs: " + e.getMessage());
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
        request.setAttribute("isUserLoggedIn", true); // Generic for sidebar consistency
        request.setAttribute("isAdminLoggedIn", true); // Specific admin flag
        request.setAttribute("currentUsername", loggedInAdmin.getFirstName()); // For sidebar
        request.setAttribute("profilePicUrl", "");
        request.setAttribute("currentServletPath", request.getServletPath()); // For active sidebar link
        request.setAttribute("appContextPath", request.getContextPath());
        // Consider adding current year attribute if your footer uses it


        String action = request.getParameter("action");
        String targetJsp = "/WEB-INF/jsp/adminManageSwaps.jsp"; // Default target JSP

         try {
            if ("viewDetails".equals(action)) {
                // Handle viewing a single swap's details
                 String swapIdStr = request.getParameter("swapId");
                 if (swapIdStr != null && !swapIdStr.trim().isEmpty()) {
                     try {
                         int swapId = Integer.parseInt(swapIdStr);
                         Swap swap = swapDAO.getSwapById(swapId); // *** IMPORTANT: You need a getSwapById method in your SwapDAO ***
                          if (swap != null) {
                             request.setAttribute("swap", swap);
                             targetJsp = "/WEB-INF/jsp/adminManageSwaps.jsp"; // Change target JSP to details page
                          } else {
                              request.setAttribute("errorMessage", "Swap not found with ID: " + swapIdStr);
                              // Fall through to the swap list page, showing the error
                          }
                     } catch (NumberFormatException e) {
                          request.setAttribute("errorMessage", "Invalid swap ID format: " + swapIdStr);
                          // Fall through to the swap list page, showing the error
                     }
                 } else {
                      request.setAttribute("errorMessage", "Swap ID parameter missing for viewDetails action.");
                      // Fall through to the swap list page, showing the error
                 }
            }

            // If action was NOT "viewDetails" or if there was an error during viewDetails,
            // load the list of swaps for the default swapManagement.jsp view.
            // This block is intentionally outside the 'if("viewDetails")' and runs by default.
            if (!"viewDetails".equals(action) || request.getAttribute("errorMessage") != null) {

                 // --- Handle Filtering ---
                 String startDateParam = request.getParameter("startDateFilter");
                 String endDateParam = request.getParameter("endDateFilter");
                 String statusFilter = request.getParameter("statusFilter"); // Will be "ALL" or a status name

                 Date startDate = null;
                 Date endDate = null;
                 SwapStatus selectedStatus = null;
                 List<Swap> swapsList = new ArrayList<>();

                 SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                 dateFormat.setLenient(false); // Be strict about date format

                 try {
                     // Parse Start Date
                     if (startDateParam != null && !startDateParam.trim().isEmpty()) {
                         startDate = dateFormat.parse(startDateParam);
                         request.setAttribute("filterStartDate", startDateParam); // Keep param value for form input
                     }

                     // Parse End Date - Use end of day for inclusivity
                     if (endDateParam != null && !endDateParam.trim().isEmpty()) {
                          // Parse the date string
                          Date parsedEndDate = dateFormat.parse(endDateParam);
                          // Set time to 23:59:59.999 for end-of-day inclusivity
                          Calendar cal = Calendar.getInstance();
                          cal.setTime(parsedEndDate);
                          cal.set(Calendar.HOUR_OF_DAY, 23);
                          cal.set(Calendar.MINUTE, 59);
                          cal.set(Calendar.SECOND, 59);
                          cal.set(Calendar.MILLISECOND, 999);
                          endDate = cal.getTime();

                          request.setAttribute("filterEndDate", endDateParam); // Keep param value for form input
                     }


                     // Parse Status Filter
                     if (statusFilter != null && !statusFilter.trim().isEmpty() && !"ALL".equalsIgnoreCase(statusFilter)) {
                          try {
                              selectedStatus = SwapStatus.valueOf(statusFilter.toUpperCase());
                              request.setAttribute("selectedStatus", statusFilter); // Keep param value for form input
                          } catch (IllegalArgumentException e) {
                              // Handle invalid status parameter - default to ALL
                              System.err.println("AdminSwapManagementServlet: Invalid status filter received: " + statusFilter);
                              request.setAttribute("errorMessage", "Invalid swap status filter: " + statusFilter);
                              request.setAttribute("selectedStatus", "ALL");
                              selectedStatus = null; // Treat as ALL if invalid
                          }
                     } else {
                          request.setAttribute("selectedStatus", "ALL"); // Default
                     }

                     // Fetch Swaps based on filters using AdminDAO methods
                     if (startDate != null && endDate != null) {
                         if (selectedStatus != null) {
                             swapsList = adminDAO.getSwapsByDateRangeAndStatus(selectedStatus, startDate, endDate);
                         } else {
                             swapsList = adminDAO.getSwapsByDateRange(startDate, endDate);
                         }
                     } else if (selectedStatus != null) {
                          // If only status is filtered, need a DAO method to get swaps by status regardless of date.
                          // Your AdminDAO doesn't have this. For simplicity, we'll get all swaps and filter in memory,
                          // OR adjust the date range to cover a very long period (like epoch to now),
                          // OR ideally, add a new DAO method. Let's get all from epoch to now if no dates are specified.
                          swapsList = adminDAO.getSwapsByDateRangeAndStatus(selectedStatus, new Date(0), new Date()); // Use epoch to now
                     }
                      else {
                         // No filters applied - get all swaps (or a default range like last 7 days, but 'all' is simpler for this page)
                          swapsList = adminDAO.getSwapsByDateRange(new Date(0), new Date()); // Use epoch to now
                     }


                 } catch (SQLException e) { // Catch SQLException during data fetching
                    System.err.println("AdminSwapManagementServlet SQL ERROR (fetching filtered swaps): " + e.getMessage());
                    e.printStackTrace();
                    request.setAttribute("errorMessage", "Database error while fetching filtered swaps: " + e.getMessage());
                    swapsList = new ArrayList<>(); // Clear list on DB error
                 }


                 request.setAttribute("swapsList", swapsList);
                 request.setAttribute("allStatuses", EnumSet.allOf(SwapStatus.class)); // Provide all status options for the dropdown

                 targetJsp = "/WEB-INF/jsp/adminManageSwaps.jsp"; // Ensure we go to the list page
            }


        } catch (Exception e) { // Catch broader Exception for other potential issues
            System.err.println("AdminSwapManagementServlet General ERROR: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "An unexpected error occurred: " + e.getMessage());
             request.setAttribute("swapsList", new ArrayList<>()); // Ensure list is not null on error
             request.setAttribute("allStatuses", EnumSet.allOf(SwapStatus.class)); // Still provide statuses
             targetJsp = "/WEB-INF/jsp/adminManageSwaps.jsp"; // Stay on the list page to show error
        }

        // Forward to the determined target JSP
        RequestDispatcher dispatcher = request.getRequestDispatcher(targetJsp);
        dispatcher.forward(request, response);
    }

    // No POST method needed for read-only swap management
}