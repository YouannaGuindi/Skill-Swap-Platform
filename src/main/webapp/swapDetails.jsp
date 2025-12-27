<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${not empty pageTitle ? pageTitle : 'Swap Details'}</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/main_styles.css">
    <style>
        /* ... (your existing styles from the "Manage Your Swaps" answer) ... */
        body { font-family: sans-serif; margin: 20px; background-color: #f4f7f9; color: #333; }
        .container { background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); max-width: 800px; margin: auto; }
        h1 { color: #2c3e50; }
        .nav-links { margin-bottom: 20px; } /* Container for navigation links */
        .nav-links a { margin-right: 15px; } /* Space out links if multiple */
        .detail-item { margin-bottom: 12px; line-height: 1.6; }
        .detail-item strong { display: inline-block; width: 160px; color: #495057; font-weight: 600; }
        .actions-panel { margin-top: 25px; padding-top: 15px; border-top: 1px solid #eee; }
        .actions-panel h3 { margin-bottom: 15px; color: #343a40;}
        .actions-panel form { display: inline-block; margin-right: 10px; margin-bottom: 10px; }
        .actions-panel button {
            padding: 8px 15px; border: none; border-radius: 4px; cursor: pointer;
            font-weight: 500; color: white; font-size: 0.9em;
            transition: background-color 0.2s ease-in-out;
        }
        .btn-accept { background-color: #28a745; } .btn-accept:hover { background-color: #218838; }
        .btn-reject { background-color: #dc3545; } .btn-reject:hover { background-color: #c82333; }
        .btn-complete { background-color: #007bff; } .btn-complete:hover { background-color: #0069d9; }
        .btn-cancel { background-color: #ffc107; color: #212529; } .btn-cancel:hover { background-color: #e0a800; }
        .message, .error { padding: 10px; margin-bottom: 15px; border-radius: 4px; text-align: center; }
        .message { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb;}
        .error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb;}
        .back-link { /* Keep existing styles if any, or add general link styling */ color: #007bff; text-decoration: none;}
        .back-link:hover { text-decoration: underline; }
        .status-badge { padding: .25em .6em; font-size: .85em; font-weight: 700; line-height: 1; text-align: center; white-space: nowrap; vertical-align: baseline; border-radius: .25rem; }
        .status-PROPOSED { background-color: #ffc107; color: #212529;}
        .status-ACCEPTED { background-color: #28a745; color: white;}
        .status-COMPLETED { background-color: #007bff; color: white;}
        .status-REJECTED { background-color: #dc3545; color: white;}
        .status-CANCELLED { background-color: #6c757d; color: white;}
        .no-actions { color: #6c757d; font-style: italic; }
    </style>
</head>
<body>
    <div class="container">
        <h1>${not empty pageTitle ? pageTitle : 'Swap Details'}</h1>

        <c:if test="${not empty param.message || not empty requestScope.successMessage}">
            <p class="message"><c:out value="${param.message}"/><c:out value="${requestScope.successMessage}"/></p>
        </c:if>
        <c:if test="${not empty param.errorMessage || not empty requestScope.errorMessage}">
            <p class="error"><c:out value="${param.errorMessage}"/><c:out value="${requestScope.errorMessage}"/></p>
        </c:if>

        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/swaps?action=mySwaps" class="back-link action-link">« Back to My Swaps</a>
            <span style="margin: 0 10px;">|</span>
            <a href="${pageContext.request.contextPath}/DashboardServlet" class="back-link action-link">Return to Dashboard »</a>
        </div>

        <c:if test="${not empty swap}">
            <div class="details-section">
                <h3>Swap Information</h3>
                <div class="detail-item"><strong>Swap ID:</strong> <c:out value="${swap.swapId}"/></div>
                <div class="detail-item"><strong>Requester:</strong> <c:out value="${swap.requesterUsername}"/></div>
                <div class="detail-item"><strong>Provider:</strong> <c:out value="${swap.providerUsername}"/></div>
                <hr>
                <div class="detail-item"><strong>Skill Offered:</strong> <c:out value="${swap.skillOffered.name}"/></div>
                <div class="detail-item"><strong>Category:</strong> <c:out value="${swap.skillOffered.category}"/></div>
                <div class="detail-item"><strong>Description:</strong> <p style="margin-left: 165px; margin-top:-1.5em;"><c:out value="${swap.skillOffered.description}"/></p></div>
                <hr>
                <div class="detail-item"><strong>Points:</strong> <c:out value="${swap.pointsExchanged}"/></div>
                <div class="detail-item"><strong>Status:</strong> <span class="status-badge status-${swap.status}">
                    <c:out value="${swap.status}"/>
                </span></div>
                <div class="detail-item"><strong>Requested:</strong> <fmt:formatDate value="${swap.requestDate}" pattern="yyyy-MM-dd HH:mm:ss"/></div>
                <div class="detail-item"><strong>Last Updated:</strong> <fmt:formatDate value="${swap.lastUpdatedDate}" pattern="yyyy-MM-dd HH:mm:ss"/></div>
            </div>

            <div class="actions-panel">
                <%-- ... (rest of your actions panel from the previous correct version) ... --%>
                <h3>Available Actions:</h3>
                <c:set var="noActionsMessage" value="This swap is in a final state (${swap.status}). No further actions are possible."/>
                <c:if test="${swap.status ne 'COMPLETED' && swap.status ne 'REJECTED' && swap.status ne 'CANCELLED'}">
                     <c:set var="noActionsMessage" value="No actions available for you at this stage."/>
                </c:if>
                <c:set var="actionsRendered" value="${false}"/>

                <%-- Actions for PROVIDER --%>
                <c:if test="${loggedInUser.username eq swap.providerUsername}">
                    <c:if test="${swap.status eq 'PROPOSED'}">
                        <form action="${pageContext.request.contextPath}/swaps" method="POST" style="display:inline;">
                            <input type="hidden" name="action" value="accept"/>
                            <input type="hidden" name="id" value="${swap.swapId}"/>
                            <button type="submit" class="btn-accept">Accept Swap</button>
                        </form>
                        <form action="${pageContext.request.contextPath}/swaps" method="POST" style="display:inline;">
                            <input type="hidden" name="action" value="reject"/>
                            <input type="hidden" name="id" value="${swap.swapId}"/>
                            <button type="submit" class="btn-reject">Reject Swap</button>
                        </form>
                        <c:set var="actionsRendered" value="${true}"/>
                    </c:if>
                    <c:if test="${swap.status eq 'ACCEPTED'}">
                        <form action="${pageContext.request.contextPath}/swaps" method="POST" style="display:inline;">
                            <input type="hidden" name="action" value="complete"/>
                            <input type="hidden" name="id" value="${swap.swapId}"/>
                            <button type="submit" class="btn-complete">Mark as Completed</button>
                        </form>
                        <form action="${pageContext.request.contextPath}/swaps" method="POST" style="display:inline;">
                            <input type="hidden" name="action" value="cancel"/>
                            <input type="hidden" name="id" value="${swap.swapId}"/>
                            <button type="submit" class="btn-cancel">Cancel Swap (Provider)</button>
                        </form>
                        <c:set var="actionsRendered" value="${true}"/>
                    </c:if>
                </c:if>

                <%-- Actions for REQUESTER --%>
                <c:if test="${loggedInUser.username eq swap.requesterUsername}">
                    <c:if test="${swap.status eq 'PROPOSED'}">
                        <form action="${pageContext.request.contextPath}/swaps" method="POST" style="display:inline;">
                            <input type="hidden" name="action" value="cancel"/>
                            <input type="hidden" name="id" value="${swap.swapId}"/>
                            <button type="submit" class="btn-cancel">Cancel My Request</button>
                        </form>
                        <c:set var="actionsRendered" value="${true}"/>
                    </c:if>
                    <c:if test="${swap.status eq 'ACCEPTED'}">
                        <form action="${pageContext.request.contextPath}/swaps" method="POST" style="display:inline;">
                            <input type="hidden" name="action" value="complete"/>
                            <input type="hidden" name="id" value="${swap.swapId}"/>
                            <button type="submit" class="btn-complete">Mark as Completed</button>
                        </form>
                        <form action="${pageContext.request.contextPath}/swaps" method="POST" style="display:inline;">
                            <input type="hidden" name="action" value="cancel"/>
                            <input type="hidden" name="id" value="${swap.swapId}"/>
                            <button type="submit" class="btn-cancel">Cancel Swap (Requester)</button>
                        </form>
                        <c:set var="actionsRendered" value="${true}"/>
                    </c:if>
                </c:if>

                <c:if test="${not actionsRendered}">
                     <p class="no-actions">${noActionsMessage}</p>
                </c:if>
            </div>
        </c:if>
        <c:if test="${empty swap && empty errorMessage && empty param.errorMessage && empty requestScope.successMessage && empty param.message}">
            <p class="error">Could not load swap details. The swap may not exist or you may not have permission to view it.</p>
        </c:if>
    </div>
</body>
</html>