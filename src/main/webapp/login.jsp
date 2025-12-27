<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Modern Login - SkillSwap</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    /* Keep ALL your existing CSS styles for .login-container, .login-box, form elements, etc. */
    /* Remove any CSS specific to #reset-password-section */
     *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Poppins', sans-serif; color: #4A5568; }
    .login-container { min-height: 100vh; background: linear-gradient(135deg, #6200ee, #03dac6); display: flex; justify-content: center; align-items: center; padding: 20px; }
    .login-box { background: white; border-radius: 12px; padding: 40px 40px; width: 100%; max-width: 420px; box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1), 0 5px 10px rgba(0, 0, 0, 0.05); text-align: center; }
    .login-box .logo-placeholder { width: 80px; height: 80px; background-color: #e0e0e0; border-radius: 50%; margin: 0 auto 25px auto; display: flex; align-items: center; justify-content: center; font-size: 1.5em; color: #6200ee; font-weight: 700; }
    .login-box h2 { color: #6200ee; font-weight: 700; font-size: 1.8em; margin-bottom: 10px; }
    .login-box .subtitle { font-size: 0.95em; color: #718096; margin-bottom: 20px; }
    .form-group { margin-bottom: 20px; text-align: left; }
    .login-box label { display: block; font-weight: 600; font-size: 0.9em; margin-bottom: 8px; color: #4A5568; }
    .login-box select,
    .login-box input[type="text"],
    .login-box input[type="password"] { width: 100%; padding: 14px 18px; border: 1px solid #CBD5E0; border-radius: 8px; font-size: 1em; color: #2D3748; background-color: #F7FAFC; transition: border-color 0.3s ease, box-shadow 0.3s ease; }
    .login-box select:focus,
    .login-box input[type="text"]:focus,
    .login-box input[type="password"]:focus { border-color: #03dac6; outline: none; box-shadow: 0 0 0 3px rgba(3, 218, 198, 0.3); }
    .form-options { display: flex; justify-content: space-between; align-items: center; margin-top: 20px; margin-bottom: 25px; font-size: 0.85em; }
    .login-box .checkbox-label { display: flex; align-items: center; font-weight: 500; color: #4A5568; gap: 8px; cursor: pointer; }
    .login-box .checkbox-label input[type="checkbox"] { accent-color: #6200ee; width: 16px; height: 16px; }
    .login-box .forgot-password a { color: #6200ee; text-decoration: none; font-weight: 500; cursor: pointer; } /* Added cursor: pointer */
    .login-box .forgot-password a:hover { text-decoration: underline; color: #03dac6; }
    .login-box button,
    .login-box input[type="submit"] { margin-top: 15px; width: 100%; padding: 15px; background: linear-gradient(90deg, #6200ee, #7e3ff2); color: white; font-weight: 600; font-size: 1.05em; border: none; border-radius: 8px; cursor: pointer; transition: background 0.3s ease, transform 0.2s ease, box-shadow 0.3s ease; box-shadow: 0 4px 12px rgba(98, 0, 238, 0.25); letter-spacing: 0.5px; }
    .login-box button:hover,
    .login-box input[type="submit"]:hover { background: linear-gradient(90deg, #4e00c0, #6200ee); transform: translateY(-2px); box-shadow: 0 6px 15px rgba(98, 0, 238, 0.35); }
    .login-box button:active,
    .login-box input[type="submit"]:active { transform: translateY(0px); box-shadow: 0 2px 8px rgba(98, 0, 238, 0.3); }
    .signup-link { margin-top: 30px; font-size: 0.9em; color: #4A5568; }
    .signup-link a { color: #6200ee; font-weight: 600; text-decoration: none; }
    .signup-link a:hover { color: #03dac6; text-decoration: underline; }
    .message-area { padding: 10px; margin-bottom: 15px; border-radius: 6px; text-align: center; font-size: 0.9em; }
    .message-area.success { background-color: #e6fffa; color: #1a7464; border: 1px solid #b2f5ea; }
    .message-area.error { background-color: #fed7d7; color: #c53030; border: 1px solid #feb2b2; }

    /* REMOVE the entire #reset-password-section styles if you keep them in the CSS file */

  </style>
</head>
<body>
  <div class="login-container">
    <div class="login-box">

      <h2>Welcome Back!</h2>
      <p class="subtitle">Please enter your details to login.</p>

      <%-- Display Login Error/Success Messages --%>
      <%-- Use this message handling block to show messages redirected from ForgotPasswordServlet/ResetPasswordServlet --%>
      <% String loginMessage = request.getParameter("message");
         if (loginMessage != null) {
             String messageText = "";
             String messageClass = "";
             if (loginMessage.equals("logout_success")) {
                 messageText = "You have been logged out successfully.";
                 messageClass = "success";
             } else if (loginMessage.equals("registration_success")) {
                 messageText = "Registration successful! Please login and check your email to verify your account.";
                 messageClass = "success";
             } else if (loginMessage.equals("admin_registration_success")) {
                 messageText = "Admin registration successful! Please login.";
                 messageClass = "success";
             } else if (loginMessage.equals("password_reset_requested")) { /* Message from ForgotPasswordServlet */
                 messageText = "If a matching account was found, a password reset email has been sent."; // Generic success message
                 messageClass = "success";
             } else if (loginMessage.equals("password_reset_failed")) { /* Message from ForgotPasswordServlet/ResetPasswordServlet */
                 messageText = "An error occurred or user not found. Please try again."; // Generic failure message
                 messageClass = "error";
             } else if (loginMessage.equals("password_reset_success")) { /* Message from ResetPasswordServlet */
                 messageText = "Your password has been reset successfully. You can now log in with your new password.";
                 messageClass = "success";
             }
             if (!messageText.isEmpty()) { %>
                <div class="message-area <%= messageClass %>"><%= messageText %></div>
      <%     }
         }
         String loginError = (String) request.getAttribute("loginError");
         if (loginError != null) { %>
            <div class="message-area error"><%= loginError %></div>
      <% } %>


      <%-- Main Login Form --%>
      <form id="login-form" action="${pageContext.request.contextPath}/loginservlet" method="post">

        <div class="form-group">
          <label for="account">Account Type:</label>
          <select id="account" name="account" required>
            <option value="" disabled selected>Select account type</option>
            <option value="user">User</option>
            <option value="admin">Admin</option>
          </select>
        </div>

        <div class="form-group">
          <label for="uname">Username or Email:</label>
          <input type="text" id="uname" name="uname" placeholder="e.g., yourname or name@example.com" required>
        </div>

        <div class="form-group">
          <label for="pass">Password:</label>
          <input type="password" id="pass" name="pass" placeholder="Enter your password" required>
        </div>

        <div class="form-options">
            <label class="checkbox-label">
              <input type="checkbox" name="rememberMe" value="on"> Remember Me
            </label>
            <div class="forgot-password">
              <a href="#" id="forgot-password-link">Forgot Password?</a> <%-- Added ID --%>
            </div>
        </div>

        <input type="submit" value="Login">

        <div class="signup-link">
          Don't have an account? <a href="${pageContext.request.contextPath}/register.jsp">Sign Up</a>
        </div>
      </form>

      <%-- !!! REMOVE the entire #reset-password-section div if you had it here !!! --%>

    </div> <%-- End of login-box div --%>
  </div> <%-- End of login-container div --%>

  <script>
      // --- Very Simple JavaScript ---
      const usernameInput = document.getElementById('uname'); // Get the main username/email input
      const forgotPasswordLink = document.getElementById('forgot-password-link'); // Get the "Forgot Password?" link
      const appContextPath = "${pageContext.request.contextPath}"; // Get context path for URL using direct EL
   
      if (forgotPasswordLink && usernameInput) {
          forgotPasswordLink.addEventListener('click', function(event) {
              event.preventDefault(); // Stop the link from just going to #

              const identifier = usernameInput.value.trim(); // Get the text the user typed

              if (identifier === "") {
                  // If the input is empty, show a message and stop
                  alert("Please enter your username or email in the field above before clicking 'Forgot Password'.");
                  return;
              }

              // Build the web address (URL) to send to the server
              // It will look like /AdvProject/forgotPassword?email=the_typed_email
              // Use encodeURIComponent to handle special characters like @ safely in the URL
              const targetUrl = appContextPath + "/forgotPassword?email=" + encodeURIComponent(identifier); // *** Use 'email' parameter name ***

              // Tell the browser to go to that new web address (this sends a GET request to your servlet)
              window.location.href = targetUrl;
          });
      }

      // Keep the message handling block from the previous login.jsp if you want to display messages
      // like "Email sent" or "User not found" after the redirect from the servlet.
      // This code reads URL parameters like ?message=... and the scriptlet above the form displays it.
  </script>

</body>
</html>