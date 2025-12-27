<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${pageTitle}</title>
    <style>
        body { font-family: sans-serif; line-height: 1.6; margin: 20px; }
        .error { color: red; }
    </style>
</head>
<body>

    <h1>Error</h1>

    <p class="error">An error occurred:</p>
    <p><c:out value="${errorMessage}"/></p>

    <p><a href="${pageContext.request.contextPath}/swaps">Back to My Swaps</a></p> <%-- Link back to a safe page --%>

</body>
</html>