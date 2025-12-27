package com.ProjAdvAndWeb.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.ProjAdvAndWeb.dao.SkillDAO;
import com.ProjAdvAndWeb.dao.UserDAO; // Needed to get users and their skills
import com.ProjAdvAndWeb.model.Skill;
import com.ProjAdvAndWeb.model.User;

@WebServlet("/BrowseSkillsServlet") // Ensure this matches your links
public class SkillBrowseServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(SkillBrowseServlet.class.getName());

    private SkillDAO skillDAO;
    private UserDAO userDAO; // To fetch users and the skills they offer

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            this.skillDAO = new SkillDAO();
            this.userDAO = new UserDAO(); // Initialize UserDAO
        } catch (Exception e) { // Catch general exceptions if DAOs throw them in constructor
            LOGGER.log(Level.SEVERE, "Failed to initialize DAOs in SkillBrowseServlet", e);
            throw new ServletException("Failed to initialize DAOs", e);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("loggedInUser") : null;
        request.setAttribute("loggedInUser", loggedInUser); // Pass the whole user object for JSP logic
        request.setAttribute("isGuest", (loggedInUser == null));
        if (loggedInUser != null) {
            request.setAttribute("currentUsernameForAction", loggedInUser.getUsername());
        } else {
            request.setAttribute("currentUsernameForAction", "");
        }


        String searchTerm = request.getParameter("searchSkill");
        String categoryFilter = request.getParameter("category"); // Assuming filter uses 'category'
        request.setAttribute("currentSearchTerm", searchTerm != null ? searchTerm.trim() : "");
        request.setAttribute("currentCategoryFilter", categoryFilter != null ? categoryFilter : "all");


        try {
            List<Skill> allGenericSkills;
            if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                // Use the search method that queries the 'skill' (generic_skills) table
                allGenericSkills = skillDAO.searchSkillsInDefinitionTable(searchTerm.trim(), categoryFilter);
            } else {
                allGenericSkills = skillDAO.getAllSkills(categoryFilter); // Fetches from 'skill' table
            }
            request.setAttribute("skillsToDisplay", allGenericSkills);

            // To know who offers which skill, we need to fetch all users and their offered skill IDs
            // This is for the "Propose Swap" button or if you want to show "Offered by X users"
            // This can be performance intensive if you have many users.
            // A simpler approach for "Propose Swap" is handled on newSwapForm.jsp.
            // For browse page, let's focus on displaying generic skills first.
            // If you need to display "offered by X users" count:
            // List<User> allUsers = userDAO.getAllUsers(); // You'd need this method in UserDAO
            // Map<Integer, Long> skillOfferedByCount = allUsers.stream()
            //     .flatMap(user -> user.getSkills().stream()) // Assuming user.getSkills() returns List<Skill> offered by THIS user
            //     .collect(Collectors.groupingBy(Skill::getId, Collectors.counting()));
            // request.setAttribute("skillOfferedByCount", skillOfferedByCount);


        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching skills for browsing", e);
            request.setAttribute("browseError", "Could not load skills: " + e.getMessage());
        }

        request.setAttribute("pageTitle", "Browse Available Skills");
        RequestDispatcher dispatcher = request.getRequestDispatcher("/browseSkills.jsp");
        dispatcher.forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // If search form POSTs, handle it like a GET
        doGet(request, response);
    }
}