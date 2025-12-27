package com.ProjAdvAndWeb.controller;

import java.io.IOException;
import java.sql.SQLException;
// import java.util.ArrayList; // Not directly used if relying on User.getSkills()
import java.util.Arrays; // For stream processing of arrays
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors; // For String.join

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.ProjAdvAndWeb.dao.SkillDAO;
import com.ProjAdvAndWeb.dao.UserDAO;
import com.ProjAdvAndWeb.model.Skill;
import com.ProjAdvAndWeb.model.User;

@WebServlet("/ProfileServlet")
public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(ProfileServlet.class.getName());

    private UserDAO userDAO;
    private SkillDAO skillDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO();
        skillDAO = new SkillDAO();
        LOGGER.info("ProfileServlet initialized.");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (loggedInUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=session_expired_profile_access");
            return;
        }

        String action = request.getParameter("action"); 

        if ("showManageSkillsPage".equals(action)) {
            try {
                List<Skill> allGenericSkills = skillDAO.getAllSkills(null); 
                request.setAttribute("allGenericSkillsWithIds", allGenericSkills);
                // loggedInUser from session is used by manageUserSkills.jsp to pre-check skills
                RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/manageUserSkills.jsp");
                dispatcher.forward(request, response);
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error fetching data for manage skills page", e);
                session.setAttribute("profileErrorMessage", "Error loading skill management page: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/ProfileServlet"); 
            }
        } else {
            // Default: Show main profile page
            request.setAttribute("profileUser", loggedInUser); // User for profile.jsp
            RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/profile.jsp");
            dispatcher.forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (loggedInUser == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Session expired or not logged in.");
            return;
        }

        String formAction = request.getParameter("formAction");
        String redirectURL = request.getContextPath() + "/ProfileServlet"; 

        try {
            if ("updateDetails".equals(formAction)) {
                String firstName = request.getParameter("firstName");
                String lastName = request.getParameter("lastName");
                String email = request.getParameter("email");
                String phoneStr = request.getParameter("phoneNumber");

                if (firstName == null || firstName.trim().isEmpty() ||
                    lastName == null || lastName.trim().isEmpty() ||
                    email == null || email.trim().isEmpty()) {
                    session.setAttribute("profileErrorMessage", "First name, last name, and email are required.");
                } else {
                    User userToUpdate = userDAO.getUserByUsername(loggedInUser.getUsername()); 
                    userToUpdate.setFirstName(firstName.trim());
                    userToUpdate.setLastName(lastName.trim());
                    userToUpdate.setEmail(email.trim());
                    if (phoneStr != null && !phoneStr.trim().isEmpty()) {
                        try {
                            userToUpdate.setPhoneNumber(Integer.parseInt(phoneStr.trim()));
                        } catch (NumberFormatException e) {
                            session.setAttribute("profileErrorMessage", "Invalid phone number format.");
                            response.sendRedirect(redirectURL); // Redirect immediately
                            return;
                        }
                    } else {
                        userToUpdate.setPhoneNumber(0); 
                    }
                    boolean success = userDAO.updateUser(userToUpdate); // Assumes UserDAO.updateUser updates these fields
                    if (success) {
                        session.setAttribute("loggedInUser", userToUpdate); 
                        session.setAttribute("profileSuccessMessage", "Profile details updated successfully!");
                    } else {
                        session.setAttribute("profileErrorMessage", "Failed to update profile details.");
                    }
                }
            } else if ("updateOfferedSkills".equals(formAction)) { // From manageUserSkills.jsp
                String[] selectedSkillIdsArray = request.getParameterValues("selectedSkillIds");
                String newSkillsString = "";
                if (selectedSkillIdsArray != null && selectedSkillIdsArray.length > 0) {
                    // Ensure there are no nulls or empty strings if the array can contain them, though unlikely from checkboxes
                    newSkillsString = Arrays.stream(selectedSkillIdsArray)
                                            .filter(id -> id != null && !id.trim().isEmpty())
                                            .collect(Collectors.joining(","));
                }

                // Use the DAO method to update the skills string directly
                boolean success = userDAO.updateUserSkillsColumnString(loggedInUser.getUsername(), newSkillsString);
                if (success) {
                    User updatedUser = userDAO.getUserByUsername(loggedInUser.getUsername()); // Refresh user from DB
                    session.setAttribute("loggedInUser", updatedUser); // Update session
                    session.setAttribute("profileSuccessMessage", "Your offered skills have been updated!");
                } else {
                    session.setAttribute("profileErrorMessage", "Failed to update your skills.");
                }
                // Redirect back to the main profile page after updating skills
                redirectURL = request.getContextPath() + "/ProfileServlet";
            
            } else {
                session.setAttribute("profileErrorMessage", "Unknown profile action: " + formAction);
            }
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid number format in profile POST action " + formAction, e);
            session.setAttribute("profileErrorMessage", "Invalid ID format provided.");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error during profile POST action " + formAction, e);
            session.setAttribute("profileErrorMessage", "Database error: " + e.getMessage());
        }
        response.sendRedirect(redirectURL);
    }
}