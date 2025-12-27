package com.ProjAdvAndWeb.controller;

import java.io.IOException;
import java.sql.SQLException; // Import SQLException

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.ProjAdvAndWeb.dao.UserDAO; 

@WebServlet("/LogoutServlet") 
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response); 
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("rememberMeToken".equals(cookie.getName())) {
                    String selector = null;
                    if (cookie.getValue() != null && cookie.getValue().contains(":")) {
                        selector = cookie.getValue().split(":", 2)[0];
                    }
                    
                    if (selector != null && !selector.isEmpty()) {
                        try {
                            userDAO.clearRememberMeToken(selector); // throws SQLException
						    System.out.println("LogoutServlet: Cleared DB remember-me token for selector: " + selector);
                        } catch (SQLException e) {
                            System.err.println("LogoutServlet: Error clearing remember-me token from DB for selector " + selector + ". " + e.getMessage());
                            e.printStackTrace();
                        }
                    }
                    
                    cookie.setValue(""); 
                    cookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath() + "/");
                    cookie.setMaxAge(0); 
                    response.addCookie(cookie);
                    System.out.println("LogoutServlet: Cleared rememberMeToken cookie from browser.");
                    break; 
                }
            }
        }

        HttpSession session = request.getSession(false); 
        if (session != null) {
            session.removeAttribute("loggedInUser");
            session.removeAttribute("loggedInAdmin");
            // session.removeAttribute("username"); // Not standard to store username separately if user object is there
            session.removeAttribute("userType");
            session.invalidate();
            System.out.println("LogoutServlet: Session invalidated.");
        }

        // Redirect to login page with a success message
        response.sendRedirect(request.getContextPath() + "/login.jsp?message=logout_success"); 
    }
}