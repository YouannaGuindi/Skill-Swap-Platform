<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ProjAdvAndWeb.model.User" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    User loggedInUser = (User) session.getAttribute("loggedInUser");
    pageContext.setAttribute("isUserLoggedIn", loggedInUser != null);
    if (loggedInUser != null) {
        pageContext.setAttribute("currentUsername", loggedInUser.getFirstName());
        // pageContext.setAttribute("profilePicUrl", loggedInUser.getProfilePicPath()); // Example
    } else {
        pageContext.setAttribute("currentUsername", "Guest");
    }
    pageContext.setAttribute("profilePicUrl", ""); // Placeholder, replace with actual logic
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>About SkillSwap - Connect, Learn, Share, Grow</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
      /* --- PASTE YOUR FULL CSS FROM THE PROVIDED ABOUT US PAGE HTML HERE --- */
      /* --- Global Resets & Base Styles --- */
      *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
      body { font-family: 'Poppins', sans-serif; background-color: #f4f7f6; color: #333; overflow-x: hidden; line-height: 1.6; }
      #coverPage { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: linear-gradient(135deg, #002366, #03dac6); display: flex; flex-direction: column; justify-content: center; align-items: center; color: white; font-family: 'Poppins', sans-serif; font-size: 2.8em; font-weight: 700; z-index: 2000; opacity: 1; transition: opacity 1.2s ease-out, visibility 1.2s ease-out; text-align: center; padding: 20px; }
      #coverPage .subtitle { font-size: 0.5em; font-weight: 400; margin-top: 15px; opacity: 0.9; }
      #coverPage.fade-out { opacity: 0; visibility: hidden; pointer-events: none; }
      body.cover-active { overflow: hidden; }
      .app-sidebar { position: fixed; top: 0; left: -260px; width: 260px; height: 100vh; background:#002366; color: white; padding: 20px; box-sizing: border-box; transition: left 0.3s cubic-bezier(0.25, 0.8, 0.25, 1); z-index: 1000; display: flex; flex-direction: column; box-shadow: 5px 0 25px rgba(0, 0, 0, 0.15); }
      .app-sidebar.open { left: 0; }
      .sidebar-header { text-align: center; margin-bottom: 25px; padding-bottom: 20px; border-bottom: 1px solid rgba(255,255,255,0.15); }
      .app-sidebar .logo-main { font-size: 2.2em; font-weight: 700; color: #03dac6; letter-spacing: 1px; margin-bottom: 10px; display: block; }
      .app-sidebar .logo-tagline { font-size: 0.9em; color: rgba(255,255,255,0.8); }
      .profile-picture-container { width: 90px; height: 90px; border-radius: 50%; overflow: hidden; margin: 0 auto 15px auto; border: 3px solid #03dac6; background-color: rgba(255,255,255,0.2); /*display: none;*/ /* Controlled by JSTL now */ display: flex; justify-content: center; align-items: center; }
      .profile-picture-container img { width: 100%; height: 100%; object-fit: cover; }
      .profile-picture-container .placeholder-icon { font-size: 3em; color: rgba(255,255,255,0.7); }
      .sidebar-username { font-size: 1.1em; font-weight: 500; color: rgba(255,255,255,0.9); margin-top: 5px; /*display: none;*/ /* Controlled by JSTL */ }
      
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
      .main-content-area { margin-left: 0; padding: 30px; transition: margin-left 0.3s cubic-bezier(0.25, 0.8, 0.25, 1), filter 0.3s ease; position: relative; z-index: 1; }
      .main-content-area.sidebar-open-push { margin-left: 260px; }
      .main-content-area.dimmed { filter: brightness(0.7) blur(2px); pointer-events: none; }
      .sidebar-toggle-btn { position: fixed; top: 20px; left: 20px; background:  #4169E1; border: none; color: white; font-size: 22px; padding: 10px 14px; cursor: pointer; border-radius: 8px; z-index: 1100; transition: background 0.3s ease, left 0.3s cubic-bezier(0.25, 0.8, 0.25, 1); box-shadow: 0 2px 5px rgba(0,0,0,0.15); }
      .sidebar-toggle-btn:hover { background: #002366; }
      .sidebar-toggle-btn.shifted { left: 280px; }
      .sidebar-fade-overlay { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.5); opacity: 0; visibility: hidden; transition: opacity 0.3s ease, visibility 0s 0.3s; z-index: 999; }
      .sidebar-fade-overlay.visible { opacity: 1; visibility: visible; transition: opacity 0.3s ease; }
      .main-header { margin-bottom: 30px; border-bottom: 1px solid #e0e0e0; text-align: center; }
      .title-banner-container { background: linear-gradient(135deg, #4169E1, #357ABD); color: white; border-radius: 12px; padding: 40px 20px; margin-bottom: 25px; text-align: center; box-shadow: 0 8px 20px rgba(53, 122, 189, 0.3); font-weight: 600; letter-spacing: 0.02em; position: relative; overflow: hidden; opacity: 0; transform: translateY(-20px); animation: popInBannerSmooth 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94) 1.7s forwards; }
      @keyframes popInBannerSmooth { to { opacity: 1; transform: translateY(0); } }
      .title-banner-container::before { content: ""; position: absolute; top: -50%; left: -50%; width: 200%; height: 200%; background: rgba(255, 255, 255, 0.1); transform: rotate(25deg); pointer-events: none; border-radius: 50%; animation: shine 6s linear infinite 2.0s; }
      @keyframes shine { 0% { transform: rotate(25deg) translateX(-120%); } 100% { transform: rotate(25deg) translateX(120%); } }
      .title-banner-container .main-title { font-size: 2.8em; font-weight: 700; color: white !important; margin: 0; line-height: 1.2; text-shadow: 0 2px 5px rgba(0,0,0,0.15); }
      .main-header .site-tagline { font-size: 1.3em; font-weight: 400; color: #555; margin-bottom: 15px; padding-bottom: 20px; }
      #welcomeMessage { display: none; }
      .content-panel { background-color: #ffffff; border-radius: 12px; padding: 30px 40px; box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08), 0 1px 3px rgba(0,0,0,0.05); margin-bottom: 30px; }
      .about-section { text-align: left; line-height: 1.8; }
      .about-section .intro-paragraph { font-size: 1.2em; font-weight: 400; color: #444; margin-bottom: 35px; padding: 20px; background-color: #f8f9fa; border-left: 5px solid #4169E1; border-radius: 0 8px 8px 0; }
      .about-section h3 { font-size: 1.9em; font-weight: 600; color: #003366; margin-top: 40px; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 2px solid #eef2f5; display: flex; align-items: center; }
      .about-section h3 .fas { margin-right: 12px; color: #4169E1; font-size: 0.8em; }
      .about-section p, .about-section ul { margin-bottom: 20px; font-size: 1.05em; color: #555; }
      .about-section ul { list-style: none; padding-left: 0; }
      .about-section ul li { padding-left: 25px; position: relative; margin-bottom: 12px; }
      .about-section ul li::before { content: '\f00c'; font-family: 'Font Awesome 6 Free'; font-weight: 900; position: absolute; left: 0; top: 2px; color: #03dac6; font-size: 0.9em; }
      .about-section .how-it-works ol { list-style: none; counter-reset: how-it-works-counter; padding-left: 0; }
      .about-section .how-it-works ol li { counter-increment: how-it-works-counter; margin-bottom: 15px; padding-left: 45px; position: relative; font-size: 1.1em; }
      .about-section .how-it-works ol li::before { content: counter(how-it-works-counter); position: absolute; left: 0; top: -2px; width: 30px; height: 30px; background-color: #4169E1; color: white; font-weight: 600; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 0.9em; }
      .about-section .how-it-works ol li strong { display: block; font-weight: 600; color: #333; margin-bottom: 3px; }
      .about-cta-buttons { text-align: center; margin-top: 40px; }
      .about-cta-buttons .btn-about { display: inline-block; padding: 14px 30px; border-radius: 25px; text-decoration: none; font-weight: 600; margin: 10px; transition: background 0.3s ease, transform 0.2s ease, box-shadow 0.3s ease; font-size: 1.1em; min-width: 200px; }
      .about-cta-buttons .btn-about:hover { transform: translateY(-3px); }
      .btn-about.primary { background: #4169E1; color: white; box-shadow: 0 4px 15px rgba(65, 105, 225, 0.3); }
      .btn-about.primary:hover { background: #3558b8; box-shadow: 0 6px 20px rgba(65, 105, 225, 0.4); }
      .btn-about.secondary { background: #03dac6; color: #1a1a2e; box-shadow: 0 4px 15px rgba(3, 218, 198, 0.3); }
      .btn-about.secondary:hover { background: #02bfae; box-shadow: 0 6px 20px rgba(3, 218, 198, 0.4); }
      @media (max-width: 992px) { .main-content-area.sidebar-open-push { margin-left: 0; } .sidebar-toggle-btn.shifted { left: 20px; } }
      @media (max-width: 768px) { .title-banner-container .main-title { font-size: 2.2em; } .main-header .site-tagline { font-size: 1.1em; } .content-panel { padding: 25px; } .about-section h3 { font-size: 1.7em; } .about-section .intro-paragraph { font-size: 1.1em; padding: 15px; } .about-cta-buttons .btn-about { padding: 12px 25px; font-size: 1em; } }
      @media (max-width: 480px) { .app-sidebar { width: 240px; left: -240px; } .main-content-area { padding: 20px; } #coverPage { font-size: 2.2em; } .title-banner-container .main-title { font-size: 1.9em; } .content-panel { padding: 20px 15px; } .about-section h3 { font-size: 1.5em; } .about-section .how-it-works ol li { padding-left: 40px; } .about-section .how-it-works ol li::before { width: 25px; height: 25px; font-size: 0.8em; top: 0;} .about-cta-buttons .btn-about { display: block; width: 100%; margin: 10px 0; } }
    </style>
</head>
<body class="cover-active">

    <div id="coverPage">SkillSwap<div class="subtitle">Connecting Skills, Sharing Knowledge</div></div>

    <nav class="app-sidebar" id="sidebar">
      <div class="sidebar-header">
        <span class="logo-main">SkillSwap</span>
        <c:if test="${not isUserLoggedIn}">
            <span class="logo-tagline">Connect & Grow</span>
        </c:if>
        <c:if test="${isUserLoggedIn}">
            <div class="profile-picture-container" style="display: flex;"> <%-- Always display container if logged in --%>
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
            <li><a href="<c:url value='/index.jsp'/>"><span class="nav-icon"><i class="fas fa-home"></i></span> Home</a></li>
            <c:if test="${isUserLoggedIn}">
                <li><a href="<c:url value='/DashboardServlet'/>"><span class="nav-icon"><i class="fas fa-tachometer-alt"></i></span> Dashboard</a></li>
                <li><a href="<c:url value='/BrowseSkillsServlet'/>"><span class="nav-icon"><i class="fas fa-search"></i></span> Browse</a></li>
                <li><a href="<c:url value='/jsp/addSkill.jsp'/>"><span class="nav-icon"><i class="fas fa-plus-circle"></i></span> Add Skill</a></li>
                <li><a href="<c:url value='/SwapServlet?action=mySwaps'/>"><span class="nav-icon"><i class="fas fa-exchange-alt"></i></span> My Swaps</a></li>
                <li><a href="<c:url value='/jsp/profile.jsp'/>"><span class="nav-icon"><i class="fas fa-user-alt"></i></span> Profile</a></li>
            </c:if>
            <c:if test="${not isUserLoggedIn}">
                <li><a href="<c:url value='/login.jsp'/>"><span class="nav-icon"><i class="fas fa-sign-in-alt"></i></span> Login</a></li>
                <li><a href="<c:url value='/register.jsp'/>"><span class="nav-icon"><i class="fas fa-user-plus"></i></span> Register</a></li>
            </c:if>
            <li><a href="<c:url value='/jsp/about.jsp'/>" class="active"><span class="nav-icon"><i class="fas fa-info-circle"></i></span> About Us</a></li>
            <li><a href="<c:url value='/jsp/help.jsp'/>"><span class="nav-icon"><i class="fas fa-headset"></i></span> Need Help?</a></li>
            <li><a href="<c:url value='/jsp/contact.jsp'/>"><span class="nav-icon"><i class="fas fa-envelope"></i></span> Contact</a></li>
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

    <div class="main-content-area" id="mainContent">
      <header class="main-header" id="mainPageHeader">
        <div class="title-banner-container">
          <h1 class="main-title">About SkillSwap</h1>
        </div>
        <p class="site-tagline">Connect, Learn, Share, Grow - Discover Our Story.</p>
      </header>

      <div class="content-panel" id="aboutPageContent">
        <section class="about-section">
            <p class="intro-paragraph">
                Welcome to SkillSwap, the place where knowledge meets opportunity, and passion finds a new purpose!
                We're thrilled to have you here and excited to tell you more about our community and what we stand for.
            </p>

            <h3><i class="fas fa-lightbulb"></i> What is SkillSwap?</h3>
            <p>
                At SkillSwap, we believe everyone has something valuable to teach and something new they’re eager to learn.
                We are a vibrant online platform designed to connect individuals who want to exchange skills and
                knowledge directly with one another – without money ever changing hands.
            </p>
            <p>
                Imagine learning a new language from a native speaker, and in return, teaching them how to play the guitar.
                Or perhaps you can offer expert coding advice in exchange for learning gourmet cooking techniques.
                That's the magic of SkillSwap: your expertise becomes your currency.
            </p>

            <h3><i class="fas fa-bullseye"></i> Our Mission</h3>
            <p>
                Our mission is simple: <strong>To make learning and teaching accessible, personal, and rewarding for everyone
                by fostering a community built on mutual exchange and growth.</strong> We aim to break down the traditional
                barriers to acquiring new skills and empower individuals to both learn and share in a supportive environment.
            </p>

            <h3><i class="fas fa-binoculars"></i> The SkillSwap Vision</h3>
            <p>We envision a world where:</p>
            <ul>
                <li>Learning is limitless and lifelong.</li>
                <li>Knowledge is shared freely for mutual benefit.</li>
                <li>Communities are strengthened through shared joy.</li>
                <li>Potential is unlocked, empowering individuals and others.</li>
            </ul>

            <h3><i class="fas fa-star"></i> Why Choose SkillSwap?</h3>
            <ul>
                <li><strong>Learn for Free (Almost!):</strong> Offer your skills, not tuition fees.</li>
                <li><strong>Diverse Range of Skills:</strong> From tech to arts, find your match.</li>
                <li><strong>Personalized Learning:</strong> Direct exchanges tailored to you.</li>
                <li><strong>Empowerment Through Teaching:</strong> Sharing knowledge is rewarding.</li>
                <li><strong>Build Real Connections:</strong> Go beyond passive courses.</li>
                <li><strong>Flexibility:</strong> Arrange swaps that work for both parties.</li>
            </ul>

            <div class="how-it-works">
                <h3><i class="fas fa-cogs"></i> How SkillSwap Works – It's Easy!</h3>
                <ol>
                    <li><strong>Create Your Profile:</strong> Sign up and tell us about yourself.</li>
                    <li><strong>List Your Skills:</strong> Share what you can teach.</li>
                    <li><strong>Define Your Learning Goals:</strong> What new skills do you seek?</li>
                    <li><strong>Find a Match:</strong> Browse or search for swap partners.</li>
                    <li><strong>Connect & Propose:</strong> Discuss terms and agree on your exchange.</li>
                    <li><strong>Swap & Grow:</strong> Start your learning and teaching journey!</li>
                </ol>
            </div>

            <h3><i class="fas fa-users"></i> Our Community: The Heart of SkillSwap</h3>
            <p>
                SkillSwap is more than just a platform; it's a thriving ecosystem of curious learners, passionate teachers,
                hobbyists, professionals, and friendly individuals from all walks of life. We are committed to fostering a
                safe, respectful, and supportive environment where everyone feels welcome and valued.
            </p>

            <div class="about-cta-buttons">
                <h3>Join the SkillSwap Movement!</h3>
                <p>Ready to unlock a new skill, share your passion, or connect with amazing people?</p>
                <a href="<c:url value='/register.jsp'/>" class="btn-about primary">Sign Up Now - It's Free!</a>
                <a href="<c:url value='/BrowseSkillsServlet'/>" class="btn-about secondary">Explore Skills</a>
            </div>

            <h3><i class="fas fa-question-circle"></i> Have Questions?</h3>
            <p>
                Visit our <a href="<c:url value='/jsp/help.jsp'/>">FAQ / Need Help Page</a> or
                <a href="<c:url value='/jsp/contact.jsp'/>">Contact Us</a> directly.
            </p>
        </section>
      </div>

    </div> <!-- End .main-content-area -->

    <script>
      // --- Standard JS for sidebar, cover page etc. (FROM YOUR PREVIOUS CODE) ---
      const sidebar = document.getElementById('sidebar');
      const toggleBtn = document.getElementById('sidebarToggle');
      const mainContent = document.getElementById('mainContent');
      const fadeOverlay = document.getElementById('sidebarFadeOverlay');
      const coverPage = document.getElementById('coverPage');
      const body = document.body;

      // The JavaScript 'updatePageForLoginState', 'loginUser', 'logoutUser', 'confirmLogout'
      // are removed as JSP handles the dynamic sidebar and links now.
      // Keep only the UI interaction logic.

      document.addEventListener('DOMContentLoaded', () => {
        if (toggleBtn && sidebar && mainContent && fadeOverlay) {
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
            window.dispatchEvent(new Event('resize')); // Initial check
        }
        if (coverPage && body) {
          setTimeout(() => {
            coverPage.classList.add('fade-out');
            body.classList.remove('cover-active');
          }, 1500); // Adjust timing as needed
        }
      });
    </script>
</body>
</html>