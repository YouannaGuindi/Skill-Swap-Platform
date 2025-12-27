package com.ProjAdvAndWeb.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

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

@WebServlet("/SkillDetailServlet")
public class SkillDetailServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(SkillDetailServlet.class.getName());

    private SkillDAO skillDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        this.skillDAO = new SkillDAO();
        this.userDAO = new UserDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("loggedInUser") : null;
        request.setAttribute("loggedInUser", loggedInUser);


        String skillIdStr = request.getParameter("skillId");
        if (skillIdStr == null || skillIdStr.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Skill ID is missing.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("/BrowseSkillsServlet"); // Redirect to browse
            dispatcher.forward(request, response);
            return;
        }

        try {
            int skillId = Integer.parseInt(skillIdStr);
            Skill skill = skillDAO.getSkillById(skillId);

            if (skill == null) {
                request.setAttribute("errorMessage", "Skill not found.");
                RequestDispatcher dispatcher = request.getRequestDispatcher("/BrowseSkillsServlet");
                dispatcher.forward(request, response);
                return;
            }
            request.setAttribute("skillDetail", skill);

            // Find users who offer this skill
            // This requires a new method in UserDAO or logic here
            List<User> allUsers = userDAO.getAllUsers(); // You'll need this method in UserDAO
            List<User> usersOfferingSkill = new ArrayList<>();
            if (allUsers != null) {
                for (User user : allUsers) {
                    // user.getSkills() should return List<Skill> offered by this user
                    if (user.getSkills().stream().anyMatch(s -> s.getId() == skillId)) {
                        usersOfferingSkill.add(user);
                    }
                }
            }
            request.setAttribute("usersOfferingSkill", usersOfferingSkill);

            RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/skillDetail.jsp");
            dispatcher.forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid Skill ID format.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("/BrowseSkillsServlet");
            dispatcher.forward(request, response);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error fetching skill detail or users", e);
            request.setAttribute("errorMessage", "Error loading skill details: " + e.getMessage());
            RequestDispatcher dispatcher = request.getRequestDispatcher("/BrowseSkillsServlet");
            dispatcher.forward(request, response);
        }
    }
}