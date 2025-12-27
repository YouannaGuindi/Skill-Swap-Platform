package com.ProjAdvAndWeb.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.net.URLEncoder; // Import URLEncoder
import java.nio.charset.StandardCharsets; // Import StandardCharsets


import com.ProjAdvAndWeb.dao.AdminDAO;
import com.ProjAdvAndWeb.dao.UserDAO;
import com.ProjAdvAndWeb.model.Admin;
import com.ProjAdvAndWeb.model.User;
import com.ProjAdvAndWeb.util.EmailUtil; // Ensure this import is correct
import com.ProjAdvAndWeb.util.PasswordUtil; // Ensure this import is correct

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/register") // Ensure this URL pattern is correct for your setup
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;
    private AdminDAO adminDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO();
        adminDAO = new AdminDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Simply forward to the registration JSP page
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String firstName = request.getParameter("fname");
        String lastName = request.getParameter("lname");
        String email = request.getParameter("email");
        String username = request.getParameter("username"); // Ensure this input field exists in register.jsp
        String plainPassword = request.getParameter("pass");
        String confirmPassword = request.getParameter("cpass");
        String phoneStr = request.getParameter("telno");
        String role = request.getParameter("role"); // Ensure this input field exists (e.g., radio buttons or select)

        // Basic Validation
        // Check for null or empty strings after trimming whitespace
        if (firstName == null || firstName.trim().isEmpty() ||
            lastName == null || lastName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            username == null || username.trim().isEmpty() ||
            plainPassword == null || plainPassword.isEmpty() || // Passwords can be just empty if no trim
            confirmPassword == null || confirmPassword.isEmpty() ||
            phoneStr == null || phoneStr.trim().isEmpty() ||
            role == null || role.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "All fields are required.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!plainPassword.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Validate phone number format (simple example)
        // Assuming '01' followed by 9 digits
        if (!phoneStr.matches("01[0-9]{9}")) {
             request.setAttribute("errorMessage", "Phone number must be 11 digits and start with 01 (e.g., 01xxxxxxxxx).");
             request.getRequestDispatcher("/register.jsp").forward(request, response);
             return;
        }

        int phoneNumber;
        try {
            // Parse the validated phone number string to an integer
            phoneNumber = Integer.parseInt(phoneStr);
        } catch (NumberFormatException e) {
            // This block might be redundant if matches() check is strict, but good for safety
            request.setAttribute("errorMessage", "Invalid phone number format.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }
        
        // Hash the password using the utility method
        String hashedPassword = PasswordUtil.hashPassword(plainPassword);
        if (hashedPassword == null) { 
            // Password hashing failed (e.g., library error, although unlikely for non-empty input)
            request.setAttribute("errorMessage", "Password processing error.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        try {
            if ("user".equalsIgnoreCase(role)) {
                // Check if username or email already exists for a User
                if (userDAO.getUserByUsername(username) != null) {
                    request.setAttribute("errorMessage", "Username '" + escapeHtml(username) + "' already exists.");
                    request.getRequestDispatcher("/register.jsp").forward(request, response);
                    return;
                }
                if (userDAO.getUserByEmail(email) != null) {
                    request.setAttribute("errorMessage", "Email '" + escapeHtml(email) + "' is already registered as a user.");
                    request.getRequestDispatcher("/register.jsp").forward(request, response);
                    return;
                }
                 // Optional: Check if phone number exists for a User
                 // if (userDAO.getUserByPhoneNumber(phoneNumber) != null) { ... }


                // Create a new User object and set properties
                User user = new User();
                user.setFirstName(firstName.trim()); // Store trimmed names
                user.setLastName(lastName.trim());
                user.setEmail(email.trim()); // Store trimmed email
                user.setUsername(username.trim()); // Store trimmed username
                user.setPasswordHash(hashedPassword);
                user.setPhoneNumber(phoneNumber);
                user.setDateRegistered(); // Assumes this sets the current timestamp
                user.setPoints(300); // Set starting points
                user.setEmailVerified(false); // Set initial verification status

                // Attempt to add the user to the database
                boolean isRegistered = userDAO.addUser(user);

                if (isRegistered) {
                    // --- Success: User added, now send verification email ---
                    // 1. Construct the base URL for the application
                    String scheme = request.getScheme();      // e.g., http or https
                    String serverName = request.getServerName(); // e.g., localhost or example.com
                    int serverPort = request.getServerPort(); // e.g., 8080 or 80/443
                    String contextPath = request.getContextPath(); // e.g., /AdvProject

                    String appBaseUrl = scheme + "://" + serverName;
                    // Only add port if it's not the default for the scheme
                    if (!((scheme.equals("http") && serverPort == 80) || (scheme.equals("https") && serverPort == 443))) {
                        appBaseUrl += ":" + serverPort;
                    }
                    appBaseUrl += contextPath;

                    // 2. Create the verification link pointing to your VerifyEmailServlet
                    // Encode the username to handle special characters
                    String verificationLink = appBaseUrl + "/VerifyEmailServlet?username=" + URLEncoder.encode(user.getUsername(), StandardCharsets.UTF_8);

                    // 3. Call the specific EmailUtil method for welcome emails
                    // This method uses the parameters to format the email content internally
                    boolean emailSent = EmailUtil.sendWelcomeEmail(user.getEmail(), user.getUsername(), serverPort, verificationLink);

                    if (!emailSent) {
                        // Log email sending failure (don't typically fail registration just because email failed)
                        System.err.println("RegisterServlet: Failed to send verification email to " + user.getEmail() + " for user " + user.getUsername() + ".");
                        // Optional: Add a message to the login page indicating email might not have been sent
                        response.sendRedirect(request.getContextPath() + "/login.jsp?message=registration_success_email_failed");
                    } else {
                         System.out.println("RegisterServlet: Verification email queued for " + user.getEmail());
                         response.sendRedirect(request.getContextPath() + "/login.jsp?message=registration_success_check_email");
                    }

                } else {
                    // Registration failed for an unknown reason in the DAO
                    request.setAttribute("errorMessage", "User registration failed. Please try again.");
                    request.getRequestDispatcher("/register.jsp").forward(request, response);
                }

            } else if ("admin".equalsIgnoreCase(role)) {
                // Admin registration logic (mostly unchanged)
                 if (adminDAO.getAdminByUsername(username) != null) {
                    request.setAttribute("errorMessage", "Admin username '" + escapeHtml(username) + "' already exists.");
                    request.getRequestDispatcher("/register.jsp").forward(request, response);
                    return;
                }
                // Consider admin email uniqueness check if necessary
                // if (adminDAO.getAdminByEmail(email) != null) { ... }


                Admin admin = new Admin();
                admin.setFirstName(firstName.trim());
                admin.setLastName(lastName.trim());
                admin.setEmail(email.trim());
                admin.setUsername(username.trim());
                admin.setPasswordHash(hashedPassword);
                admin.setPhoneNumber(phoneNumber); // Assuming admin PK is phone number or just stored here
                admin.setDateRegistered(new Timestamp(System.currentTimeMillis()));

                boolean isAdminRegistered = adminDAO.addAdmin(admin);
                if (isAdminRegistered) {
                    // Admins might not need email verification, or a different process
                    response.sendRedirect(request.getContextPath() + "/login.jsp?message=admin_registration_success");
                } else {
                    request.setAttribute("errorMessage", "Admin registration failed. Please try again.");
                    request.getRequestDispatcher("/register.jsp").forward(request, response);
                }
            } else {
                // Invalid role provided in the form
                request.setAttribute("errorMessage", "Invalid role selected.");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            // Handle database errors, especially unique constraints
            e.printStackTrace(); // Log the full stack trace on the server side

            // Check for common SQL states for integrity constraint violation (duplicate key)
            // SQLSTATE starting with '23' (Integrity Constraint Violation) or checking message content (less reliable)
            if (e.getSQLState() != null && e.getSQLState().startsWith("23")) {
                 request.setAttribute("errorMessage", "Registration failed: Username, email, or phone number might already be taken.");
            } else {
                 request.setAttribute("errorMessage", "A database error occurred during registration. Please try again.");
                 // Optionally show detailed message during development, hide in production
                 // request.setAttribute("errorMessage", "Database error during registration: " + e.getMessage());
            }
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        } catch (Exception e) {
             // Catch any other unexpected errors
             e.printStackTrace();
             request.setAttribute("errorMessage", "An unexpected error occurred during registration. Please try again.");
             request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }

    // Removed the private sendVerificationEmail method

    /**
     * Basic HTML escaping utility to prevent XSS when displaying user input back in the JSP.
     * This is for displaying error messages etc.
     */
    private String escapeHtml(String raw) {
        if (raw == null) {
            return "";
        }
        // Use String replace for simplicity, consider a dedicated library like Apache Commons Text
        return raw.replace("&", "&") // Escape & first
                  .replace("<", "<")
                  .replace(">", ">")
                  .replace("\"", "\"")
                  .replace("'", "'"); // Escape single quote
    }
}