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
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import db.daos.UserDAO;
import db.entities.List_category;
import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.Part;

@MultipartConfig
public class ShoppingListServlet extends HttpServlet {

    private String imagesPath;
    private UserDAO userDao;
    private List_regDAO list_regDao;
    private List_categoryDAO list_categoryDao;
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
                    List_category l_cat = list_categoryDao.getByPrimaryKey(cat_id);
                    List_reg list = new List_reg(name, user, l_cat, description);
                    list_regDao.insert(list);
                    System.err.println("Ok, list created: " + list.getId());
                    response.sendRedirect(contextPath + "restricted/homepage.html?tab=" + request.getParameter("tab"));
                } catch (Exception ex) {
                    System.err.println("Cannot insert list: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }

            case "edit": {
                try {
                    String name = request.getParameter("name");
                    String description = request.getParameter("description");
                    List_reg list = list_regDao.getByPrimaryKey(Integer.parseInt(request.getParameter("list_id")));
                    list.setName(name);
                    list.setDescription(description);
                    list_regDao.update(list);

                    saveImage(request.getPart("image"), "shopping_lists", list.getId().toString());
                    System.err.println("Ok, list modified: " + list.getId());
                    response.sendRedirect(contextPath + "restricted/shopping.list.html?listID=" + request.getParameter("list_id"));
                } catch (DAOException ex) {
                    System.err.println("Cannot edit list: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }

            case "delete": {
                try {
                    Integer id = Integer.parseInt(request.getParameter("list_id"));
                    List_reg list = list_regDao.getByPrimaryKey(id);
                    list_regDao.delete(list);
                    deleteImage("list_categories", id.toString());
                    System.err.println("Ok, list deleted");
                    response.sendRedirect(contextPath + "restricted/homepage.html?tab=" + request.getParameter("tab"));
                } catch (DAOException ex) {
                    System.err.println("Impossible to delete list by given ID: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }

            case "addProduct": {
                try {
                    Integer list_id = Integer.parseInt(request.getParameter("list_id"));
                    Integer prod_id = Integer.parseInt(request.getParameter("product_id"));
                    Integer amount = Integer.parseInt(request.getParameter("amount"));
                    List_reg list_reg = list_regDao.getByPrimaryKey(list_id);
                    Product product = productDao.getByPrimaryKey(prod_id);
                    list_regDao.insertProduct(list_reg, product, amount);
                    response.sendRedirect(contextPath + "restricted/shopping.list.html?listID=" + list_id);
                } catch (DAOException ex) {
                    System.err.println("Cannot add product to list: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }

            case "removeProduct": {
                try {
                    Integer list_id = Integer.parseInt(request.getParameter("list_id"));
                    Integer prod_id = Integer.parseInt(request.getParameter("product_id"));
                    List_reg list_reg = list_regDao.getByPrimaryKey(list_id);
                    Product product = productDao.getByPrimaryKey(prod_id);
                    list_regDao.removeProduct(list_reg, product);
                    response.sendRedirect(contextPath + "restricted/shopping.list.html?listID=" + list_id);
                } catch (DAOException ex) {
                    System.err.println("Cannot remove product from list: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }

            case "resetProduct": {
                try {
                    Integer list_id = Integer.parseInt(request.getParameter("list_id"));
                    Integer prod_id = Integer.parseInt(request.getParameter("product_id"));
                    List_reg list_reg = list_regDao.getByPrimaryKey(list_id);
                    Product product = productDao.getByPrimaryKey(prod_id);
                    list_regDao.updateAmountPurchased(list_reg, product, 0);
                    response.sendRedirect(contextPath + "restricted/shopping.list.html?listID=" + list_id);
                } catch (DAOException ex) {
                    System.err.println("Cannot reset product purchased amount: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }

            case "changeProductTotal": {
                try {
                    Integer list_id = Integer.parseInt(request.getParameter("list_id"));
                    Integer prod_id = Integer.parseInt(request.getParameter("product_id"));
                    Integer amount = Integer.parseInt(request.getParameter("amount"));
                    List_reg list_reg = list_regDao.getByPrimaryKey(list_id);
                    Product product = productDao.getByPrimaryKey(prod_id);
                    list_regDao.updateAmountTotal(list_reg, product, amount);
                    response.sendRedirect(contextPath + "restricted/shopping.list.html?listID=" + list_id);
                } catch (DAOException ex) {
                    System.err.println("Cannot change product total amount: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
            }

            case "purchaseProducts": {
                try {
                    Integer list_id = Integer.parseInt(request.getParameter("list_id"));
                    List_reg list_reg = list_regDao.getByPrimaryKey(list_id);
                    String[] prod_ids_s = request.getParameterValues("product_id");
                    for (String prod_id_s : prod_ids_s) {
                        Integer prod_id = Integer.parseInt(prod_id_s);
                        Product product = productDao.getByPrimaryKey(prod_id);
                        Integer purchased = Integer.parseInt(request.getParameter("purchased_" + prod_id));
                        list_regDao.updateAmountPurchased(list_reg, product, purchased);
                    }

                    response.sendRedirect(contextPath + "restricted/shopping.list.html?listID=" + list_id);
                } catch (DAOException ex) {
                    System.err.println("Cannot purchase products: " + ex);
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
