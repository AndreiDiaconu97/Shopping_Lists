/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets.user;

import db.daos.List_categoryDAO;
import db.daos.List_regDAO;
import db.daos.Prod_categoryDAO;
import db.daos.ProductDAO;
import db.entities.List_reg;
import db.entities.Product;
import db.entities.User;
import db.exceptions.DAOException;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.IOException;
import java.util.List;
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
import db.entities.List_category;

public class ShoppingListServlet extends HttpServlet {

    private UserDAO userDao;
    private List_regDAO list_regDao;
    private List_categoryDAO list_categoryDao;
    private ProductDAO productDao;
    private Prod_categoryDAO prod_categoryDao;
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
            list_regDao = daoFactory.getDAO(List_regDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for list_reg", ex);
        }
        try {
            list_categoryDao = daoFactory.getDAO(List_categoryDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for list_category", ex);
        }
        try {
            productDao = daoFactory.getDAO(ProductDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for product", ex);
        }
        try {
            prod_categoryDao = daoFactory.getDAO(Prod_categoryDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for prod_category", ex);
        }
        try {
            userDao = daoFactory.getDAO(UserDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for user", ex);
        }

        props = System.getProperties();
        props.setProperty("mail.smtp.host", m_host);
        props.setProperty("mail.smtp.port", m_port);
        props.setProperty("mail.smtp.socketFactory.port", m_port);
        props.setProperty("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
        props.setProperty("mail.smtp.auth", "true");
        props.setProperty("mail.smtp.starttls.enable", "true");

        session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(m_username, m_password);
            }
        });
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }

        if (request.getParameter("sharedlist") != null) {
            Integer id = Integer.parseInt(request.getParameter("sharedlist"));
            String email = request.getParameter("email");
            response.setCharacterEncoding("UTF-8");
            String ownerEmail;
            User owner;
            Integer check = 1;
            try {
                List_reg list = list_regDao.getByPrimaryKey(id);
                owner = list.getOwner();
                ownerEmail = owner.getEmail();
                List<User> users = list_regDao.getUsersSharedTo(list);

                for (User user : users) {
                    if (user.getEmail().equals(email)) {
                        check = 2;
                    }
                }
                if (ownerEmail.equals(email)) {
                    check = 3;
                }
            } catch (DAOException ex) {
                System.err.println("errors");
            }

            System.err.println(check);

            if (check == 2) {
                response.getWriter().print("already");
            } else if (check == 3) {
                response.getWriter().print("same");
            } else {
                List_reg list = new List_reg();
                User Owner = new User();

                try {
                    list = list_regDao.getByPrimaryKey(id);
                    Owner = list.getOwner();
                } catch (DAOException ex) {
                    System.err.println("");
                }

                String firstname = Owner.getFirstname();
                String lastname = Owner.getLastname();
                String message = "Ehi " + firstname + " invited you to join his list! Click on the link below to join!"
                        + "\n\n http://localhost:8084/Shopping/restricted/shopping.lists.handler?share=true&list_id=" + id + "&email=" + email;

                Message msg = new MimeMessage(session);
                try {
                    msg.setFrom(new InternetAddress(m_username));
                    msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email, false));
                    msg.setSubject("Invite from " + firstname + " " + lastname);
                    msg.setText(message);
                    msg.setSentDate(new java.util.Date());
                    Transport.send(msg);
                } catch (MessagingException me) {
                    me.printStackTrace(System.err);
                    response.getWriter().print("error");
                }
                response.getWriter().print("success");
            }
        }

        if (request.getParameter("share") != null) {
            String email = request.getParameter("email");
            Integer id = Integer.parseInt(request.getParameter("list_id"));

            try {
                List_reg list = list_regDao.getByPrimaryKey(id);
                User user = userDao.getByEmail(email);
                list_regDao.shareListToUser(list, user);

            } catch (DAOException ex) {
                System.err.println("Cannot share the list");
            }

            response.sendRedirect(contextPath + "restricted/homepage.html");
        }

        if (request.getParameter("shareurl") != null) {
            Integer id = Integer.parseInt(request.getParameter("id"));
            HttpSession session = request.getSession(false);
            User user = null;
            user = (User) session.getAttribute("user");

            try {
                List_reg list = list_regDao.getByPrimaryKey(id);
                list_regDao.shareListToUser(list, user);

            } catch (DAOException ex) {
                System.err.println("Cannot share the list");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }

        String action = "";
        if (request.getParameter("action") != null) {
            action = request.getParameter("action");
        }

        switch (action) {
            case "create": {
                try {
                    HttpSession session = request.getSession(false);
                    User user = (User) session.getAttribute("user");
                    String name = request.getParameter("name");
                    String description = request.getParameter("description");
                    Integer cat_id = Integer.valueOf(request.getParameter("category"));
                    List_category l_cat = list_categoryDao.getByPrimaryKey(cat_id);
                    List_reg list = new List_reg(name, user, l_cat, description);
                    list_regDao.insert(list);
                } catch (Exception ex) {
                    System.err.println("Cannot insert list: " + ex.getMessage());
                }
                break;
            }
            case "edit": {
                HttpSession session = request.getSession(false);
                User user = (User) session.getAttribute("user");
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                Integer cat_id = Integer.parseInt(request.getParameter("category"));
                try {
                    List_category l_cat = list_categoryDao.getByPrimaryKey(cat_id);
                    List_reg list = new List_reg(name, user, l_cat, description);
                    list.setId(Integer.parseInt(request.getParameter("listID")));
                    list_regDao.update(list);
                    System.err.println("Ok, lista modificata:" + list.getId());
                } catch (DAOException ex) {
                    System.err.println("Errore in modifica lista");
                }
                break;
            }
            case "delete": {
                Integer id = Integer.parseInt(request.getParameter("list_id"));
                try {
                    List_reg list = list_regDao.getByPrimaryKey(id);
                    try {
                        list_regDao.delete(list);
                        System.err.println("List deleted");
                    } catch (DAOException ex) {
                        System.err.println("Impossible to delete selected list");
                    }
                } catch (DAOException ex) {
                    System.err.println("Impossible to retrieve list by given ID");
                }
                break;
            }
            case "add": {
                Integer list_id = Integer.parseInt(request.getParameter("list_id"));
                Integer prod_id = Integer.parseInt(request.getParameter("product_id"));
                Integer amount = Integer.parseInt(request.getParameter("amount"));
                try {
                    List_reg list_reg = list_regDao.getByPrimaryKey(list_id);
                    Product product = productDao.getByPrimaryKey(prod_id);
                    list_regDao.insertProduct(list_reg, product, amount);
                } catch (DAOException ex) {
                    System.err.println("Cannot add product to list");
                }
                break;
            }
            default:
                System.err.println("ShoppingListServlet: unsupported parameter");
                break;
        }
        response.sendRedirect(contextPath + "restricted/homepage.html");
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
