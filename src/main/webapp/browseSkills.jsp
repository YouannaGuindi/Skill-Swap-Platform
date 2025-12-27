<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ProjAdvAndWeb.model.User" %> <%-- For loggedInUser --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %> <%-- For string functions etc. --%>

<%
    User loggedInUserJsp = (User) session.getAttribute("loggedInUser"); // Renamed
    pageContext.setAttribute("isUserLoggedIn", loggedInUserJsp != null);
    if (loggedInUserJsp != null) {
        pageContext.setAttribute("currentUsername", loggedInUserJsp.getFirstName());
        pageContext.setAttribute("currentUsernameForAction", loggedInUserJsp.getUsername());
        pageContext.setAttribute("profilePicUrl", ""); // Placeholder
    } else {
        pageContext.setAttribute("currentUsername", "Guest");
        pageContext.setAttribute("profilePicUrl", "");
        pageContext.setAttribute("currentUsernameForAction", "");
    }
    // browseError and currentSearchTerm are set by the servlet
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title><c:out value="${pageTitle != null ? pageTitle : 'Browse Skills - SkillSwap'}"/></title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
  <style>
    /* --- PASTE THE CSS FROM YOUR PREVIOUS browseSkills.jsp HERE --- */
    /* Ensure .skill-card-browse has styles for image if you add one */
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: "Poppins", sans-serif; background-color: #f0f4f8; color: #333; line-height: 1.6; padding-top: 0; /* Removed top padding, banner handles it */ min-height: 100vh; display: flex; flex-direction: column; align-items: center; }
    .banner { width: 100%; background: linear-gradient(135deg, #4a90e2, #357ABD); color: white; padding: 50px 20px 30px; text-align: center; margin-bottom: 30px; box-shadow: 0 8px 20px rgb(53 122 189 / 0.3); border-bottom-left-radius: 20px; border-bottom-right-radius: 20px; font-weight: 600; letter-spacing: 0.02em; }
    .banner h1 { font-weight: 700; font-size: 2.8rem; margin-bottom: 10px; text-shadow: 0 2px 5px rgba(0,0,0,0.15); }
    .banner p { font-weight: 400; font-size: 1.2rem; max-width: 600px; margin: 0 auto 20px; text-shadow: 0 1px 3px rgba(0,0,0,0.1); }

    .browse-container { max-width: 1300px; /* Slightly wider */ width: 100%; margin: 0 auto 40px; padding: 0 20px; /* Let filter bar and grid handle their own padding */ }
    .page-header { text-align: center; margin-bottom: 30px; color: #2c3e50; }
    .page-header h1 { font-size: 2.5em; font-weight: 700; margin-bottom: 5px; }
    .page-header p { font-size: 1.05em; color: #7f8c8d; }

    .filter-bar { display: flex; flex-wrap: wrap; gap: 15px; margin-bottom: 30px; padding: 15px; background-color: #fff; border-radius: 12px; box-shadow: 0 5px 15px rgba(0,0,0,0.07); align-items: center; }
    .filter-bar .search-input { flex-grow: 1; padding: 12px 15px; font-size: 1em; border: 1px solid #d1d8e0; border-radius: 8px; min-width: 200px; transition: border-color 0.2s ease, box-shadow 0.2s ease; }
    .filter-bar .search-input:focus { outline: none; border-color: #3498db; box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.2); }
    .filter-bar .category-select { padding: 12px 15px; font-size: 1em; border: 1px solid #d1d8e0; border-radius: 8px; background-color: #fff; min-width: 180px; cursor: pointer; }
    .filter-bar button[type="submit"] { padding: 12px 20px; font-size: 1em; background-color: #3498db; color: white; border: none; border-radius: 8px; cursor: pointer; transition: background-color 0.2s; }
    .filter-bar button[type="submit"]:hover { background-color: #2980b9; }

    .skills-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 25px; }
    .skill-card-browse { background-color: #fff; border-radius: 12px; box-shadow: 0 6px 18px rgba(0, 0, 0, 0.08); padding: 20px; display: flex; flex-direction: column; transition: transform 0.25s ease, box-shadow 0.25s ease; text-decoration: none; color: inherit; /* For clickable card */ }
    .skill-card-browse:hover { transform: translateY(-5px); box-shadow: 0 10px 25px rgba(0, 0, 0, 0.12); }
    .skill-card-browse .skill-category { display: inline-block; background-color: #e9f5ff; color: #3498db; padding: 6px 12px; border-radius: 20px; font-size: 0.8em; font-weight: 600; margin-bottom: 12px; user-select: none; }
    .skill-card-browse h3 { font-size: 1.3em; color: #2c3e50; margin-bottom: 8px; }
    .skill-card-browse .skill-description { font-size: 0.95em; color: #566573; flex-grow: 1; margin-bottom: 15px; line-height: 1.5; overflow: hidden; display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; }
    /* For the link inside the card if not making the whole card clickable */
    .skill-card-browse .details-link { display: inline-block; margin-top: auto; color: #3498db; text-decoration: none; font-weight: 600; }
    .skill-card-browse .details-link:hover { text-decoration: underline; }

    .no-skills-message { text-align: center; font-size: 1.2em; color: #7f8c8d; padding: 50px 20px; background-color: #fff; border-radius: 12px; box-shadow: 0 6px 20px rgba(0, 0, 0, 0.06); margin-top: 25px; }
    .back-to-home { display: block; text-align: center; margin-top: 30px; margin-bottom: 30px; }
    .back-to-home a { color: #3498db; text-decoration: none; font-weight: 600; padding: 10px 20px; border: 1px solid #3498db; border-radius: 8px; transition: background-color 0.2s ease, color 0.2s ease; user-select: none; display: inline-block; }
    .back-to-home a:hover, .back-to-home a:focus { background-color: #3498db; color: white; outline: none; }
    .error-message-jsp { padding: 15px; margin-bottom: 15px; border-radius: 4px; text-align: center; background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb;}
  </style>
</head>
<body>
  <div class="banner">
    <h1>Explore Our Skill Universe</h1>
    <p>Discover a world of knowledge and talent. Find skills offered by our vibrant community members.</p>
  </div>

  <div class="browse-container">
    <%-- Server-side error message display --%>
    <c:if test="${not empty browseError}">
        <p class="error-message-jsp"><c:out value="${browseError}"/></p>
    </c:if>

    <form action="<c:url value='/BrowseSkillsServlet'/>" method="get" class="filter-bar">
      <input
        type="text"
        name="searchSkill" <%-- Name attribute for form submission --%>
        id="searchInput"
        class="search-input"
        placeholder="Search skills by name..."
        value="<c:out value='${currentSearchTerm}'/>"
      />
      <select name="category" id="categoryFilter" class="category-select"> <%-- Name attribute --%>
        <option value="all" ${currentCategoryFilter eq 'all' or empty currentCategoryFilter ? 'selected' : ''}>All Categories</option>
        <%-- Dynamically populate categories from the fetched skills, or have a predefined list --%>
        <%-- For simplicity, let's assume you have a way to get unique categories.
             If 'allGenericSkills' is available, you can create a Set of categories.
             Alternatively, SkillDAO could return a list of unique categories.
             For now, hardcoding a few common ones as an example: --%>
        <option value="Technology" ${currentCategoryFilter eq 'Technology' ? 'selected' : ''}>Technology</option>
        <option value="Creative Arts" ${currentCategoryFilter eq 'Creative Arts' ? 'selected' : ''}>Creative Arts</option>
        <option value="Lifestyle" ${currentCategoryFilter eq 'Lifestyle' ? 'selected' : ''}>Lifestyle</option>
        <option value="Business" ${currentCategoryFilter eq 'Business' ? 'selected' : ''}>Business</option>
        <option value="Education" ${currentCategoryFilter eq 'Education' ? 'selected' : ''}>Education</option>
        <option value="Health & Wellness" ${currentCategoryFilter eq 'Health & Wellness' ? 'selected' : ''}>Health & Wellness</option>
      </select>
      <button type="submit">Search</button>
    </form>

    <div class="skills-grid" id="skillsGrid">
      <c:choose>
        <c:when test="${not empty skillsToDisplay}">
          <c:forEach var="skill" items="${skillsToDisplay}">
            <%-- Make the entire card clickable to a skill detail page --%>
            <a href="<c:url value='/SkillDetailServlet?skillId=${skill.id}'/>" class="skill-card-browse">
                <span class="skill-category"><c:out value="${skill.category}"/></span>
                <h3><c:out value="${skill.name}"/></h3>
                <p class="skill-description"><c:out value="${fn:substring(skill.description, 0, 100)}"/>${fn:length(skill.description) > 100 ? '...' : ''}</p>
                <%-- Information about who offers it would typically be on the SkillDetailServlet page --%>
                <%-- For "Propose Swap" from here, it's tricky without knowing a specific provider.
                     This button is better placed on a page listing users who offer THIS skill.
                <c:if test="${isUserLoggedIn}">
                    <span class="details-link">View Details & Providers →</span>
                </c:if>
                --%>
                 <span class="details-link" style="margin-top:auto;">View Details & Providers →</span>
            </a>
          </c:forEach>
        </c:when>
        <c:otherwise>
          <div class="no-skills-message" id="noSkillsMessage">
            <c:choose>
                <c:when test="${not empty currentSearchTerm or (not empty currentCategoryFilter and currentCategoryFilter ne 'all')}">
                    No skills found matching your criteria. Try a different search or category!
                </c:when>
                <c:otherwise>
                    No skills currently available. Check back later!
                </c:otherwise>
            </c:choose>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <div class="back-to-home">
        <c:choose>
            <c:when test="${isUserLoggedIn}">
                <a href="<c:url value='/DashboardServlet'/>"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
            </c:when>
            <c:otherwise>
                <a href="<c:url value='/index.jsp'/>"><i class="fas fa-arrow-left"></i> Back to Home</a>
            </c:otherwise>
        </c:choose>
    </div>
  </div>
  <%-- Removed the client-side JavaScript that used 'allAvailableSkills' array --%>
</body>
</html>