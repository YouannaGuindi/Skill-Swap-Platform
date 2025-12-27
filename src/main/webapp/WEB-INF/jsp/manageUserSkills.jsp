<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ProjAdvAndWeb.model.User" %>
<%@ page import="com.ProjAdvAndWeb.model.Skill" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    if (loggedInUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?message=session_expired_skill_management");
        return;
    }
    pageContext.setAttribute("appContextPath", request.getContextPath());

    // Get user's currently offered skills (IDs as strings) to pre-check boxes
    List<String> userOfferedSkillIds = new ArrayList<>();
    if (loggedInUser.getSkills() != null) {
        for (Skill skill : loggedInUser.getSkills()) {
            userOfferedSkillIds.add(String.valueOf(skill.getId()));
        }
    }
    pageContext.setAttribute("userOfferedSkillIds", userOfferedSkillIds);

    // Fetch all generic skills (these should have IDs now)
    // This list needs to be populated by a servlet before forwarding to this page.
    // For now, we assume 'allGenericSkillsWithIds' is set by the servlet.
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Manage Your Skills - SkillSwap</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <style>
    /* Paste the CSS you provided for manageUserSkills.html here */
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    body {
      font-family: 'Poppins', sans-serif;
      background: linear-gradient(135deg, #e0f2f1, #b2dfdb);
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh; /* Use min-height for scrollable content */
      overflow-y: auto; /* Allow body to scroll if needed */
    }
    .container {
      display: flex;
      width: 90%;
      max-width: 1200px;
      min-height: 85vh; /* Allow container to grow */
      max-height: 95vh; /* Limit height and enable internal scroll */
      align-items: stretch; /* Stretch children to fill height */
      position: relative;
      gap: 30px;
      background: #ffffff;
      border-radius: 20px;
      box-shadow: 0 15px 40px rgba(0, 0, 0, 0.1);
      padding: 20px;
      margin: 20px 0; /* Add some margin if body scrolls */
    }
    .form-container {
      background: white;
      border-radius: 16px;
      padding: 25px 30px;
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
      border-top: 6px solid #098074;
      max-width: 520px;
      width: 100%;
      z-index: 2;
      animation: slideIn 1s ease-out;
      height: 100%; /* Take full height of parent if stretched */
      overflow-y: auto;
    }
    .form-container::-webkit-scrollbar { width: 8px; }
    .form-container::-webkit-scrollbar-thumb { background-color: #00796B; border-radius: 10px; }
    .form-container::-webkit-scrollbar-track { background-color: #e0f2f1; }

    .form-container > h3 {
      text-align: center; margin-bottom: 25px; font-size: 1.8rem; color: #004D40;
    }
    fieldset {
      border: 1px solid #b2dfdb; border-radius: 10px; padding: 15px 20px; margin-bottom: 25px; background-color: #fafffd;
    }
    legend {
      font-size: 1.3em; font-weight: 600; color: #00695C; padding: 0 8px; margin-left: 5px;
    }
     .skill-group {
      display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 10px 15px; margin-top: 10px;
    }
    .skill-group .sub-category-title {
      grid-column: 1 / -1; font-size: 1.05em; font-weight: 500; color: #00796B; margin-top: 10px; margin-bottom: 5px; padding-bottom: 5px; border-bottom: 1px dashed #a7d8d1;
    }
    .checkbox-label {
      display: flex; align-items: center; cursor: pointer; font-size: 0.9rem; color: #37474F; position: relative; padding-left: 28px; user-select: none; margin-bottom: 8px;
    }
    .checkbox-label input[type="checkbox"] {
      position: absolute; opacity: 0; cursor: pointer; height: 0; width: 0;
    }
    .checkmark {
      position: absolute; top: 50%; left: 0; transform: translateY(-50%); height: 18px; width: 18px; background-color: #e8f5e9; border: 1px solid #a5d6a7; border-radius: 4px; transition: background-color 0.2s ease, border-color 0.2s ease;
    }
    .checkbox-label:hover input[type="checkbox"] ~ .checkmark { background-color: #c8e6c9; }
    .checkbox-label input[type="checkbox"]:checked ~ .checkmark { background-color: #00897B; border-color: #00897B; }
    .checkmark:after { content: ""; position: absolute; display: none; }
    .checkbox-label input[type="checkbox"]:checked ~ .checkmark:after { display: block; }
    .checkbox-label .checkmark:after { left: 5px; top: 1px; width: 4px; height: 9px; border: solid white; border-width: 0 2px 2px 0; transform: rotate(45deg); }
    /* No other skill input for now, as skills come from DB */
    .form-buttons {
      text-align: center; margin-top: 30px; display: flex; gap: 15px; justify-content: center;
    }
    .form-buttons button {
      padding: 10px 25px; border: none; border-radius: 20px; cursor: pointer; font-family: 'Poppins', sans-serif; font-size: 0.95em; font-weight: 600; transition: all 0.3s; min-width: 140px;
    }
    .form-buttons button[type="submit"] {
      background-color: #00897B; color: white; box-shadow: 0 4px 10px rgba(0, 137, 123, 0.3);
    }
    .form-buttons button[type="submit"]:hover {
      background-color: #00695C; transform: translateY(-2px); box-shadow: 0 6px 15px rgba(0, 137, 123, 0.4);
    }
    .form-buttons .btn-cancel {
        background-color: #f44336; color: white;
    }
    .form-buttons .btn-cancel:hover {
        background-color: #d32f2f;
    }

    .visual { flex: 1; height: 100%; display: flex; align-items: center; justify-content: center; position: relative; }
    .blob { position: absolute; z-index: 0; width: 300px; height: 300px; background: radial-gradient(circle at 30% 30%, #80cbc4, #4db6ac); border-radius: 50% 60% 50% 60% / 60% 50% 60% 50%; animation: float 7s ease-in-out infinite; opacity: 0.45; }
    .blob:nth-child(2) { width: 220px; height: 220px; left: 80px; top: 60px; background: radial-gradient(circle at 60% 40%, #a5d6a7, #81c784); animation-delay: 2.5s; opacity: 0.4; }
    .skill-card { z-index: 1; width: 260px; padding: 20px; background: #ffffff; border-radius: 20px; box-shadow: 0 8px 20px rgba(0, 0, 0, 0.07); text-align: center; position: relative; animation: popIn 1.2s ease-out; }
    .skill-card::before { content: ""; position: absolute; top: -10px; right: -10px; width: 50px; height: 50px; background: #FFB74D; border-radius: 50%; opacity: 0.6; }
    .skill-card h3 { font-size: 1.4rem; margin-bottom: 10px; color: #00695C; }
    .skill-card p { font-size: 0.95rem; color: #37474F; }

    @keyframes float { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(20px); } }
    @keyframes popIn { 0% { transform: scale(0.8); opacity: 0; } 100% { transform: scale(1); opacity: 1; } }
    @keyframes slideIn { 0% { transform: translateY(40px); opacity: 0; } 100% { transform: translateY(0); opacity: 1; } }

    @media (max-width: 900px) {
      .container { flex-direction: column; height: auto; max-height: none; padding: 20px; gap: 20px; overflow-y: auto; overflow-x: hidden; }
      body { height: auto; padding: 20px 0; /* Allow body to grow and provide padding */ }
      .form-container { max-width: 100%; height: auto; margin-bottom: 20px; overflow-y: visible; padding: 20px; }
      .visual { height: 250px; width: 100%; }
      .blob { width: 200px; height: 200px; opacity: 0.3; }
      .blob:nth-child(2) { width: 150px; height: 150px; left: 20%; top: 10%; }
      .skill-card { margin-top: 0; transform: scale(0.9); }
    }
    @media (max-width: 600px) {
      .container { border-radius: 0; padding: 10px; margin: 0; }
      body { padding: 0; }
      .form-container > h3 { font-size: 1.6rem; }
      legend { font-size: 1.2em; }
      .skill-group { grid-template-columns: 1fr; }
      .checkbox-label { font-size: 0.85rem; padding-left: 25px; }
      .checkmark { height: 16px; width: 16px; }
      .checkbox-label .checkmark:after { left: 4px; top: 1px; width: 4px; height: 8px;}
      .visual { display: none; }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="form-container">
      <h3>Manage Your Offered Skills</h3>
      <form id="manageSkillsForm" action="${appContextPath}/ProfileServlet" method="post">
        <input type="hidden" name="formAction" value="updateOfferedSkills"> <%-- New action for ProfileServlet --%>

        <%-- Example: Grouping skills by category dynamically --%>
        <c:set var="currentCategory" value=""/>
        <c:forEach var="skill" items="${allGenericSkillsWithIds}"> <%-- This needs to be populated by servlet --%>
            <c:if test="${skill.category ne currentCategory}">
                <c:if test="${not empty currentCategory}">
                    </div></fieldset> <%-- Close previous fieldset and skill-group --%>
                </c:if>
                <fieldset>
                    <legend><c:out value="${skill.category}"/></legend>
                    <div class="skill-group">
                <c:set var="currentCategory" value="${skill.category}"/>
            </c:if>
            <label class="checkbox-label">
                <input type="checkbox" name="selectedSkillIds" value="${skill.id}"
                       <c:if test="${userOfferedSkillIds.contains(String.valueOf(skill.id))}">checked</c:if>>
                <span class="checkmark"></span> <c:out value="${skill.name}"/>
            </label>
        </c:forEach>
        <c:if test="${not empty currentCategory}">
            </div></fieldset> <%-- Close the last fieldset and skill-group --%>
        </c:if>

        <c:if test="${empty allGenericSkillsWithIds}">
            <p>No generic skills available to select. Please contact admin.</p>
        </c:if>

        <div class="form-buttons">
            <button type="submit">Save My Skills</button>
            <a href="${appContextPath}/ProfileServlet" class="btn-cancel" style="text-decoration:none; padding: 10px 25px; border-radius: 20px; font-size: 0.95em; font-weight: 600;">Cancel</a>
        </div>
      </form>
    </div>

    <div class="visual">
      <div class="blob"></div>
      <div class="blob"></div>
      <div class="skill-card">
        <h3>Skill Profile</h3>
        <p>Select the skills you'd like to offer. Your choices here will update your profile.</p>
      </div>
    </div>
  </div>

  <%-- No client-side saving to localStorage or redirect here, form submits to servlet --%>
</body>
</html>