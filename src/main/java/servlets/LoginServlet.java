/*
 * AA 2017-2018
 * Introduction to Web Programming
 * Lab 07 - ShoppingList List
 * UniTN
 */
package servlets;

import db.daos.Reg_UserDAO;
import db.entities.Reg_User;
import db.exceptions.DAOException;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet that handles the login web page.
 *
 * @author Stefano Chirico &lt;stefano dot chirico at unitn dot it&gt;
 * @since 2018.04.04
 */
public class LoginServlet extends HttpServlet {

    private Reg_UserDAO reg_userDao;
    private NV_UserDao nv_userDao;

    @Override
    public void init() throws ServletException {
        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new ServletException("Impossible to get dao factory (login servlet)");
        }
        try {
            reg_userDao = daoFactory.getDAO(Reg_UserDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for reg_user", ex);
        }
        try {
            nv_userDao = daoFactory.getDAO(NV_UserDao.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for nv_user", ex);
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     *
     * @author Stefano Chirico
     * @since 1.0.180404
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }

        try {
            Reg_User reg_user = reg_userDao.getByEmailAndPassword(email, password);
            if (reg_user == null) {
                
                if(reg_userDao.getByEmail(email) != null){
                    // wrong password
                } else if(nv_userDao.getByEmail(email) != null){
                    // need to verify
                } else {
                    // need to register
                }
                
                //response.sendRedirect(response.encodeRedirectURL(contextPath + "login.handler"));
            } else {
                request.getSession().setAttribute("reg_user", reg_user);
                if (reg_user.getIs_admin()) {
                    response.sendRedirect(response.encodeRedirectURL(contextPath + "restricted/admin"));
                } else {
                    response.sendRedirect(response.encodeRedirectURL(contextPath + "restricted/shopping.lists.handler"));
                }
            }
        } catch (DAOException ex) {
            //TODO: log exception
            request.getServletContext().log("Impossible to retrieve the user", ex);
        }
    }
}
