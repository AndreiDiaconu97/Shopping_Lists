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
    private List_categoryDAO list_categoryDao;
    private ProductDAO productDao;
    private Prod_categoryDAO prod_categoryDao;
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
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }
        
        if (request.getParameter("sharing") != null) {
                       
            Integer access = Integer.parseInt(request.getParameter("selectAccess"));      
            Integer id = Integer.parseInt(request.getParameter("listToshare"));
            String email = request.getParameter("userToshare");
            response.setCharacterEncoding("UTF-8");
            String ownerEmail;
            User owner;
            Boolean check = true;
            
            
            
            try {          
                User receiver = userDao.getByEmail(email);
                List_reg list = list_regDao.getByPrimaryKey(id);
                owner = list.getOwner();
                ownerEmail = owner.getEmail();
                List<User> users = list_regDao.getUsersSharedTo(list);
                
                if(receiver.getIs_admin()) check = false;
                
                
                if (ownerEmail.equals(email)) check = false;
                for (User user : users) {
                    if (user.getEmail().equals(email)) check = false;
                }
              
                if(check){
                    JDBC_utility.AccessLevel accesslv =  utility.intToAccessLevel(access);
                    list_regDao.inviteUser(list, receiver, accesslv);
                }
                
                response.sendRedirect(contextPath + "restricted/homepage.html");
        
            } catch (DAOException ex) {
                System.err.println("errors");
            }
        }
    }

   
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
