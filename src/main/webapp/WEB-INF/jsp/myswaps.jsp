<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${not empty pageTitle ? pageTitle : 'My Swaps'}</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/main_styles.css">
    <style>
        /* ... (your existing styles from the previous answer) ... */
        body { font-family: sans-serif; margin: 20px; background-color: #f4f7f9; color: #333; }
        .container { background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 12px 15px; border: 1px solid #ddd; text-align: left; }
        th { background-color: #e9ecef; color: #495057; }
        tr:nth-child(even) { background-color: #f8f9fa; }
        tr:hover { background-color: #e2e6ea; }
        .action-link, .filter-link {
            color: #007bff; text-decoration: none; margin-right: 10px;
        }
        .action-link:hover, .filter-link:hover { text-decoration: underline; }
        .message, .error { padding: 10px; margin-bottom: 15px; border-radius: 4px; }
        .message { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb;}
        .error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb;}
        .filters { margin-bottom: 20px; }
        .filters a { margin-right: 15px; }
        .filters .active-filter { font-weight: bold; text-decoration: none; color: #1a1a1a; }
    </style>
</head>
<body>
    <div class="container">
        <h1>${not empty pageTitle ? pageTitle : 'My Swaps'}</h1>

        <c:if test="${not empty param.message || not empty requestScope.successMessage}">
            <p class="message"><c:out value="${param.message}"/><c:out value="${requestScope.successMessage}"/></p>
        </c:if>
        <c:if test="${not empty param.errorMessage || not empty requestScope.errorMessage}">
            <p class="error"><c:out value="${param.errorMessage}"/><c:out value="${requestScope.errorMessage}"/></p>
        </c:if>
         <c:if test="${not empty requestScope.filterError}">
             <p class="error"><c:out value="${requestScope.filterError}"/></p>
         </c:if>


        <p><a href="${pageContext.request.contextPath}/DashboardServlet" class="action-link">« Back to Dashboard</a></p>
        <p><a href="${pageContext.request.contextPath}/swaps?action=showNewRequestForm" class="action-link">Initiate New Swap</a></p>

        <div class="filters">
            Filter by status:
            <a href="${pageContext.request.contextPath}/swaps?action=mySwaps&filter=all" class="filter-link ${empty currentFilter || currentFilter == 'all' ? 'active-filter' : ''}">All</a>
            <a href="${pageContext.request.contextPath}/swaps?action=mySwaps&filter=PROPOSED" class="filter-link ${currentFilter == 'PROPOSED' ? 'active-filter' : ''}">Proposed</a>
            <a href="${pageContext.request.contextPath}/swaps?action=mySwaps&filter=ACCEPTED" class="filter-link ${currentFilter == 'ACCEPTED' ? 'active-filter' : ''}">Accepted</a>
            <a href="${pageContext.request.contextPath}/swaps?action=mySwaps&filter=COMPLETED" class="filter-link ${currentFilter == 'COMPLETED' ? 'active-filter' : ''}">Completed</a>
            <a href="${pageContext.request.contextPath}/swaps?action=mySwaps&filter=REJECTED" class="filter-link ${currentFilter == 'REJECTED' ? 'active-filter' : ''}">Rejected</a>
            <a href="${pageContext.request.contextPath}/swaps?action=mySwaps&filter=CANCELLED" class="filter-link ${currentFilter == 'CANCELLED' ? 'active-filter' : ''}">Cancelled</a>
        </div>

        <c:choose>
            <c:when test="${empty mySwaps}">
                <p>
                    You have no swaps
                    <c:if test="${not empty currentFilter && currentFilter ne 'all'}">
                        matching the status '<c:out value="${currentFilter}"/>'.
                    </c:if>
                    .
                </p>
            </c:when>
            <c:otherwise>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Role</th>
                            <th>Other Party</th>
                            <th>Skill</th>
                            <th>Points</th>
                            <th>Status</th>
                            <th>Last Updated</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="swap" items="${mySwaps}">
                            <tr>
                                <td><c:out value="${swap.swapId}"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${loggedInUser.username eq swap.requesterUsername}">Requester</c:when>
                                        <c:when test="${loggedInUser.username eq swap.providerUsername}">Provider</c:when>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${loggedInUser.username eq swap.requesterUsername}"><c:out value="${swap.providerUsername}"/></c:when>
                                        <c:when test="${loggedInUser.username eq swap.providerUsername}"><c:out value="${swap.requesterUsername}"/></c:when>
                                    </c:choose>
                                </td>
                                <td><c:out value="${swap.skillOffered.name}"/></td>
                                <td><c:out value="${swap.pointsExchanged}"/></td>
                                <td><c:out value="${swap.status}"/></td>
                                <td><fmt:formatDate value="${swap.lastUpdatedDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/swaps?action=view&id=${swap.swapId}" class="action-link">View/Manage</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html>