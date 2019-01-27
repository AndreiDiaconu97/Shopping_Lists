/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets.user;

import db.daos.Prod_categoryDAO;
import db.daos.ProductDAO;
import db.entities.Prod_category;
import db.entities.Product;
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
 * @author Andrea Mattè
 */
public class ProductServlet extends HttpServlet {

    private ProductDAO productDao;
    private Prod_categoryDAO prod_categoryDao;

    @Override
    public void init() throws ServletException {

        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new ServletException("Impossible to get dao factory");
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
                    Integer cat_id = Integer.parseInt(request.getParameter("category"));
                    Prod_category p_cat = prod_categoryDao.getByPrimaryKey(cat_id);
                    Product product = new Product(name, p_cat, user, description);
                    productDao.insert(product);
                    System.err.println("Ok, product created: " + product.getId());
                } catch (DAOException | NumberFormatException ex) {
                    System.err.println("Cannot create product: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }
            case "edit": {
                try {
                    HttpSession session = request.getSession(false);
                    User user = (User) session.getAttribute("user");
                    String name = request.getParameter("name");
                    String description = request.getParameter("description");
                    Integer cat_id = Integer.parseInt(request.getParameter("category"));
                    Prod_category p_cat = prod_categoryDao.getByPrimaryKey(cat_id);
                    Product product = new Product(name, p_cat, user, description);
                    product.setId(Integer.parseInt(request.getParameter("id")));
                    productDao.update(product);
                    System.err.println("Ok, product modified: " + product.getId());
                } catch (DAOException ex) {
                    System.err.println("Cannot edit product");
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }
            case "delete": {
                try {
                    Integer id = Integer.parseInt(request.getParameter("list_id"));
                    Product product = productDao.getByPrimaryKey(id);
                    productDao.delete(product);
                    System.err.println("Ok, product deleted");
                } catch (DAOException ex) {
                    System.err.println("Impossible to delete product by given ID");
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }
            default:
                System.err.println("ShoppingListServlet: unsupported parameter");
                response.sendRedirect(contextPath + "error.html");
                break;
        }
        if (!response.isCommitted()) {
            response.sendRedirect(contextPath + "restricted/homepage.html#nav-myProducts");
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
