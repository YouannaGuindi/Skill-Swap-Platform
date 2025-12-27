<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ProjAdvAndWeb.model.Admin" %>
<%@ page import="com.ProjAdvAndWeb.model.User" %>
<%@ page import="com.ProjAdvAndWeb.model.Skill" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- Attributes set by AdminUserManagementServlet (when no action or action != viewDetails):
    loggedInAdmin, isUserLoggedIn, isAdminLoggedIn, currentUsername, profilePicUrl,
    currentServletPath, appContextPath,
    allUsers (List of User objects), errorMessage
--%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Manage Users - SkillSwap Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
     <style>
        /* !!! IMPORTANT: COPY AND PASTE ALL YOUR COMMON ADMIN CSS FROM adminDashboard.jsp / adminViewUserDetails.jsp HERE !!! */
        /* Ensure all the sidebar, main content, toggle button, overlay, and basic page-header-admin styles are included */
        /* Add specific styles for the user list table */
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

        /* Common table/card styles */
        .page-header-admin { text-align: center; margin-bottom: 30px; padding-bottom: 20px; border-bottom: 1px solid #e0e0e0;}
        .page-header-admin h1 { font-size: 2.4em; color: #002366; margin-bottom: 5px;}
        .page-header-admin p { font-size: 1.1em; color: #555; }

        /* --- User List Table Styles --- */
        .user-list-container {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.07);
            margin: 20px 0;
            overflow-x: auto; /* Make table scrollable on small screens */
        }
        .user-list-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        .user-list-table th, .user-list-table td {
            text-align: left;
            padding: 12px;
            border-bottom: 1px solid #ddd;
        }
         .user-list-table th {
            background-color: #f2f2f2;
            font-weight: 600;
            color: #333;
            white-space: nowrap; /* Prevent header text wrapping */
         }
        .user-list-table tbody tr:hover {
            background-color: #f9f9f9;
        }
        .user-list-table td .action-link {
            color: #003973;
            text-decoration: none;
            font-weight: 500;
            margin-right: 10px;
            transition: color 0.2s ease;
        }
         .user-list-table td .action-link:hover {
            color: #002366;
            text-decoration: underline;
        }
         .user-list-table td .action-link i {
             margin-right: 4px;
         }

         .no-data {
             text-align: center;
             padding: 20px;
             color: #555;
         }

         @media (max-width: 992px) {
            .main-content-area.sidebar-open-push { margin-left: 0; }
            .sidebar-toggle-btn.shifted { left: 20px; }
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
            <c:url var="url_admin_user_management" value="/AdminUserManagementServlet"/> <%-- Link to AdminUserManagementServlet --%>
            <c:url var="url_admin_swap_management" value="/AdminSwapManagementServlet"/> <%-- Link to AdminSwapManagementServlet --%>
            <c:url var="url_main_site_index" value="/index.jsp"/>

            <li><a href="${url_admin_dashboard}" class="${currentServletPath eq '/AdminDashboardServlet' ? 'active' : ''}"><span class="nav-icon"><i class="fas fa-tachometer-alt"></i></span> Dashboard Overview</a></li>
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
            <h1>Manage User Accounts</h1>
            <p>View and manage registered users.</p>
        </header>

        <%-- Display error message if any --%>
        <c:if test="${not empty requestScope.errorMessage}">
            <p style="color:red; text-align:center; padding:10px; background-color: #ffebee; border: 1px solid #ffcdd2; border-radius: 4px;">
                <i class="fas fa-exclamation-triangle"></i> <c:out value="${requestScope.errorMessage}"/>
            </p>
        </c:if>

        <div class="user-list-container">
            <c:choose>
                <%-- Check if the allUsers list is not null and not empty --%>
                <c:when test="${not empty allUsers}">
                    <table class="user-list-table">
                        <thead>
                            <tr>
                                <th>Username</th>
                                <th>Full Name</th>
                                <th>Email</th>
                                <th>Registered</th>
                                <th>Points</th>
                                <th>Email Verified</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="user" items="${allUsers}">
                                <tr>
                                    <td><c:out value="${user.username}"/></td>
                                    <td><c:out value="${user.firstName} ${user.lastName}"/></td>
                                    <td><c:out value="${user.email}"/></td>
                                    <td><fmt:formatDate value="${user.dateRegistered}" pattern="yyyy-MM-dd"/></td>
                                    <td><c:out value="${user.points}"/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${user.emailVerified}"><span style="color: green;"><i class="fas fa-check-circle"></i> Yes</span></c:when>
                                            <c:otherwise><span style="color: orange;"><i class="fas fa-exclamation-circle"></i> No</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <%-- Link to view details - sends action=viewDetails and the username --%>
                                        <c:url var="viewDetailsUrl" value="/AdminUserManagementServlet">
                                            <c:param name="action" value="viewDetails"/>
                                            <c:param name="username" value="${user.username}"/>
                                        </c:url>
                                        <a href="${viewDetailsUrl}" class="action-link" title="View Details"><i class="fas fa-info-circle"></i> View</a>
                                        <%-- Add other actions like Edit, Suspend if needed later --%>
                                        <%-- <a href="..." class="action-link" title="Edit User"><i class="fas fa-edit"></i> Edit</a> --%>
                                        <%-- <a href="..." class="action-link" title="Suspend User"><i class="fas fa-user-slash"></i> Suspend</a> --%>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <%-- Display message if allUsers is empty or null --%>
                    <p class="no-data">No users found in the database.</p>
                </c:otherwise>
            </c:choose>
        </div>

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
</body>
</html>