<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ProjAdvAndWeb.model.User" %>
<%@ page import="com.ProjAdvAndWeb.model.Skill" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<% pageContext.setAttribute("url_my_swaps", request.getContextPath() + "/swaps?action=mySwaps"); %>
<% pageContext.setAttribute("url_contact", request.getContextPath() + "/contact.jsp"); %>
<%pageContext.setAttribute("currentServletPath", request.getServletPath());
    pageContext.setAttribute("currentActionParam", request.getParameter("action")); // Add/Ensure this line
%>
<% pageContext.setAttribute("currentServletPath", request.getServletPath());
    pageContext.setAttribute("currentActionParam", request.getParameter("action")); // Add/Ensure this line
%>


<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    pageContext.setAttribute("isUserLoggedIn", loggedInUser != null);

    String currentUsernameForDisplay = "Guest"; // Renamed from your currentUsernameDisplay
    // String userFullName = ""; // Not directly used in sidebar, keep if page needs
    // String userUniqueUsernameForNotes = "";  // For notes widget, keep

    if (loggedInUser != null) {
        currentUsernameForDisplay = loggedInUser.getFirstName();
        pageContext.setAttribute("currentUsername", currentUsernameForDisplay); // For Master Sidebar
        // userFullName = loggedInUser.getFirstName() + " " + loggedInUser.getLastName();
        // userUniqueUsernameForNotes = loggedInUser.getUsername();
        // pageContext.setAttribute("profilePicUrl", loggedInUser.getProfilePicPath()); // Actual
        pageContext.setAttribute("profilePicUrl", ""); // Placeholder
    } else {
        pageContext.setAttribute("currentUsername", "Guest");
        pageContext.setAttribute("profilePicUrl", "");
    }
    // Pass other necessary attributes like counts for the dashboard content
    pageContext.setAttribute("currentUsernameDisplay", currentUsernameForDisplay); // For welcome message on page
    // ... keep other pageContext.setAttribute for userFullNameDisplay, userUniqueUsernameForNotes, etc.

    pageContext.setAttribute("currentServletPath", request.getServletPath()); // For active link in Master Sidebar
    // ... keep other pageContext.setAttribute for appContextPath, currentYear, counts ...
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>SkillSwap - Home</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
      /* --- YOUR NEW FULL CSS BLOCK --- */
      *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
      body {
        font-family: 'Poppins', sans-serif;
        background-color: #f4f7f6;
        color: #333;
        overflow-x: hidden;
        line-height: 1.6;
      }

      /* --- Cover Page Styles --- */
      #coverPage { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: linear-gradient(135deg, #6200ee, #03dac6); display: flex; flex-direction: column; justify-content: center; align-items: center; color: white; font-size: 2.8em; font-weight: 700; z-index: 2000; opacity: 1; transition: opacity 1.2s ease-out, visibility 1.2s ease-out; text-align: center; padding: 20px; }
      #coverPage .subtitle { font-size: 0.5em; font-weight: 400; margin-top: 15px; opacity: 0.9; }
      #coverPage.fade-out { opacity: 0; visibility: hidden; pointer-events: none; }
      body.cover-active { overflow: hidden; }

      /* --- Sidebar --- */
      .app-sidebar { position: fixed; top: 0; left: -260px; width: 260px; height: 100vh; background: #6200ee; color: white; padding: 20px; box-sizing: border-box; transition: left 0.3s cubic-bezier(0.25, 0.8, 0.25, 1); z-index: 1000; display: flex; flex-direction: column; box-shadow: 3px 0 15px rgba(0,0,0,0.1); }
      .app-sidebar.open { left: 0; }
      .sidebar-header { text-align: center; margin-bottom: 25px; padding-bottom: 20px; border-bottom: 1px solid rgba(255,255,255,0.15); }
      .profile-picture-container { width: 90px; height: 90px; border-radius: 50%; overflow: hidden; margin: 0 auto 15px auto; border: 3px solid #03dac6; background-color: rgba(255,255,255,0.2); display: flex; justify-content: center; align-items: center; }
      .profile-picture-container img { width: 100%; height: 100%; object-fit: cover; }
      .profile-picture-container .placeholder-icon { font-size: 3em; color: rgba(255,255,255,0.7); }
      .app-sidebar .logo { font-size: 1.8em; font-weight: 700; color: #03dac6; letter-spacing: 1px; margin-bottom: 0; }
      .sidebar-username { font-size: 1.1em; font-weight: 500; color: rgba(255,255,255,0.9); margin-top: 5px; display: none; /* Initially hidden */ }
        .app-sidebar { position: fixed; top: 0; left: -260px; width: 260px; height: 100vh; background:#002366; color: white; padding: 20px; box-sizing: border-box; transition: left 0.3s cubic-bezier(0.25, 0.8, 0.25, 1); z-index: 1000; display: flex; flex-direction: column; box-shadow: 5px 0 25px rgba(0, 0, 0, 0.15); }
  .app-sidebar.open { left: 0; }
  .sidebar-header { text-align: center; margin-bottom: 25px; padding-bottom: 20px; border-bottom: 1px solid rgba(255,255,255,0.15); }
  .app-sidebar .logo-main { font-size: 2.2em; font-weight: 700; color: #03dac6; letter-spacing: 1px; margin-bottom: 10px; display: block; }
  .app-sidebar .logo-tagline { font-size: 0.9em; color: rgba(255,255,255,0.8); }
  .profile-picture-container { width: 90px; height: 90px; border-radius: 50%; overflow: hidden; margin: 0 auto 15px auto; border: 3px solid #03dac6; background-color: rgba(255,255,255,0.2); display: flex; justify-content: center; align-items: center; }
  .profile-picture-container img { width: 100%; height: 100%; object-fit: cover; }
  .profile-picture-container .placeholder-icon { font-size: 3em; color: rgba(255,255,255,0.7); }
  .sidebar-username { font-size: 1.1em; font-weight: 500; color: rgba(255,255,255,0.9); margin-top: 5px; }
  .sidebar-nav {flex-grow: 1;margin-top: 10px;overflow-y: auto;padding-right: 2px;scrollbar-width: thin; scrollbar-color: rgba(255, 255, 255, 0.2) transparent; /* For Firefox */}
  .sidebar-nav::-webkit-scrollbar {width: 5px;}
  .sidebar-nav::-webkit-scrollbar-track {background: transparent;}
  .sidebar-nav::-webkit-scrollbar-thumb {background-color: rgba(255, 255, 255, 0.2);border-radius: 10px;}
  .sidebar-nav::-webkit-scrollbar-thumb:hover {background-color: rgba(255, 255, 255, 0.4);}
  .sidebar-nav ul { list-style: none; padding:0; margin:0;}
  .sidebar-nav ul li { margin-bottom: 12px; }
  .sidebar-nav a { color: rgba(255,255,255,0.85); text-decoration: none; font-weight: 500; font-size: 1.05em; display: flex; align-items: center; gap: 12px; padding: 12px 18px; border-radius: 8px; transition: background 0.25s ease, color 0.25s ease, transform 0.2s ease, padding-left 0.2s ease; }
  .sidebar-nav a .nav-icon { width: 20px; text-align: center; }
  .sidebar-nav a:hover, .sidebar-nav a.active { background: #03dac6; color: #1a1a2e; font-weight: 600; transform: translateX(5px); padding-left: 22px; }
  .sidebar-footer { margin-top: auto; padding-top: 20px; border-top: 1px solid rgba(255,255,255,0.2); }
  .sidebar-footer a { display: block; text-align: center; padding: 10px; margin-bottom: 10px; border-radius: 6px; text-decoration: none; font-weight: 600; transition: background 0.2s ease, color 0.2s ease; }
  .sidebar-footer a.btn-login { background: #03dac6; color: #1a1a2e; } .sidebar-footer a.btn-login:hover { background: #02bfae; }
  .sidebar-footer a.btn-signup { background: transparent; border: 1px solid #03dac6; color: #03dac6; } .sidebar-footer a.btn-signup:hover { background: #03dac6; color: #1a1a2e; }
  .sidebar-footer a.btn-logout { background: #e74c3c; color: white; } .sidebar-footer a.btn-logout:hover { background: #c0392b; }
  .main-content-area { margin-left: 0; padding: 30px; transition: margin-left 0.3s cubic-bezier(0.25, 0.8, 0.25, 1), filter 0.3s ease; position: relative; z-index: 1; }
  .main-content-area.sidebar-open-push { margin-left: 260px; }
  .main-content-area.dimmed { filter: brightness(0.7) blur(2px); pointer-events: none; }
  .sidebar-toggle-btn { position: fixed; top: 20px; left: 20px; background:  #4169E1; border: none; color: white; font-size: 22px; padding: 10px 14px; cursor: pointer; border-radius: 8px; z-index: 1100; transition: background 0.3s ease, left 0.3s cubic-bezier(0.25, 0.8, 0.25, 1); box-shadow: 0 2px 5px rgba(0,0,0,0.15); }
  .sidebar-toggle-btn:hover { background: #002366; }
  .sidebar-toggle-btn.shifted { left: 280px; }
  .sidebar-fade-overlay { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.5); opacity: 0; visibility: hidden; transition: opacity 0.3s ease, visibility 0s 0.3s; z-index: 999; }
  .sidebar-fade-overlay.visible { opacity: 1; visibility: visible; transition: opacity 0.3s ease; }
        background-color: #00897B; color: #dee2e6; border: 1px solid rgb(6, 0, 0);
        padding: 8px 16px; border-radius: 5px; cursor: pointer; transition: all 0.3s ease;
        /* Ensure it behaves like other footer links if needed */
        /* display: block; text-align: center; text-decoration: none; font-weight: 600; margin-bottom: 10px; */
      }
      .sidebar-footer .logout-button:hover { background-color: #e74c3c; color: white; }


      .main-content-area { margin-left: 0; padding: 30px; transition: margin-left 0.3s cubic-bezier(0.25, 0.8, 0.25, 1); }
      .main-content-area.sidebar-open { margin-left: 260px; }
      .main-content-area.dimmed { filter: brightness(0.7) blur(2px); pointer-events: none; }
      .sidebar-toggle-btn { position: fixed; top: 20px; left: 20px; background: #6200ee; border: none; color: white; font-size: 22px; padding: 10px 14px; cursor: pointer; border-radius: 8px; z-index: 1100; transition: background 0.3s ease, left 0.3s cubic-bezier(0.25, 0.8, 0.25, 1); box-shadow: 0 2px 5px rgba(0,0,0,0.15); }
      .sidebar-toggle-btn:hover { background: #4e00c0; } .sidebar-toggle-btn.shifted { left: 280px; }
      .sidebar-fade-overlay { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.5); opacity: 0; visibility: hidden; transition: opacity 0.3s ease, visibility 0s 0.3s; z-index: 999; }
      .sidebar-fade-overlay.visible { opacity: 1; visibility: visible; transition: opacity 0.3s ease; }
      .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; padding-bottom: 20px; border-bottom: 1px solid #e0e0e0; }
      .page-header-title-group h1 { font-size: 2.2em; font-weight: 600; color: #6200ee; margin-bottom: 5px; }
      #welcomeMessage { font-size: 1.2em; font-weight: 400; color: #555; } #welcomeMessage .username { font-weight: 600; color: #03dac6; }
      .dashboard-panel { background-color: #ffffff; border-radius: 12px; padding: 30px; box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08), 0 1px 3px rgba(0,0,0,0.05); margin-bottom: 30px; }
      .dashboard-panel .quick-stats { margin-bottom: 30px; }
      .quick-stats { display: flex; justify-content: space-around; background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%); color: white; padding: 30px; border-radius: 10px; box-shadow: 0 5px 20px rgba(0,0,0,0.1); }
      .stat-item { text-align: center; flex-basis: 0; flex-grow: 1; padding: 0 10px;}
      .stat-item .stat-number { font-size: 2em; font-weight: 700; display: block; margin-bottom: 5px; }
      .stat-item .stat-label { font-size: 0.85em; opacity: 0.9; }
       .dashboard-grid { display: grid; grid-template-columns: repeat(3, 1fr);gap: 25px; }
      .dashboard-card { background: white; border-radius: 10px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.07); transition: transform 0.25s ease, box-shadow 0.25s ease; display: flex; flex-direction: column; }
      .dashboard-card:hover { transform: translateY(-5px); box-shadow: 0 8px 25px rgba(0,0,0,0.1); }
      .card-icon { font-size: 2.5em; color: #6200ee; margin-bottom: 15px; height: 40px; display: flex; align-items: center; }
      .dashboard-card h3 { font-size: 1.3em; font-weight: 600; color: #333; margin-bottom: 10px; }
      .dashboard-card p { font-size: 0.95em; color: #555; flex-grow: 1; margin-bottom: 15px; }
      .dashboard-card .btn-card, .dashboard-card .action-btn { display: inline-block; padding: 10px 18px; background: #03dac6; color: #1a1a2e; text-decoration: none; border-radius: 6px; font-weight: 600; text-align: center; transition: background 0.2s ease; align-self: flex-start; border: none; cursor: pointer;}
      .dashboard-card .btn-card:hover, .dashboard-card .action-btn:hover { background: #02bfae; }
      .dashboard-card .action-btn { background-color: #00897B; color: white; border-radius: 25px; padding: 12px 30px; font-weight: 700; box-shadow: 0 4px 12px rgba(0,137,123,0.3); }
      .dashboard-card .action-btn:hover { background: #00695c; }
      .dashboard-card #message { margin-top: 12px; color: #00695C; font-weight: 500; font-size: 0.9em; }

      .dashboard-section { margin-bottom: 30px; padding: 25px; background-color: #f8f9fa; border-radius: 8px; border: 1px solid #e9ecef; }
      .dashboard-section h2 { font-size: 1.5em; font-weight: 600; color: #495057; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #dee2e6; display: flex; align-items: center; }
      .dashboard-section h2 .fas { margin-right: 10px; color: #6200ee; font-size: 0.9em; }
      .tips-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; }
      .tip-card { background: white; border-radius: 8px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); border-left: 4px solid #03dac6; }
      .tip-card h4 { font-size: 1.1em; color: #6200ee; margin-bottom: 8px; }
      .tip-card p { font-size: 0.9em; color: #6c757d; margin-bottom: 10px; }
      .tip-card a { font-size: 0.9em; color: #007bff; text-decoration: none; font-weight: 500; }
      .tip-card a:hover { text-decoration: underline; }
      .did-you-know-card { background: linear-gradient(135deg, #f3e5f5, #e1f5fe); padding: 20px; border-radius: 8px; text-align: center; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
      .did-you-know-card .fas { font-size: 1.8em; color: #8e44ad; margin-bottom: 10px; }
      .did-you-know-card p { font-size: 1em; color: #4a4a4a; font-style: italic; }
      .my-notes-widget textarea { width: 100%; min-height: 120px; padding: 10px; border: 1px solid #ced4da; border-radius: 6px; font-family: 'Poppins', sans-serif; font-size: 0.95em; resize: vertical; margin-bottom: 10px; }
      .my-notes-widget textarea:focus { outline: none; border-color: #6200ee; box-shadow: 0 0 0 0.2rem rgba(98,0,238,.25); }
      .my-notes-widget button { padding: 8px 15px; background-color: #6200ee; color: white; border: none; border-radius: 5px; cursor: pointer; font-weight: 500; transition: background-color 0.2s ease; }
      .my-notes-widget button:hover { background-color: #4e00c0; }
      .site-footer { text-align: center; padding: 25px 0; margin-top: 40px; border-top: 1px solid #e0e0e0; background-color: #e9ecef; font-size: 0.9em; color: #6c757d; }
      .site-footer nav ul { list-style: none; padding: 0; margin: 0 0 10px 0; }
      .site-footer nav li { display: inline-block; margin: 0 10px; }
      .site-footer nav a { color: #495057; text-decoration: none; }
      .site-footer nav a:hover { text-decoration: underline; color: #6200ee; }
      @media (max-width: 768px) { .dashboard-section h2 { font-size: 1.3em; } .tips-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body class="cover-active">

    <div id="coverPage"> SkillSwap <div class="subtitle">Connecting Skills, Sharing Knowledge</div></div>

    <%-- COMMON SIDEBAR - Uses JSTL for dynamic links and user info --%>
    <nav class="app-sidebar" id="sidebar">
    <div class="sidebar-header">
        <div class="profile-picture-container" <c:if test="${not isUserLoggedIn}">style="display:none;"</c:if>>
            <c:choose>
                <c:when test="${isUserLoggedIn && not empty profilePicUrl && profilePicUrl ne ''}"><img src="<c:out value='${profilePicUrl}'/>" alt="User Profile"></c:when>
                <c:otherwise><span class="placeholder-icon"><i class="fas fa-user-circle"></i></span></c:otherwise>
            </c:choose>
        </div>
        <div class="logo">SkillSwap</div> <%-- Or logo-main if your CSS targets that --%>
        <c:if test="${not isUserLoggedIn && (currentServletPath eq '/index.jsp' || currentServletPath eq '/actualDashboard.jsp')}"> <%-- Show tagline only on home/landing for guests --%>
            <div class="logo-tagline">Connect | Share | Learn</div>
        </c:if>
        <div class="sidebar-username" <c:if test="${not isUserLoggedIn}">style="display:none;"</c:if>>
            Hello, <c:out value="${currentUsernameDisplay}"/>!
        </div>
    </div>
    <div class="sidebar-nav">
        <ul id="sidebarNavItems">
            <%-- JSTL variables for URLs should be defined at the top of EACH JSP --%>
            <c:url var="url_index" value="/index.jsp"/>
            <c:url var="url_dashboard_servlet" value="/DashboardServlet"/>
            <c:url var="url_browse_skills" value="/BrowseSkillsServlet"/>
            <c:url var="url_my_swaps" value="/SwapServlet?action=mySwaps"/>
            <c:url var="url_offer_skill" value="/ProfileServlet#manage-skills"/>
            <c:url var="url_profile" value="/ProfileServlet"/>
            <c:url var="url_settings" value="/jsp/settings.jsp"/>
            <c:url var="url_about" value="/about.jsp"/>
            <c:url var="url_contact" value="/contact.jsp"/>
            <c:url var="url_help" value="/jsp/help.jsp"/>
            <c:url var="url_login" value="/login.jsp"/>
            <c:url var="url_register" value="/register.jsp"/>
            <c:set var="currentPage" value="${pageContext.request.servletPath}"/>

            <li><a href="${url_index}" class="${currentPage eq '/index.jsp' ? 'active' : ''}"><span class="icon">🏠</span> Home</a></li>

            <c:if test="${isUserLoggedIn}">
                <li><a href="${url_dashboard_servlet}" class="${currentPage eq '/DashboardServlet' or currentPage eq '/actualDashboard.jsp' or currentPage eq '/jsp/actualDashboard.jsp' ? 'active' : ''}"><span class="icon"><i class="fas fa-tachometer-alt"></i></span> Dashboard</a></li>
                <li><a href="${url_browse_skills}" class="${currentPage eq '/BrowseSkillsServlet' or currentPage eq '/browse_skills.jsp' or currentPage eq '/jsp/browse_skills.jsp' ? 'active' : ''}"><span class="icon">🔍</span> Browse Skills</a></li>
              <li><a href="${url_profile}" class="${currentServletPath eq '/ProfileServlet' ? 'active' : ''}"><span class="icon">👤</span> Profile</a></li>
              <li><a href="${url_offer_skill}" class="${currentServletPath eq '/ProfileServlet' ? 'active' : ''}"><span class="icon">✨</span> Offer a Skill</a></li>
               <li><a href="<c:url value='/swaps?action=mySwaps'/>" class="$"><span class="icon">🔄</span> My Swaps</a></li>
            </c:if>

            <c:if test="${not isUserLoggedIn}">
                <c:if test="${currentPage ne '/login.jsp'}"><li><a href="${url_login}"><span class="icon"><i class="fas fa-sign-in-alt"></i></span> Login</a></li></c:if>
                <c:if test="${currentPage ne '/register.jsp'}"><li><a href="${url_register}"><span class="icon"><i class="fas fa-user-plus"></i></span> Register</a></li></c:if>
               <li><a href="${url_add_skill}" class="${(currentServletPath eq '/WEB-INF/jsp/addSkill.jsp') ? 'active' : ''}"><span class="icon">✨</span> Offer a Skill</a></li>
            </c:if>

            <li><a href="${url_about}" class="${currentPage eq '/about.jsp' ? 'active' : ''}"><span class="icon"><i class="fas fa-info-circle"></i></span> About</a></li>
            <li><a href="${url_contact}" class="${currentPage eq '/contact.jsp' ? 'active' : ''}"><span class="icon"><i class="fas fa-envelope"></i></span> Contact</a></li>
        </ul>
    </div>
    <div class="sidebar-footer">
        <c:choose>
            <c:when test="${isUserLoggedIn}">
                <a href="<c:url value='/LogoutServlet'/>" class="btn-logout">Logout</a>
            </c:when>
            <c:otherwise>
                 <c:if test="${currentPage ne '/login.jsp' and currentPage ne '/register.jsp'}">
                    <a href="${url_login}" class="btn-login">Login</a>
                    <a href="${url_register}" class="btn-signup">Sign Up</a>
                </c:if>
            </c:otherwise>
        </c:choose>
    </div>
</nav>
    <div id="sidebarFadeOverlay" class="sidebar-fade-overlay"></div>
    <button class="sidebar-toggle-btn" id="sidebarToggle" aria-label="Toggle sidebar"><i class="fas fa-bars"></i></button>

    <!-- Main content -->
    <div class="main-content-area" id="mainContent">
      <header class="page-header" id="mainPageHeaderToReplace"> <%-- Replaced main-header with page-header from your HTML template --%>
        <div class="page-header-title-group">
            <c:choose>
                <c:when test="${isUserLoggedIn}">
                    <h1>Dashboard</h1> <%-- Using the h1 from your HTML template's main content header --%>
                    <h2 id="welcomeMessage"><c:out value="Welcome, ${currentUsernameDisplay}!"/></h2> <%-- Populating #welcomeMessage --%>
                </c:when>
                <c:otherwise>
                    <h1>Welcome to SkillSwap!</h1> <%-- Main title for guests --%>
                    <h2 id="welcomeMessage" style="font-size:1.0em; display:block;">Connect, learn, and share your skills effortlessly.</h2>
                </c:otherwise>
            </c:choose>
        </div>
      </header>

      <div class="dashboard-panel">
        <c:if test="${isUserLoggedIn}">
            <section class="quick-stats" id="quickStatsSection" style="display:flex;">
                <div class="stat-item"><span class="stat-number" id="statSkillsOffered"><c:out value="${skillsOfferedCount != null ? skillsOfferedCount : fn:length(sessionScope.loggedInUser.skills)}"/></span><span class="stat-label">Skills Offered</span></div>
                <div class="stat-item"><span class="stat-number" id="statActiveSwaps"><c:out value="${activeSwapsCount != null ? activeSwapsCount : 0}"/></span><span class="stat-label">Active Swaps</span></div>
                <div class="stat-item"><span class="stat-number" id="statPendingRequests"><c:out value="${pendingRequestsCount != null ? pendingRequestsCount : 0}"/></span><span class="stat-label">Pending Requests</span></div>
                <div class="stat-item"><span class="stat-number" id="statSkillsToLearn"><c:out value="${sessionScope.loggedInUser.points}"/></span><span class="stat-label">My Points</span></div> <%-- Assuming Skills to Learn was My Points --%>
            </section>

            <section class="dashboard-grid" id="mainDashboardGrid" style="display:grid;">
                <div class="dashboard-card"><div class="card-icon"><i class="fas fa-chalkboard-teacher"></i></div><h3>Send Skill Request</h3><p>Need a helping hand? Request the skills you're looking for...</p><a href="<c:url value='/swaps?action=showNewRequestForm'/>" class="btn-card">Request</a> </div>
                <div class="dashboard-card"> <div class="card-icon"><i class="fas fa-book-open"></i></div> <h3>Learn Something New</h3> <p>Explore skills offered by others...</p> <a href="<c:url value='/BrowseSkillsServlet'/>" class="btn-card">Browse Skills</a> </div>
                <div class="dashboard-card"> <div class="card-icon"><i class="fas fa-tasks"></i></div> <h3>Manage Your Swaps</h3> <p>Keep track of your ongoing skill exchanges...</p> <a href="<c:url value='/swaps?action=mySwaps'/>" class="btn-card">View My Swaps</a> </div>
                <div class="dashboard-card"> <div class="card-icon"><i class="fas fa-user-edit"></i></div> <h3>Update Your Profile</h3> <p>Keep your skills and information up-to-date...</p> <a href="<c:url value='/ProfileServlet'/>" class="btn-card">Edit Profile</a> </div>
                <div class="dashboard-card"> <div class="card-icon"><i class="fas fa-map-marker-alt"></i></div> <h3>Head Office Location</h3> <p>Quickly find our head office location...</p> <button id="locationBtn" class="action-btn" type="button">Use My Location</button> <div id="message"></div> </div>
            </section>
        </c:if>

        <c:if test="${not isUserLoggedIn}">
            <section class="hero-image-section" id="heroSectionGuest" style="display: block;">
                <img src="<c:url value='/images/default-hero-image.jpg'/>" alt="Skills sharing" />
                <div class="hero-overlay-content">
                  <h1>Discover new skills and teach what you know</h1>
                  <p>Join our community and start swapping skills with people nearby.</p>
                  <div class="hero-cta-buttons">
                    <a href="<c:url value='/register.jsp'/>" class="btn-primary">Join Now</a>
                    <a href="<c:url value='/login.jsp'/>" class="btn-secondary">Login</a>
                  </div>
                  <div class="guest-browse-link">Or <a href="<c:url value='/BrowseSkillsServlet?guest=true'/>">browse as a guest</a>.</div>
                </div>
            </section>
        </c:if>

        <c:if test="${isUserLoggedIn}">
            <section class="dashboard-section tips-for-success" id="tipsSection" style="display:block;">
                <h2><i class="fas fa-lightbulb"></i> Tips for Success</h2>
                <div class="tips-grid">
                    <div class="tip-card"><h4>Complete Your Profile</h4><p>A detailed profile helps. <a href="<c:url value='/ProfileServlet'/>">Go to Profile</a></p></div>
                    <div class="tip-card"><h4>Clear Communication</h4><p>Be clear about what you offer and expect.</p></div>
                    <div class="tip-card"><h4>Explore Diverse Skills</h4><p>Learn something new! <a href="<c:url value='/BrowseSkillsServlet'/>">Browse Now</a></p></div>
                </div>
            </section>
            <section class="dashboard-section did-you-know" id="didYouKnowSection" style="display:block;">
                <h2><i class="fas fa-question-circle"></i> Did You Know?</h2>
                <div class="did-you-know-card"><i class="fas fa-brain"></i><p id="didYouKnowFact">Learning improves memory!</p></div>
            </section>
            <section class="dashboard-section my-notes-widget" id="myNotesSection" style="display:block;">
                <h2><i class="fas fa-sticky-note"></i> My Quick Notes</h2>
                <textarea id="userNotes" placeholder="Jot down reminders... (Saved in your browser)"></textarea>
                <button id="saveNotesBtn" type="button">Save Notes</button>
            </section>
        </c:if>

        <c:if test="${not isUserLoggedIn}">
            <div class="content-grid-logged-out" id="whyHowGrid" style="display: flex; margin-top: 30px;">
              <div class="feature-highlight-column">
                <h2>Why SkillSwap?</h2>
                <div class="card"> <h3>Easy to Connect</h3> <p>Find people nearby...</p> </div>
                <div class="card"> <h3>Build Your Profile</h3> <p>Create a skill portfolio...</p> </div>
                <div class="card"> <h3>Safe and Secure</h3> <p>Our platform ensures privacy...</p> </div>
              </div>
               <div class="feature-highlight-column">
                <h2>How It Works</h2>
                <div class="card"> <h3>1. Sign Up</h3> <p>Create your free account...</p> </div>
                <div class="card"> <h3>2. List Your Skills</h3> <p>Offer what you can teach...</p> </div>
                <div class="card"> <h3>3. Swap!</h3> <p>Connect with others...</p> </div>
              </div>
            </div>
        </c:if>
      </div>
    </div>

    <footer class="site-footer">
        <nav><ul>
            <li><a href="<c:url value='/about.jsp'/>">About Us</a></li>
            <li><a href="<c:url value='/contact.jsp'/>">Contact</a></li>
            <li><a href="<c:url value='/jsp/terms.jsp'/>">Terms of Service</a></li>
            <li><a href="<c:url value='/jsp/privacy.jsp'/>">Privacy Policy</a></li>
            <li><a href="<c:url value='/jsp/help.jsp'/>">FAQ</a></li>
        </ul></nav>
        <p>© <c:out value="${currentYear}"/> SkillSwap. All rights reserved.</p>
    </footer>

    <script>
      // --- COMMON UI JAVASCRIPT (Sidebar toggle, Cover page fade, Did You Know, My Notes, Geolocation) ---
      // Ensure this script uses the IDs from THIS HTML: sidebar, sidebarToggle, mainContent, sidebarFadeOverlay, coverPage
      const sidebar = document.getElementById('sidebar');
      const toggleBtn = document.getElementById('sidebarToggle');
      const mainContent = document.getElementById('mainContent');
      const fadeOverlay = document.getElementById('sidebarFadeOverlay');
      const coverPage = document.getElementById('coverPage');
      const body = document.body;

      // Make AppContext available for JS if needed for dynamic URLs in JS-generated content
      const AppContext = {
          baseUrl: "${pageContext.request.contextPath}" // Example: "/ProjAdvAndWeb"
      };

      document.addEventListener('DOMContentLoaded', () => {
        // Sidebar Toggle Logic
        if (toggleBtn && sidebar && mainContent && fadeOverlay) {
            toggleBtn.addEventListener('click', () => {
                const isOpen = sidebar.classList.toggle('open');
                fadeOverlay.classList.toggle('visible', isOpen);
                if (window.innerWidth > 992) {
                    mainContent.classList.toggle('sidebar-open'); // Your original push class
                    toggleBtn.classList.toggle('shifted');
                } else {
                    mainContent.classList.remove('sidebar-open');
                    toggleBtn.classList.remove('shifted');
                    body.style.overflow = isOpen ? 'hidden' : '';
                }
            });
            fadeOverlay.addEventListener('click', () => {
                sidebar.classList.remove('open');
                fadeOverlay.classList.remove('visible');
                body.style.overflow = '';
                if (window.innerWidth > 992) {
                    mainContent.classList.remove('sidebar-open');
                    toggleBtn.classList.remove('shifted');
                }
            });
            window.addEventListener('resize', () => {
                if (window.innerWidth > 992) {
                    if (sidebar.classList.contains('open')) {
                        mainContent.classList.add('sidebar-open');
                        toggleBtn.classList.add('shifted');
                        fadeOverlay.classList.remove('visible'); body.style.overflow = '';
                    } else {
                         mainContent.classList.remove('sidebar-open');
                         toggleBtn.classList.remove('shifted');
                    }
                } else {
                    mainContent.classList.remove('sidebar-open');
                    toggleBtn.classList.remove('shifted');
                    if (sidebar.classList.contains('open')) {
                        if(!fadeOverlay.classList.contains('visible')) fadeOverlay.classList.add('visible');
                        body.style.overflow = 'hidden';
                    } else {
                        fadeOverlay.classList.remove('visible');
                        body.style.overflow = '';
                    }
                }
            });
            window.dispatchEvent(new Event('resize'));
        }

        // Cover page fade out
        const isCurrentlyCoverActive = body.classList.contains('cover-active');
        if (coverPage && isCurrentlyCoverActive) {
            setTimeout(() => {
                coverPage.classList.add('fade-out');
                body.classList.remove('cover-active');
            }, 1500);
        } else if (coverPage) {
             coverPage.style.display = 'none';
        }

        // "Did You Know?" Feature (only if section is visible - for logged-in users)
        const didYouKnowSection = document.getElementById('didYouKnowSection');
        const didYouKnowFactElement = document.getElementById('didYouKnowFact');
        if (didYouKnowFactElement && didYouKnowSection && getComputedStyle(didYouKnowSection).display !== 'none') {
            const didYouKnowFacts = ["Fact 1!", "Fact 2!", "Fact 3!"]; // Keep your facts
            let currentFactIndex = 0;
            function showNextFact() {
                currentFactIndex = (currentFactIndex + 1) % didYouKnowFacts.length;
                didYouKnowFactElement.textContent = didYouKnowFacts[currentFactIndex];
            }
            setInterval(showNextFact, 10000);
            showNextFact();
        }

        // "My Notes" Widget (only if section is visible - for logged-in users)
        const myNotesSection = document.getElementById('myNotesSection');
        const userNotesTextarea = document.getElementById('userNotes');
        const saveNotesBtn = document.getElementById('saveNotesBtn');
        // Get the server-side username for notes key, fall back to empty if not set (though it should be for logged in)
        const loggedInUsernameForNotesJS = "<c:out value='${userUniqueUsernameForNotes}' default='' escapeXml='false'/>";

        function loadSavedNotes() {
            if (userNotesTextarea && loggedInUsernameForNotesJS) {
                const savedNotes = localStorage.getItem('skillSwapUserNotes_' + loggedInUsernameForNotesJS);
                userNotesTextarea.value = savedNotes ? savedNotes : "";
            }
        }
        if (userNotesTextarea && saveNotesBtn && myNotesSection && getComputedStyle(myNotesSection).display !== 'none') {
            saveNotesBtn.addEventListener('click', () => {
                if (loggedInUsernameForNotesJS) {
                    localStorage.setItem('skillSwapUserNotes_' + loggedInUsernameForNotesJS, userNotesTextarea.value);
                    alert('Notes saved locally!');
                } else { alert('Please log in to save notes.'); }
            });
            if (loggedInUsernameForNotesJS) loadSavedNotes();
        }

        // Geolocation (only if button is visible - for logged-in users)
        const locationBtn = document.getElementById('locationBtn');
        const messageDiv = document.getElementById('message');
        if (locationBtn && messageDiv && getComputedStyle(locationBtn.closest('.dashboard-card')).display !== 'none') {
            locationBtn.addEventListener('click', () => { /* ... your geolocation logic ... */ });
        }

        // Update welcome message in header if it's the placeholder and JS has a name
        // JSTL should primarily handle this. This is just a fallback.
        const welcomeHeaderMsgEl = document.getElementById('welcomeMessageDisplay'); // For header
        const localStoredUsername = localStorage.getItem('loggedInUser'); // This was from your original JS
        const serverSideDisplayName = "<c:out value='${currentUsernameDisplay}' default='Guest' escapeXml='false'/>";

        if (welcomeHeaderMsgEl) {
            const usernameSpanInHeader = welcomeHeaderMsgEl.querySelector('.username');
            if (usernameSpanInHeader && serverSideDisplayName !== 'Guest') {
                usernameSpanInHeader.textContent = serverSideDisplayName;
            } else if (usernameSpanInHeader && localStoredUsername && usernameSpanInHeader.textContent.includes("[Username]")) {
                usernameSpanInHeader.textContent = localStoredUsername;
            }
        }
        // Sidebar username is now fully handled by JSTL.
      });
    </script>
</body>
</html>