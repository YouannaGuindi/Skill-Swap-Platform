<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Create Account - SkillSwap</title>
  <%-- You'll need to create style1.css or adapt the login page's style --%>
  <%-- For now, let's add some basic styles similar to login for consistency --%>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Poppins', sans-serif; color: #4A5568; background: linear-gradient(135deg, #6200ee, #03dac6); display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
    form { background: white; border-radius: 12px; padding: 30px 40px; width: 100%; max-width: 500px; box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1), 0 5px 10px rgba(0, 0, 0, 0.05); }
    fieldset { border: none; }
    legend { color: #6200ee; font-weight: 700; font-size: 1.8em; margin-bottom: 25px; text-align: center; width: 100%; }
    table { width: 100%; border-collapse: collapse; }
    td { padding: 8px 0; }
    label { display: block; font-weight: 600; font-size: 0.9em; margin-bottom: 5px; color: #4A5568; }
    input[type="text"], input[type="email"], input[type="password"], input[type="tel"] { width: 100%; padding: 12px 15px; border: 1px solid #CBD5E0; border-radius: 8px; font-size: 1em; color: #2D3748; background-color: #F7FAFC; transition: border-color 0.3s ease, box-shadow 0.3s ease; }
    input[type="text"]:focus, input[type="email"]:focus, input[type="password"]:focus, input[type="tel"]:focus { border-color: #03dac6; outline: none; box-shadow: 0 0 0 3px rgba(3, 218, 198, 0.3); }
    input[type="radio"] { margin-right: 5px; accent-color: #6200ee; }
    td label input[type="radio"] { margin-right: 5px; } /* Space between radio and its text */
    td > label { margin-right: 20px; } /* Space between User and Admin radio options */
    input[type="submit"] { margin-top: 25px; width: 100%; padding: 15px; background: linear-gradient(90deg, #6200ee, #7e3ff2); color: white; font-weight: 600; font-size: 1.05em; border: none; border-radius: 8px; cursor: pointer; transition: background 0.3s ease, transform 0.2s ease; box-shadow: 0 4px 12px rgba(98, 0, 238, 0.25); }
    input[type="submit"]:hover { background: linear-gradient(90deg, #4e00c0, #6200ee); transform: translateY(-2px); }
    .message-area { padding: 10px; margin-bottom: 15px; border-radius: 6px; text-align: center; font-size: 0.9em; }
    .message-area.error { background-color: #fed7d7; color: #c53030; border: 1px solid #feb2b2; }
    .login-link { text-align: center; margin-top: 20px; font-size: 0.9em; }
    .login-link a { color: #6200ee; font-weight: 600; text-decoration: none; }
    .login-link a:hover { text-decoration: underline; color: #03dac6;}
  </style>
</head>
<body>
  <form action="${pageContext.request.contextPath}/register" method="POST">
    <fieldset>
      <legend>Create Your Account</legend>

      <% String errorMessage = (String) request.getAttribute("errorMessage");
         if (errorMessage != null) { %>
            <div class="message-area error"><%= errorMessage %></div>
      <% } %>

      <table>
        <tr>
          <td><label for="fname">First Name:</label></td>
          <td><input type="text" id="fname" name="fname" placeholder="Enter Your First Name" required /></td>
        </tr>
        <tr>
          <td><label for="lname">Last Name:</label></td>
          <td><input type="text" id="lname" name="lname" placeholder="Enter Your Last Name" required /></td>
        </tr>
        <tr>
          <td><label for="username">Username:</label></td>
          <td><input type="text" id="username" name="username" placeholder="Choose a Username" required /></td>
        </tr>
        <tr>
          <td><label for="email">Email:</label></td>
          <td><input type="email" id="email" name="email" placeholder="Enter Your Email" required /></td>
        </tr>
        <tr>
          <td><label for="pass">Password:</label></td>
          <td><input type="password" id="pass" name="pass" placeholder="Enter Your Password" required /></td>
        </tr>
        <tr>
          <td><label for="cpass">Confirm Password:</label></td>
          <td><input type="password" id="cpass" name="cpass" placeholder="Re-Enter Your Password" required /></td>
        </tr>
        <tr>
          <td><label for="telno">Phone Number:</label></td>
          <td><input type="tel" id="telno" name="telno" placeholder="01xxxxxxxxx" pattern="01[0-9]{9}" title="Phone number must be 11 digits and start with 01." required /></td>
        </tr>
        <tr>
          <td><label>Role:</label></td>
          <td>
            <label for="user"><input type="radio" id="user" name="role" value="user" required />User</label>
            <label for="admin"><input type="radio" id="admin" name="role" value="admin" required />Admin</label>
          </td>
        </tr>
        <tr>
          <td colspan="2" style="text-align: center;">
            <input type="submit" id="submit" name="submit" value="Create Account" />
          </td>
        </tr>
      </table>
      <div class="login-link">
        Already have an account? <a href="${pageContext.request.contextPath}/login.jsp">Login here</a>
      </div>
    </fieldset>
  </form>
</body>
</html>