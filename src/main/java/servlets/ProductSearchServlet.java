/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets;

import db.daos.ProductDAO;
import db.entities.Product;
import db.exceptions.DAOException;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author andrea
 */
public class ProductSearchServlet extends HttpServlet {

    private ProductDAO productDao;
    private List<Product> allProducts;

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
            allProducts = productDao.getAll();
        } catch (DAOException ex) {
            throw new ServletException("Impossible to get all products: " + ex.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }

        if (request.getParameter("text") != null) {
            String text = request.getParameter("text");
            List<Product> searched = new ArrayList<>();
            for (Product p : allProducts) {
                if (p.getName().contains(text)) {
                    searched.add(p);
                }
            }
            
            String searchedJSON = "{\"result\": [";
            if (searched.size() == 0) {
                searchedJSON += "]}";
            } else {
                for (Product p : searched) {
                    searchedJSON = searchedJSON.concat("{\"id\": " + p.getId() + ", \"name\": \"" + p.getName() + "\", \"description\": \"" + p.getDescription() + "\"}, ");
                }
                searchedJSON = searchedJSON.substring(0, searchedJSON.length() - 2);
                searchedJSON += "]}";
            }
            //System.err.println("Searched: " + searchedJSON);
            response.getWriter().print(searchedJSON);
        } else {
            // ERROR
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
