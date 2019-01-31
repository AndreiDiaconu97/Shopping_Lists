/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets.user;

import db.daos.List_categoryDAO;
import db.daos.Prod_categoryDAO;
import db.daos.ProductDAO;
import db.daos.UserDAO;
import db.entities.List_category;
import db.entities.Prod_category;
import db.entities.Product;
import db.entities.User;
import db.exceptions.DAOException;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
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
 * @author Andrei Diaconu
 */
@MultipartConfig
public class UserServlet extends HttpServlet {

    private String imagesPath;
    private UserDAO userDao;

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

    @Override
    public void init() throws ServletException {
        imagesPath = getServletContext().getInitParameter("imagesPath");

        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new ServletException("Impossible to get dao factory");
        }

        try {
            userDao = daoFactory.getDAO(UserDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for user", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = "";
        if (request.getParameter("action") != null) {
            action = request.getParameter("action");
        } else {
            System.err.println("UserServlet: action parameter needed!");
            response.sendRedirect(response.encodeRedirectURL("../error.html?noAction"));
            return;
        }

        switch (action) {
            case "edit": {
                try {
                    HttpSession session = request.getSession(false);
                    User user = (User) session.getAttribute("user");

                    String firstname = request.getParameter("firstname");
                    String lastname = request.getParameter("lastname");
                    user.setFirstname(firstname);
                    user.setLastname(lastname);

                    userDao.update(user);
                    saveImage(request.getPart("image"), "avatars", user.getId().toString());
                } catch (Exception ex) {
                    System.err.println("Error updating user: " + ex);
                    response.sendRedirect(response.encodeRedirectURL("../error.html?userEdit"));
                }
                if (!response.isCommitted()) {
                    response.sendRedirect(request.getHeader("referer"));
                }
                break;
            }
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}
