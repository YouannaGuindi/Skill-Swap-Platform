package com.ProjAdvAndWeb.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.ProjAdvAndWeb.dao.UserDAO;
import com.ProjAdvAndWeb.model.User;
import com.ProjAdvAndWeb.util.EmailUtil;

/**
 * Servlet implementation class ForgotPasswordServlet
 */
@WebServlet("/forgotPassword")


public class ForgotPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private UserDAO userDAO; // Assuming you have a DAO for users

    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO(); // Initialize your UserDAO
    }

    // *** Use doGet because the link+JS sends a GET request ***
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get the email from the web address (URL parameter)
        // The JS sends it as '?email=...'
        String userEmail = request.getParameter("email");

        // Simple check: if email is missing or empty, redirect with a failure message
        if (userEmail == null || userEmail.trim().isEmpty()) {
            System.out.println("Forgot Password GET request with missing or empty email parameter.");
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=password_reset_failed");
            return; // Stop here
        }

        User user = null;
        try {
            // Find the user by email using your DAO
            // YOU MUST HAVE getUserByEmail IN YOUR UserDAO (See DAO section below)
            user = userDAO.getUserByEmail(userEmail);

            // *** Security point: Always respond the same way ***
            // Whether the user is found or not, we redirect to login.jsp with the SAME success message.
            // This prevents someone from guessing emails to see if they are registered.
            if (user != null && user.getEmail() != null && !user.getEmail().isEmpty()) {
                // User found and has an email. Construct the link and send the email.

                // --- THIS IS THE INSECURE PART ---
                // Build the link for the email. It's just a basic link containing the user's email.
                // This link IS NOT a secure, temporary token. It just tells /resetPassword which user it is.
                String resetLink = request.getScheme() + "://" +         // http or https
                                   request.getServerName() +             // like localhost or example.com
                                   (request.getServerPort() == 80 || request.getServerPort() == 443 ? "" : ":" + request.getServerPort()) + // Add port only if needed
                                   request.getContextPath() +            // like /AdvProject
                                   "/resetPassword?email=" + URLEncoder.encode(user.getEmail(), StandardCharsets.UTF_8.toString()); // !!! Link to the reset servlet/JSP and include email (encoded) !!!

                System.out.println("Attempting to send password reset email (INSECURE) for: " + userEmail);
                System.out.println("Reset Link (INSECURE): " + resetLink); // Log the link for debugging

                // Call your EmailUtil function
                // Use the EXACT function signature provided: sendPasswordResetEmail(String toEmail, String username, String resetLink)
                boolean emailSent = EmailUtil.sendPasswordResetEmail(user.getEmail(), user.getUsername(), resetLink); // Use user.getUsername() for the email body

                if (emailSent) {
                    System.out.println("Password reset email sent successfully (INSECURE) to " + user.getEmail());
                    // Redirect back to the login page with the success message
                    response.sendRedirect(request.getContextPath() + "/login.jsp?message=password_reset_requested");
                } else {
                     System.err.println("Failed to send password reset email (INSECURE) to " + user.getEmail());
                    // Log the failure, but still redirect with the success message for security reasons.
                    response.sendRedirect(request.getContextPath() + "/login.jsp?message=password_reset_requested");
                }

            } else {
                // User not found, or user has no email.
                // Log this on the server, but redirect with the success message for security.
                System.out.println("Forgot Password request for non-existent user/email or user without email: " + userEmail);
                response.sendRedirect(request.getContextPath() + "/login.jsp?message=password_reset_requested");
            }

        } catch (SQLException e) {
            // Database error during user lookup
            e.printStackTrace();
            System.err.println("Database error during forgot password process for: " + userEmail);
            // Redirect with a generic failure message on database error
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=password_reset_failed");

        } catch (Exception e) {
            // Any other unexpected errors (e.g., problem in EmailUtil if not handled internally)
            e.printStackTrace();
            System.err.println("Unexpected error during forgot password process for: " + userEmail);
             // Redirect with a generic failure message on other errors
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=password_reset_failed");
        }
    }

    // The doPost method is not needed in this very simple flow, you can remove it.
    // protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { ... }
}
