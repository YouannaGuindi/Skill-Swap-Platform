package com.ProjAdvAndWeb.controller;

import java.io.IOException;
// import java.io.PrintWriter; // Not needed if forwarding for errors
import java.security.SecureRandom;
import java.sql.Timestamp;
import java.sql.SQLException;
import java.util.Base64;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.ProjAdvAndWeb.model.User;
import com.ProjAdvAndWeb.model.Admin;
import com.ProjAdvAndWeb.dao.UserDAO;
import com.ProjAdvAndWeb.dao.AdminDAO;
import com.ProjAdvAndWeb.util.PasswordUtil;

@WebServlet("/loginservlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final int REMEMBER_ME_EXPIRY_DAYS = 30;

    private UserDAO userDAO;
    private AdminDAO adminDAO;
    private SecureRandom secureRandom; // Initialized in init()

    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO();
        adminDAO = new AdminDAO();
        secureRandom = new SecureRandom(); // Initialize here
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String acctype = request.getParameter("account");
        String uname = request.getParameter("uname"); // This can be username or email
        String passwordFromForm = request.getParameter("pass");
        String rememberMe = request.getParameter("rememberMe"); // "on" if checked, null otherwise

        // Validate inputs
        if (acctype == null || acctype.trim().isEmpty() ||
            uname == null || uname.trim().isEmpty() ||
            passwordFromForm == null || passwordFromForm.isEmpty()) {
            request.setAttribute("loginError", "Account type, username/email, and password are required.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }


        try {
            if ("admin".equalsIgnoreCase(acctype)) {
                Admin admin = adminDAO.validateAdmin(uname, passwordFromForm);
                if (admin != null) {
                    HttpSession session = request.getSession();
                    session.setAttribute("loggedInAdmin", admin);
                    session.setAttribute("userType", "admin");
                    // TODO: Create an AdminPage.jsp or an admin dashboard servlet
                    response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp"); // Example admin page
                    return;
                } else {
                    request.setAttribute("loginError", "Invalid admin username or password.");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                    return;
                }
            } else { // Default to user login
                User user = userDAO.validateUser(uname, passwordFromForm);
                // If validateUser only checks by username, and uname could be email:
                if (user == null && uname.contains("@")) { // Attempt to get by email if username fails and it looks like an email
                    User userByEmail = userDAO.getUserByEmail(uname);
                    if (userByEmail != null && PasswordUtil.checkPassword(passwordFromForm, userByEmail.getPasswordHash())) {
                        user = userByEmail;
                    }
                }

                if (user != null) {
                    if (!user.isEmailVerified()) {
                        request.setAttribute("loginError", "Please verify your email before logging in. Check your inbox (and spam folder).");
                        // Optionally, add a link/button to resend verification email here if you implement that feature
                        request.getRequestDispatcher("/login.jsp").forward(request, response);
                        return;
                    }

                    HttpSession session = request.getSession();
                    session.setAttribute("loggedInUser", user);
                    session.setAttribute("userType", "user");

                    if ("on".equals(rememberMe)) { // Checkbox value is "on" when checked
                        handleRememberMe(request, response, user.getUsername());
                    }
                    response.sendRedirect(request.getContextPath() + "/actualDashboard.jsp");
                    return;
                } else {
                    request.setAttribute("loginError", "Invalid username/email or password.");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                    return;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("loginError", "A database error occurred: " + e.getMessage());
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("loginError", "An unexpected error occurred: " + e.getMessage());
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }

    private void handleRememberMe(HttpServletRequest request, HttpServletResponse response, String username) throws SQLException {
        String selector = generateSecureToken(16);
        String validator = generateSecureToken(32);
        String hashedValidator = PasswordUtil.hashPassword(validator);

        long expiryTimeMillis = System.currentTimeMillis() + (REMEMBER_ME_EXPIRY_DAYS * 24L * 60 * 60 * 1000);
        Timestamp expiryDate = new Timestamp(expiryTimeMillis);

        if (userDAO.storeRememberMeToken(username, selector, hashedValidator, expiryDate)) {
            Cookie rememberMeCookie = new Cookie("rememberMeToken", selector + ":" + validator);
            rememberMeCookie.setMaxAge(REMEMBER_ME_EXPIRY_DAYS * 24 * 60 * 60);
            rememberMeCookie.setHttpOnly(true);
            rememberMeCookie.setSecure(request.isSecure());
            rememberMeCookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath()); // Set path correctly
            response.addCookie(rememberMeCookie);
            System.out.println("LoginServlet: Remember Me cookie set for " + username);
        } else {
            System.err.println("LoginServlet: Failed to store remember-me token in DB for user: " + username);
        }
    }

    private String generateSecureToken(int byteLength) {
        byte[] tokenBytes = new byte[byteLength];
        secureRandom.nextBytes(tokenBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(tokenBytes);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Forward GET requests to the login page, allowing it to display messages (e.g., after logout)
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }
}