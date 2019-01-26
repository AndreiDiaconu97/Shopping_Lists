/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets.admin;

import db.daos.List_categoryDAO;
import db.daos.Prod_categoryDAO;
import db.daos.ProductDAO;
import db.entities.List_category;
import db.entities.Prod_category;
import db.entities.Product;
import db.entities.User;
import db.exceptions.DAOException;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@MultipartConfig
public class AdminServlet extends HttpServlet {

    private Prod_categoryDAO prod_categoryDao;
    private List_categoryDAO list_categoryDao;
    private ProductDAO productDao; // maybe useless: create product = post to ProductServlet
    public String uploadDir;

    private void saveFile(HttpServletRequest request, HttpServletResponse response, String contextPath, Integer id, String subfolder) {
        try {
            Part filePart = request.getPart("image");
            if (filePart != null) {
                if (filePart.getContentType().contains("image")) {
                    String imageFormat = filePart.getContentType().replaceFirst("image/", ".");
                    //TODO: if folders do not exist, create them first
                    filePart.write(uploadDir + "\\" + subfolder + "\\" + id + imageFormat);
                }
            }
        } catch (IOException | ServletException ex) {
            Logger.getLogger(AdminServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    @Override
    public void init() throws ServletException {
        uploadDir = getServletContext().getInitParameter("uploadDir");
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
                String id_s = request.getParameter("id");
                Integer id = Integer.parseInt(id_s != null ? id_s : "-1");
                String name = request.getParameter("name");
                String description = request.getParameter("description");

                try {
                    List_category cat = list_categoryDao.getByPrimaryKey(id);
                    if (cat == null) {
                        cat = new List_category(name, description);
                        list_categoryDao.insert(cat);
                        System.err.println("Ok. Nome della categoria di lista inserita: " + cat.getName());
                    } else {
                        saveFile(request, response, contextPath, id, "list_categories");

                        if (name != null) {
                            cat.setName(name);
                        }
                        if (description != null) {
                            cat.setDescription(description);
                        }
                        list_categoryDao.update(cat);
                        System.err.println("Ok. Nome della categoria di lista modificata: " + cat.getName());
                    }

                } catch (DAOException ex) {
                    System.err.println("Errore DAO: " + ex.getMessage());
                }
                if (!response.isCommitted()) {
                    response.sendRedirect(contextPath + "admin/admin.html?tab=" + request.getParameter("tab"));
                }
                break;
            }

            case "productcat": {
                try {
                    String id_s = request.getParameter("id");
                    Integer id = Integer.parseInt(id_s != null ? id_s : "-1");
                    String name = request.getParameter("name");
                    String description = request.getParameter("description");
                    String list_cat_s = request.getParameter("list_category");
                    Integer list_cat = Integer.parseInt(list_cat_s != null ? list_cat_s : "-1");
                    String renew_s = request.getParameter("renew_time");
                    Integer renew_time = Integer.parseInt(renew_s != null ? renew_s : "0");
                    Prod_category prod_cat = prod_categoryDao.getByPrimaryKey(id);
                    if (prod_cat == null) {
                        List_category list_category = list_categoryDao.getByPrimaryKey(list_cat);
                        if (list_category == null) {
                            throw new DAOException("To create a prod_cat you need to specify 1 list_category");
                        }
                        prod_cat = new Prod_category(name, description, renew_time);
                        prod_categoryDao.insert(prod_cat);
                        list_categoryDao.insertProd_category(list_category, prod_cat);
                    } else {
                        saveFile(request, response, contextPath, id, "product_categories");

                        if (name != null) {
                            prod_cat.setName(name);
                        }
                        if (description != null) {
                            prod_cat.setDescription(description);
                        }
                        if (renew_time != null) {
                            prod_cat.setRenewtime(renew_time);
                        }
                        prod_categoryDao.update(prod_cat);
                    }
                } catch (Exception ex) {
                    System.err.println(ex.getMessage());
                    response.sendRedirect(response.encodeRedirectURL(contextPath + "error.html?admin"));
                }
                if (!response.isCommitted()) {
                    response.sendRedirect(contextPath + "admin/admin.html?tab=" + request.getParameter("tab"));
                }
                break;
            }

            case "listproductcat": {
                try {
                    String id_s = request.getParameter("list_cat");
                    Integer id = Integer.parseInt(id_s != null ? id_s : "-1");
                    List_category list_category = list_categoryDao.getByPrimaryKey(id);
                    if (list_category == null) {
                        throw new DAOException("Cannot add prod_cats to invalid list_cat");
                    } else {
                        if (request.getParameter("prod_category_add") != null) {
                            String[] p_c_ids_add = request.getParameterValues("prod_category_add");
                            for (String p_c_s : p_c_ids_add) {
                                Integer p_c_id = Integer.parseInt(p_c_s != null ? p_c_s : "-1");
                                Prod_category toAdd = prod_categoryDao.getByPrimaryKey(p_c_id);
                                if (toAdd == null) {
                                    throw new DAOException("Tried to add invalid prod_cat to valid list_cat");
                                } else {
                                    list_categoryDao.insertProd_category(list_category, toAdd);
                                }
                            }
                        }

                        if (request.getParameter("prod_category_rem") != null) {
                            String[] p_c_ids_rem = request.getParameterValues("prod_category_rem");
                            for (String p_c_s : p_c_ids_rem) {
                                Integer p_c_id = Integer.parseInt(p_c_s != null ? p_c_s : "-1");
                                Prod_category toRem = prod_categoryDao.getByPrimaryKey(p_c_id);
                                if (toRem == null) {
                                    throw new DAOException("Tried to remove invalid prod_cat from valid list_cat");
                                } else {
                                    list_categoryDao.removeProd_category(list_category, toRem);
                                }
                            }
                        }
                    }
                    if (!response.isCommitted()) {
                        response.sendRedirect(contextPath + "admin/list.cat.html?list_catID=" + id + "&tab=" + request.getParameter("tab"));
                    }
                } catch (Exception ex) {
                    response.sendRedirect(response.encodeRedirectURL(contextPath + "error.html?admin"));
                }
                break;
            }

            case "product": {
                try {
                    HttpSession session = request.getSession(false);
                    User user = (User) session.getAttribute("user");
                    String id_s = request.getParameter("id");
                    Integer id = Integer.parseInt(id_s != null ? id_s : "-1");
                    String name = request.getParameter("name");
                    String description = request.getParameter("description");
                    String p_cat_s = request.getParameter("category");
                    Integer p_cat = Integer.parseInt(p_cat_s != null ? p_cat_s : "-1");
                    Product prod = productDao.getByPrimaryKey(id);
                    Prod_category prod_category = prod_categoryDao.getByPrimaryKey(p_cat);
                    if (prod == null) {
                        if (prod_category == null) {
                            throw new DAOException("To create a product you need a valid product cat");
                        }
                        prod = new Product(name, prod_category, user, description);
                        productDao.insert(prod);
                    } else {
                        saveFile(request, response, contextPath, id, "public_products");

                        if (name != null) {
                            prod.setName(name);
                        }
                        if (description != null) {
                            prod.setDescription(description);
                        }
                        if (prod_category != null) {
                            prod.setCategory(prod_category);
                        }
                        productDao.update(prod);
                    }
                } catch (Exception ex) {
                    response.sendRedirect(response.encodeRedirectURL(contextPath + "error.html?admin"));
                }
                if (!response.isCommitted()) {
                    response.sendRedirect(contextPath + "admin/admin.html?tab=" + request.getParameter("tab"));
                }
                break;
            }
        }
    }
}
