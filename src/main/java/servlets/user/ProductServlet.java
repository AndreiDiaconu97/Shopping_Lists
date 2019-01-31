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
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

/**
 *
 * @author Andrea Mattè
 */
@MultipartConfig
public class ProductServlet extends HttpServlet {

    private String imagesPath;
    private ProductDAO productDao;
    private Prod_categoryDAO prod_categoryDao;

    private void saveImage(Part imagePart, String folder, String imageName) throws IOException {
        if (imagePart.getSubmittedFileName().equals("")) {
            return;
        }

        File imageFile = new File(imagesPath + folder + "/" + imageName);
        imageFile.delete();
        try (InputStream fileContent = imagePart.getInputStream()) {
            Files.copy(fileContent, imageFile.toPath());
        }
    }

    private void deleteImage(String folder, String imageName) {
        File imageFile = new File(imagesPath + folder + "/" + imageName);
        imageFile.delete();
    }

    @Override
    public void init() throws ServletException {
        imagesPath = getServletContext().getInitParameter("imagesPath");

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
        request.setCharacterEncoding("UTF-8");
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
                    saveImage(request.getPart("image"), "products", product.getId().toString());
                    System.err.println("Ok, product created: " + product.getId());
                } catch (DAOException | NumberFormatException ex) {
                    System.err.println("Cannot create product: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }
            case "edit": {
                try {
                    Integer prodID = Integer.parseInt(request.getParameter("prodID"));
                    String name = request.getParameter("name");
                    String description = request.getParameter("description");
                    //Integer cat_id = Integer.parseInt(request.getParameter("category"));
                    //Prod_category p_cat = prod_categoryDao.getByPrimaryKey(cat_id);

                    System.err.println("NAME: " + name);

                    Product product = productDao.getByPrimaryKey(prodID);
                    product.setName(name);
                    product.setDescription(description);
                    //product.setCategory(p_cat);
                    productDao.update(product);
                    saveImage(request.getPart("image"), "products", product.getId().toString());
                    System.err.println("Ok, product modified: " + product.getId());
                } catch (DAOException ex) {
                    System.err.println("Cannot edit product");
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }
            case "delete": {
                try {
                    Integer id = Integer.parseInt(request.getParameter("prodID"));
                    Product product = productDao.getByPrimaryKey(id);
                    productDao.delete(product);
                    deleteImage("products", id.toString());
                    System.err.println("Ok, product deleted");
                } catch (DAOException ex) {
                    System.err.println("Impossible to delete product by given ID");
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }
            default:
                System.err.println("ProductServlet: unsupported parameter");
                response.sendRedirect(contextPath + "error.html");
                break;
        }
        if (!response.isCommitted()) {
            response.sendRedirect(contextPath + "restricted/homepage.html?tab=" + request.getParameter("tab"));
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
