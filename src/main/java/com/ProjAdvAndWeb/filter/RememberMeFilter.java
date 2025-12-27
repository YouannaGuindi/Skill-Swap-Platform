package com.ProjAdvAndWeb.filter;

import java.io.IOException;
import java.sql.SQLException; // Import SQLException

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.ProjAdvAndWeb.dao.UserDAO;
import com.ProjAdvAndWeb.model.User;
import com.ProjAdvAndWeb.util.PasswordUtil;

@WebFilter("/*") // Apply to all requests to catch session/cookie early
public class RememberMeFilter extends HttpFilter implements Filter {
    
    private UserDAO userDAO;

    @Override
    public void init(FilterConfig fConfig) throws ServletException {
        super.init(fConfig);
        userDAO = new UserDAO();
        System.out.println("RememberMeFilter initialized.");
    }

	@Override
	public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        HttpSession session = request.getSession(false); 

        if (session == null || session.getAttribute("loggedInUser") == null) { 
            Cookie[] cookies = request.getCookies(); 
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("rememberMeToken".equals(cookie.getName())) {
                        String tokenValue = cookie.getValue();
                        if (tokenValue == null || tokenValue.isEmpty() || !tokenValue.contains(":")) {
                            // Invalid token format, clear it
                            clearRememberMeCookie(request, response, null); // Pass null for selector if unknown
                            break; 
                        }
                        String[] parts = tokenValue.split(":", 2);

                        if (parts.length == 2) {
                            String selectorFromCookie = parts[0];
                            String validatorFromCookie = parts[1];

                            try {
                                UserDAO.RememberMeTokenData tokenAuthData = userDAO.getRememberMeTokenDataBySelector(selectorFromCookie);

                                if (tokenAuthData != null) {
                                    if (PasswordUtil.checkPassword(validatorFromCookie, tokenAuthData.storedValidatorHash)) {
                                        User user = userDAO.getUserByUsername(tokenAuthData.username);
                                        if (user != null) {
                                            session = request.getSession(); // Create new session
                                            session.setAttribute("loggedInUser", user);
                                            // session.setAttribute("userType", "user"); // Set userType if you use it
                                            System.out.println("RememberMeFilter: User " + user.getUsername() + " logged in via Remember Me.");
                                        } else {
                                            System.err.println("RememberMeFilter: User not found for valid token: " + tokenAuthData.username);
                                            clearRememberMeCookie(request, response, selectorFromCookie);
                                            userDAO.clearRememberMeToken(selectorFromCookie);
                                        }
                                    } else {
                                        System.err.println("RememberMeFilter: Validator mismatch for selector: " + selectorFromCookie + ". Potential tampering.");
                                        clearRememberMeCookie(request, response, selectorFromCookie);
                                        userDAO.clearRememberMeToken(selectorFromCookie);
                                    }
                                }
                                // If tokenAuthData is null, it means token was not found or was expired and cleared by getRememberMeTokenDataBySelector
                            } catch (SQLException e) {
                                System.err.println("RememberMeFilter: Database error during token validation for selector " + selectorFromCookie + ". " + e.getMessage());
                                e.printStackTrace(); 
                                // Potentially clear cookie here too if DB error occurs, but be cautious not to over-clear
                            }
                        } else {
                             // Invalid token format after split
                            clearRememberMeCookie(request, response, null);
                        }
                        break; 
                    }
                }
            }
        }
        chain.doFilter(request, response); 
    }

    private void clearRememberMeCookie(HttpServletRequest request, HttpServletResponse response, String selector) {
        Cookie c = new Cookie("rememberMeToken", "");
        c.setMaxAge(0);
        c.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath() + "/"); 
        response.addCookie(c);
        System.out.println("RememberMeFilter: Cleared rememberMeToken cookie from browser" + (selector != null ? " for selector: " + selector : "."));
    }

	@Override
	public void destroy() {
        System.out.println("RememberMeFilter destroyed.");
	}
}