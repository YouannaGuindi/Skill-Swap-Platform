<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ProjAdvAndWeb.model.User" %>
<%@ page import="com.ProjAdvAndWeb.model.Skill" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    User loggedInUserJsp = (User) session.getAttribute("loggedInUser"); // Renamed
    pageContext.setAttribute("isUserLoggedIn", loggedInUserJsp != null);
    if (loggedInUserJsp != null) {
        pageContext.setAttribute("currentUsername", loggedInUserJsp.getFirstName());
        pageContext.setAttribute("profilePicUrl", ""); 
        pageContext.setAttribute("currentUsernameDisplay", loggedInUserJsp.getFirstName());
    } else {
        pageContext.setAttribute("currentUsername", "Guest");
        pageContext.setAttribute("profilePicUrl", "");
        pageContext.setAttribute("currentUsernameDisplay", "Guest");
    }
    pageContext.setAttribute("currentServletPath", request.getServletPath());
    pageContext.setAttribute("appContextPath", request.getContextPath());
    java.util.Calendar cal = java.util.Calendar.getInstance();
    pageContext.setAttribute("currentYear", cal.get(java.util.Calendar.YEAR));
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>My Profile - SkillSwap</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* ... (Keep your existing profile.jsp styles, including sidebar styles) ... */
        /* Ensure you have the .app-sidebar, .sidebar-toggle-btn etc. styles from previous correct version */
        body { font-family: 'Poppins', sans-serif; background-color: #f4f7f6; margin:0; }
        .app-sidebar { /* Basic styles for the sidebar from your actualDashboard */
            position: fixed; top: 0; left: -260px; width: 260px; height: 100vh; background:#002366; color: white; padding: 20px; box-sizing: border-box; transition: left 0.3s cubic-bezier(0.25, 0.8, 0.25, 1); z-index: 1000; display: flex; flex-direction: column; box-shadow: 5px 0 25px rgba(0, 0, 0, 0.15);
        }
        .app-sidebar.open { left: 0; }
        .sidebar-header { text-align: center; margin-bottom: 25px; padding-bottom: 20px; border-bottom: 1px solid rgba(255,255,255,0.15); }
        .app-sidebar .logo { font-size: 1.8em; font-weight: 700; color: #03dac6; letter-spacing: 1px; margin-bottom: 0; }
        .app-sidebar .logo-tagline { font-size: 0.9em; color: rgba(255,255,255,0.8); }
        .profile-picture-container { width: 90px; height: 90px; border-radius: 50%; overflow: hidden; margin: 0 auto 15px auto; border: 3px solid #03dac6; background-color: rgba(255,255,255,0.2); display: flex; justify-content: center; align-items: center; }
        .profile-picture-container img { width: 100%; height: 100%; object-fit: cover; }
        .profile-picture-container .placeholder-icon { font-size: 3em; color: rgba(255,255,255,0.7); }
        .sidebar-username { font-size: 1.1em; font-weight: 500; color: rgba(255,255,255,0.9); margin-top: 5px; }
        .sidebar-nav {flex-grow: 1;margin-top: 10px;overflow-y: auto;padding-right: 2px;}
        .sidebar-nav ul { list-style: none; padding:0; margin:0;}
        .sidebar-nav ul li { margin-bottom: 12px; }
        .sidebar-nav a { color: rgba(255,255,255,0.85); text-decoration: none; font-weight: 500; font-size: 1.05em; display: flex; align-items: center; gap: 12px; padding: 12px 18px; border-radius: 8px; transition: background 0.25s ease, color 0.25s ease, transform 0.2s ease, padding-left 0.2s ease; }
        .sidebar-nav a .icon, .sidebar-nav a .nav-icon { width: 20px; text-align: center; }
        .sidebar-nav a:hover, .sidebar-nav a.active { background: #03dac6; color: #1a1a2e; font-weight: 600; transform: translateX(5px); padding-left: 22px; }
        .sidebar-footer { margin-top: auto; padding-top: 20px; border-top: 1px solid rgba(255,255,255,0.2); }
        .sidebar-footer a { display: block; text-align: center; padding: 10px; margin-bottom: 10px; border-radius: 6px; text-decoration: none; font-weight: 600; transition: background 0.2s ease, color 0.2s ease; }
        .sidebar-footer a.btn-logout { background: #e74c3c; color: white; } .sidebar-footer a.btn-logout:hover { background: #c0392b; }
        .sidebar-footer a.btn-login { background: #03dac6; color: #1a1a2e; } .sidebar-footer a.btn-login:hover { background: #02bfae; }
        .sidebar-footer a.btn-signup { background: transparent; border: 1px solid #03dac6; color: #03dac6; } .sidebar-footer a.btn-signup:hover { background: #03dac6; color: #1a1a2e; }
         .sidebar-nav::-webkit-scrollbar {width: 5px;}
      .sidebar-nav::-webkit-scrollbar-track {background: transparent;}
      .sidebar-nav::-webkit-scrollbar-thumb {background-color: rgba(255, 255, 255, 0.2);border-radius: 10px;}
      .sidebar-nav::-webkit-scrollbar-thumb:hover {background-color: rgba(255, 255, 255, 0.4);}
        .main-content-area { margin-left: 0; padding: 30px; transition: margin-left 0.3s cubic-bezier(0.25, 0.8, 0.25, 1), filter 0.3s ease; position: relative; z-index: 1; }
        .main-content-area.sidebar-open-push { margin-left: 260px; } 
        .main-content-area.dimmed { filter: brightness(0.7) blur(2px); pointer-events: none; } 
        .sidebar-toggle-btn { position: fixed; top: 20px; left: 20px; background:  #4169E1; border: none; color: white; font-size: 22px; padding: 10px 14px; cursor: pointer; border-radius: 8px; z-index: 1100; transition: background 0.3s ease, left 0.3s cubic-bezier(0.25, 0.8, 0.25, 1); box-shadow: 0 2px 5px rgba(0,0,0,0.15); }
        .sidebar-toggle-btn:hover { background: #002366; }
        .sidebar-toggle-btn.shifted { left: 280px; } 
        .sidebar-fade-overlay { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.5); opacity: 0; visibility: hidden; transition: opacity 0.3s ease, visibility 0s 0.3s; z-index: 999; }
        .sidebar-fade-overlay.visible { opacity: 1; visibility: visible; transition: opacity 0.3s ease; }

        .page-header h1 { color: #6200ee; margin-bottom: 20px; font-size: 2em; }
        .profile-section { background: #fff; padding: 25px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 30px; }
        .profile-section h2 { margin-top: 0; color: #333; border-bottom: 1px solid #eee; padding-bottom: 10px; margin-bottom: 20px; font-size: 1.4em;}
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; font-weight: 500; margin-bottom: 8px; color: #555; }
        .form-group input[type="text"],
        .form-group input[type="email"],
        .form-group input[type="number"], 
        .form-group select {
            width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box; font-size: 1em;
        }
        .form-group input[readonly] { background-color: #f0f0f0; cursor: not-allowed; }
        .btn-submit, .btn-manage-skills { background-color: #6200ee; color: white; padding: 12px 20px; border: none; border-radius: 6px; cursor: pointer; font-size: 1em; font-weight: 500; transition: background-color 0.2s; text-decoration: none; display: inline-block; }
        .btn-submit:hover, .btn-manage-skills:hover { background-color: #4e00c0; }
        .skills-list { list-style: none; padding: 0; }
        .skills-list li { background: #f9f9f9; padding: 10px 15px; border-radius: 4px; margin-bottom: 8px; display: flex; justify-content: space-between; align-items: center; border: 1px solid #eee;}
        .message { padding: 15px; margin-bottom: 20px; border-radius: 5px; font-weight: 500; }
        .success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb;}
        .warning { background-color: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
        .site-footer { text-align: center; padding: 25px 0; margin-top: 40px; border-top: 1px solid #e0e0e0; background-color: #e9ecef; font-size: 0.9em; color: #6c757d; }
        .site-footer nav ul { list-style: none; padding: 0; margin: 0 0 10px 0; }
        .site-footer nav li { display: inline-block; margin: 0 10px; }
        .site-footer nav a { color: #495057; text-decoration: none; }
        .site-footer nav a:hover { text-decoration: underline; color: #6200ee; }
    </style>
</head>
<body>

    <nav class="app-sidebar" id="sidebar">
        <%-- ... Your full sidebar HTML from previous correct version ... --%>
        <div class="sidebar-header">
            <div class="profile-picture-container" <c:if test="${not isUserLoggedIn}">style="display:none;"</c:if>>
                <c:choose><c:when test="${isUserLoggedIn && not empty profilePicUrl && profilePicUrl ne ''}"><img src="<c:out value='${profilePicUrl}'/>" alt="User Profile"></c:when><c:otherwise><span class="placeholder-icon"><i class="fas fa-user-circle"></i></span></c:otherwise></c:choose>
            </div>
            <div class="logo">SkillSwap</div>
            <c:if test="${not isUserLoggedIn && (currentServletPath eq '/index.jsp' || currentServletPath eq '/actualDashboard.jsp')}"><div class="logo-tagline">Connect | Share | Learn</div></c:if>
            <div class="sidebar-username" <c:if test="${not isUserLoggedIn}">style="display:none;"</c:if>>Hello, <c:out value="${currentUsernameDisplay}"/>!</div>
        </div>
        <div class="sidebar-nav">
            <ul id="sidebarNavItems">
                <c:url var="url_index" value="/index.jsp"/><c:url var="url_dashboard_servlet" value="/DashboardServlet"/><c:url var="url_browse_skills" value="/BrowseSkillsServlet"/><c:url var="url_my_swaps" value="/SwapServlet?action=mySwaps"/><c:url var="url_offer_skill" value="/ProfileServlet?action=showManageSkillsPage"/> <%-- MODIFIED --%> <c:url var="url_profile" value="/ProfileServlet"/> <c:url var="url_about" value="/about.jsp"/><c:url var="url_contact" value="/contact.jsp"/><c:url var="url_login" value="/login.jsp"/><c:url var="url_register" value="/register.jsp"/>
                <li><a href="${url_index}" class="${currentServletPath eq '/index.jsp' ? 'active' : ''}"><span class="icon">🏠</span> Home</a></li>
                <c:if test="${isUserLoggedIn}">
                    <li><a href="${url_dashboard_servlet}" class="${currentServletPath eq '/DashboardServlet' or currentServletPath eq '/actualDashboard.jsp' ? 'active' : ''}"><span class="icon"><i class="fas fa-tachometer-alt"></i></span> Dashboard</a></li>
                    <li><a href="${url_browse_skills}" class="${currentServletPath eq '/BrowseSkillsServlet' ? 'active' : ''}"><span class="icon">🔍</span> Browse Skills</a></li>
                    <li><a href="${url_profile}" class="${currentServletPath eq '/ProfileServlet' and (empty param.action or param.action ne 'showManageSkillsPage') ? 'active' : ''}"><span class="icon">👤</span> Profile</a></li>
                    <li><a href="${url_offer_skill}" class="${currentServletPath eq '/ProfileServlet' and param.action eq 'showManageSkillsPage' ? 'active' : ''}"><span class="icon">✨</span> Offer/Manage Skills</a></li>
                    <li><a href="${url_my_swaps}" class="${currentServletPath eq '/SwapServlet' and param.action eq 'mySwaps' ? 'active' : ''}"><span class="icon">🔄</span> My Swaps</a></li>
                </c:if>
                <c:if test="${not isUserLoggedIn}"><c:if test="${currentServletPath ne '/login.jsp'}"><li><a href="${url_login}"><span class="icon"><i class="fas fa-sign-in-alt"></i></span> Login</a></li></c:if><c:if test="${currentServletPath ne '/register.jsp'}"><li><a href="${url_register}"><span class="icon"><i class="fas fa-user-plus"></i></span> Register</a></li></c:if></c:if>
                <li><a href="${url_about}" class="${currentServletPath eq '/about.jsp' ? 'active' : ''}"><span class="icon"><i class="fas fa-info-circle"></i></span> About</a></li>
                <li><a href="${url_contact}" class="${currentServletPath eq '/contact.jsp' ? 'active' : ''}"><span class="icon"><i class="fas fa-envelope"></i></span> Contact</a></li>
            </ul>
        </div>
        <div class="sidebar-footer"><c:choose><c:when test="${isUserLoggedIn}"><a href="<c:url value='/LogoutServlet'/>" class="btn-logout">Logout</a></c:when><c:otherwise><c:if test="${currentServletPath ne '/login.jsp' and currentServletPath ne '/register.jsp'}"><a href="${url_login}" class="btn-login">Login</a><a href="${url_register}" class="btn-signup">Sign Up</a></c:if></c:otherwise></c:choose></div>
    </nav>
    <div id="sidebarFadeOverlay" class="sidebar-fade-overlay"></div>
    <button class="sidebar-toggle-btn" id="sidebarToggle" aria-label="Toggle sidebar"><i class="fas fa-bars"></i></button>


    <div class="main-content-area" id="mainContent">
        <header class="page-header">
            <h1>My Profile</h1>
        </header>

        <c:if test="${not empty sessionScope.profileSuccessMessage}"><div class="message success"><c:out value="${sessionScope.profileSuccessMessage}"/></div><c:remove var="profileSuccessMessage" scope="session"/></c:if>
        <c:if test="${not empty sessionScope.profileErrorMessage}"><div class="message error"><c:out value="${sessionScope.profileErrorMessage}"/></div><c:remove var="profileErrorMessage" scope="session"/></c:if>
        <c:if test="${not empty sessionScope.profileWarningMessage}"><div class="message warning"><c:out value="${sessionScope.profileWarningMessage}"/></div><c:remove var="profileWarningMessage" scope="session"/></c:if>

        <section class="profile-section">
            <h2>Account Details</h2>
            <form action="${appContextPath}/ProfileServlet" method="post">
                <input type="hidden" name="formAction" value="updateDetails">
                <%-- ... (Account Details form fields as before) ... --%>
                <div class="form-group"><label for="username">Username:</label><input type="text" id="username" name="username" value="<c:out value='${profileUser.username}'/>" readonly></div>
                <div class="form-group"><label for="firstName">First Name:</label><input type="text" id="firstName" name="firstName" value="<c:out value='${profileUser.firstName}'/>" required></div>
                <div class="form-group"><label for="lastName">Last Name:</label><input type="text" id="lastName" name="lastName" value="<c:out value='${profileUser.lastName}'/>" required></div>
                <div class="form-group"><label for="email">Email:</label><input type="email" id="email" name="email" value="<c:out value='${profileUser.email}'/>" required></div>
                <div class="form-group"><label for="phoneNumber">Phone Number:</label><input type="number" id="phoneNumber" name="phoneNumber" value="${profileUser.phoneNumber != 0 ? profileUser.phoneNumber : ''}" placeholder="Optional"></div>
                <div class="form-group"><label>Points:</label><input type="text" value="<c:out value='${profileUser.points}'/>" readonly></div>
                <div class="form-group"><label>Date Registered:</label><input type="text" value="<fmt:formatDate value='${profileUser.dateRegistered}' pattern='yyyy-MM-dd HH:mm'/>" readonly></div>
                <button type="submit" class="btn-submit">Update Details</button>
            </form>
        </section>

        <section class="profile-section" id="manage-skills-section">
            <h2>My Offered Skills</h2>
            <c:choose>
                <c:when test="${not empty profileUser.skills}">
                    <ul class="skills-list">
                        <c:forEach var="skill" items="${profileUser.skills}">
                            <li>
                                <span><c:out value="${skill.name}"/> (<c:out value="${skill.category}"/>)</span>
                                <%-- Optional: Keep quick remove here, or remove it entirely if all management is on new page --%>
                                <%--
                                <form action="${appContextPath}/ProfileServlet" method="post" style="display: inline;">
                                    <input type="hidden" name="formAction" value="removeOfferedSkill">
                                    <input type="hidden" name="skillIdToRemove" value="${skill.id}">
                                    <button type="submit" class="btn-remove-skill" onclick="return confirm('Are you sure you want to remove this skill?');">Remove</button>
                                </form>
                                --%>
                            </li>
                        </c:forEach>
                    </ul>
                </c:when>
                <c:otherwise>
                    <p>You are not currently offering any skills.</p>
                </c:otherwise>
            </c:choose>

            <div style="margin-top: 20px;">
                <a href="${appContextPath}/ProfileServlet?action=showManageSkillsPage" class="btn-manage-skills">
                    Manage My Offered Skills
                </a>
            </div>
        </section>

    </div> <%-- End main-content-area --%>

    <footer class="site-footer">
        <%-- ... (Footer content as before) ... --%>
        <nav><ul><li><a href="<c:url value='/about.jsp'/>">About Us</a></li><li><a href="<c:url value='/contact.jsp'/>">Contact</a></li><li><a href="<c:url value='/jsp/terms.jsp'/>">Terms of Service</a></li><li><a href="<c:url value='/jsp/privacy.jsp'/>">Privacy Policy</a></li><li><a href="<c:url value='/jsp/help.jsp'/>">FAQ</a></li></ul></nav>
        <p>© <c:out value="${currentYear}"/> SkillSwap. All rights reserved.</p>
    </footer>

    <script>
      // --- Sidebar Toggle Script (from previous correct version) ---
      const sidebar = document.getElementById('sidebar');
      const toggleBtn = document.getElementById('sidebarToggle');
      const mainContent = document.getElementById('mainContent');
      const fadeOverlay = document.getElementById('sidebarFadeOverlay');
      const body = document.body;

      document.addEventListener('DOMContentLoaded', () => {
        if (toggleBtn && sidebar && mainContent && fadeOverlay) {
            toggleBtn.addEventListener('click', () => { /* ... (full toggle logic as before) ... */
                const isOpen = sidebar.classList.toggle('open');
                fadeOverlay.classList.toggle('visible', isOpen);
                if (window.innerWidth > 992) {
                    mainContent.classList.toggle('sidebar-open-push'); 
                    toggleBtn.classList.toggle('shifted');
                    body.style.overflow = ''; 
                } else { 
                    mainContent.classList.remove('sidebar-open-push');
                    toggleBtn.classList.remove('shifted');
                    body.style.overflow = isOpen ? 'hidden' : ''; 
                }
            });
            fadeOverlay.addEventListener('click', () => { /* ... (full fade overlay logic) ... */
                sidebar.classList.remove('open');
                fadeOverlay.classList.remove('visible');
                body.style.overflow = ''; 
                if (window.innerWidth > 992) {
                    mainContent.classList.remove('sidebar-open-push');
                    toggleBtn.classList.remove('shifted');
                }
            });
            window.addEventListener('resize', () => { /* ... (full resize logic) ... */
                if (window.innerWidth > 992) { 
                    if (sidebar.classList.contains('open')) {
                        mainContent.classList.add('sidebar-open-push');
                        toggleBtn.classList.add('shifted');
                        fadeOverlay.classList.remove('visible'); 
                        body.style.overflow = '';
                    } else {
                         mainContent.classList.remove('sidebar-open-push');
                         toggleBtn.classList.remove('shifted');
                    }
                } else { 
                    mainContent.classList.remove('sidebar-open-push'); 
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
      });
    </script>
</body>
</html>