package com.ProjAdvAndWeb.util;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.time.Year;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;


public class EmailUtil {

    private static final String CONFIG_FILE = "email.properties";
    private static Properties emailProps = new Properties();
    private static boolean configLoaded = false;

    static {
        System.out.println("EmailUtil: Static block attempting to load " + CONFIG_FILE);
        try (InputStream input = EmailUtil.class.getClassLoader().getResourceAsStream(CONFIG_FILE)) {
            if (input == null) {
                System.err.println("FATAL: EmailUtil cannot find " + CONFIG_FILE + " in classpath.");
            } else {
                emailProps.load(input);
                System.out.println("EmailUtil: " + CONFIG_FILE + " loaded. Checking properties...");
                // Simplified check for demo, assuming essential ones will be there
                if (emailProps.getProperty("smtp.host") == null ||
                    emailProps.getProperty("smtp.user") == null ||
                    emailProps.getProperty("smtp.password") == null ||
                    emailProps.getProperty("smtp.sender.email") == null) {
                    System.err.println("FATAL: Basic SMTP properties missing (host, user, password, sender.email).");
                    configLoaded = false;
                } else {
                    configLoaded = true;
                    System.out.println("EmailUtil: Email configuration loaded successfully.");
                }
            }
        } catch (Exception e) {
            System.err.println("FATAL: Exception during EmailUtil static block: " + e.getMessage());
            e.printStackTrace();
            configLoaded = false;
        }
        System.out.println("EmailUtil: Static block finished. configLoaded = " + configLoaded);
    }

    private EmailUtil() { }

