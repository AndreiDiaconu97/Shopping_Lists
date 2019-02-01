/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets;

import db.daos.List_anonymousDAO;
import db.daos.List_regDAO;
import db.daos.NV_UserDAO;
import db.entities.NV_User;
import db.entities.User;
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
import db.daos.UserDAO;
import db.entities.List_anonymous;
import db.entities.List_reg;
import db.entities.Product;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import javax.servlet.http.Cookie;

/**
 *
 * @author andrea
 */
public class AuthenticationServlet extends HttpServlet {

    UserDAO userDao;
    NV_UserDAO nv_userDao;
    List_regDAO list_regDao;
    List_anonymousDAO list_anonymousDao;
    final String m_host = "smtp.gmail.com";
    final String m_port = "465";
    final String m_username = "test.progetto.lopardo@gmail.com";
    final String m_password = "Abcde1234%";
    Properties props;
    Session mail_session;

    @Override
    public void init() throws ServletException {
        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new ServletException("Impossible to get dao factory");
        }
        try {
            userDao = daoFactory.getDAO(UserDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for user", ex);
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

        mail_session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(m_username, m_password);
            }
        });
        super.getServletContext().log("AUTH SERVLET INITIALIZED");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }

        // VALIDATE
        if (request.getParameter("validate") != null) {
            String email = request.getParameter("email");
            String code = request.getParameter("code");
            try {
                User user = nv_userDao.validateUsingEmailAndCode(email, code);
                HttpSession session = request.getSession(false);
                if (session != null && user != null) {
                    session.setAttribute("user", user);
                }

                Cookie[] cookies = request.getCookies();
                String listID_s = null;
                for (Cookie c : cookies) {
                    if ("anonymous_list_ID".equals(c.getName())) {
                        listID_s = c.getValue();
                    }
                }
                if (listID_s != null) {
                    try {
                        Integer listID = Integer.parseInt(listID_s);
                        List_anonymous list_anonymous = list_anonymousDao.getByPrimaryKey(listID);
                        List<Product> products = list_anonymousDao.getProducts(list_anonymous);
                        List_reg list_reg = new List_reg(list_anonymous.getName(), user, list_anonymous.getCategory(), list_anonymous.getDescription());
                        list_regDao.insert(list_reg);
                        for (Product p : products) {
                            list_regDao.insertProduct(list_reg, p, list_anonymousDao.getAmountTotal(list_anonymous, p));
                            list_regDao.updateAmountPurchased(list_reg, p, list_anonymousDao.getAmountPurchased(list_anonymous, p));
                        }
                        list_anonymousDao.delete(list_anonymous);
                        response.addCookie(new Cookie("anonymous_list_ID", null));
                    } catch (DAOException e) {
                        System.err.println("Cannot transfer anonymous list to normal list");
                    }
                }
            } catch (DAOException ex) {
                request.getServletContext().log("Unable to validate user", ex);
                response.sendRedirect(contextPath + "registration.html?status=error");
                return;
            }
            request.getServletContext().log("Validated user");
            response.sendRedirect(contextPath + "login.html?status=validated");
        } else {
            // bad request
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

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
                    User user = (User) session.getAttribute("user");
                    if (user != null) {
                        session.setAttribute("user", null);
                        session.invalidate();
                        user = null;
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
                    if (userDao.getByEmail(email) != null) {
                        status = "alreadyregistered";
                    } else if (nv_userDao.getByEmail(email) != null) {
                        status = "needtoverify";
                    } else {
                        NV_User nv_user = new NV_User(email, password, firstname, lastname);
                        String code = nv_user.getCode();
                        
                        try {
                            nv_userDao.insert(nv_user);
                        } catch (DAOException ex) {
                            request.getServletContext().log("Impossible to register user");
                            status = "error";
                            break;
                        }
                        // send email with code
                        String link = "http://localhost:8084" + contextPath + "auth?validate=true&email=" + nv_user.getEmail() + "&code=" + code;
                        request.getServletContext().log("Message is: " + link);

                        Message msg = new MimeMessage(mail_session);
                        try {
                            File email_html = new File((String) getServletContext().getInitParameter("realPath") + "\\src\\main\\webapp\\WEB-INF\\email.html");
                            byte[] encoded = Files.readAllBytes(Paths.get(email_html.getAbsolutePath()));
                            String email_string = new String(encoded, "UTF-8");
                            email_string = email_string.replace("NOME E COGNOME", nv_user.getFirstname() + " " + nv_user.getLastname());
                            email_string = email_string.replace("LINK", link);
                            msg.setFrom(new InternetAddress(m_username, "LISTR shopping"));
                            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(nv_user.getEmail(), false));
                            msg.setSubject("Registration to LISTR");
                            msg.setContent(email_string, "text/html");
                            msg.setSentDate(new java.util.Date());
                            Transport.send(msg);
                        } catch (MessagingException me) {
                            me.printStackTrace(System.err);
                            System.err.println("MAIL ERROR");
                            status = "mailerror";
                            break;
                        }
                        request.getServletContext().log("REGISTERED " + email);
                        status = "success";
                    }
                } catch (DAOException ex) {
                    request.getServletContext().log("Impossible to check if user is already registered", ex);
                    status = "dberror";
                }
                break;
            }
            case "login": {
                String email = request.getParameter("email");
                String password = request.getParameter("password");
                // email and password can't be empty because input is "required"
                try {
                    User user = userDao.getByEmailAndPassword(email, password);
                    if (user == null) {
                        if (userDao.getByEmail(email) != null) {
                            status = "wrongpsw";
                        } else if (nv_userDao.getByEmail(email) != null) {
                            status = "needtoverify";
                        } else {
                            status = "needtoregister";
                        }
                    } else {
                        request.getSession().setAttribute("user", user);
                        if (user.getIs_admin()) {
                            response.sendRedirect(response.encodeRedirectURL(contextPath + "admin/admin.html"));
                        } else {
                            response.sendRedirect(response.encodeRedirectURL(contextPath + "restricted/homepage.html"));
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
