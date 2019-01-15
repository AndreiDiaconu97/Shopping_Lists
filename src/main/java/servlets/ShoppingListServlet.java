/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets;

import db.daos.List_regDAO;
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
import org.json.JSONArray;
import org.json.JSONObject;
import db.daos.UserDAO;

public class ShoppingListServlet extends HttpServlet {

    private UserDAO userDao;
    private List_regDAO list_regDao;
    private ProductDAO productDao;
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
            throw new ServletException("Impossible to get dao for user", ex);
        }
        try {
            productDao = daoFactory.getDAO(ProductDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for product", ex);
        }
        try {
            userDao = daoFactory.getDAO(UserDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for product", ex);
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

        if (request.getParameter("getList") != null) {
            int id = Integer.parseInt(request.getParameter("getList"));
            try {
                List_reg list = list_regDao.getByPrimaryKey(id);
                JSONObject listJSON = new JSONObject();
                listJSON.put("id", list.getId());
                listJSON.put("name", list.getName());
                listJSON.put("description", list.getDescription());
                JSONArray productsJSON = new JSONArray();
                for (Product p : list_regDao.getProducts(list)) {
                    JSONObject productJSON = new JSONObject();
                    productJSON.put("name", p.getName());
                    productJSON.put("description", p.getDescription());
                    productsJSON.put(productJSON);
                }
                listJSON.put("products", productsJSON);
                response.setCharacterEncoding("UTF-8");
                response.getWriter().print(listJSON);
            } catch (DAOException ex) {
                System.err.println("Impossible to get further info for list with id=" + id);
            }
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
                owner = userDao.getByPrimaryKey(list.getOwner());
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
                    Integer ownerId = list.getOwner();
                    Owner = userDao.getByPrimaryKey(ownerId);
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

            response.sendRedirect(contextPath + "restricted/shopping.lists.html");
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
                HttpSession session = request.getSession(false);
                User user = user = (User) session.getAttribute("user");
                Integer id = user.getId();
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String category = request.getParameter("category");

                List_reg list = new List_reg(name, id, category, description, null);

                try {
                    list_regDao.insert(list);
                    System.err.println("Ok. Id della lista inserita:" + list.getId());
                } catch (DAOException ex) {
                    System.err.println("Errore. Id della lista inserita:" + list.getId());
                }
                break;
            }
            case "edit": {
                HttpSession session = request.getSession(false);
                User user = (User) session.getAttribute("user");
                Integer id = user.getId();
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String category = request.getParameter("category");
                List_reg list = new List_reg(name, id, category, description, null);
                list.setId(Integer.parseInt(request.getParameter("listID")));
                try {
                    list_regDao.update(list);
                    System.err.println("Ok, lista modificata:" + list.getId());
                } catch (DAOException ex) {
                    System.err.println("Errore. Lista inserita:" + list.getId());
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
                String name = request.getParameter("object_name");
                String id = request.getParameter("list_id");
                Product product = new Product();
                List_reg list_reg = new List_reg();
                try {
                    list_reg = list_regDao.getByPrimaryKey(Integer.parseInt(id));
                    product = productDao.getByName(name);
                    System.err.println(list_reg.getName());
                } catch (Exception e) {
                    System.err.println(e);
                }
                if (product != null) {
                    try {
                        list_regDao.insertProduct(list_reg, product);
                    } catch (DAOException e) {
                        System.err.println("Impossible to insert given product");
                    }
                }
                break;
            }
            default:
                System.err.println("ShoppingListServlet: unsupported parameter");
                break;
        }
        response.sendRedirect(contextPath + "restricted/shopping.lists.html");
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