    private static boolean sendCoreEmail(String toEmail, String subject, String plainTextBody) {
        if (!configLoaded) {
            System.err.println("EmailUtil: Email configuration was NOT loaded. Cannot send email.");
            return false;
        }
        if (toEmail == null || toEmail.trim().isEmpty() || subject == null || plainTextBody == null) {
            System.err.println("EmailUtil: Missing toEmail, subject, or body.");
            return false;
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", emailProps.getProperty("smtp.host"));
        props.put("mail.smtp.port", emailProps.getProperty("smtp.port", "587")); // Default to 587

        // ***** FORCE STARTTLS FOR DEMO *****
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true"); // FORCE IT
        // props.put("mail.smtp.starttls.required", "true"); // Can also try this
        // props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3"); // Specify modern protocols
        // ***** END FORCE *****

        if ("true".equalsIgnoreCase(emailProps.getProperty("smtp.debug", "false"))) {
            props.put("mail.debug", "true");
            System.out.println("EmailUtil: JavaMail Session debug enabled.");
        }

        final String smtpUser = emailProps.getProperty("smtp.user");
        final String smtpPassword = emailProps.getProperty("smtp.password");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(smtpUser, smtpPassword);
            }
        });

        try {
            MimeMessage message = new MimeMessage(session);
            String senderEmail = emailProps.getProperty("smtp.sender.email");
            String senderName = emailProps.getProperty("smtp.sender.name", "SkillSwap Support");

            message.setFrom(new InternetAddress(senderEmail, senderName));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject, "UTF-8");
            message.setText(plainTextBody, "UTF-8", "plain");

            System.out.println("EmailUtil: Attempting to send email (FORCED STARTTLS) to: " + toEmail);
            Transport.send(message);
            System.out.println("EmailUtil: Email sent to " + toEmail + " | Subject: " + subject);
            return true;
        } catch (AuthenticationFailedException e) {
            System.err.println("EmailUtil: SMTP Authentication Failed for user: " + smtpUser);
            e.printStackTrace();
            return false;
        } catch (MessagingException e) {
            System.err.println("EmailUtil: MessagingException sending email to " + toEmail + ". Details: " + e.getMessage());
            e.printStackTrace();
            Exception nextEx = e.getNextException();
            if (nextEx != null) {
                System.err.println("EmailUtil: Nested exception: ");
                nextEx.printStackTrace();
            }
            return false;
        } catch (Exception e) {
            System.err.println("EmailUtil: Unexpected error sending email to " + toEmail);
            e.printStackTrace();
            return false;
        }
    }

    // ... (getFooter and all your public static email sending methods remain the same) ...
    // Ensure they are all present and call the sendCoreEmail above.
    private static String getFooter() {
        String appName = emailProps.getProperty("smtp.sender.name", "SkillSwap");
        return String.format("\n\n---\nThank you,\nThe %s Team\n© %d %s",
                appName, Year.now().getValue(), appName);
    }

    public static boolean sendWelcomeEmail(String toEmail, String username, int startingPoints, String verificationLink) {
        if (!configLoaded) { System.err.println("WelcomeEmail: Config not loaded."); return false; }
        if (username == null || verificationLink == null || toEmail == null || toEmail.isEmpty()) { System.err.println("WelcomeEmail: Missing params."); return false; }
        String appName = emailProps.getProperty("smtp.sender.name", "SkillSwap");
        String subject = "Welcome to " + appName + ", " + username + "!";
        String body = String.format(
            "Hi %s,\n\n" +
            "Welcome to %s!\n" +
            "Congratulations, you have earned %d points to start your swaps.\n\n" +
            "Please click the following link to verify your email address:\n%s" +
            "%s",
            username, appName, startingPoints, verificationLink, getFooter()
        );
        return sendCoreEmail(toEmail, subject, body);
    }

    public static boolean sendPasswordResetEmail(String toEmail, String username, String resetLink) {
         if (!configLoaded) { System.err.println("PasswordResetEmail: Config not loaded."); return false; }
        if (username == null || resetLink == null || toEmail == null || toEmail.isEmpty()) { System.err.println("PasswordResetEmail: Missing params."); return false; }
        String appName = emailProps.getProperty("smtp.sender.name", "SkillSwap");
        String subject = "Password Reset Request for " + appName;
        String body = String.format(
            "Hi %s,\n\n" +
            "We received a request to reset the password for your SkillSwap account.\n\n" +
            "To reset your password, click the link below.\n\n" +
            "Reset Password Link: %s\n\n" +
            "If you did not request a password reset, please ignore this email.\n\n" +
            "%s",
            username, resetLink, getFooter()
        );
        return sendCoreEmail(toEmail, subject, body);
    }

    public static boolean sendSwapConfirmationEmails(String requesterEmail, String providerEmail,
                                                  String requesterName, String providerName,
                                                  String skillRequesterReceivesName,
                                                  int pointsExchanged) {
        if (!configLoaded) {
             System.err.println("EmailUtil (sendSwapConfirmationEmails): Email config not loaded. Cannot send.");
             return false;
        }
         if (requesterEmail == null || requesterEmail.trim().isEmpty() ||
             providerEmail == null || providerEmail.trim().isEmpty() ||
             requesterName == null || requesterName.trim().isEmpty() ||
             providerName == null || providerName.trim().isEmpty() ||
             skillRequesterReceivesName == null || skillRequesterReceivesName.trim().isEmpty()) {
              System.err.println("EmailUtil (sendSwapConfirmationEmails): Missing required details (emails, names, skill name).");
              return false;
         }

        boolean requesterEmailSent = false;
        boolean providerEmailSent = false;
        String appName = emailProps.getProperty("smtp.sender.name", "SkillSwap");
        String footer = getFooter();

        String subjectToRequester = "Skill Swap Confirmed! Connect with " + providerName;
        String pointsTextForRequester = (pointsExchanged > 0) ? String.format("This transaction involved an exchange of %d points from your account.\n\n", pointsExchanged) : "";
        String bodyToRequesterPlainText = String.format(
            "Hi %s,\n\n" + 
            "Great news! Your request to access the skill '%s', offered by %s, has been confirmed!\n\n" + 
            "%s" + 
            "You can now connect with %s to arrange the details of receiving the skill.\n\n" + 
            "Here is their email address: %s\n\n" + 
            "Happy Swapping!\n" + 
            "%s", 
            requesterName, skillRequesterReceivesName, providerName,
            pointsTextForRequester, 
            providerName, providerEmail,
            footer
        );
        try {
             requesterEmailSent = sendCoreEmail(requesterEmail, subjectToRequester, bodyToRequesterPlainText);
        } catch (Exception e) { 
             System.err.println("EmailUtil: Error sending confirmation email to requester " + requesterEmail);
             e.printStackTrace();
        }

        String subjectToProvider = "Skill Swap Confirmed! Connect with " + requesterName;
        String pointsTextForProvider = (pointsExchanged > 0) ? String.format("You have earned %d points from this transaction.\n\n", pointsExchanged) : "";
         String bodyToProviderPlainText = String.format(
            "Hi %s,\n\n" + 
            "Good news! The skill swap request from %s to access your skill '%s' has been confirmed!\n\n" + 
            "%s" + 
            "You can now connect with %s to arrange the details of transferring the skill.\n\n" + 
            "Here is their email address: %s\n\n" + 
            "Happy Swapping!\n" +
            "%s", 
            providerName, requesterName, skillRequesterReceivesName,
            pointsTextForProvider, 
            requesterName, requesterEmail,
            footer
        );
        try {
             providerEmailSent = sendCoreEmail(providerEmail, subjectToProvider, bodyToProviderPlainText);
        } catch (Exception e) {
             System.err.println("EmailUtil: Error sending confirmation email to provider " + providerEmail);
             e.printStackTrace();
        }
        return requesterEmailSent && providerEmailSent;
    }
    
    public static boolean sendSkillAccessedNotification(String toProviderEmail, String providerName, String skillName, String accessorName, int pointsEarnedByProvider) {
        if (!configLoaded) { System.err.println("SkillAccessed: Config not loaded."); return false; }
        if (providerName == null || skillName == null || accessorName == null) { return false; }
        String subject = "Someone Accessed Your Skill: " + skillName;
        String body = String.format(
            "Hi %s,\n\n" +
            "%s has accessed your skill: '%s'.\n\n" +
            "You have earned %d points for this!" +
            "%s",
            providerName, accessorName, skillName, pointsEarnedByProvider, getFooter()
        );
        return sendCoreEmail(toProviderEmail, subject, body);
    }

    public static boolean sendPointsSpentNotification(String toUserEmail, String username, String skillName, String providerName, int pointsSpent, int newBalance) {
        if (!configLoaded) { System.err.println("PointsSpent: Config not loaded."); return false; }
        if (username == null || skillName == null || providerName == null ) { return false; }
        String appName = emailProps.getProperty("smtp.sender.name", "SkillSwap");
        String subject = "Points Spent on " + appName;
        String body = String.format(
            "Hi %s,\n\n" +
            "You spent %d points to access the skill '%s' from %s.\n\n" +
            "Your new balance is %d points." +
            "%s",
            username, pointsSpent, skillName, providerName, newBalance, getFooter()
        );
        return sendCoreEmail(toUserEmail, subject, body);
    }
    public static boolean sendPointsBalanceChangeNotification(String toEmail, String username, int pointsChanged, String reason, int newTotalBalance) {
        if (!configLoaded) { System.err.println("sendPointsBalanceChangeNotification: Config not loaded."); return false; }
        if (username == null || reason == null) { return false; }
        String appName = emailProps.getProperty("smtp.sender.name", "SkillSwap");
        String subject = "Your " + appName + " Points Balance Updated";
        String changeDescription = pointsChanged >= 0 ? "earned " + pointsChanged : "spent " + (-pointsChanged); 

        String body = String.format(
            "Hi %s,\n\n" +
            "Your points balance has been updated. You %s points.\n\n" +
            "Reason: %s\n" +
            "Your new total balance is %d points." +
            "%s",
            username, changeDescription, reason, newTotalBalance, getFooter()
        );
        return sendCoreEmail(toEmail, subject, body);
    }
    
    public static boolean sendContactUsConfirmation(String toContactEmail, String contactName, String contactSubjectFromUser) {
        if (!configLoaded) { 
            System.err.println("EmailUtil (sendContactUsConfirmation): Email config not loaded.");
            return false;
        }
        if (contactName == null || contactName.trim().isEmpty() ||
            contactSubjectFromUser == null || contactSubjectFromUser.trim().isEmpty() ||
            toContactEmail == null || toContactEmail.trim().isEmpty()) { 
            System.err.println("EmailUtil: Contact name, user's subject, or recipient email is missing for confirmation email.");
            return false;
        }

        String appName = emailProps.getProperty("smtp.sender.name", "SkillSwap");
        String subjectForConfirmationEmail = "Thank you for contacting " + appName + "!";

        String body = String.format(
            "Hi %s,\n\n" +
            "Thank you for contacting us at %s. We have received your message regarding: '%s'.\n\n" +
            "Someone from our team will get in touch with you soon regarding your concerns.\n\n" +
            "Please do not reply directly to this automated email." +
            "%s", 
            contactName, appName, contactSubjectFromUser, getFooter()
        );

        return sendCoreEmail(toContactEmail, subjectForConfirmationEmail, body);
    }
 
     public static boolean sendContactNotificationToSystem(String userName, String userEmail, String userSubject, String userMessage) {
         if (!configLoaded) {
             System.err.println("EmailUtil (sendContactNotificationToSystem): Email config not loaded.");
             return false;
         }
         String systemRecipientEmail = emailProps.getProperty("smtp.sender.email");

         if (systemRecipientEmail == null || systemRecipientEmail.trim().isEmpty()) {
             System.err.println("EmailUtil: smtp.sender.email is not configured in email.properties. Cannot send system notification.");
             return false;
         }

         if (userName == null || userEmail == null || userSubject == null || userMessage == null) {
             System.err.println("EmailUtil: Missing user details for system notification.");
             return false;
         }

         String appName = emailProps.getProperty("smtp.sender.name", "SkillSwap");
         String subjectForSystem = "[" + appName + " Contact Form] New Message from " + userName + ": " + userSubject;

         String body = String.format(
             "A new contact form submission has been received from the %s website:\n\n" +
             "User's Name: %s\n" +
             "User's Email: %s\n" + 
             "User's Subject: %s\n\n" +
             "User's Message:\n------------------------------------\n%s\n------------------------------------\n\n" +
             "You can reply to the user directly at: %s",
             appName, userName, userEmail, userSubject, userMessage, userEmail
         );
         return sendCoreEmail(systemRecipientEmail, subjectForSystem, body);
     }

     public static boolean sendSwapRequestNotification(String toProviderEmail, String providerName,
                                                  String requesterName, String skillName, int pointsOffered,
                                                  String swapLink) {
        if (!configLoaded) { System.err.println("sendSwapRequestNotification: Config not loaded."); return false; }
        if (providerName == null || requesterName == null || skillName == null || swapLink == null) {
            System.err.println("sendSwapRequestNotification: Missing details for swap request email.");
            return false;
        }

        String appName = emailProps.getProperty("smtp.sender.name", "SkillSwap");
        String subject = "New Skill Swap Request from " + requesterName;
        String body = String.format(
            "Hi %s,\n\n" +
            "%s has requested to swap for your skill '%s', offering %d points.\n\n" +
            "You can view and manage this request here:\n%s\n\n" +
            "If you did not expect this, you can ignore this email or check your account.\n" +
            "%s", 
            providerName, requesterName, skillName, pointsOffered, swapLink, getFooter()
        );
        return sendCoreEmail(toProviderEmail, subject, body);
    }
}