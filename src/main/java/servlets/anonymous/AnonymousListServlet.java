/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets.anonymous;

import db.daos.List_anonymousDAO;
import db.daos.List_categoryDAO;
import db.daos.Prod_categoryDAO;
import db.daos.ProductDAO;
import db.entities.Product;
import db.exceptions.DAOException;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import db.entities.List_anonymous;
import db.entities.List_category;
import javax.servlet.http.Cookie;

public class AnonymousListServlet extends HttpServlet {

    private List_anonymousDAO list_anonymousDao;
    private List_categoryDAO list_categoryDao;
    private ProductDAO productDao;
    private Prod_categoryDAO prod_categoryDao;

    @Override
    public void init() throws ServletException {
        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new ServletException("Impossible to get dao factory");
        }
        try {
            list_anonymousDao = daoFactory.getDAO(List_anonymousDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for list_anonymous", ex);
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
                    String name = request.getParameter("name");
                    String description = request.getParameter("description");
                    Integer cat_id = Integer.parseInt(request.getParameter("category"));
                    List_category l_cat = list_categoryDao.getByPrimaryKey(cat_id);
                    List_anonymous list = new List_anonymous(name, description, l_cat);
                    list_anonymousDao.insert(list);
                    System.err.println("Ok, list_anonymous created: " + list.getId());
                    response.addCookie(new Cookie("anonymous_list_ID", list.getId().toString()));
                    response.sendRedirect(contextPath + "anonymous/homepage.html");
                } catch (Exception ex) {
                    System.err.println("Cannot create list_anonymous: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }

            case "edit": {
                try {
                    String name = request.getParameter("name");
                    String description = request.getParameter("description");
                    List_anonymous list = list_anonymousDao.getByPrimaryKey(Integer.parseInt(request.getParameter("list_id")));
                    list.setName(name);
                    list.setDescription(description);
                    list_anonymousDao.update(list);

                    System.err.println("Ok, list_anonymous modified: " + list.getId());
                    response.sendRedirect(contextPath + "anonymous/homepage.html");
                } catch (DAOException ex) {
                    System.err.println("Cannot edit list_anonymous: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }

            case "delete": {
                try {
                    Integer id = Integer.parseInt(request.getParameter("list_id"));
                    List_anonymous list = list_anonymousDao.getByPrimaryKey(id);
                    list_anonymousDao.delete(list);
                    System.err.println("Ok, list_anonymous deleted");
                    response.sendRedirect(contextPath + "anonymous/homepage.html");
                } catch (DAOException ex) {
                    System.err.println("Impossible to delete list_anonymous by given ID: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }

            case "addProduct": {
                try {
                    Integer list_id = Integer.parseInt(request.getParameter("list_id"));
                    Integer prod_id = Integer.parseInt(request.getParameter("product_id"));
                    Integer amount = Integer.parseInt(request.getParameter("amount"));
                    List_anonymous list = list_anonymousDao.getByPrimaryKey(list_id);
                    Product product = productDao.getByPrimaryKey(prod_id);
                    list_anonymousDao.insertProduct(list, product, amount);
                    response.sendRedirect(contextPath + "anonymous/homepage.html");
                } catch (DAOException ex) {
                    System.err.println("Cannot add product to list_anonymous: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }

            case "removeProduct": {
                try {
                    Integer list_id = Integer.parseInt(request.getParameter("list_id"));
                    Integer prod_id = Integer.parseInt(request.getParameter("product_id"));
                    List_anonymous list = list_anonymousDao.getByPrimaryKey(list_id);
                    Product product = productDao.getByPrimaryKey(prod_id);
                    list_anonymousDao.removeProduct(list, product);
                    response.sendRedirect(contextPath + "anonymous/homepage.html");
                } catch (DAOException ex) {
                    System.err.println("Cannot remove product from list_anonymous: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
                break;
            }

            case "resetProduct": {
                try {
                    Integer list_id = Integer.parseInt(request.getParameter("list_id"));
                    Integer prod_id = Integer.parseInt(request.getParameter("product_id"));
                    List_anonymous list = list_anonymousDao.getByPrimaryKey(list_id);
                    Product product = productDao.getByPrimaryKey(prod_id);
                    list_anonymousDao.updateAmountPurchased(list, product, 0);
                    response.sendRedirect(contextPath + "anonymous/homepage.html");
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
                    List_anonymous list = list_anonymousDao.getByPrimaryKey(list_id);
                    Product product = productDao.getByPrimaryKey(prod_id);
                    list_anonymousDao.updateAmountTotal(list, product, amount);
                    response.sendRedirect(contextPath + "anonymous/homepage.html");
                } catch (DAOException ex) {
                    System.err.println("Cannot change product total amount: " + ex);
                    response.sendRedirect(contextPath + "error.html");
                }
            }

            case "purchaseProducts": {
                try {
                    Integer list_id = Integer.parseInt(request.getParameter("list_id"));
                    List_anonymous list = list_anonymousDao.getByPrimaryKey(list_id);
                    String[] prod_ids_s = request.getParameterValues("product_id[]");
                    if(prod_ids_s==null){
                        prod_ids_s = new String[0];
                    }
                    for (String prod_id_s : prod_ids_s) {
                        Integer prod_id = Integer.parseInt(prod_id_s);
                        Product product = productDao.getByPrimaryKey(prod_id);
                        Integer purchased = Integer.parseInt(request.getParameter("purchased_" + prod_id));
                        System.err.println("Purchasing: list=" + list.getId() + ", prod=" + product.getId() + ", purchased=" + purchased);
                        if(!list_anonymousDao.getProducts(list).contains(product)){
                            throw new DAOException("Cannot purchase product not in list_anonymous");
                        }
                        list_anonymousDao.updateAmountPurchased(list, product, purchased);
                    }

                    response.sendRedirect(contextPath + "anonymous/homepage.html");
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
