package com.ProjAdvAndWeb.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException; // Import SQLException

import com.ProjAdvAndWeb.dao.UserDAO;
import com.ProjAdvAndWeb.model.User;

@WebServlet("/VerifyEmailServlet")

public class VerifyEmailServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private UserDAO userDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO(); 
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String username = request.getParameter("username"); 

        out.println("<!DOCTYPE html><html><head><title>Email Verification</title>");
        out.println("<link rel='stylesheet' href='" + request.getContextPath() + "/css/style.css'>"); // General stylesheet
        out.println("</head><body><div class='container'>");
        out.println("<h1>Email Verification Status</h1>");

        if (username == null || username.trim().isEmpty()) {
            out.println("<p class='error-message'>Error: No username provided in the verification link.</p>");
        } else {
            try {
                User user = userDAO.getUserByUsername(username); // throws SQLException

                if (user == null) {
                    out.println("<p class='error-message'>Error: User '" + escapeHtml(username) + "' not found. The verification link may be invalid or expired.</p>");
                } else if (user.isEmailVerified()) { 
                    out.println("<p class='info-message'>Information: The email for user '" + escapeHtml(username) + "' is already verified.</p>");
                    out.println("<p>You can <a href='" + request.getContextPath() + "/login.jsp'>login here</a>.</p>");
                } else {
                    boolean updateSuccess = userDAO.updateUserEmailVerificationStatus(username, true); // throws SQLException

                    if (updateSuccess) {
                        out.println("<p class='success-message'>Success! Your email address has been verified for user '" + escapeHtml(username) + "'.</p>");
                        out.println("<p>You can now <a href='" + request.getContextPath() + "/login.jsp'>login</a> to your account.</p>");
                    } else {
                        out.println("<p class='error-message'>Error: Could not update verification status for user '" + escapeHtml(username) + "'. Please contact support or try again later.</p>");
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<p class='error-message'>A database error occurred while verifying your email: " + e.getMessage() + ". Please try again later.</p>");
            }
        }

        out.println("<hr><p><a href='" + request.getContextPath() + "/index.jsp'>Go to Homepage</a></p>");
        out.println("</div></body></html>");
        out.close();
    }

    private String escapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;") // Must be first
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#x27;")
                   .replace("/", "&#x2F;");
    }

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}
}