/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets;

import db.daos.Prod_categoryDAO;
import db.daos.ProductDAO;
import db.daos.jdbc.JDBC_utility.SortBy;
import db.entities.Prod_category;
import db.entities.Product;
import db.entities.User;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author andrea
 */
public class ProductSearch extends HttpServlet {

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
            throw new ServletException("Impossible to get dao for products", ex);
        }
        try{
            prod_categoryDao = daoFactory.getDAO(Prod_categoryDAO.class);
        } catch(DAOFactoryException ex){
            throw new ServletException("Impossible to get dao for prod_categories", ex);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }

        try {
            HttpSession session = request.getSession(false);
            User user = (User) session.getAttribute("user");
            String name = request.getParameter("name");
            String cat_s = request.getParameter("category");
            Boolean pubs = "true".equals(request.getParameter("publics"));
            String sortby_s = request.getParameter("sortby");
            SortBy sortby = sortby_s=="popularity" ? SortBy.POPULARITY : (sortby_s=="name" ? SortBy.NAME : SortBy.RATING);
            Integer cat_id = Integer.parseInt(cat_s != null ? cat_s : "-1");
            Prod_category prod_category = prod_categoryDao.getByPrimaryKey(cat_id);
                
            List<Product> searched = productDao.filterProducts(name, prod_category, user, pubs, sortby);
            
            response.setCharacterEncoding("UTF-8");
            response.getWriter().print(Product.toJSON(searched));

        } catch (Exception ex) {
            response.sendRedirect(contextPath + "error.html?prodsearch");
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
