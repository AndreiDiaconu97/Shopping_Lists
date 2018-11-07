/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets;

import db.daos.NV_UserDAO;
import db.daos.Reg_UserDAO;
import db.entities.NV_User;
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
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }
        
        if (request.getParameter("login") != null) {

        } else if (request.getParameter("register") != null) {
            System.err.println("REGISTERING YOZA");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String firstname = request.getParameter("firstname");
            String lastname = request.getParameter("lastname");
            // email and password can't be empty because input is "required"
            try {
                if (reg_userDao.getByEmail(email) != null) {
                    // already registered
                    response.sendRedirect(contextPath + "registration.html?alreadyRegistered=true");
                } else if (nv_userDao.getByEmail(email) != null) {
                    // already registered, need verification
                    response.sendRedirect(contextPath + "registration.html?needToVerify=true");
                } else {
                    String code = nv_userDao.generateCode(NV_User.getCode_size());
                    NV_User nv_user = new NV_User(email, password, firstname, lastname, code);
                    try {
                        nv_userDao.insert(nv_user);
                    } catch (DAOException ex) {
                        request.getServletContext().log("Impossible to register user");
                    }
                    // send email with code

                    String message = "http://localhost:8085/try2/Servletmerda?code=" + code + "&check_id=True";

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
        } else if (request.getParameter("logout") != null) {

        } else if (request.getParameter("validate") != null) {

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
