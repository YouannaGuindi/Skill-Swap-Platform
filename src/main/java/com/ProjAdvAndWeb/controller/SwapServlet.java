package com.ProjAdvAndWeb.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
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
import com.ProjAdvAndWeb.dao.SwapDAO;
import com.ProjAdvAndWeb.dao.UserDAO;
import com.ProjAdvAndWeb.model.Skill;
import com.ProjAdvAndWeb.model.Swap;
import com.ProjAdvAndWeb.model.SwapStatus;
import com.ProjAdvAndWeb.model.User;
import com.ProjAdvAndWeb.util.EmailUtil; 
import com.google.gson.Gson;

@WebServlet("/swaps")
public class SwapServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(SwapServlet.class.getName());

    private SwapDAO swapDAO;
    private UserDAO userDAO;
    private SkillDAO skillDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        swapDAO = new SwapDAO();
        userDAO = new UserDAO();
        skillDAO = new SkillDAO();
        LOGGER.info("SwapServlet DAOs initialized successfully.");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("loggedInUser") : null;
        String action = request.getParameter("action");

        if (loggedInUser == null && !"getProviderSkills".equals(action) ) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=session_expired_or_login_required");
            return;
        }

        try {
            if ("mySwaps".equals(action)) {
                viewMySwaps(request, response, loggedInUser, request.getParameter("filter"));
            } else if ("view".equals(action)) {
                viewSwapDetails(request, response, loggedInUser);
            } else if ("showNewRequestForm".equals(action)) {
                List<User> allOtherUsers = userDAO.getAllUsersExcept(loggedInUser.getUsername());
                request.setAttribute("allOtherUsers", allOtherUsers);
                request.setAttribute("pageTitle", "Request a New Skill Swap");
                request.getRequestDispatcher("/WEB-INF/jsp/newSwapForm.jsp").forward(request, response);
            } 
            
            else if ("getProviderSkills".equals(action)) {
                String providerUsername = request.getParameter("providerUsername");
                List<Skill> actualProviderSkills = new ArrayList<>();
                if (providerUsername != null && !providerUsername.isEmpty()) {
                    User provider = userDAO.getUserByUsername(providerUsername);
                    if (provider != null) {
                        actualProviderSkills = provider.getSkills(); // This fetches the REAL skills

                        // === DEBUG LOGGING for REAL skills (Keep this) ===
                        LOGGER.info("SwapServlet (getProviderSkills) - Provider: " + providerUsername);
                        if (actualProviderSkills == null) {
                            LOGGER.info("SwapServlet (getProviderSkills) - actualProviderSkills from provider.getSkills() is NULL");
                        } else {
                            LOGGER.info("SwapServlet (getProviderSkills) - actualProviderSkills size: " + actualProviderSkills.size());
                            for (int i = 0; i < actualProviderSkills.size(); i++) {
                                Skill s = actualProviderSkills.get(i);
                                if (s == null) {
                                     LOGGER.info("SwapServlet (getProviderSkills) - Skill at index " + i + " is NULL");
                                } else {
                                     LOGGER.info("SwapServlet (getProviderSkills) - Actual Skill " + i + ": ID=" + s.getId() + ", Name=" + s.getName() + ", Category=" + s.getCategory() + ", Description=" + s.getDescription());
                                }
                            }
                        }
                        // === END DEBUG LOGGING ===
                    } else {
                        LOGGER.warning("SwapServlet (getProviderSkills) - Provider User object is NULL for username: " + providerUsername);
                    }
                }

                // --- THIS IS THE CRITICAL CHANGE: SENDING ACTUAL SKILLS ---
                String jsonOutput = new Gson().toJson(actualProviderSkills); 
                LOGGER.info("SWAP_SERVLET (doGet): ACTUAL JSON output for getProviderSkills: " + jsonOutput);
                // --- THE "FORCED TEST JSON" SECTION SHOULD BE COMPLETELY REMOVED OR COMMENTED OUT ---
                
                response.setContentType("application/json"); 
                response.setCharacterEncoding("UTF-8");    
                response.getWriter().write(jsonOutput);
                return; 
            } 
            // ^^^^^^ THIS IS THE BLOCK TO REPLACE/UPDATE ^^^^^^
            else {
                LOGGER.warning("SwapServlet doGet called with unknown or missing action: " + action);
                response.sendRedirect(request.getContextPath() + "/DashboardServlet");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in SwapServlet doGet for action: " + action, e);
            handleError(request, response, "A database error occurred: " + e.getMessage(), loggedInUser);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error in SwapServlet doGet for action: " + action, e);
            handleError(request, response, "An unexpected error occurred: " + e.getMessage(), loggedInUser);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User loggedInUser = (session != null) ? (User) session.getAttribute("loggedInUser") : null;

        if (loggedInUser == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Session expired. Please log in again.");
            return;
        }

        String action = request.getParameter("action");
        LOGGER.info("SwapServlet doPost received action: " + action);
        String swapIdParam = request.getParameter("id"); // Get swapId early for error redirection

        try {
            if ("initiate".equals(action)) {
                initiateSwap(request, response, loggedInUser, session);
            } else if ("accept".equals(action)) {
                updateSwapStatus(request, response, loggedInUser, SwapStatus.ACCEPTED);
            } else if ("reject".equals(action)) {
                updateSwapStatus(request, response, loggedInUser, SwapStatus.REJECTED);
            } else if ("complete".equals(action)) {
                updateSwapStatus(request, response, loggedInUser, SwapStatus.COMPLETED);
            } else if ("cancel".equals(action)) {
                updateSwapStatus(request, response, loggedInUser, SwapStatus.CANCELLED);
            } else {
                LOGGER.warning("SwapServlet doPost called with unknown action: " + action);
                request.setAttribute("errorMessage", "Unknown action requested.");
                response.sendRedirect(request.getContextPath() + "/DashboardServlet?errorMessage=Unknown+action");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error in SwapServlet doPost for action: " + action, e);
            String redirectUrl = (swapIdParam != null && !swapIdParam.isEmpty()) ?
                                 "/swaps?action=view&id=" + swapIdParam :
                                 "/swaps?action=mySwaps"; // Fallback if id isn't part of this request
            response.sendRedirect(request.getContextPath() + redirectUrl + "&errorMessage=" + response.encodeURL("Database error: " + e.getMessage()));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error in SwapServlet doPost for action: " + action, e);
            response.sendRedirect(request.getContextPath() + "/DashboardServlet?errorMessage=" + response.encodeURL("An unexpected error occurred."));
        }
    }

    private void viewMySwaps(HttpServletRequest request, HttpServletResponse response, User loggedInUser, String filter)
            throws ServletException, IOException, SQLException {
        // This method remains as you provided
        List<Swap> mySwaps = swapDAO.getSwapsByUsername(loggedInUser.getUsername());
        String pageTitle = "My Skill Swaps";

        if (filter != null && !filter.isEmpty() && !"all".equalsIgnoreCase(filter)) {
            try {
                SwapStatus filterStatusEnum = SwapStatus.valueOf(filter.toUpperCase());
                mySwaps = mySwaps.stream()
                                 .filter(swap -> swap.getStatus() == filterStatusEnum)
                                 .collect(Collectors.toList());
                pageTitle = filterStatusEnum.name().charAt(0) + filterStatusEnum.name().substring(1).toLowerCase() + " Swaps";
            } catch (IllegalArgumentException e) {
                LOGGER.warning("Invalid filter value for swaps: " + filter);
                request.setAttribute("filterError", "Invalid filter: " + filter);
            }
        }
        request.setAttribute("mySwaps", mySwaps);
        request.setAttribute("pageTitle", pageTitle);
        request.setAttribute("currentFilter", filter != null ? filter : "all");
        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/myswaps.jsp");
        dispatcher.forward(request, response);
    }

    private void viewSwapDetails(HttpServletRequest request, HttpServletResponse response, User loggedInUser)
            throws ServletException, IOException, SQLException {
        // This method remains as you provided
        String swapIdStr = request.getParameter("id");
        if (swapIdStr == null || swapIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/swaps?action=mySwaps&errorMessage=" + response.encodeURL("Swap ID is required."));
            return;
        }
        try {
            int swapId = Integer.parseInt(swapIdStr);
            Swap swap = swapDAO.getSwapById(swapId);

            if (swap == null) {
                response.sendRedirect(request.getContextPath() + "/swaps?action=mySwaps&errorMessage=" + response.encodeURL("Swap not found."));
                return;
            }
            if (!loggedInUser.getUsername().equals(swap.getRequesterUsername()) &&
                !loggedInUser.getUsername().equals(swap.getProviderUsername())) {
                LOGGER.warning("Unauthorized attempt to view swap " + swapId + " by user " + loggedInUser.getUsername());
                response.sendRedirect(request.getContextPath() + "/swaps?action=mySwaps&errorMessage=" + response.encodeURL("You are not authorized to view this swap."));
                return;
            }
            request.setAttribute("swap", swap);
            request.setAttribute("pageTitle", "Swap Details - ID: " + swap.getSwapId());
            RequestDispatcher dispatcher = request.getRequestDispatcher("/swapDetails.jsp");
            dispatcher.forward(request, response);
        } catch (NumberFormatException e) {
            LOGGER.warning("Invalid Swap ID format for view details: " + swapIdStr);
            response.sendRedirect(request.getContextPath() + "/swaps?action=mySwaps&errorMessage=" + response.encodeURL("Invalid Swap ID format."));
        }
    }

    private void initiateSwap(HttpServletRequest request, HttpServletResponse response, User loggedInUser, HttpSession session)
            throws ServletException, IOException, SQLException {
        // This method remains largely as you provided.
        // Ensure User.getSkills() is functional if used, or replace with skillDAO.getSkillsByUsername()
        String providerUsernameFromForm = request.getParameter("providerUsername");
        String skillRequestedIdStr = request.getParameter("skillRequestedId");
        String pointsOfferedStr = request.getParameter("pointsOffered");

        if (providerUsernameFromForm == null || providerUsernameFromForm.isEmpty() ||
            skillRequestedIdStr == null || skillRequestedIdStr.isEmpty() ||
            pointsOfferedStr == null || pointsOfferedStr.isEmpty()) {
            request.setAttribute("errorMessage", "All fields are required.");
            repopulateAndForwardToNewSwapForm(request, response, loggedInUser);
            return;
        }
         if (loggedInUser.getUsername().equals(providerUsernameFromForm)) {
             request.setAttribute("errorMessage", "You cannot initiate a swap with yourself.");
             repopulateAndForwardToNewSwapForm(request, response, loggedInUser); return;
        }
        int skillRequestedId;
        int pointsOffered;
        try {
            skillRequestedId = Integer.parseInt(skillRequestedIdStr);
            pointsOffered = Integer.parseInt(pointsOfferedStr);
            if (pointsOffered <= 0) {
                request.setAttribute("errorMessage", "Points offered must be positive.");
                repopulateAndForwardToNewSwapForm(request, response, loggedInUser);
                return;
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid skill ID or points format.");
            repopulateAndForwardToNewSwapForm(request, response, loggedInUser);
            return;
        }

        Skill requestedSkillDetails = this.skillDAO.getSkillById(skillRequestedId);
        User providerUserDetails = this.userDAO.getUserByUsername(providerUsernameFromForm);

        if (requestedSkillDetails == null || providerUserDetails == null) {
             request.setAttribute("errorMessage", "Invalid provider or skill selected.");
             repopulateAndForwardToNewSwapForm(request, response, loggedInUser);
             return;
        }
        
        // This line assumes providerUserDetails.getSkills() works and is populated.
        // If not, you would use: List<Skill> providerSkills = this.skillDAO.getSkillsByUsername(providerUserDetails.getUsername());
        // and then check against providerSkills.
        List<Skill> skillsOfProvider = providerUserDetails.getSkills();
        boolean providerOffersSkill = false;
        if (skillsOfProvider != null) {
            providerOffersSkill = skillsOfProvider.stream()
                                      .anyMatch(skill -> skill.getId() == skillRequestedId);
        }

        if (!providerOffersSkill) {
            request.setAttribute("errorMessage", "The selected provider does not offer the chosen skill, or skills could not be loaded.");
            repopulateAndForwardToNewSwapForm(request, response, loggedInUser);
            return;
        }

        Swap newSwap = new Swap();
        newSwap.setRequesterUsername(loggedInUser.getUsername());
        newSwap.setProviderUsername(providerUserDetails.getUsername());
        newSwap.setOfferedSkillId(skillRequestedId);
        newSwap.setSkillOffered(requestedSkillDetails); 
        newSwap.setPointsExchanged(pointsOffered);
        newSwap.setStatus(SwapStatus.PROPOSED);
        Timestamp now = new Timestamp(System.currentTimeMillis());
        newSwap.setRequestDate(now);
        newSwap.setLastUpdatedDate(now);

        boolean success = this.swapDAO.createSwapRequest(newSwap);

        if (success) {
            LOGGER.info("Swap request ID " + newSwap.getSwapId() + " initiated by " + loggedInUser.getUsername() + " to " + providerUserDetails.getUsername());
            String emailMessageSuffix = "";
            try {
                // Ensure EmailUtil.sendSwapRequestNotification is distinct from sendSwapConfirmationEmails
                boolean emailSent = EmailUtil.sendSwapRequestNotification(
                    providerUserDetails.getEmail(), 
                    (providerUserDetails.getFirstName() != null ? providerUserDetails.getFirstName() : providerUserDetails.getUsername()),
                    (loggedInUser.getFirstName() != null ? loggedInUser.getFirstName() : loggedInUser.getUsername()), 
                    requestedSkillDetails.getName(), 
                    pointsOffered,
                    request.getContextPath() + "/swaps?action=view&id=" + newSwap.getSwapId());
                if (emailSent) {
                     emailMessageSuffix = " and they have been notified by email!";
                } else {
                     emailMessageSuffix = " (email notification failed).";
                }
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Failed to send swap request email.", e);
                emailMessageSuffix = " (email notification encountered an error).";
            }
            if (session != null) {
                session.setAttribute("successMessage", "Swap request sent to " + 
                    (providerUserDetails.getFirstName() != null ? providerUserDetails.getFirstName() : providerUserDetails.getUsername()) +
                    emailMessageSuffix);
            }
            response.sendRedirect(request.getContextPath() + "/DashboardServlet");
        } else {
            request.setAttribute("errorMessage", "Failed to create swap request.");
            repopulateAndForwardToNewSwapForm(request, response, loggedInUser);
        }
    }
    private void repopulateAndForwardToNewSwapForm(HttpServletRequest request, HttpServletResponse response, User loggedInUser)
         throws ServletException, IOException {
         try {
              List<User> allOtherUsers = userDAO.getAllUsersExcept(loggedInUser.getUsername());
              request.setAttribute("allOtherUsers", allOtherUsers);
         } catch (SQLException e) {
             LOGGER.log(Level.WARNING, "Failed to repopulate users for newSwapForm on error", e);
         }
         request.setAttribute("pageTitle", "Request a New Skill Swap");
         request.setAttribute("providerUsernameValue", request.getParameter("providerUsername"));
         request.setAttribute("skillRequestedIdValue", request.getParameter("skillRequestedId"));
         request.setAttribute("pointsOfferedValue", request.getParameter("pointsOffered"));
         RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/jsp/newSwapForm.jsp");
         dispatcher.forward(request, response);
     }


    private void updateSwapStatus(HttpServletRequest request, HttpServletResponse response, User loggedInUser, SwapStatus newStatus)
            throws ServletException, IOException, SQLException {
        String swapIdStr = request.getParameter("id");
        if (swapIdStr == null || swapIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/swaps?action=mySwaps&errorMessage=" + response.encodeURL("Swap ID is required for status update."));
            return;
        }
        int swapId;
        try {
            swapId = Integer.parseInt(swapIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/swaps?action=mySwaps&errorMessage=" + response.encodeURL("Invalid Swap ID format."));
            return;
        }

        Swap swap = swapDAO.getSwapById(swapId); // This should ideally populate swap.skillOffered
        if (swap == null) {
            response.sendRedirect(request.getContextPath() + "/swaps?action=mySwaps&errorMessage=" + response.encodeURL("Swap not found."));
            return;
        }

        // Authorization Logic (remains as you provided)
        boolean authorizedToAct = false;
        String currentUsername = loggedInUser.getUsername();
        SwapStatus currentStatus = swap.getStatus();

        if (currentUsername.equals(swap.getProviderUsername())) { 
            if (currentStatus == SwapStatus.PROPOSED && (newStatus == SwapStatus.ACCEPTED || newStatus == SwapStatus.REJECTED)) {
                authorizedToAct = true;
            } else if (currentStatus == SwapStatus.ACCEPTED && (newStatus == SwapStatus.COMPLETED || newStatus == SwapStatus.CANCELLED )) {
                authorizedToAct = true;
            }
        } else if (currentUsername.equals(swap.getRequesterUsername())) { 
            if (currentStatus == SwapStatus.PROPOSED && newStatus == SwapStatus.CANCELLED) { 
                authorizedToAct = true;
            } else if (currentStatus == SwapStatus.ACCEPTED && (newStatus == SwapStatus.COMPLETED || newStatus == SwapStatus.CANCELLED)) {
                authorizedToAct = true;
            }
        }

        if (!authorizedToAct) {
            LOGGER.warning("Unauthorized status update attempt for swap " + swapId + " by user " + currentUsername + " from " + currentStatus + " to " + newStatus);
            response.sendRedirect(request.getContextPath() + "/swaps?action=view&id=" + swapId + "&errorMessage=" + response.encodeURL("Action not allowed for this swap or your role."));
            return;
        }

        boolean success = swapDAO.updateSwapStatusAndPoints(swapId, newStatus, userDAO); 

        if (success) {
            LOGGER.info("Swap ID " + swapId + " status updated to " + newStatus + " by user " + currentUsername);
            String successMessage = "Swap status updated to " + newStatus + ".";

            // ** NEW: Send email notification if swap is ACCEPTED **
            if (newStatus == SwapStatus.ACCEPTED) {
                try {
                    User requester = userDAO.getUserByUsername(swap.getRequesterUsername());
                    User provider = userDAO.getUserByUsername(swap.getProviderUsername());
                    
                    Skill skillOffered = swap.getSkillOffered();
                    if (skillOffered == null && swap.getOfferedSkillId() > 0) { 
                        skillOffered = skillDAO.getSkillById(swap.getOfferedSkillId());
                    }

                    if (requester != null && provider != null && skillOffered != null &&
                        requester.getEmail() != null && !requester.getEmail().isEmpty() &&
                        provider.getEmail() != null && !provider.getEmail().isEmpty() && 
                        skillOffered.getName() != null && !skillOffered.getName().isEmpty()) {
                        
                        String requesterNameForEmail = (requester.getFirstName() != null && !requester.getFirstName().isEmpty()) 
                                                       ? requester.getFirstName() : requester.getUsername();
                        String providerNameForEmail = (provider.getFirstName() != null && !provider.getFirstName().isEmpty()) 
                                                      ? provider.getFirstName() : provider.getUsername();

                        boolean emailsSent = EmailUtil.sendSwapConfirmationEmails(
                                requester.getEmail(),
                                provider.getEmail(),
                                requesterNameForEmail,
                                providerNameForEmail,
                                skillOffered.getName(),
                                swap.getPointsExchanged()
                        );
                        if (emailsSent) {
                            LOGGER.info("Swap acceptance confirmation emails sent successfully for swap ID " + swapId);
                            successMessage += " Confirmation emails have been sent to both parties.";
                        } else {
                            LOGGER.warning("Failed to send swap acceptance confirmation emails for swap ID " + swapId + ". Check EmailUtil logs.");
                            successMessage += " (Email notification failed. Please check system logs).";
                        }
                    } else {
                        String missingDetailsLog = String.format(
                            "Cannot send acceptance email for swap %d. Requester: %s (Email: %s), Provider: %s (Email: %s), Skill: %s (Name: %s).",
                            swapId, 
                            (requester != null ? requester.getUsername() : "null"), (requester != null ? requester.getEmail() : "null"),
                            (provider != null ? provider.getUsername() : "null"), (provider != null ? provider.getEmail() : "null"),
                            (skillOffered != null ? "ID " + skillOffered.getId() : "null"), (skillOffered != null ? skillOffered.getName() : "null")
                        );
                        LOGGER.warning(missingDetailsLog);
                        successMessage += " (Email notification could not be sent: required user/skill data missing or invalid).";
                    }
                } catch (SQLException sqle) {
                    LOGGER.log(Level.SEVERE, "Database error fetching user/skill details for email notification (swap ID " + swapId + ")", sqle);
                    successMessage += " (Error preparing email data: database issue).";
                } catch (Exception e) { 
                    LOGGER.log(Level.SEVERE, "Unexpected error sending swap acceptance emails for swap ID " + swapId, e);
                    successMessage += " (An unexpected error occurred during email notification).";
                }
            }
            response.sendRedirect(request.getContextPath() + "/swaps?action=view&id=" + swapId + "&message=" + response.encodeURL(successMessage));
        } else {
            response.sendRedirect(request.getContextPath() + "/swaps?action=view&id=" + swapId + "&errorMessage=" + response.encodeURL("Failed to update swap status. Possible reasons: insufficient points or concurrent update."));
        }
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response, String errorMessage, User loggedInUser)
            throws ServletException, IOException {
        request.setAttribute("errorMessage", errorMessage);
        // If user is logged in, redirecting to Dashboard might be better than forwarding to login.jsp
        String forwardPage;
        if (loggedInUser != null) {
            // Consider redirecting to dashboard with error in query param if preferred
            // response.sendRedirect(request.getContextPath() + "/DashboardServlet?errorMessage=" + response.encodeURL(errorMessage));
            // return; 
            forwardPage = "/DashboardServlet"; // Or a specific error page like /WEB-INF/jsp/errors.jsp
        } else {
            forwardPage = "/login.jsp";
        }
        // For now, using forward as per original structure
        request.getRequestDispatcher(forwardPage).forward(request, response);
    }

    @Override
    public void destroy() {
        super.destroy();
        LOGGER.info("SwapServlet destroyed.");
    }
}