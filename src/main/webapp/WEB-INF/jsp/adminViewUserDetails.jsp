<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ProjAdvAndWeb.model.Admin" %>
<%@ page import="com.ProjAdvAndWeb.model.User" %>
<%@ page import="com.ProjAdvAndWeb.model.Skill" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- Attributes set by AdminUserManagementServlet (when action=viewDetails):
    loggedInAdmin, isUserLoggedIn, isAdminLoggedIn, currentUsername, profilePicUrl,
    currentServletPath, appContextPath,
    user (the User object being viewed), errorMessage
--%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <%-- Access the 'user' attribute set by the servlet --%>
    <title>User Details - <c:out value="${user.username}"/> - SkillSwap Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
     <style>
        /* !!! IMPORTANT: COPY AND PASTE ALL YOUR COMMON ADMIN CSS FROM adminDashboard.jsp HERE !!! */
        /* This includes styles for body, sidebar (.app-sidebar, .sidebar-header, .sidebar-nav, .sidebar-footer),
           main content (.main-content-area), toggle button (.sidebar-toggle-btn), overlay (.sidebar-fade-overlay),
           cover page (#coverPage if used on this page), and common table/card styles (.page-header-admin)
           Also include the .user-details-container and .user-info-item styles from the previous example.
        */
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Poppins', sans-serif; background-color: #f4f7f6; color: #333; overflow-x: hidden; line-height: 1.6; }

        /* --- MASTER SIDEBAR CSS (background: #002366) --- */
        .app-sidebar { position: fixed; top: 0; left: -260px; width: 260px; height: 100vh; background:#002366; color: white; padding: 20px; box-sizing: border-box; transition: left 0.3s cubic-bezier(0.25, 0.8, 0.25, 1); z-index: 1000; display: flex; flex-direction: column; box-shadow: 5px 0 25px rgba(0, 0, 0, 0.15); }
        .app-sidebar.open { left: 0; }
        .sidebar-header { text-align: center; margin-bottom: 25px; padding-bottom: 20px; border-bottom: 1px solid rgba(255,255,255,0.15); }
        .app-sidebar .logo-main { font-size: 2.2em; font-weight: 700; color: #03dac6; letter-spacing: 1px; margin-bottom: 10px; display: block; }
        .app-sidebar .logo-tagline { font-size: 0.9em; color: rgba(255,255,255,0.8); }
        .profile-picture-container { width: 90px; height: 90px; border-radius: 50%; overflow: hidden; margin: 0 auto 15px auto; border: 3px solid #03dac6; background-color: rgba(255,255,255,0.2); display: flex; justify-content: center; align-items: center; font-size: 2em; }
        .profile-picture-container img { width: 100%; height: 100%; object-fit: cover; }
        .profile-picture-container .placeholder-icon { font-size: 3em; color: rgba(255,255,255,0.7); }
        .sidebar-username { font-size: 1.1em; font-weight: 500; color: rgba(255,255,255,0.9); margin-top: 5px; }
        .sidebar-nav {flex-grow: 1;margin-top: 10px;overflow-y: auto;padding-right: 2px;scrollbar-width: thin; scrollbar-color: rgba(255, 255, 255, 0.2) transparent;}
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
        .sidebar-footer a.btn-logout { background: #e74c3c; color: white; }
        .sidebar-footer a.btn-logout:hover { background: #c0392b; }

        /* Main content and toggle styles */
        .main-content-area { margin-left: 0; padding: 30px; transition: margin-left 0.3s cubic-bezier(0.25, 0.8, 0.25, 1), filter 0.3s ease; position: relative; z-index: 1;}
        .main-content-area.sidebar-open-push { margin-left: 260px; }
        .main-content-area.dimmed { filter: brightness(0.7) blur(2px); pointer-events: none; }
        .sidebar-toggle-btn { position: fixed; top: 20px; left: 20px; background:  #4169E1; border: none; color: white; font-size: 22px; padding: 10px 14px; cursor: pointer; border-radius: 8px; z-index: 1100; transition: background 0.3s ease, left 0.3s cubic-bezier(0.25, 0.8, 0.25, 1); box-shadow: 0 2px 5px rgba(0,0,0,0.15); }
        .sidebar-toggle-btn:hover { background: #002366; }
        .sidebar-toggle-btn.shifted { left: 280px; }
        .sidebar-fade-overlay { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.5); opacity: 0; visibility: hidden; transition: opacity 0.3s ease, visibility 0s 0.3s; z-index: 999; }
        .sidebar-fade-overlay.visible { opacity: 1; visibility: visible; transition: opacity 0.3s ease; }

        /* Cover Page (Optional) */
        #coverPage { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: linear-gradient(135deg, #002366, #03dac6); display: flex; flex-direction: column; justify-content: center; align-items: center; color: white; font-family: 'Poppins', sans-serif; font-size: 2.8em; font-weight: 700; z-index: 2000; opacity: 1; transition: opacity 1.2s ease-out, visibility 1.2s ease-out; text-align: center; padding: 20px; }
        #coverPage .subtitle { font-size: 0.5em; font-weight: 400; margin-top: 15px; opacity: 0.9; }
        #coverPage.fade-out { opacity: 0; visibility: hidden; pointer-events: none; }
        body.cover-active { overflow: hidden; }

        /* Common table/card styles (keep if used on this page) */
        .page-header-admin { text-align: center; margin-bottom: 30px; padding-bottom: 20px; border-bottom: 1px solid #e0e0e0;}
        .page-header-admin h1 { font-size: 2.4em; color: #002366; margin-bottom: 5px;}
        .page-header-admin p { font-size: 1.1em; color: #555; }

        /* Styles for User Details */
        .user-details-container {
            background-color: #fff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.07);
            max-width: 700px; /* Limit width for readability */
            margin: 20px auto; /* Center the block */
            /* ADDED SCROLLING AND MAX HEIGHT */
            max-height: calc(100vh - 150px); /* Allow it to take up most of the viewport height before scrolling, leaving space for header/footer */
            overflow-y: auto; /* Add vertical scrolling to this container if content overflows */
        }
        .user-details-container h2 {
             font-size: 2em;
             color: #002366;
             margin-bottom: 20px;
             text-align: center;
             padding-bottom: 15px;
             border-bottom: 2px solid #002366;
        }
        .user-info-item {
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }
        .user-info-item:last-child {
            border-bottom: none;
            padding-bottom: 0;
            margin-bottom: 0;
        }
        .user-info-item strong {
            display: inline-block; /* Make label bold and potentially fixed width */
            width: 150px; /* Adjust as needed */
            color: #555;
        }
        .user-info-item span {
            display: inline-block;
            color: #333;
        }
        .user-info-item .skills-list {
            list-style: none; padding: 0; margin-top: 5px;
        }
         .user-info-item .skills-list li {
            display: inline-block; background-color: #e0eafc; color: #003973; padding: 3px 8px; border-radius: 4px; margin-right: 5px; margin-bottom: 5px; font-size: 0.9em;
         }

        /* Back link style */
        .back-link { display: inline-block; margin-top: 25px; padding: 10px 20px; background-color: #003973; color: white; text-decoration: none; border-radius: 5px; transition: background-color 0.2s ease; }
        .back-link:hover { background-color: #002366; }


        @media (max-width: 992px) {
            .main-content-area.sidebar-open-push { margin-left: 0; }
            .sidebar-toggle-btn.shifted { left: 20px; }
        }
         @media (max-width: 768px) {
            .user-details-container { padding: 20px; }
            .user-info-item strong { width: 100px; }
        }
    </style>
</head>
<body <c:if test="${isAdminLoggedIn}">class="cover-active"</c:if>>

    <%-- Optional Cover Page (If used here) --%>
    <%-- <c:if test="${isAdminLoggedIn}">
        <div id="coverPage">SkillSwap Admin<div class="subtitle">System Monitoring</div></div>
    </c:if> --%>

    <%-- ===== ADMIN MASTER SIDEBAR HTML (DUPLICATED) ===== --%>
    <nav class="app-sidebar" id="sidebar">
      <div class="sidebar-header">
        <span class="logo-main">SkillSwap</span>
        <span class="logo-tagline">Admin Panel</span>
        <div class="profile-picture-container">
            <i class="fas fa-user-shield placeholder-icon" style="font-size: 2.5em; color: rgba(255,255,255,0.7);"></i>
        </div>
        <div class="sidebar-username" style="display: block;">
            <c:out value="${currentUsername}"/> (<c:out value="${loggedInAdmin.username}"/>)
        </div>
      </div>
      <div class="sidebar-nav">
          <ul id="sidebarNavItems">
            <%-- Define URLs for navigation --%>
            <c:url var="url_admin_dashboard" value="/AdminDashboardServlet"/>
            <%-- Removed Add Admin link --%>
            <c:url var="url_admin_user_management" value="/AdminUserManagementServlet"/> <%-- Link to AdminUserManagementServlet --%>
            <c:url var="url_admin_swap_management" value="/AdminSwapManagementServlet"/> <%-- Link to AdminSwapManagementServlet --%>
            <%-- Removed System Settings and Reported Content links --%>
            <c:url var="url_main_site_index" value="/index.jsp"/>

            <li><a href="${url_admin_dashboard}" class="${currentServletPath eq '/AdminDashboardServlet' ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-tachometer-alt"></i></span> Dashboard Overview</a></li>
             <%-- Removed Add New Admin link --%>
            <%-- Mark active for user pages - Include the list and details JSP paths here --%>
            <li><a href="${url_admin_user_management}" class="${currentServletPath eq '/AdminUserManagementServlet' or fn:endsWith(currentServletPath, '/adminUserList.jsp') or fn:endsWith(currentServletPath, '/adminViewUserDetails.jsp') ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-users-cog"></i></span> Manage Users</a></li>
            <li><a href="${url_admin_swap_management}" class="${currentServletPath eq '/AdminSwapManagementServlet' or fn:endsWith(currentServletPath, '/adminSwapManagement.jsp') or fn:endsWith(currentServletPath, '/adminSwapDetails.jsp') ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-exchange-alt"></i></span> Manage Swaps</a></li>

            <hr style="border-color: rgba(255,255,255,0.1); margin: 10px 0;">
            <li><a href="${url_main_site_index}"><span class="nav-icon"><i class="fas fa-globe"></i></span> View Main Site</a></li>
          </ul>
      </div>
      <div class="sidebar-footer">
        <c:if test="${isAdminLoggedIn}">
            <c:url var="url_logout" value="/LogoutServlet?userType=admin"/>
            <a href="${url_logout}" class="btn-logout">Logout Admin</a>
        </c:if>
      </div>
    </nav>
    <%-- ===== END ADMIN MASTER SIDEBAR HTML ===== --%>

    <div id="sidebarFadeOverlay" class="sidebar-fade-overlay"></div>
    <button class="sidebar-toggle-btn" id="sidebarToggle" aria-label="Toggle sidebar"><i class="fas fa-bars"></i></button>

    <div class="main-content-area" id="mainContent">

        <header class="page-header-admin">
            <h1>User Account Details</h1>
            <%-- Access the 'user' attribute set by the servlet --%>
            <%-- Only show username if user is not empty --%>
            <c:if test="${not empty user}">
                 <p>Viewing details for <c:out value="${user.username}"/></p>
            </c:if>
             <c:if test="${empty user}">
                 <p>Viewing details</p>
            </c:if>
        </header>

        <%-- Display error message if user not found etc. --%>
        <c:if test="${not empty requestScope.errorMessage}">
            <p style="color:red; text-align:center; padding:10px; background-color: #ffebee; border: 1px solid #ffcdd2; border-radius: 4px;">
                <i class="fas fa-exclamation-triangle"></i> <c:out value="${requestScope.errorMessage}"/>
            </p>
        </c:if>

        <%-- Display user details if user object is available --%>
        <c:if test="${not empty user}"> <%-- Access the 'user' attribute set by the servlet --%>
            <div class="user-details-container">
                <h2><i class="fas fa-user-circle"></i> <c:out value="${user.firstName} ${user.lastName}"/> (<c:out value="${user.username}"/>)</h2>

                <div class="user-info-item">
                    <strong>Email:</strong> <span><c:out value="${user.email}"/></span>
                </div>
                 <div class="user-info-item">
                    <strong>Phone Number:</strong> <span><c:out value="${user.phoneNumber}"/></span>
                </div>
                 <div class="user-info-item">
                    <strong>Date Registered:</strong> <span><fmt:formatDate value="${user.dateRegistered}" pattern="MMMM dd, yyyy 'at' hh:mm:ss a z"/></span>
                </div>
                 <div class="user-info-item">
                    <strong>Current Points:</strong> <span><c:out value="${user.points}"/></span>
                </div>
                 <div class="user-info-item">
                    <strong>Email Verified:</strong>
                    <span>
                         <c:choose>
                            <c:when test="${user.emailVerified}"><span style="color: green; font-weight:bold;"><i class="fas fa-check-circle"></i> Verified</span></c:when>
                            <c:otherwise><span style="color: orange; font-weight:bold;"><i class="fas fa-exclamation-circle"></i> Not Verified</span></c:otherwise>
                        </c:choose>
                    </span>
                </div>

                <h3><i class="fas fa-tools"></i> Skills Offered by User</h3>
                <div class="detail-item">
                    <c:choose>
                        <c:when test="${not empty user.skills}">
                            <ul class="skills-list">
                                <c:forEach var="skill" items="${user.skills}">
                                    <li><i class="fas fa-tag"></i> <c:out value="${skill.name}"/> (<c:out value="${skill.category}"/>)</li>
                                </c:forEach>
                            </ul>
                        </c:when>
                        <c:otherwise>
                            <p>This user has not listed any skills.</p>
                        </c:otherwise>
                    </c:choose>
                </div>

                <%-- REMOVED THE ACTIONS BAR --%>
                <%--
                <div class="actions-bar">
                     <a href="..." class="action-btn btn-edit"><i class="fas fa-edit"></i> Edit User</a>
                     <button class="action-btn btn-suspend" onclick="...">
                        <i class="fas fa-user-slash"></i> Suspend
                     </button>
                </div>
                --%>

            </div>
        </c:if>
        <%-- Removed this else block because the error message handles the "not found" case --%>
        <%-- <c:if test="${empty user && empty requestScope.errorMessage}">
             <p class="no-data" style="text-align:center;">User details could not be loaded or user does not exist.</p>
        </c:if> --%>


        <%-- Link back to the user list --%>
        <p style="text-align: center; margin-top: 20px;">
            <%-- This link correctly goes back to the servlet without parameters, which will now lead to the list page --%>
            <a href="<c:url value='/AdminUserManagementServlet'/>" class="back-link" style="margin-left: auto; margin-right:auto; display:block; width: fit-content; "><i class="fas fa-arrow-left"></i> Back to User Management List</a>
        </p>

    </div> <!-- End .main-content-area -->

    <%-- ===== COMMON JAVASCRIPT (DUPLICATED) ===== --%>
    <script>
      const sidebar = document.getElementById('sidebar');
      const toggleBtn = document.getElementById('sidebarToggle');
      const mainContent = document.getElementById('mainContent');
      const fadeOverlay = document.getElementById('sidebarFadeOverlay');
       // const coverPage = document.getElementById('coverPage'); // If used on this page
      const body = document.body;

      document.addEventListener('DOMContentLoaded', () => {
        if (toggleBtn && sidebar && fadeOverlay) {
          toggleBtn.addEventListener('click', () => {
            const isOpen = sidebar.classList.toggle('open');
            fadeOverlay.classList.toggle('visible', isOpen);
            if (mainContent) mainContent.classList.toggle('dimmed', isOpen);

            if (window.innerWidth > 992) {
              if (mainContent) mainContent.classList.add('sidebar-open-push', isOpen);
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
            window.dispatchEvent(new Event('resize')); // Initial check on load
        }

        // Cover Page Fade Out Logic (If used here)
        // const hasCoverPage = body.classList.contains('cover-active');
        // if (coverPage && hasCoverPage) {
        //   setTimeout(() => {
        //     coverPage.classList.add('fade-out');
        //     body.classList.remove('cover-active');
        //   }, 1500); // Adjust timing if needed
        // } else if (coverPage) {
        //     coverPage.style.display = 'none';
        // }
      });
    </script>
     <%-- Optional: status coloring JS if needed --%>
     <script>
       document.addEventListener('DOMContentLoaded', function() {
           const statusElements = document.querySelectorAll('.data-table span[class^="status-"]'); // Might not have tables on details page
           statusElements.forEach(el => {
               const status = el.textContent.trim().toLowerCase();
               el.classList.add('status-' + status);
           });
       });
    </script>
</body>
</html>