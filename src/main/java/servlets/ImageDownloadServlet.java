/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets;

import db.daos.List_categoryDAO;
import db.daos.Prod_categoryDAO;
import db.daos.ProductDAO;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Andrei Diaconu
 */
public class ImageDownloadServlet extends HttpServlet {

    private String imagesDir;
    private String imagesPath;
    private Prod_categoryDAO prod_categoryDao;
    private List_categoryDAO list_categoryDao;
    private ProductDAO productDao; // maybe useless: create product = post to ProductServlet

    @Override
    public void init() throws ServletException {
        imagesDir = getServletContext().getInitParameter("imagesDir");
        imagesPath = getServletContext().getInitParameter("imagesPath");
        if (imagesDir == null) {
            throw new ServletException("Please supply imagesDir parameter");
        }

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
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }

        String requestResource = request.getRequestURI().replaceFirst(contextPath + imagesDir + "/", "");
        String requestFile = requestResource.substring(requestResource.indexOf("/") + 1);
        String requestFolder;
        if (!requestResource.contains("/")) { // check for subFolder
            requestFolder = "";
        } else {
            requestFolder = requestResource.substring(0, requestResource.indexOf("/"));
        }

        File imageFile = new File(imagesPath + requestFolder + "/" + requestFile);
        if (!imageFile.exists() || imageFile.isDirectory()) {
            imageFile = new File(imagesPath + requestFolder + "/" + "default");
        }
        Files.copy(imageFile.toPath(), response.getOutputStream());
        //System.err.println("REAL PATH: " + imagesPath);
    }
}
