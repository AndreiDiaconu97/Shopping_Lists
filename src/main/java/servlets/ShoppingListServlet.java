/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets;

import db.daos.List_regDAO;
import db.daos.NV_UserDAO;
import db.daos.ProductDAO;
import db.daos.Reg_UserDAO;
import db.entities.List_reg;
import db.entities.Product;
import db.entities.Reg_User;
import db.exceptions.DAOException;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class ShoppingListServlet extends HttpServlet {

    private Reg_UserDAO reg_userDao;
    private NV_UserDAO nv_userDao;
    private List_regDAO list_regDao;
    private ProductDAO productDao;

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
        try {
            list_regDao = daoFactory.getDAO(List_regDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for reg_user", ex);
        }
        try {
            productDao = daoFactory.getDAO(ProductDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for product", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }

        if (request.getParameter("create") != null) {
            HttpSession session = request.getSession(false);
            Reg_User reg_user = null;
            reg_user = (Reg_User) session.getAttribute("reg_user");
            Integer id = reg_user.getId();
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String category = request.getParameter("category");

            List_reg list = new List_reg(name, id, category, description, null);

            try {
                list_regDao.insert(list);
                System.err.println("Ok. Id della lista inserita:" + list.getId());
            } catch (Exception e) {
                System.err.println("Errore. Id della lista inserita:" + list.getId());
            }
            response.sendRedirect(contextPath + "restricted/shopping.lists.html");
        }

        if (request.getParameter("edit") != null) {
            HttpSession session = request.getSession(false);
            Reg_User reg_user = null;
            reg_user = (Reg_User) session.getAttribute("reg_user");
            Integer id = reg_user.getId();
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
            response.sendRedirect(contextPath + "restricted/shopping.lists.html");
        }
        
        if (request.getParameter("delete") != null) {
            Integer id = Integer.parseInt(request.getParameter("list_id"));
            try {
                List_reg list = list_regDao.getByPrimaryKey(id);
                try{
                    list_regDao.delete(list);
                    System.err.println("List deleted");
                }catch (DAOException ex){
                    System.err.println("Impossible to delete selected list");
                }
                
            } catch (DAOException ex) {
                System.err.println("Impossible to retrieve list by given ID");
            }
           
            response.sendRedirect(contextPath + "restricted/shopping.lists.html");
        }
        
        if(request.getParameter("add") != null){
            String name = request.getParameter("object_name");
            String id = request.getParameter("list_id");
            Product product = new Product();
            List_reg list_reg = new List_reg();
           
            try{
                list_reg = list_regDao.getByPrimaryKey(Integer.parseInt(id));
                product = productDao.getByName(name);
                System.err.println(list_reg.getName());
            }catch(Exception e){
                System.err.println(e);
            }
            
            if(product != null){
                try{
                    list_regDao.insertProduct(list_reg, product);   
                }catch (DAOException e){
                    System.err.println("Impossible to insert given product");
                }
            }      
            
            response.sendRedirect(contextPath + "restricted/shopping.lists.html");
            
            
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
