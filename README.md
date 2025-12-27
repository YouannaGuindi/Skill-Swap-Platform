# Skill Swap Platform

A web-based platform for users to swap skills and connect with others.  
Built using **Java, JSP, and Maven**.

---

## Features

- User registration and login  
- Skill posting and swapping system  
- Search and filter skills  
- Email notifications (SMTP credentials removed for security)  

---

## Demo Video

Watch the platform in action: [▶️ Demo Video](https://drive.google.com/drive/folders/1a2j8v1hhvAGhPCzuvIPGtiGehILCxR1w?usp=sharing)

> Note: Email sending requires SMTP credentials which are not included for security.  
> All other features work without email setup.

---

## Installation & Running

1. Clone the repository: ```bash
git clone https://github.com/YouannaGuindi/Skill-Swap-Platform.git

2. Import into Eclipse as a Maven project.

3. Run on a Tomcat server (or any Java web server).

4. Open in a browser at http://localhost:8080/Skill-Swap-Platform.

## Database Setup

This project uses a MySQL database. To set it up locally:

1. Open phpMyAdmin (XAMPP/MAMP) or MySQL Workbench.

2. Create a database, e.g., skillswap_db.

3. Import the provided SQL file or create tables manually:

4. Update DBConnectionUtil.java (or wherever your DB config is) with:
    
    db.url=jdbc:mysql://localhost:3306/skillswap_db
    db.user=YOUR_DB_USERNAME
    db.password=YOUR_DB_PASSWORD

5. Restart the local server and run the project.

