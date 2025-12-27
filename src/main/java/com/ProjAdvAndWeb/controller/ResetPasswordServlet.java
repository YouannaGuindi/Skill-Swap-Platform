package com.ProjAdvAndWeb.controller;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.ProjAdvAndWeb.dao.UserDAO;
import com.ProjAdvAndWeb.model.User;
import com.ProjAdvAndWeb.util.PasswordUtil;

/**
 * Servlet implementation class ResetPasswordServlet
 */
@WebServlet("/resetPassword")

public class ResetPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private UserDAO userDAO; // Assuming you have a DAO for users

    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO(); // Initialize your UserDAO
    }

    // Handles GET request when user clicks the link in the email (/resetPassword?email=...)
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Read email from the URL parameter
        String userEmail = request.getParameter("email");

        // Basic check: if email parameter is missing or empty, set an error and forward
        if (userEmail == null || userEmail.trim().isEmpty()) {
            System.out.println("Reset Password GET request with missing or empty email parameter.");
            request.setAttribute("resetError", "Invalid password reset link. Please request a new one.");
            // Forward to the JSP. The JSP's logic will detect the missing email and show the error.
            request.getRequestDispatcher("/resetPassword.jsp").forward(request, response);
            return;
        }

        // Email is present. Just forward to the JSP to display the form.
        // The JSP will read the 'email' parameter again from the request.getParameter("email").
        System.out.println("Reset Password GET request for email: " + userEmail + ". Forwarding to resetPassword.jsp");
        request.getRequestDispatcher("/resetPassword.jsp").forward(request, response);
    }

    // Handles POST request when user submits the new password form from resetPassword.jsp
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get data from the form submission (from resetPassword.jsp)
        String userEmail = request.getParameter("email"); // Get email from the hidden input in the form
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // --- Basic Validation ---
        if (userEmail == null || userEmail.trim().isEmpty() ||
            newPassword == null || newPassword.isEmpty() ||
            confirmPassword == null || confirmPassword.isEmpty()) {
            System.out.println("Reset Password POST request with missing parameters.");
            request.setAttribute("resetError", "All fields are required.");
             // Need to pass the email back to the JSP if forwarding on error so it can display the form again
            request.setAttribute("email", userEmail); // Set attribute so JSP can read it
            request.getRequestDispatcher("/resetPassword.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
             System.out.println("Reset Password POST request: Passwords do not match.");
            request.setAttribute("resetError", "Passwords do not match.");
             // Need to pass the email back to the JSP if forwarding on error
             request.setAttribute("email", userEmail); // Set attribute so JSP can read it
            request.getRequestDispatcher("/resetPassword.jsp").forward(request, response);
            return;
        }

        // --- Find User and Update Password ---
        User user = null;
        try {
            // Find the user by email using your DAO before updating the password
            // YOU MUST HAVE getUserByEmail method in your UserDAO (See DAO section below)
            user = userDAO.getUserByEmail(userEmail);

            if (user != null) {
                // User found. Hash the new password and update it in the DB.
                String hashedPassword = PasswordUtil.hashPassword(newPassword); // Hash the new password

                // YOU MUST HAVE updatePassword method in your UserDAO (See DAO section below)
                // This method takes the user's email and the new hashed password and updates the DB.
                boolean passwordUpdated = userDAO.updatePassword(user.getEmail(), hashedPassword); // Assuming updatePassword takes email and hash

                if (passwordUpdated) {
                    System.out.println("Password successfully reset (INSECURE flow) for user with email: " + userEmail);
                    // Redirect to login page with a success message
                    // You need to add handling for 'password_reset_success' message in login.jsp
                    response.sendRedirect(request.getContextPath() + "/login.jsp?message=password_reset_success");
                } else {
                    System.err.println("Failed to update password in DB (INSECURE flow) for user with email: " + userEmail);
                    request.setAttribute("resetError", "Failed to update password. Please try again.");
                     request.setAttribute("email", userEmail); // Set attribute so JSP can read it
                    request.getRequestDispatcher("/resetPassword.jsp").forward(request, response);
                }

            } else {
                 // User not found for the given email (shouldn't happen if email is valid, but handle defensively)
                 System.out.println("Reset Password POST request: User not found for email: " + userEmail + " (INSECURE flow)");
                 request.setAttribute("resetError", "User not found. Please request a new reset link.");
                 // Don't set email attribute as it's invalid, JSP will show the general error message
                 request.getRequestDispatcher("/resetPassword.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            // Database error during user lookup or password update
            e.printStackTrace();
             System.err.println("Database error during password reset (INSECURE flow) for: " + userEmail);
            request.setAttribute("resetError", "A database error occurred. Please try again.");
             request.setAttribute("email", userEmail); // Set attribute so JSP can read it
            request.getRequestDispatcher("/resetPassword.jsp").forward(request, response);
        } catch (Exception e) { // Catch any other unexpected exceptions (e.g., from hashing)
             e.printStackTrace();
              System.err.println("Unexpected error during password reset (INSECURE flow) for: " + userEmail);
             request.setAttribute("resetError", "An unexpected error occurred. Please try again.");
              request.setAttribute("email", userEmail); // Set attribute so JSP can read it
             request.getRequestDispatcher("/resetPassword.jsp").forward(request, response);
        }
    }
}
