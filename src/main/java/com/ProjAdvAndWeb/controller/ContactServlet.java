package com.ProjAdvAndWeb.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.ProjAdvAndWeb.util.EmailUtil;



@WebServlet("/ContactServlet")
public class ContactServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String subjectFromUser = request.getParameter("subject");
        String messageContent = request.getParameter("message");

        boolean isValid = true;
        StringBuilder errorMessage = new StringBuilder();
        if (name == null || name.trim().isEmpty()) { isValid = false; errorMessage.append("Name is required. "); }
        if (email == null || email.trim().isEmpty()) { isValid = false; errorMessage.append("Email is required. "); }
        else if (!email.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")) { isValid = false; errorMessage.append("Valid email required. ");}
        if (subjectFromUser == null || subjectFromUser.trim().isEmpty()) { isValid = false; errorMessage.append("Subject is required. "); }
        if (messageContent == null || messageContent.trim().isEmpty()) { isValid = false; errorMessage.append("Message is required. "); }

        if (!isValid) {
            request.setAttribute("contactMessage", errorMessage.toString().trim());
            request.setAttribute("contactMessageType", "error");
            request.setAttribute("formName", name);
            request.setAttribute("formEmail", email);
            request.setAttribute("formSubject", subjectFromUser);
            request.setAttribute("formMessage", messageContent);
            request.getRequestDispatcher("/contact.jsp").forward(request, response);
            return;
        }

        System.out.println("--- Contact Form Submission Received ---");
        System.out.println("Name: " + name);
        System.out.println("Email: " + email);
        System.out.println("Subject: " + subjectFromUser);
        System.out.println("Message: " + messageContent);
        System.out.println("----------------------------------------");
        // TODO: Implement actual storage/processing of the contact message here (e.g., save to DB)

        // 4. Attempt to send the internal notification TO THE SYSTEM'S SENDER EMAIL
        boolean systemNotificationSent = EmailUtil.sendContactNotificationToSystem(name, email, subjectFromUser, messageContent);

        if (!systemNotificationSent) {
            System.err.println("CRITICAL: Failed to send contact form notification to the system email (" +
                               EmailUtil.class.getClassLoader().getResourceAsStream("email.properties") != null ? // Quick check
                               new java.util.Properties().getProperty("smtp.sender.email", "NOT_FOUND_IN_PROPS") : "PROPS_NOT_LOADED" +
                               "). Check email configuration and server logs.");
            // This is an internal failure. The user experience should still focus on their confirmation.
        }

        // 5. Attempt to send the confirmation email to the user
        boolean userConfirmationSent = EmailUtil.sendContactUsConfirmation(email, name, subjectFromUser);

        if (userConfirmationSent) {
            request.setAttribute("contactMessage", "Your message has been sent successfully! A confirmation email is on its way to " + email + ".");
            request.setAttribute("contactMessageType", "success");
        } else {
            request.setAttribute("contactMessage", "Your message has been received. However, we encountered an issue sending a confirmation email to " + email + ". Our team will still review your message.");
            request.setAttribute("contactMessageType", "error");
            request.setAttribute("formName", name);
            request.setAttribute("formEmail", email);
            request.setAttribute("formSubject", subjectFromUser);
            request.setAttribute("formMessage", messageContent);
        }

        request.getRequestDispatcher("/contact.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/contact.jsp");
    }
}