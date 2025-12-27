<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ProjAdvAndWeb.model.User" %>
<%@ page import="com.ProjAdvAndWeb.model.Skill" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    // User object from session, should be up-to-date
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?message=login_required_skill_page");
        return;
    }
    // 'allGenericSkills' is set as a request attribute by DashboardServlet's doGet?action=showAddSkillPage
    // 'userOfferedSkills' comes from the session's loggedInUser object
    pageContext.setAttribute("userOfferedSkills", loggedInUser.getSkills()); 
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Add/Manage My Offered Skills</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/form_styles.css"> <%-- Ensure this path is correct --%>
    <style>
        /* Basic message styling if not covered by form_styles.css */
        .message { padding: 10px; margin-bottom: 15px; border-radius: 4px; border: 1px solid transparent; }
        .success { color: #155724; background-color: #d4edda; border-color: #c3e6cb; }
        .error { color: #721c24; background-color: #f8d7da; border-color: #f5c6cb; }
        .warning { color: #856404; background-color: #fff3cd; border-color: #ffeeba; }
        .form-container { max-width: 700px; margin: 20px auto; padding: 20px; background: #fff; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group select, .form-group button { width: 100%; padding: 10px; border-radius: 4px; border: 1px solid #ccc; box-sizing: border-box; }
        .form-group button { background-color: #007bff; color: white; cursor: pointer; }
        .form-group button:hover { background-color: #0056b3; }
        .btn-remove-sm { background-color: #dc3545; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer; font-size: 0.9em; }
        .btn-remove-sm:hover { background-color: #c82333; }
        ul { list-style-type: none; padding-left: 0; }
        li { padding: 8px 0; border-bottom: 1px solid #eee; }
        li:last-child { border-bottom: none; }
    </style>
</head>
<body>
    <%-- OPTIONAL: Include a common header/sidebar if this page is standalone.
         If it's part of a larger layout system, this might not be needed here.
         For simplicity, we'll make it a self-contained management page. --%>
    <%-- <jsp:include page="/WEB-INF/jsp/common/sidebar.jsp" /> --%>


    <div class="form-container">
        <h2>My Offered Skills</h2>

        <%-- Display messages from session (set by DashboardServlet POST) --%>
        <c:if test="${not empty sessionScope.dashboardSuccessMessage}">
            <div class="message success"><c:out value="${sessionScope.dashboardSuccessMessage}"/></div>
            <% session.removeAttribute("dashboardSuccessMessage"); %>
        </c:if>
        <c:if test="${not empty sessionScope.dashboardErrorMessage}">
            <div class="message error"><c:out value="${sessionScope.dashboardErrorMessage}"/></div>
            <% session.removeAttribute("dashboardErrorMessage"); %>
        </c:if>
        <c:if test="${not empty sessionScope.dashboardWarningMessage}">
            <div class="message warning"><c:out value="${sessionScope.dashboardWarningMessage}"/></div>
            <% session.removeAttribute("dashboardWarningMessage"); %>
        </c:if>

        <h3>Skills I Currently Offer:</h3>
        <c:choose>
            <c:when test="${not empty userOfferedSkills}">
                <ul>
                    <c:forEach var="skill" items="${userOfferedSkills}">
                        <li>
                            <c:out value="${skill.name}"/> (<c:out value="${skill.category}"/>)
                            <form action="${pageContext.request.contextPath}/DashboardServlet" method="post" style="display:inline; margin-left:10px; float: right;">
                                <input type="hidden" name="action" value="removeOfferedSkill"/>
                                <input type="hidden" name="genericSkillId" value="${skill.id}"/>
                                <button type="submit" class="btn-remove-sm">Remove</button>
                            </form>
                        </li>
                    </c:forEach>
                </ul>
            </c:when>
            <c:otherwise>
                <p>You are not currently offering any skills.</p>
            </c:otherwise>
        </c:choose>
        <hr style="margin: 20px 0;">
        <h3>Add a New Skill to My Offerings:</h3>
        <c:choose>
            <c:when test="${not empty allGenericSkills}">
                <form action="${pageContext.request.contextPath}/DashboardServlet" method="post">
                    <input type="hidden" name="action" value="addOfferedSkill"/>
                    <div class="form-group">
                        <label for="genericSkillIdToAdd">Select Skill to Offer:</label>
                        <select id="genericSkillIdToAdd" name="genericSkillId" required>
                            <option value="">-- Select a Skill --</option>
                            <c:forEach var="skill" items="${allGenericSkills}">
                                <c:set var="alreadyOffered" value="${false}"/>
                                <c:forEach var="offeredSkill" items="${userOfferedSkills}">
                                    <c:if test="${offeredSkill.id eq skill.id}"><c:set var="alreadyOffered" value="${true}"/></c:if>
                                </c:forEach>
                                <c:if test="${not alreadyOffered}">
                                    <option value="${skill.id}"><c:out value="${skill.name}"/> (<c:out value="${skill.category}"/>)</option>
                                </c:if>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-actions form-group">
                        <button type="submit">Add Selected Skill to My Offerings</button>
                    </div>
                </form>
            </c:when>
            <c:otherwise>
                <p>No generic skills are currently available to add, or they could not be loaded. Please try again later or contact support.</p>
            </c:otherwise>
        </c:choose>
        <p style="margin-top:20px; text-align:center;"><a href="${pageContext.request.contextPath}/DashboardServlet">Back to Dashboard</a></p>
    </div>
</body>
</html>