<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Skill Details: <c:out value="${skillDetail.name}"/></title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* ... your CSS ... */
        body { font-family: 'Poppins', sans-serif; background-color: #f4f7f9; margin: 0; padding: 20px; color: #333; }
        .container { max-width: 900px; margin: 20px auto; background-color: #fff; padding: 30px; border-radius: 12px; box-shadow: 0 5px 25px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; margin-bottom: 10px; font-size: 2.2em; border-bottom: 2px solid #e0e0e0; padding-bottom: 10px;}
        .skill-category-detail { display: inline-block; background-color: #e9f5ff; color: #3498db; padding: 6px 12px; border-radius: 20px; font-size: 0.9em; font-weight: 600; margin-bottom: 15px; }
        .skill-description-detail { font-size: 1.1em; margin-bottom: 25px; line-height: 1.7; color: #555; }
        h2 { color: #34495e; margin-top: 30px; margin-bottom: 15px; font-size: 1.6em; border-bottom: 1px dashed #bdc3c7; padding-bottom: 8px;}
        .user-list { list-style: none; padding: 0; }
        .user-list li { background-color: #f9f9f9; border: 1px solid #eee; padding: 15px; margin-bottom: 10px; border-radius: 8px; display: flex; justify-content: space-between; align-items: center; }
        .user-list li .user-info { font-size: 1.05em; }
        .user-list li .user-info strong { color: #2980b9; }
        .propose-swap-btn-detail { padding: 8px 15px; background-color: #2ecc71; color: white; text-decoration: none; border-radius: 6px; font-weight: 500; transition: background-color 0.2s; }
        .propose-swap-btn-detail:hover { background-color: #27ae60; }
        .no-providers { color: #7f8c8d; font-style: italic; }
        .back-link { display: inline-block; margin-top: 30px; color: #3498db; text-decoration: none; font-weight: 600; }
        .back-link:hover { text-decoration: underline; }
        .error-message { color: #c0392b; background-color: #fdd; border: 1px solid #c0392b; padding: 10px; border-radius: 4px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <c:if test="${not empty errorMessage}">
            <p class="error-message"><c:out value="${errorMessage}"/></p>
        </c:if>

        <c:if test="${not empty skillDetail}">
            <h1><c:out value="${skillDetail.name}"/></h1>
            <p><span class="skill-category-detail"><c:out value="${skillDetail.category}"/></span></p>
            <p class="skill-description-detail"><c:out value="${skillDetail.description}"/></p>

            <h2>Users Offering This Skill:</h2>
            <c:choose>
                <c:when test="${not empty usersOfferingSkill}">
                    <ul class="user-list">
                        <c:forEach var="provider" items="${usersOfferingSkill}">
                            <li>
                                <div class="user-info">
                                    <strong><c:out value="${provider.firstName} ${provider.lastName}"/></strong> (<c:out value="${provider.username}"/>)
                                </div>
                                <%-- THIS IS THE CORRECT PLACEMENT --%>
                                <c:if test="${loggedInUser != null && loggedInUser.username ne provider.username}">
                                    <a href="<c:url value='/swaps?action=showNewRequestForm&prefillProvider=${provider.username}&prefillSkillId=${skillDetail.id}'/>"
                                       class="propose-swap-btn-detail">
                                        Request <c:out value="${skillDetail.name}"/> from this User
                                    </a>
                                </c:if>
                            </li>
                        </c:forEach>
                    </ul>
                </c:when>
                <c:otherwise>
                    <p class="no-providers">Currently, no users are offering this specific skill, or you might be the only one offering it.</p>
                </c:otherwise>
            </c:choose>
        </c:if>

        <a href="<c:url value='/BrowseSkillsServlet'/>" class="back-link">← Back to Browse Skills</a>
    </div>
</body>
</html>