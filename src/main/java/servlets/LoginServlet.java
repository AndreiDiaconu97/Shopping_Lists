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

    @Override
    public void init() throws ServletException {
        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new ServletException("Impossible to get dao factory for user storage system");
        }
        try {
            reg_userDao = daoFactory.getDAO(Reg_UserDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao factory for user storage system", ex);
        }
    }

    /**
     * Handles the HTTP <code>GET</code> method.
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
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println(
                "<!DOCTYPE html>\n"
                + "<html>\n"
                + "    <head>\n"
                + "        <title>Lab 07: Authentication Area</title>\n"
                + "        <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n"
                + "        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">\n"
                + "        <!-- Latest compiled and minified CSS -->\n"
                + "        <link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css\" crossorigin=\"anonymous\">\n"
                + "        <link rel=\"stylesheet\" href=\"https://use.fontawesome.com/releases/v5.0.8/css/all.css\" crossorigin=\"anonymous\">\n"
                + "        <!-- Custom styles for this template -->\n"
                //+ "        <link href=\"css/signin.css\" rel=\"stylesheet\">\n"
                + "        <link href=\"css/floating-labels.css\" rel=\"stylesheet\">\n"
                + "    </head>\n"
                + "    <body>\n"
                //                + "    <div class=\"container\">\n"
                //                + "        <div class=\"jumbotron\">\n"
                + "        <form class=\"form-signin\" action=\"" + contextPath + "login.handler\" method=\"POST\">\n"
                + "            <div class=\"text-center mb-4\">\n"
                + "                <img class=\"mb-4\" src=\"images/unitn_logo_1024.png\"  width=\"128\" height=\"128\">\n"
                + "                <h3 class=\"h3 mb-3 font-weight-normal\">Authentication Area</h3>\n"
                + "                <p>You must authenticate to access, view, modify and share your Shopping Lists</p>\n"
                + "            </div>\n"
                + "            <div class=\"form-label-group\">\n"
                + "                <input type=\"email\" id=\"username\" name=\"username\" class=\"form-control\" placeholder=\"Username\" required autofocus>\n"
                + "                <label for=\"username\">Username</label>\n"
                + "            </div>\n"
                + "            <div class=\"form-label-group\">\n"
                + "                <input type=\"password\" id=\"password\" name=\"password\" class=\"form-control\" placeholder=\"Password\" required>\n"
                + "                <label for=\"password\">Password</label>\n"
                + "            </div>\n"
                + "            <div class=\"checkbox mb-3\">\n"
                + "                <label>\n"
                + "                    <input type=\"checkbox\" name=\"rememberMe\" value=\"true\"> Remember me\n"
                + "                </label>\n"
                + "            </div>\n"
                + "            <button class=\"btn btn-lg btn-primary btn-block\" type=\"submit\">Sign in</button>\n"
                + "        </form>\n"
                //                + "            </div>\n"
                //                + "        </div> <!-- /container -->\n"
                + "        <!-- Latest compiled and minified JavaScript -->\n"
                + "        <script src=\"https://code.jquery.com/jquery-3.2.1.min.js\" crossorigin=\"anonymous\"></script>\n"
                + "        <script src=\"https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.18.1/moment.min.js\" crossorigin=\"anonymous\"></script>\n"
                + "        <script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js\" crossorigin=\"anonymous\"></script>\n"
                + "    </body>\n"
                + "</html>"
        );
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
        String email = request.getParameter("username");
        String password = request.getParameter("password");

        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }

        try {
            Reg_User reg_user = reg_userDao.getByEmailAndPassword(email, password);
            if (reg_user == null) {
                response.sendRedirect(response.encodeRedirectURL(contextPath + "login.handler"));
            } else {
                request.getSession().setAttribute("reg_user", reg_user);
                if (reg_user.getIs_admin()) {
                    response.sendRedirect(response.encodeRedirectURL(contextPath + "restricted/admin/users.handler"));
                } else {
                    response.sendRedirect(response.encodeRedirectURL(contextPath + "restricted/shopping.lists.handler?id=" + reg_user.getId()));
                }
            }
        } catch (DAOException ex) {
            //TODO: log exception
            request.getServletContext().log("Impossible to retrieve the user", ex);
        }
    }
}
