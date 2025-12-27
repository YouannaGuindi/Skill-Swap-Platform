<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ProjAdvAndWeb.model.User" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- Removed fn taglib as it's not used in this simplified version --%>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    pageContext.setAttribute("isUserLoggedIn", loggedInUser != null);
    if (loggedInUser != null) {
        pageContext.setAttribute("currentUsername", loggedInUser.getFirstName());
        // Example for profile picture URL, adapt as needed from your User model
        // pageContext.setAttribute("profilePicUrl", loggedInUser.getProfilePicPath() != null ? request.getContextPath() + "/" + loggedInUser.getProfilePicPath() : "");
        pageContext.setAttribute("profilePicUrl", ""); // Default placeholder
    } else {
        pageContext.setAttribute("currentUsername", "Guest");
        pageContext.setAttribute("profilePicUrl", "");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>SkillSwap - Welcome!</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
      /* --- Styles from original index.jsp --- */
      *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
      body { font-family: 'Poppins', sans-serif; background-color: #f4f7f6; color: #333; overflow-x: hidden; line-height: 1.6; }
      
      /* --- COMMON SIDEBAR CSS (Derived from index.jsp/about.jsp) --- */
      .app-sidebar { position: fixed; top: 0; left: -260px; width: 260px; height: 100vh; background:#002366; color: white; padding: 20px; box-sizing: border-box; transition: left 0.3s cubic-bezier(0.25, 0.8, 0.25, 1); z-index: 1000; display: flex; flex-direction: column; box-shadow: 5px 0 25px rgba(0, 0, 0, 0.15); }
      .app-sidebar.open { left: 0; }
      .sidebar-header { text-align: center; margin-bottom: 25px; padding-bottom: 20px; border-bottom: 1px solid rgba(255,255,255,0.15); }
      .app-sidebar .logo-main { font-size: 2.2em; font-weight: 700; color: #03dac6; letter-spacing: 1px; margin-bottom: 10px; display: block; }
      .app-sidebar .logo-tagline { font-size: 0.9em; color: rgba(255,255,255,0.8); }
      .profile-picture-container { width: 90px; height: 90px; border-radius: 50%; overflow: hidden; margin: 0 auto 15px auto; border: 3px solid #03dac6; background-color: rgba(255,255,255,0.2); display: flex; justify-content: center; align-items: center; }
      .profile-picture-container img { width: 100%; height: 100%; object-fit: cover; }
      .profile-picture-container .placeholder-icon { font-size: 3em; color: rgba(255,255,255,0.7); }
      .sidebar-username { font-size: 1.1em; font-weight: 500; color: rgba(255,255,255,0.9); margin-top: 5px; }
      /* ... other styles ... */
      .sidebar-nav {flex-grow: 1;margin-top: 10px;overflow-y: auto;padding-right: 2px;scrollbar-width: thin; scrollbar-color: rgba(255, 255, 255, 0.2) transparent; /* For Firefox */}

      .sidebar-nav::-webkit-scrollbar {width: 5px;}
      .sidebar-nav::-webkit-scrollbar-track {background: transparent;}
      .sidebar-nav::-webkit-scrollbar-thumb {background-color: rgba(255, 255, 255, 0.2);border-radius: 10px;}
      .sidebar-nav::-webkit-scrollbar-thumb:hover {background-color: rgba(255, 255, 255, 0.4);}
/* ... other styles ... */
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
      
      /* Cover Page */
      #coverPage { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: linear-gradient(135deg, #0953dc, #03dac6); display: flex; flex-direction: column; justify-content: center; align-items: center; color: white; font-family: 'Poppins', sans-serif; font-size: 2.8em; font-weight: 700; z-index: 2000; opacity: 1; transition: opacity 1.2s ease-out, visibility 1.2s ease-out; text-align: center; padding: 20px; }
      #coverPage .subtitle { font-size: 0.5em; font-weight: 400; margin-top: 15px; opacity: 0.9; }
      #coverPage.fade-out { opacity: 0; visibility: hidden; pointer-events: none; }
      body.cover-active { overflow: hidden; }

      /* --- Remaining page-specific styles from original index.jsp --- */
      .main-header { margin-bottom: 30px; padding-bottom: 20px; border-bottom: 1px solid #e0e0e0; text-align: center; }
      .main-header .main-title { font-size: 2.4em; font-weight: 600; color:  #002366; margin-bottom: 8px; }
      .main-header .site-tagline { font-size: 1.3em; font-weight: 400; color: #555; }
      #welcomeMessage { font-size: 2.2em; font-weight: 600; color:  #4169E1; margin-bottom: 5px; }
      #welcomeMessage .username { font-weight: 700; color: #03dac6; }
      #welcomeMessage + .site-tagline { font-size: 1.2em; }
      .hero-image-section { position: relative; margin-bottom: 40px; border-radius: 8px; overflow: hidden; background: white; box-shadow: 0 5px 15px rgba(0,0,0,0.07); }
      .hero-image-section img { width: 100%; display: block; max-height: 350px; object-fit: cover; border-radius: 8px 8px 0 0; }
      .hero-overlay-content { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); color: #fff; max-width: 90%; width: 600px; text-shadow: 0 2px 8px rgba(0,0,0,0.7); text-align: center; padding: 20px; box-sizing: border-box; }
      .hero-overlay-content h1 { font-size: 2.5em; margin-bottom: 15px; }
      .hero-overlay-content p { font-size: 1.1em; margin-bottom: 20px; }
      .hero-cta-buttons a { display: inline-block; padding: 12px 25px; border-radius: 5px; text-decoration: none; font-weight: 700; margin: 5px; transition: background 0.3s ease, transform 0.2s ease; }
      .hero-cta-buttons a:hover { transform: translateY(-2px); }
      .btn-primary { background:  #4169E1; color: white; }
      .btn-primary:hover { background: #002366; }
      .btn-secondary { background: #70fffa; color: #000; }
      .btn-secondary:hover { background: #40e0d0; color: #000; }
      .guest-browse-link { margin-top: 15px; font-size: 1em; color: white; text-shadow: 0 1px 3px rgba(0,0,0,0.8); }
      .guest-browse-link a { color: #70fffa; font-weight: 700; text-decoration: underline; }
      .content-grid-logged-out { display: flex; flex-wrap: wrap; gap: 25px; justify-content: center; margin-bottom: 30px; }
      .feature-highlight-column { flex: 1 1 300px; min-width: 280px; max-width: 450px; background: #ffffff; border-radius: 10px; padding: 25px; box-shadow: 0 5px 15px rgba(0, 0, 0, 0.07); }
      .feature-highlight-column h2 { font-size: 1.8em; font-weight: 600; color:  #4169E1; margin-top: 0; margin-bottom: 25px; text-align: left; }
      .feature-highlight-column .card { background: #f9f9f9; border-radius: 8px; padding: 20px; margin-bottom: 20px; box-shadow: inset 0 0 5px rgba(0,0,0,0.03); text-align: left; }
      .feature-highlight-column .card:last-child { margin-bottom: 0; }
      .feature-highlight-column .card h3 { font-size: 1.3em; font-weight: 600; color: #333333; margin-top: 0; margin-bottom: 10px; }
      .feature-highlight-column .card p { font-size: 0.95em; color: #555555; line-height: 1.6; }
      .dashboard-panel { background-color: #ffffff; border-radius: 12px; padding: 30px; box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08), 0 1px 3px rgba(0,0,0,0.05); margin-bottom: 30px; }
      .quick-stats { display: flex; justify-content: space-around; background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%); color: white; padding: 30px; border-radius: 10px; box-shadow: 0 5px 20px rgba(0,0,0,0.1); margin-bottom: 30px; }
      .stat-item { text-align: center; flex-basis: 0; flex-grow:1; padding: 0 10px;}
      .stat-item .stat-number { font-size: 2.2em; font-weight: 700; display: block; margin-bottom: 5px; }
      .stat-item .stat-label { font-size: 0.9em; opacity: 0.9; }
      .content-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 25px; }
      .dashboard-card { background: white; border-radius: 10px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.07); transition: transform 0.25s ease, box-shadow 0.25s ease; display: flex; flex-direction: column; text-align: center; }
      .dashboard-card:hover { transform: translateY(-5px); box-shadow: 0 8px 25px rgba(0,0,0,0.1); }
      .card-icon { font-size: 2.8em; color: #6200ee; margin-bottom: 15px; height: 50px; display: flex; align-items: center; justify-content: center; }
      .dashboard-card h3 { font-size: 1.5em; font-weight: 600; color: #333; margin-bottom: 10px; }
      .dashboard-card p { font-size: 1em; color: #555; flex-grow: 1; margin-bottom: 20px; line-height: 1.5; }
      .dashboard-card .btn-card-action, .dashboard-card .btn-card-primary { display: inline-block; padding: 12px 28px; text-decoration: none; border-radius: 25px; font-weight: 600; transition: background 0.2s ease, transform 0.2s ease; align-self: center; font-size: 1em; border: none; cursor: pointer; min-width: 150px; }
      .dashboard-card .btn-card-action:hover, .dashboard-card .btn-card-primary:hover { transform: translateY(-2px); }
      .dashboard-card .btn-card-primary { background: #6200ee; color: white; }
      .dashboard-card .btn-card-primary:hover { background: #4e00c0;}
      .dashboard-card .btn-card-action { background: #03dac6; color: #1a1a2e; }
      .dashboard-card .btn-card-action:hover { background: #02bfae; }
      .dashboard-card .btn-card-primary + .btn-card-action { margin-top: 10px; }
      @media (max-width: 992px) { .main-content-area.sidebar-open-push { margin-left: 0; } .sidebar-toggle-btn.shifted { left: 20px; } .content-grid-logged-out {flex-direction: column; align-items: center;} .feature-highlight-column{max-width: 90%;} }
      @media (max-width: 768px) { .main-header .main-title { font-size: 2em; } #welcomeMessage {font-size: 1.8em;} .main-header .site-tagline, #welcomeMessage + .site-tagline { font-size: 1.1em; } .dashboard-panel { padding: 20px; } .quick-stats { flex-direction: column; gap: 20px; } .hero-overlay-content h1 {font-size: 2em;} .hero-overlay-content p {font-size: 1em;} }
      @media (max-width: 480px) { .app-sidebar { width: 240px; left: -240px; } .main-content-area { padding: 20px; } #coverPage { font-size: 2.2em; } .profile-picture-container { width: 70px; height: 70px;} .app-sidebar .logo-main { font-size: 1.8em; } .main-header .main-title { font-size: 1.8em; } #welcomeMessage {font-size: 1.6em;} .dashboard-panel { padding: 15px; border-radius: 8px; } .quick-stats { padding: 20px; } .dashboard-card h3 {font-size: 1.3em;} .dashboard-card p {font-size: 0.9em;} .dashboard-card .btn-card-action, .dashboard-card .btn-card-primary {padding: 10px 20px;} .hero-overlay-content h1 {font-size: 1.8em;} }
    </style>
</head>
<body class="cover-active"> <%-- Add cover-active if you want the initial fade effect --%>

    <div id="coverPage">SkillSwap<div class="subtitle">Connecting Skills, Sharing Knowledge</div></div>

    <%-- ===== MASTER SIDEBAR HTML (Paste the master sidebar HTML here) ===== --%>
    <nav class="app-sidebar" id="sidebar">
      <div class="sidebar-header">
        <span class="logo-main">SkillSwap</span>
        <c:if test="${not isUserLoggedIn}">
            <span class="logo-tagline">Connect & Grow</span>
        </c:if>
        <c:if test="${isUserLoggedIn}">
            <div class="profile-picture-container" style="display: flex;">
                <c:choose>
                    <c:when test="${not empty profilePicUrl && profilePicUrl ne ''}">
                        <img src="<c:out value='${profilePicUrl}'/>" alt="User Profile Picture">
                    </c:when>
                    <c:otherwise>
                        <span class="placeholder-icon"><i class="fas fa-user-circle"></i></span>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="sidebar-username" style="display: block;"><c:out value="${currentUsername}"/></div>
        </c:if>
      </div>
      <div class="sidebar-nav">
          <ul id="sidebarNavItems">
            <c:url var="url_index" value="/index.jsp"/>
            <c:url var="url_about" value="/about.jsp"/>
            <c:url var="url_contact" value="/contact.jsp"/>
            <c:url var="url_help" value="/jsp/help.jsp"/>
            <c:url var="url_browse_skills" value="/BrowseSkillsServlet"/>
            <c:url var="url_login" value="/login.jsp"/>
            <c:url var="url_register" value="/register.jsp"/>
            <c:set var="currentPage" value="${pageContext.request.servletPath}"/>

            <li><a href="${url_index}" class="${currentPage eq '/index.jsp' ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-home"></i></span> Home</a></li>
            <c:if test="${isUserLoggedIn}">
                <c:url var="url_dashboard" value="/DashboardServlet"/>
                <c:url var="url_add_skill" value="/jsp/addSkill.jsp"/>
                <c:url var="url_my_swaps" value="/SwapServlet?action=mySwaps"/>
                <c:url var="url_profile" value="/jsp/profile.jsp"/>
                <li><a href="${url_dashboard}" class="${(currentPage eq '/DashboardServlet' or currentPage eq '/actualDashboard.jsp') ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-tachometer-alt"></i></span> Dashboard</a></li>
                <li><a href="${url_browse_skills}" class="${(currentPage eq '/BrowseSkillsServlet' or currentPage eq '/browseSkills.jsp') ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-search"></i></span> Browse Skills</a></li>
                <li><a href="${url_add_skill}" class="${currentPage eq '/jsp/addSkill.jsp' ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-plus-circle"></i></span> Add/Manage Skills</a></li>
                <li><a href="${url_my_swaps}" class="${currentPage eq '/SwapServlet' and param.action eq 'mySwaps' ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-exchange-alt"></i></span> My Swaps</a></li>
                <li><a href="${url_profile}" class="${currentPage eq '/jsp/profile.jsp' ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-user-alt"></i></span> Profile</a></li>
            </c:if>
            <c:if test="${not isUserLoggedIn}">
                <c:if test="${currentPage ne '/login.jsp'}">
                    <li><a href="${url_login}" class="${currentPage eq '/login.jsp' ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-sign-in-alt"></i></span> Login</a></li>
                </c:if>
                <c:if test="${currentPage ne '/register.jsp'}">
                     <li><a href="${url_register}" class="${currentPage eq '/register.jsp' ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-user-plus"></i></span> Register</a></li>
                </c:if>
                <li><a href="${url_browse_skills}" class="${(currentPage eq '/BrowseSkillsServlet' or currentPage eq '/browseSkills.jsp') ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-search"></i></span> Browse Skills</a></li>
            </c:if>
            <li><a href="${url_about}" class="${currentPage eq '/about.jsp' ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-info-circle"></i></span> About</a></li>
            <li><a href="${url_contact}" class="${(currentPage eq '/contact.jsp' or currentPage eq '/jsp/contact.jsp' or currentPage eq '/jsp/concernForm.jsp') ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-envelope"></i></span> Contact</a></li>
            
          </ul>
      </div>
      <div class="sidebar-footer">
        <c:choose>
            <c:when test="${isUserLoggedIn}">
                <c:url var="url_logout" value="/LogoutServlet"/>
                <a href="${url_logout}" class="btn-logout">Logout</a>
            </c:when>
            <c:otherwise>
                <c:if test="${currentPage ne '/login.jsp' and currentPage ne '/register.jsp'}">
                    <a href="${url_login}" class="btn-login">Login</a>
                    <a href="${url_register}" class="btn-signup">Sign Up</a>
                </c:if>
                <c:if test="${currentPage eq '/login.jsp' or currentPage eq '/register.jsp'}">
                     <a href="${url_index}" class="btn-login" style="background: transparent; border: 1px solid #03dac6; color: #03dac6; width: calc(100% - 20px); margin-left:10px; margin-right:10px;">Back to Home</a>
                </c:if>
            </c:otherwise>
        </c:choose>
      </div>
    </nav>
    <%-- ===== END MASTER SIDEBAR HTML ===== --%>

    <div id="sidebarFadeOverlay" class="sidebar-fade-overlay"></div>
    <button class="sidebar-toggle-btn" id="sidebarToggle" aria-label="Toggle sidebar"><i class="fas fa-bars"></i></button>

    <div class="main-content-area" id="mainContent">
      <header class="main-header">
        <c:choose>
            <c:when test="${isUserLoggedIn}">
                 <h2 id="welcomeMessage" style="display: block;">Welcome back, <span class="username"><c:out value="${currentUsername}"/></span>!</h2>
                 <p class="site-tagline">Ready to explore and share your skills? <a href="<c:url value='/DashboardServlet'/>">Go to your Dashboard</a>.</p>
            </c:when>
            <c:otherwise>
                <h1 class="main-title" style="display: block;">Welcome to SkillSwap!</h1>
                <p class="site-tagline" style="display: block;">Connect, learn, and share your skills effortlessly.</p>
            </c:otherwise>
        </c:choose>
      </header>

      <c:if test="${not isUserLoggedIn}">
          <section class="hero-image-section" id="heroSection" style="display: block;">
            <img src="https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=1170&q=80" alt="Skills sharing" />
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

      <div class="dashboard-panel" id="mainDashboardPanel_IndexPage" style="display: block;">
          <div class="content-grid">
              <c:choose>
                  <c:when test="${isUserLoggedIn}">
                      <div class="dashboard-card">
                          <div class="card-icon"><i class="fas fa-tachometer-alt"></i></div>
                          <h3>My Dashboard</h3>
                          <p>View your stats, manage skills, and track exchanges.</p>
                          <a href="<c:url value='/DashboardServlet'/>" class="btn-card-primary">Go to Dashboard</a>
                      </div>
                      <div class="dashboard-card">
                          <div class="card-icon"><i class="fas fa-search"></i></div>
                          <h3>Browse Skills</h3>
                          <p>Explore skills offered by other members of the community.</p>
                          <a href="<c:url value='/BrowseSkillsServlet'/>" class="btn-card-action">Start Browsing</a>
                      </div>
                  </c:when>
                  <c:otherwise>
                      <div class="dashboard-card">
                        <div class="card-icon"><i class="fas fa-door-open"></i></div>
                        <h3>Get Started</h3>
                        <p>New to SkillSwap? Create an account to start your journey or log in if you're returning.</p>
                        <a href="<c:url value='/register.jsp'/>" class="btn-card-action btn-card-primary">Register Now</a>
                        <a href="<c:url value='/login.jsp'/>" class="btn-card-action" style="margin-top: 10px;">Login</a>
                      </div>
                      <div class="dashboard-card">
                        <div class="card-icon"><i class="fas fa-info-circle"></i></div>
                        <h3>About SkillSwap</h3>
                        <p>Learn more about our mission, how SkillSwap works, and what makes our community special.</p>
                        <a href="<c:url value='/about.jsp'/>" class="btn-card-action">Discover More</a>
                      </div>
                  </c:otherwise>
              </c:choose>
          </div>
      </div>

      <div class="content-grid-logged-out" style="display: flex;">
          <div class="feature-highlight-column">
            <h2>Why SkillSwap?</h2>
            <div class="card"> <h3>Easy to Connect</h3> <p>Find people nearby who want to learn and teach skills.</p> </div>
            <div class="card"> <h3>Build Your Profile</h3> <p>Create a skill portfolio and track your learning journey.</p> </div>
            <div class="card"> <h3>Safe and Secure</h3> <p>Our platform ensures privacy and secure communication.</p> </div>
          </div>
           <div class="feature-highlight-column">
            <h2>How It Works</h2>
            <div class="card"> <h3>1. Sign Up</h3> <p>Create your free account in minutes.</p> </div>
            <div class="card"> <h3>2. List Your Skills</h3> <p>Offer what you can teach and list what you want to learn.</p> </div>
            <div class="card"> <h3>3. Swap!</h3> <p>Connect with others and start your skill exchange.</p> </div>
          </div>
      </div>

    </div>

    <%-- ===== COMMON JAVASCRIPT (Paste the common JS snippet here) ===== --%>
    <script>
      // --- Standard JS for sidebar, cover page etc. ---
      const sidebar = document.getElementById('sidebar');
      const toggleBtn = document.getElementById('sidebarToggle');
      const mainContent = document.getElementById('mainContent'); 
      const fadeOverlay = document.getElementById('sidebarFadeOverlay');
      const coverPage = document.getElementById('coverPage'); 
      const body = document.body;

      document.addEventListener('DOMContentLoaded', () => {
        if (toggleBtn && sidebar && fadeOverlay) { 
          toggleBtn.addEventListener('click', () => {
            const isOpen = sidebar.classList.toggle('open');
            fadeOverlay.classList.toggle('visible', isOpen);
            if (mainContent) mainContent.classList.toggle('dimmed', isOpen);

            if (window.innerWidth > 992) {
              if (mainContent) mainContent.classList.toggle('sidebar-open-push', isOpen);
              toggleBtn.classList.toggle('shifted', isOpen);
            } else {
              if (mainContent) mainContent.classList.remove('sidebar-open-push');
              toggleBtn.classList.remove('shifted');
              body.style.overflow = isOpen ? 'hidden' : '';
            }
          });
          fadeOverlay.addEventListener('click', () => {
            sidebar.classList.remove('open');
            fadeOverlay.classList.remove('visible');
            if (mainContent) mainContent.classList.remove('dimmed');
            if (window.innerWidth > 992) {
              if (mainContent) mainContent.classList.remove('sidebar-open-push');
              toggleBtn.classList.remove('shifted');
            }
            body.style.overflow = '';
          });
           window.addEventListener('resize', () => {
                if (window.innerWidth > 992) { 
                    if (sidebar.classList.contains('open')) {
                        if (mainContent) mainContent.classList.add('sidebar-open-push');
                        toggleBtn.classList.add('shifted');
                        fadeOverlay.classList.remove('visible');
                        if (mainContent) mainContent.classList.remove('dimmed');
                    } else {
                        if (mainContent) mainContent.classList.remove('sidebar-open-push');
                        toggleBtn.classList.remove('shifted');
                    }
                     body.style.overflow = '';
                } else { 
                    if (mainContent) mainContent.classList.remove('sidebar-open-push');
                    toggleBtn.classList.remove('shifted');
                    if (sidebar.classList.contains('open')) {
                        fadeOverlay.classList.add('visible');
                        if (mainContent) mainContent.classList.add('dimmed');
                        body.style.overflow = 'hidden';
                    } else {
                        fadeOverlay.classList.remove('visible');
                        if (mainContent) mainContent.classList.remove('dimmed');
                        body.style.overflow = '';
                    }
                }
            });
            window.dispatchEvent(new Event('resize'));
        }
        const hasCoverPage = body.classList.contains('cover-active');
        if (coverPage && hasCoverPage) {
          setTimeout(() => {
            coverPage.classList.add('fade-out');
            body.classList.remove('cover-active');
          }, 1500);
        } else if (coverPage) { 
            coverPage.style.display = 'none';
        }
      });
    </script>
</body>
</html>