/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets;

import db.daos.List_categoryDAO;
import db.daos.Prod_categoryDAO;
import db.daos.ProductDAO;
import db.entities.List_category;
import db.entities.Prod_category;
import db.entities.User;
import db.exceptions.DAOException;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author andrea
 */
public class AdminServlet extends HttpServlet {

    private Prod_categoryDAO prod_categoryDao;
    private List_categoryDAO list_categoryDao;
    private ProductDAO productDao; // maybe useless: create product = post to ProductServlet

    @Override
    public void init() throws ServletException {

        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new ServletException("Impossible to get dao factory");
        }

        try {
            prod_categoryDao = daoFactory.getDAO(Prod_categoryDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for product categories", ex);
        }
        try {
            list_categoryDao = daoFactory.getDAO(List_categoryDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for list categories", ex);
        }
        try {
            productDao = daoFactory.getDAO(ProductDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for products", ex);
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

            case "listcat": {
                String name = request.getParameter("name");
                String description = request.getParameter("description");

                try {
                    List_category cat = list_categoryDao.getByPrimaryKey(name);
                    if (cat == null) {
                        cat = new List_category(name, description, null);
                        list_categoryDao.insert(cat);
                        System.err.println("Ok. Nome della categoria di lista inserita: " + cat.getName());
                    } else {
                        cat.setDescription(description);
                        list_categoryDao.update(cat);
                        System.err.println("Ok. Nome della categoria di lista modificata: " + cat.getName());
                    }

                } catch (DAOException ex) {
                    System.err.println("Errore DAO: " + ex.getMessage());
                }

                break;
            }

            case "productcat": {
                HttpSession session = request.getSession(false);
                User user = user = (User) session.getAttribute("user");
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String list_cat = request.getParameter("list_category");

                try {
                    Prod_category cat = prod_categoryDao.getByPrimaryKey(name);
                    if (cat == null) {
                        //cat = new Prod_category(name, description, list_cat, null);
                    }
                } catch (DAOException ex) {

                }
                break;
            }
        }
    }

}
