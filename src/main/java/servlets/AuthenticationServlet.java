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
        super.getServletContext().log("AUTH SERVLET ALMOST INITIALIZED");
        props = System.getProperties();
        props.setProperty("mail.smtp.host", m_host);
        props.setProperty("mail.smtp.port", m_port);
        props.setProperty("mail.smtp.socketFactory.port", m_port);
        props.setProperty("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
        props.setProperty("mail.smtp.auth", "true");
        props.setProperty("mail.smtp.starttls.enable", "true");
        //props.setProperty("mail.debug", "true");

        session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(m_username, m_password);
            }
        });
        super.getServletContext().log("AUTH SERVLET INITIALIZED");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }

        // VALIDATE
        if (request.getParameter("validate") != null) {
            String code = request.getParameter("code");
            try {
                nv_userDao.validateUsingCode(code);
            } catch (DAOException ex) {
                request.getServletContext().log("Unable to validate user", ex);
                response.sendRedirect(contextPath + "registration.html?status=error");
                return;
            }
            request.getServletContext().log("Validated user");
            response.sendRedirect(contextPath + "login.html?status=validated");
            return;
        } else {
            // bad request
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }

        String status = "";
        String action = "";
        if (request.getParameter("action") != null) {
            action = request.getParameter("action");
        }

        switch (action) {
            case "logout": {
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
                    return;
                }
                break;
            }
            case "register": {
                String email = request.getParameter("email");
                String password = request.getParameter("password");
                String firstname = request.getParameter("firstname");
                String lastname = request.getParameter("lastname");
                request.getServletContext().log("REGISTERING " + email);
                // email and password can't be empty because input is "required"
                try {
                    if (reg_userDao.getByEmail(email) != null) {
                        status = "alreadyregistered";
                    } else if (nv_userDao.getByEmail(email) != null) {
                        status = "needtoverify";
                    } else {
                        NV_User nv_user = new NV_User(email, password, firstname, lastname, null);
                        String code = nv_user.getCode();
                        try {
                            nv_userDao.insert(nv_user);
                        } catch (DAOException ex) {
                            request.getServletContext().log("Impossible to register user");
                            status = "error";
                            break;
                        }
                        // send email with code
                        String message = "http://localhost:8084/Shopping/auth?validate=true&code=" + code
                                + "\n\nYour pass is: " + password;
                        request.getServletContext().log("Message is: " + message);

                        Message msg = new MimeMessage(session);
                        try {
                            msg.setFrom(new InternetAddress(m_username));
                            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(nv_user.getEmail(), false));
                            msg.setSubject("Registration to LopardoShopping");
                            msg.setText(message);
                            msg.setSentDate(new java.util.Date());
                            Transport.send(msg);
                        } catch (MessagingException me) {
                            me.printStackTrace(System.err);
                            status = "mailerror";
                            break;
                        }
                    }
                } catch (DAOException ex) {
                    request.getServletContext().log("Impossible to check if user is already registered", ex);
                    status = "dberror";
                    break;
                }
                request.getServletContext().log("REGISTERED " + email);
                status = "success";
                break;
            }
            case "login": {
                String email = request.getParameter("email");
                String password = request.getParameter("password");
                // email and password can't be empty because input is "required"
                try {
                    Reg_User reg_user = reg_userDao.getByEmailAndPassword(email, password);
                    if (reg_user == null) {
                        if (reg_userDao.getByEmail(email) != null) {
                            status = "wrongpsw";
                        } else if (nv_userDao.getByEmail(email) != null) {
                            status = "needtoverify";
                        } else {    
                            status = "needtoregister";
                        }
                    } else {
                        request.getSession().setAttribute("reg_user", reg_user);
                        if (reg_user.getIs_admin()) {
                            response.sendRedirect(response.encodeRedirectURL(contextPath + "restricted/admin"));
                        } else {
                            response.sendRedirect(response.encodeRedirectURL(contextPath + "restricted/shopping.lists.html"));
                        }
                        return;
                    }
                } catch (DAOException ex) {
                    request.getServletContext().log("Impossible to retrieve the user", ex);
                    status = "dberror";
                }
                break;
            }
            case "changepsw":
                // nothing yet
                break;
            // bad request
            default:
                break;
        }
        response.sendRedirect(contextPath + "login.html" + (status.equals("") ? "" : "?status=") + status);
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
