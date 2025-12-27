<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ProjAdvAndWeb.model.User" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- Removed fn taglib if not used in this specific page's logic after sidebar change --%>
<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    pageContext.setAttribute("isUserLoggedIn", loggedInUser != null);
    if (loggedInUser != null) {
        pageContext.setAttribute("currentUsername", loggedInUser.getFirstName());
        pageContext.setAttribute("userNameValue", loggedInUser.getFirstName() + " " + loggedInUser.getLastName());
        pageContext.setAttribute("userEmailValue", loggedInUser.getEmail());
        // pageContext.setAttribute("profilePicUrl", loggedInUser.getProfilePicPath()); // Actual
        pageContext.setAttribute("profilePicUrl", ""); // Placeholder
    } else {
        pageContext.setAttribute("currentUsername", "Guest");
        pageContext.setAttribute("userNameValue", "");
        pageContext.setAttribute("userEmailValue", "");
        pageContext.setAttribute("profilePicUrl", "");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Submit Your Concern - SkillSwap</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <%-- Link to your common layout CSS --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main_layout.css">
    <style>
        /* --- CONCERN FORM SPECIFIC STYLES (from your HTML) --- */
        /* Override body for this specific page if main_layout.css doesn't match the gradient */
        body.concern-form-page { /* Add this class to body tag */
          font-family: 'Poppins', sans-serif;
          background: linear-gradient(135deg, #30aa9c, #38f3d6);
          /* display: flex; align-items: center; justify-content: center; height: 100vh; */ /* This might conflict with sidebar */
          overflow-y: auto; /* Allow scrolling if form is long */
        }

        /* Adjust .main-content-area for this specific form page if needed */
        .main-content-area.concern-form-main {
            padding: 0; /* Remove padding to let concern-form-body-wrapper control it */
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: calc(100vh - 0px); /* Adjust if you have a fixed global header */
        }

        .concern-form-body-wrapper {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            padding: 20px; /* Padding for the gradient area within main-content */
        }
        .concern-container {
            display: flex;
            width: 100%; /* Take full width of its parent */
            max-width: 1000px; /* Max width for the content within gradient */
            min-height: 80vh; /* Or auto */
            align-items: center;
            position: relative;
            gap: 30px;
        }
        .form-container {
            background: white; border-radius: 16px; padding: 35px 40px;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.1); border-top: 6px solid #00A87D;
            max-width: 520px; width: 100%; z-index: 2; animation: slideIn 1s ease-out;
            flex-shrink: 0; /* Prevent form from shrinking too much */
        }
        .form-container h2 { text-align: center; margin-bottom: 25px; font-size: 2rem; color: #222b38; }
        .form-group { margin-bottom: 20px; }
        .form-container label { display: block; margin-bottom: 6px; font-weight: 500; color: #5a677a; }
        .form-container input[type="text"],
        .form-container input[type="email"],
        .form-container textarea { width: 100%; padding: 12px; border: 1px solid #d8dde4; border-radius: 8px; font-size: 1rem; transition: all 0.2s; }
        .form-container input:focus,
        .form-container textarea:focus { border-color: #00A87D; box-shadow: 0 0 0 3px rgba(0, 168, 125, 0.2); outline: none; }
        .form-container textarea { resize: vertical; min-height: 100px; }
        .form-container button[type="submit"] { display: block; margin: 20px auto 0; padding: 12px 30px; background-color: #00A87D; color: white; border: none; border-radius: 25px; font-weight: 600; font-size: 1rem; cursor: pointer; transition: all 0.3s; }
        .form-container button:hover { background-color: #008261; transform: translateY(-2px); }
        .visual { flex: 1; height: 100%; display: flex; align-items: center; justify-content: center; position: relative; }
        .blob { position: absolute; z-index: 0; width: 300px; height: 300px; background: radial-gradient(circle at 30% 30%, #a0e7e5, #65f7e8); border-radius: 50% 60% 50% 60% / 60% 50% 60% 50%; animation: float 6s ease-in-out infinite; opacity: 0.5; }
        .blob:nth-child(2) { width: 220px; height: 220px; left: 80px; top: 60px; background: radial-gradient(circle at 60% 40%, #81d4fa, #4fc3f7); animation-delay: 2s; }
        .skill-card { z-index: 1; width: 260px; padding: 20px; background: #ffffff; border-radius: 20px; box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08); text-align: center; position: relative; animation: popIn 1.2s ease-out; }
        .skill-card::before { content: ""; position: absolute; top: -10px; right: -10px; width: 50px; height: 50px; background: #FFCA28; border-radius: 50%; opacity: 0.6; }
        .skill-card h3 { font-size: 1.4rem; margin-bottom: 10px; color: #00796B; }
        .skill-card p { font-size: 0.95rem; color: #546e7a; }
        @keyframes float { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(20px); } }
        @keyframes popIn { 0% { transform: scale(0.8); opacity: 0; } 100% { transform: scale(1); opacity: 1; } }
        @keyframes slideIn { 0% { transform: translateY(40px); opacity: 0; } 100% { transform: translateY(0); opacity: 1; } }
        .message-area { padding: 10px; margin-bottom: 15px; border-radius: 6px; text-align: center; font-size: 0.9em; width:100%; }
        .message-area.success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .message-area.error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb;}

        @media (max-width: 992px) { /* For when sidebar is visible but screen is smaller */
          .main-content-area.sidebar-open-push.concern-form-main { margin-left: 0; }
          .sidebar-toggle-btn.shifted { left: 20px; }
        }
        @media (max-width: 900px) {
          .concern-form-body-wrapper { min-height: auto; align-items: flex-start; padding-top: 80px; /* Space for sidebar toggle */}
          .concern-container { flex-direction: column; height: auto; padding-top: 30px; padding-bottom: 30px; }
          .visual { height: 250px; margin-bottom: 20px; width:100%;}
          .blob { display: none; }
          .skill-card { margin-top: 0; }
          .form-container { max-width: 100%; }
        }
         @media (max-width: 480px) {
          .form-container { padding: 25px 20px; }
          .form-container h2 { font-size: 1.6rem; }
        }
    </style>
</head>
<body class="concern-form-page"> <%-- No cover-active, but new class for body background --%>

    <%-- COMMON SIDEBAR --%>
    <nav class="app-sidebar" id="sidebar">
      <div class="sidebar-header">
        <span class="logo-main">SkillSwap</span>
        <c:if test="${not isUserLoggedIn}">
            <span class="logo-tagline">Connect & Grow</span>
        </c:if>
        <c:if test="${isUserLoggedIn}">
            <div class="profile-picture-container" style="display: flex;">
                <c:choose>
                    <c:when test="${not empty profilePicUrl && profilePicUrl ne ''}"><img src="<c:out value='${profilePicUrl}'/>" alt="User Profile"></c:when>
                    <c:otherwise><span class="placeholder-icon"><i class="fas fa-user-circle"></i></span></c:otherwise>
                </c:choose>
            </div>
            <div class="sidebar-username" style="display: block;"><c:out value="${currentUsername}"/></div>
        </c:if>
      </div>
      <div class="sidebar-nav">
          <ul>
            <%-- URLs generated dynamically with JSTL --%>
            <c:url var="indexPath" value="/index.jsp"/>
            <c:url var="dashboardServletPath" value="/DashboardServlet"/>
            <c:url var="dashboardMainJspPath" value="/jsp/dashboardMain.jsp"/>
            <c:url var="browseSkillsServletPath" value="/BrowseSkillsServlet"/>
            <c:url var="browseSkillsJspPath" value="/jsp/browse_skills.jsp"/>
            <c:url var="addSkillJspPath" value="/jsp/addSkill.jsp"/>
            <c:url var="swapServletPath" value="/SwapServlet"/>
            <c:url var="profileJspPath" value="/jsp/profile.jsp"/>
            <c:url var="aboutJspPath" value="/about.jsp"/>
            <c:url var="contactJspPath" value="/contact.jsp"/>
            <c:url var="settingsJspPath" value="/jsp/settings.jsp"/>
            <c:url var="helpJspPath" value="/jsp/help.jsp"/>
            <c:url var="loginJspPath" value="/login.jsp"/>
            <c:url var="registerJspPath" value="/register.jsp"/>

            <li><a href="${indexPath}" class="${pageContext.request.servletPath eq indexPath ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-home"></i></span> Home</a></li>
            <c:if test="${isUserLoggedIn}">
                <li><a href="${dashboardServletPath}" class="${pageContext.request.servletPath eq dashboardServletPath or pageContext.request.servletPath eq dashboardMainJspPath ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-tachometer-alt"></i></span> Dashboard</a></li>
                <li><a href="${browseSkillsServletPath}" class="${pageContext.request.servletPath eq browseSkillsServletPath or pageContext.request.servletPath eq browseSkillsJspPath ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-search"></i></span> Browse Skills</a></li>
                <li><a href="${addSkillJspPath}" class="${pageContext.request.servletPath eq addSkillJspPath ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-plus-circle"></i></span> Add/Manage My Skills</a></li>
                <li><a href="<c:url value='/SwapServlet?action=mySwaps'/>" class="${pageContext.request.servletPath eq swapServletPath and param.action eq 'mySwaps' ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-exchange-alt"></i></span> My Swaps</a></li>
                <li><a href="${profileJspPath}" class="${pageContext.request.servletPath eq profileJspPath ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-user-alt"></i></span> Profile</a></li>
            </c:if>
            <c:if test="${not isUserLoggedIn}">
                <li><a href="${loginJspPath}" class="${pageContext.request.servletPath eq loginJspPath ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-sign-in-alt"></i></span> Login</a></li>
                <li><a href="${registerJspPath}" class="${pageContext.request.servletPath eq registerJspPath ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-user-plus"></i></span> Register</a></li>
                <li><a href="${browseSkillsServletPath}" class="${pageContext.request.servletPath eq browseSkillsServletPath or pageContext.request.servletPath eq browseSkillsJspPath ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-search"></i></span> Browse Skills</a></li>
            </c:if>
            <li><a href="${aboutJspPath}" class="${pageContext.request.servletPath eq aboutJspPath ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-info-circle"></i></span> About</a></li>
            <%-- Mark Contact as active if coming from contact.jsp or help.jsp to submit concern --%>
            <li><a href="${contactJspPath}" class="${pageContext.request.servletPath eq contactJspPath or pageContext.request.servletPath eq '/jsp/concernForm.jsp' ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-envelope"></i></span> Contact</a></li>
            <li><a href="${settingsJspPath}" class="${pageContext.request.servletPath eq settingsJspPath ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-cog"></i></span> Settings</a></li>
            <li><a href="${helpJspPath}" class="${pageContext.request.servletPath eq helpJspPath or pageContext.request.servletPath eq '/jsp/concernForm.jsp' ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-headset"></i></span> Need Help?</a></li>
          </ul>
      </div>
      <div class="sidebar-footer">
        <c:choose>
            <c:when test="${isUserLoggedIn}">
                <a href="<c:url value='/LogoutServlet'/>" class="btn-logout">Logout</a>
            </c:when>
            <c:otherwise>
                <a href="<c:url value='/login.jsp'/>" class="btn-login">Login</a>
                <a href="<c:url value='/register.jsp'/>" class="btn-signup">Sign Up</a>
            </c:otherwise>
        </c:choose>
      </div>
    </nav>

    <div id="sidebarFadeOverlay" class="sidebar-fade-overlay"></div>
    <button class="sidebar-toggle-btn" id="sidebarToggle" aria-label="Toggle sidebar"><i class="fas fa-bars"></i></button>

    <div class="main-content-area concern-form-main" id="mainContent">
        <div class="concern-form-body-wrapper">
            <div class="concern-container">
                <div class="form-container">
                  <h2>Submit Your Concern</h2>

                  <c:if test="${not empty requestScope.formMessage}">
                      <div class="message-area ${requestScope.messageType == 'success' ? 'success' : 'error'}">
                          <c:out value="${requestScope.formMessage}"/>
                      </div>
                  </c:if>

                  <form action="<c:url value='/ConcernServlet'/>" method="POST">
                    <div class="form-group">
                      <label for="name">Your Name:</label>
                      <input type="text" id="name" name="name" placeholder="e.g., John Doe" value="<c:out value="${userNameValue}"/>" required>
                    </div>
                    <div class="form-group">
                      <label for="email">Your Email:</label>
                      <input type="email" id="email" name="email" placeholder="e.g., john@example.com" value="<c:out value="${userEmailValue}"/>" required>
                    </div>
                    <div class="form-group">
                      <label for="message">Concern / Message:</label>
                      <textarea id="message" name="message" placeholder="Describe your concern..." required></textarea>
                    </div>
                    <button type="submit">Send Message</button>
                  </form>
                </div>

                <div class="visual">
                  <div class="blob"></div>
                  <div class="blob"></div>
                  <div class="skill-card">
                    <h3>Skill Swap</h3>
                    <p>Share your skills, get help from others.<br/>Connect. Learn. Grow.</p>
                  </div>
                </div>
            </div>
        </div>
    </div>

    <script>
      // --- Standard JS for sidebar (FROM YOUR index.jsp) ---
      const sidebar = document.getElementById('sidebar');
      const toggleBtn = document.getElementById('sidebarToggle');
      const mainContent = document.getElementById('mainContent');
      const fadeOverlay = document.getElementById('sidebarFadeOverlay');
      const body = document.body; // No coverPage for this form

      document.addEventListener('DOMContentLoaded', () => {
        if (toggleBtn && sidebar && mainContent && fadeOverlay) {
            // ... (exact same sidebar toggle JS as in index.jsp and contact.jsp) ...
            toggleBtn.addEventListener('click', () => {
                const isOpen = sidebar.classList.toggle('open');
                fadeOverlay.classList.toggle('visible', isOpen);
                mainContent.classList.toggle('dimmed', isOpen);
                if (window.innerWidth > 992) {
                    mainContent.classList.toggle('sidebar-open-push', isOpen);
                    toggleBtn.classList.toggle('shifted', isOpen);
                } else {
                    mainContent.classList.remove('sidebar-open-push');
                    toggleBtn.classList.remove('shifted');
                    body.style.overflow = isOpen ? 'hidden' : '';
                }
            });
            fadeOverlay.addEventListener('click', () => {
                sidebar.classList.remove('open');
                fadeOverlay.classList.remove('visible');
                mainContent.classList.remove('dimmed');
                if (window.innerWidth > 992) {
                    mainContent.classList.remove('sidebar-open-push');
                    toggleBtn.classList.remove('shifted');
                }
                 body.style.overflow = '';
            });
            window.addEventListener('resize', () => {
                if (window.innerWidth > 992) {
                    if (sidebar.classList.contains('open')) {
                        mainContent.classList.add('sidebar-open-push');
                        toggleBtn.classList.add('shifted');
                        fadeOverlay.classList.remove('visible');
                        mainContent.classList.remove('dimmed');
                    } else {
                        mainContent.classList.remove('sidebar-open-push');
                        toggleBtn.classList.remove('shifted');
                    }
                     body.style.overflow = '';
                } else {
                    mainContent.classList.remove('sidebar-open-push');
                    toggleBtn.classList.remove('shifted');
                    if (sidebar.classList.contains('open')) {
                        fadeOverlay.classList.add('visible');
                        mainContent.classList.add('dimmed');
                        body.style.overflow = 'hidden';
                    } else {
                        fadeOverlay.classList.remove('visible');
                        mainContent.classList.remove('dimmed');
                        body.style.overflow = '';
                    }
                }
            });
            window.dispatchEvent(new Event('resize'));
        }
        // No cover page fade out for this form
      });
    </script>
</body>
</html>