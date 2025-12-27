<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Reset Password - SkillSwap</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Reuse or adapt styles from login.jsp */
         *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Poppins', sans-serif; color: #4A5568; background: linear-gradient(135deg, #6200ee, #03dac6); display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px;}
        .reset-box { background: white; border-radius: 12px; padding: 40px 40px; width: 100%; max-width: 420px; box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1), 0 5px 10px rgba(0, 0, 0, 0.05); text-align: center; }
         .reset-box h2 { color: #6200ee; font-weight: 700; font-size: 1.8em; margin-bottom: 10px; }
        .reset-box .subtitle { font-size: 0.95em; color: #718096; margin-bottom: 20px; }
        .form-group { margin-bottom: 20px; text-align: left; }
        .reset-box label { display: block; font-weight: 600; font-size: 0.9em; margin-bottom: 8px; color: #4A5568; }
        .reset-box input[type="email"],
        .reset-box input[type="password"] { width: 100%; padding: 14px 18px; border: 1px solid #CBD5E0; border-radius: 8px; font-size: 1em; color: #2D3748; background-color: #F7FAFC; transition: border-color 0.3s ease, box-shadow 0.3s ease; }
         .reset-box input[type="email"]:focus,
        .reset-box input[type="password"]:focus { border-color: #03dac6; outline: none; box-shadow: 0 0 0 3px rgba(3, 218, 198, 0.3); }
        .reset-box button,
        .reset-box input[type="submit"] { margin-top: 15px; width: 100%; padding: 15px; background: linear-gradient(90deg, #6200ee, #7e3ff2); color: white; font-weight: 600; font-size: 1.05em; border: none; border-radius: 8px; cursor: pointer; transition: background 0.3s ease, transform 0.2s ease, box-shadow 0.3s ease; box-shadow: 0 4px 12px rgba(98, 0, 238, 0.25); letter-spacing: 0.5px; }
        .reset-box button:hover,
        .reset-box input[type="submit"]:hover { background: linear-gradient(90deg, #4e00c0, #6200ee); transform: translateY(-2px); box-shadow: 0 6px 15px rgba(98, 0, 238, 0.35); }
         .reset-box button:active,
        .reset-box input[type="submit"]:active { transform: translateY(0px); box-shadow: 0 2px 8px rgba(98, 0, 238, 0.3); }
         .message-area { padding: 10px; margin-bottom: 15px; border-radius: 6px; text-align: center; font-size: 0.9em; }
        .message-area.success { background-color: #e6fffa; color: #1a7464; border: 1px solid #b2f5ea; }
        .message-area.error { background-color: #fed7d7; color: #c53030; border: 1px solid #feb2b2; }
    </style>
</head>
<body>
    <div class="reset-box">
        <h2>Reset Your Password</h2>
        <p class="subtitle">Enter your new password below.</p>

        <%-- Read email from URL parameter (GET) OR from attribute (POST error) --%>
        <%
            String userEmail = request.getParameter("email"); // Try getting from GET parameter
            if (userEmail == null || userEmail.trim().isEmpty()) {
                 // If not in GET parameter, check if the servlet set it as an attribute after a POST error
                 userEmail = (String) request.getAttribute("email");
                 // IMPORTANT: If getting from attribute, it's already decoded by servlet.
                 // If getting from getParameter, it's automatically decoded by the container.
            }

            // Get any error message set by the ResetPasswordServlet
            String resetErrorMessage = (String) request.getAttribute("resetError");
        %>

         <%-- Display Error Message from servlet --%>
        <% if (resetErrorMessage != null) { %>
           <div class="message-area error"><%= resetErrorMessage %></div>
        <% } %>

        <%-- Check if we have a valid email to display the form --%>
        <% if (userEmail == null || userEmail.trim().isEmpty()) { %>
            <div class="message-area error">Invalid password reset link. Please request a new one.</div>
             <p class="signup-link" style="margin-top: 20px;">
               <a href="${pageContext.request.contextPath}/login.jsp">Back to Login</a>
           </p>
        <% } else { %>
             <%-- Password Reset Form --%>
            <form action="${pageContext.request.contextPath}/resetPassword" method="post">
                <%-- Hidden field to pass the email back to the servlet on POST --%>
                <input type="hidden" name="email" value="<%= userEmail %>">

                 <div class="form-group">
                    <label for="reset-email">Email Address:</label>
                    <%-- Display email, make it read-only --%>
                    <input type="email" id="reset-email" value="<%= userEmail %>" readonly style="background-color: #e9ecef; cursor: not-allowed;">
                </div>

                <div class="form-group">
                    <label for="new-pass">New Password:</label>
                    <input type="password" id="new-pass" name="newPassword" placeholder="Enter new password" required>
                </div>

                <div class="form-group">
                    <label for="confirm-pass">Confirm New Password:</label>
                    <input type="password" id="confirm-pass" name="confirmPassword" placeholder="Confirm new password" required>
                </div>

                <button type="submit">Reset Password</button>
            </form>
         <% } %> <%-- End of if/else check for valid email --%>


    </div>
</body>
</html>