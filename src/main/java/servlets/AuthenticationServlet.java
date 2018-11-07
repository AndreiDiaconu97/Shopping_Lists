/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets;

import db.daos.NV_UserDAO;
import db.daos.Reg_UserDAO;
import db.entities.NV_User;
import db.entities.Reg_User;
import db.exceptions.DAOException;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.IOException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Authenticator;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author andrea
 */
public class AuthenticationServlet extends HttpServlet {

    Reg_UserDAO reg_userDao;
    NV_UserDAO nv_userDao;
    final String m_host = "smtp.gmail.com";
    final String m_port = "465";
    final String m_username = "test.progetto.lopardo@gmail.com";
    final String m_password = "Abcde1234%";
    Properties props;
    Session session;

    @Override
    public void init() throws ServletException {
        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new ServletException("Impossible to get dao factory");
        }
        try {
            reg_userDao = daoFactory.getDAO(Reg_UserDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for reg_user", ex);
        }
        try {
            nv_userDao = daoFactory.getDAO(NV_UserDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for nv_user", ex);
        }
        System.err.println("AUTH SERVLET ALMOST INITIALIZED");
        props = System.getProperties();
        props.setProperty("mail.smtp.host", m_host);
        props.setProperty("mail.smtp.port", m_port);
        props.setProperty("mail.smtp.socketFactory.port", m_port);
        props.setProperty("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
        props.setProperty("mail.smtp.auth", "true");
        props.setProperty("mail.smtp.starttls.enable", "true");
        props.setProperty("mail.debug", "true");

        session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(m_username, m_password);
            }
        });
        System.err.println("AUTH SERVLET INITIALIZED");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }
        
        // LOGOUT
        if (request.getParameter("logout") != null) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                Reg_User reg_user = (Reg_User) session.getAttribute("reg_user");
                if (reg_user != null) {
                    session.setAttribute("reg_user", null);
                    session.invalidate();
                    reg_user = null;
                }
            }

            if (!response.isCommitted()) {
                response.sendRedirect(response.encodeRedirectURL(contextPath + "login.html"));
            }
            
        // REGISTER  
        } else if (request.getParameter("register") != null) {
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String firstname = request.getParameter("firstname");
            String lastname = request.getParameter("lastname");
            System.err.println("REGISTERING " + email);
            // email and password can't be empty because input is "required"
            try {
                if (reg_userDao.getByEmail(email) != null) {
                    // already registered
                    response.sendRedirect(contextPath + "registration.html?alreadyRegistered=true");
                } else if (nv_userDao.getByEmail(email) != null) {
                    // already registered, need verification
                    response.sendRedirect(contextPath + "registration.html?needToVerify=true");
                } else {
                    String code = nv_userDao.generateCode(NV_User.getCODE_SIZE());
                    NV_User nv_user = new NV_User(email, password, firstname, lastname, code);
                    try {
                        nv_userDao.insert(nv_user);
                    } catch (DAOException ex) {
                        request.getServletContext().log("Impossible to register user");
                    }
                    // send email with code

                    String message = "http://localhost:8084/auth?validate=true&code=" + code;
                    System.err.println("Message is: " + message);

                    Message msg = new MimeMessage(session);
                    try {
                        msg.setFrom(new InternetAddress(m_username));
                        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(nv_user.getEmail(), false));
                        msg.setSubject("Lab 10 - Simple Example");
                        msg.setText(message);
                        msg.setSentDate(new java.util.Date());
                        Transport.send(msg);
                    } catch (MessagingException me) {
                        me.printStackTrace(System.err);
                    }
                }
            } catch (DAOException ex) {
                request.getServletContext().log("Impossible to check if user is already registered", ex);
            }
            System.err.println("REGISTERED " + email);
            
        // LOGIN
        } else if (request.getParameter("login") != null) {
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            // email and password can't be empty because input is "required"

            try {
                Reg_User reg_user = reg_userDao.getByEmailAndPassword(email, password);
                if (reg_user == null) {

                    if (reg_userDao.getByEmail(email) != null) {
                        // wrong password
                    } else if (nv_userDao.getByEmail(email) != null) {
                        // need to verify
                    } else {
                        // need to register
                    }

                    //response.sendRedirect(response.encodeRedirectURL(contextPath + "login.handler"));
                } else {
                    request.getSession().setAttribute("reg_user", reg_user);
                    if (reg_user.getIs_admin()) {
                        response.sendRedirect(response.encodeRedirectURL(contextPath + "restricted/admin"));
                    } else {
                        response.sendRedirect(response.encodeRedirectURL(contextPath + "restricted/shopping.lists.html"));
                    }
                }
            } catch (DAOException ex) {
                request.getServletContext().log("Impossible to retrieve the user", ex);
            }
            
        // VALIDATE
        } else if (request.getParameter("validate") != null) {
            String code = request.getParameter("code");
            try {
                nv_userDao.validateUsingCode(code);
            } catch (DAOException ex) {
                request.getServletContext().log("Unable to validate user", ex);
            }
            
        // CHANGE PASSWORD
        } else if (request.getParameter("changepsw") != null) {

        } else {
            // bad request
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
