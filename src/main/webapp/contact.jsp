<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Contact Us - SkillSwap</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
  <style>
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: 'Poppins', sans-serif;
      background: linear-gradient(135deg, #30aa9c, #38f3d6);
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100vh;
      overflow: hidden; /* As per your original request */
    }

    .container {
      display: flex;
      width: 90%;
      max-width: 1200px;
      height: 90vh; /* As per your original request */
      align-items: center;
      position: relative;
      gap: 30px;
    }

    .form-container {
      background: white;
      border-radius: 16px;
      padding: 35px 40px;
      box-shadow: 0 12px 30px rgba(0, 0, 0, 0.1);
      border-top: 6px solid #00A87D;
      max-width: 520px;
      width: 100%;
      z-index: 2;
      animation: slideIn 1s ease-out;
    }

    .form-container h2 {
      text-align: center;
      margin-bottom: 25px;
      font-size: 2rem;
      color: #222b38;
    }

    .form-group {
      margin-bottom: 20px;
    }

    label {
      display: block;
      margin-bottom: 6px;
      font-weight: 500;
      color: #5a677a;
    }

    input[type="text"],
    input[type="email"],
    textarea {
      width: 100%;
      padding: 12px;
      border: 1px solid #d8dde4;
      border-radius: 8px;
      font-size: 1rem;
      transition: all 0.2s;
    }

    input:focus,
    textarea:focus {
      border-color: #00A87D;
      box-shadow: 0 0 0 3px rgba(0, 168, 125, 0.2);
      outline: none;
    }

    textarea {
      resize: vertical;
      min-height: 100px;
    }

    button[type="submit"] {
      display: block;
      margin: 20px auto 0;
      padding: 12px 30px;
      background-color: #00A87D;
      color: white;
      border: none;
      border-radius: 25px;
      font-weight: 600;
      font-size: 1rem;
      cursor: pointer;
      transition: all 0.3s;
    }

    button:hover {
      background-color: #008261;
      transform: translateY(-2px);
    }
    
    /* Minimal style for server messages - will only apply if messages are present */
    .server-message {
        text-align: center;
        padding: 8px; 
        margin-bottom: 15px; 
        border-radius: 5px;
        font-size: 0.9rem; 
        border: 1px solid transparent; 
    }
    .server-message.success {
        background-color: #e6fffa;
        color: #00796B; 
        border-color: #b2dfdb; 
    }
    .server-message.error {
        background-color: #ffebee; 
        color: #c62828; 
        border-color: #ffcdd2; 
    }

    .visual {
      flex: 1;
      height: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      position: relative;
    }

    .blob {
      position: absolute;
      z-index: 0;
      width: 300px;
      height: 300px;
      background: radial-gradient(circle at 30% 30%, #a0e7e5, #65f7e8);
      border-radius: 50% 60% 50% 60% / 60% 50% 60% 50%;
      animation: float 6s ease-in-out infinite;
      opacity: 0.5;
    }

    .blob:nth-child(2) {
      width: 220px;
      height: 220px;
      left: 80px;
      top: 60px;
      background: radial-gradient(circle at 60% 40%, #81d4fa, #4fc3f7);
      animation-delay: 2s;
    }

    .skill-card {
      z-index: 1;
      width: 260px;
      padding: 20px;
      background: #ffffff;
      border-radius: 20px;
      box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
      text-align: center;
      position: relative;
      animation: popIn 1.2s ease-out;
    }

    .skill-card::before {
      content: "";
      position: absolute;
      top: -10px;
      right: -10px;
      width: 50px;
      height: 50px;
      background: #FFCA28;
      border-radius: 50%;
      opacity: 0.6;
    }

    .skill-card h3 {
      font-size: 1.4rem;
      margin-bottom: 10px;
      color: #00796B;
    }

    .skill-card p {
      font-size: 0.95rem;
      color: #546e7a;
    }

    @keyframes float {
      0%, 100% { transform: translateY(0); }
      50% { transform: translateY(20px); }
    }

    @keyframes popIn {
      0% { transform: scale(0.8); opacity: 0; }
      100% { transform: scale(1); opacity: 1; }
    }

    @keyframes slideIn {
      0% { transform: translateY(40px); opacity: 0; }
      100% { transform: translateY(0); opacity: 1; }
    }

    @media (max-width: 900px) {
      .container {
        flex-direction: column;
        height: auto; /* Allow content to determine height */
        padding-top: 30px; /* Adjusted from 50px for less top space if messages appear */
        padding-bottom: 30px; /* Add padding at bottom */
        overflow-y: auto; /* Allow scroll on small screens if form + message is too long */
        /* max-height: 100vh; Removed to allow scrolling beyond viewport if needed */
      }
      body { 
          /* On small screens, allow body to scroll if content overflows */
          height: auto; 
          overflow-y: auto;
      }

      .visual {
        height: 300px; /* Keep visual height fixed or make it smaller if needed */
        margin-top: 20px; /* Space between form and visual */
      }

      .blob {
        display: none;
      }

      .skill-card {
        margin-top: 0; /* Visual has margin now */
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="form-container">
      <h2>Contact Us</h2>
      
      <%-- Display message from servlet --%>
      <% String contactMessage = (String) request.getAttribute("contactMessage"); %>
      <% String contactMessageType = (String) request.getAttribute("contactMessageType"); %>
      <% if (contactMessage != null && !contactMessage.isEmpty()) { %>
        <div class="server-message <%= contactMessageType != null ? contactMessageType : "" %>">
            <%= contactMessage %>
        </div>
      <% } %>

      <%-- Form now submits to ContactServlet --%>
      <form action="${pageContext.request.contextPath}/ContactServlet" method="POST">
        <div class="form-group">
          <label for="contactName">Your Name:</label>
          <input type="text" id="contactName" name="name" placeholder="e.g., John Doe" required
                 value="<%= request.getAttribute("formName") != null ? request.getAttribute("formName") : "" %>">
        </div>
        <div class="form-group">
          <label for="contactEmail">Your Email:</label>
          <input type="email" id="contactEmail" name="email" placeholder="e.g., john@example.com" required
                 value="<%= request.getAttribute("formEmail") != null ? request.getAttribute("formEmail") : "" %>">
        </div>
        <div class="form-group">
          <label for="contactSubject">Subject:</label>
          <input type="text" id="contactSubject" name="subject" placeholder="e.g., General Inquiry" required
                 value="<%= request.getAttribute("formSubject") != null ? request.getAttribute("formSubject") : "" %>">
        </div>
        <div class="form-group">
          <label for="contactMessageContent">Message:</label>
          <textarea id="contactMessageContent" name="message" placeholder="Your message here..." required><%= request.getAttribute("formMessage") != null ? request.getAttribute("formMessage") : "" %></textarea>
        </div>
        <button type="submit">Send Message</button>
      </form>
    </div>

    <div class="visual">
      <div class="blob"></div>
      <div class="blob"></div>
      <div class="skill-card">
        <h3>Skill Swap</h3>
        <p>Share your skills, get help from others.<br/>Connect. Learn. Grow.</p>
      </div>
    </div>
  </div>
</body>
</html>