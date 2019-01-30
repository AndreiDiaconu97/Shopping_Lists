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
import db.daos.UserDAO;
import db.daos.jdbc.JDBC_utility;
import db.entities.List_reg;
import db.entities.User;
import db.exceptions.DAOException;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.IOException;
import java.util.List;
import java.util.Properties;
import javax.mail.Session;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author andrea
 */
public class ShareShoppingListServlet extends HttpServlet {

    private UserDAO userDao;
    private List_regDAO list_regDao;
    private JDBC_utility utility;
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
            userDao = daoFactory.getDAO(UserDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for user", ex);
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
            case "sharing": {
                try {
                    Integer access = Integer.parseInt(request.getParameter("selectAccess"));
                    Integer id = Integer.parseInt(request.getParameter("listToshare"));
                    String email = request.getParameter("userToshare");

                    User invited = userDao.getByEmail(email);
                    List_reg list = list_regDao.getByPrimaryKey(id);
                    List<User> shared_users = list_regDao.getUsersSharedTo(list);
                    List<User> invited_users = list_regDao.getInvitedUsers(list);

                    if (invited.equals(list.getOwner())) {
                        System.err.println("Cannot invite " + invited.getEmail() + ": is owner");
                    } else if (invited.getIs_admin()) {
                        System.err.println("Cannot invite " + invited.getEmail() + ": is admin");
                    } else if (shared_users.contains(invited)) {
                        System.err.println("Cannot invite " + invited.getEmail() + ": already shared");
                    } else if (invited_users.contains(invited)) {
                        System.err.println("Cannot invite " + invited.getEmail() + ": already invited");
                    } else {
                        JDBC_utility.AccessLevel accesslv = utility.intToAccessLevel(access);
                        list_regDao.inviteUser(list, invited, accesslv);
                        System.err.println("Invited user " + invited.getEmail() + " to list " + list.getName());
                    }
                    response.sendRedirect(contextPath + "restricted/shopping.list.html?listID=" + id);

                } catch (DAOException ex) {
                    System.err.println("Cannot invite user to list: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }

            case "accept": {
                try {
                    HttpSession session = request.getSession(false);
                    User user = (User) session.getAttribute("user");
                    Integer list_id = Integer.parseInt(request.getParameter("list_id"));
                    List_reg list = list_regDao.getByPrimaryKey(list_id);
                    list_regDao.acceptInvite(list, user);
                    response.sendRedirect(contextPath + "restricted/homepage.html?tab=sharedLists");
                } catch (DAOException ex) {
                    System.err.println("Cannot accept invite to list: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
                break;

            }

            case "decline": {
                try {
                    HttpSession session = request.getSession(false);
                    User user = (User) session.getAttribute("user");
                    Integer list_id = Integer.parseInt(request.getParameter("list_id"));
                    List_reg list = list_regDao.getByPrimaryKey(list_id);
                    list_regDao.declineInvite(list, user);
                    response.sendRedirect(contextPath + "restricted/homepage.html?tab=sharedLists");
                } catch (DAOException ex) {
                    System.err.println("Cannot decline invite to list: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }

            default: {
                System.err.println("ShoppingListServlet: unsupported parameter: " + action);
                response.sendRedirect(contextPath + "error.html");
                break;
            }
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
