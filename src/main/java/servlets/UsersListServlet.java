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
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet that handles the users web page.
 *
 * @author Stefano Chirico &lt;stefano dot chirico at unitn dot it&gt;
 * @since 2018.04.04
 */
public class UsersListServlet extends HttpServlet {

    private Reg_UserDAO dao;

    @Override
    public void init() throws ServletException {
        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new ServletException("Impossible to get dao factory for user storage system");
        }
        try {
            dao = daoFactory.getDAO(Reg_UserDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao factory for user storage system", ex);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String cp = getServletContext().getContextPath();
        if (!cp.endsWith("/")) {
            cp += "/";
        }
        final String contextPath = cp;

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        try {
            List<Reg_User> reg_users = dao.getAll();

            out.println(
                    "<!DOCTYPE html>\n"
                    + "<html>\n"
                    + "    <head>\n"
                    + "        <title>Lab 07: Users List</title>\n"
                    + "        <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n"
                    + "        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">\n"
                    + "        <!-- Latest compiled and minified CSS -->\n"
                    + "        <link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css\" crossorigin=\"anonymous\">\n"
                    + "        <link rel=\"stylesheet\" href=\"https://use.fontawesome.com/releases/v5.0.8/css/all.css\" crossorigin=\"anonymous\">\n"
                    + "        <link rel=\"stylesheet\" href=\"../css/floating-labels.css\">\n"
                    + "    </head>\n"
                    + "    <body>\n"
                    //+ "        <div class=\"jumbotron jumbotron-fluid\">\n"
                    + "            <div class=\"container-fluid\">\n"
                    + "                <div class=\"card border-primary\">\n"
                    + "                    <div class=\"card-header bg-primary text-white\">\n"
                    + "                        <h5 class=\"card-title\">Users</h5>\n"
                    + "                    </div>\n"
                    + "                    <div class=\"card-body\">\n"
                    + "                        The following table lists all the users of the application.<br>\n"
                    + "                        For each user, you can see the count of shopping-lists shared with him.<br>\n"
                    + "                        Clicking on the number of shopping-lists, you can show the collection of shopping-lists shared with &quot;selected&quot; user.\n"
                    + "                    </div>\n"
                    + "\n"
                    + "                    <!-- Table -->\n"
                    + "                    <div class=\"table-responsive\">\n"
                    + "                        <table class=\"table table-sm table-hover\">\n"
                    + "                            <thead>\n"
                    + "                                <tr>\n"
                    + "                                    <th>Email</th>\n"
                    + "                                    <th>First name</th>\n"
                    + "                                    <th>Last name</th>\n"
                    + "                                    <th>Shopping Lists</th>\n"
                    + "                                </tr>\n"
                    + "                            </thead>\n"
                    + "                            <tbody>\n"
            );
            for (Reg_User reg_user : reg_users) {
                out.println(
                        "                                <tr>\n"
                        + "                                    <td>" + reg_user.getEmail() + "</td>\n"
                        + "                                    <td>" + reg_user.getFirstname() + "</td>\n"
                        + "                                    <td><a href=\"" + response.encodeURL(contextPath + "restricted/shopping.lists.handler?id=" + reg_user.getId()) + "\"><span class=\"badge badge-primary badge-pill\">" + "reg_user.getShoppingListsCount()" + "</span></a></td>\n"
                        + "                                </tr>\n"
                );
            }
            out.println(
                    "                            </tbody>\n"
                    + "                        </table>\n"
                    + "                  </div>\n"
                    + "                    \n"
                    + "                    <div class=\"card-footer\"><span class=\"float-left\">Copyright &copy; 2018 - Stefano Chirico</span><a href=\"" + (contextPath + "restricted/logout.handler") + "\" class=\"float-right\"><button type=\"button\" class=\"btn btn-primary btn-sm\">Logout</button></a></div>\n"
                    + "                </div>\n"
                    + "            </div>\n"
                    //+ "        </div>\n"
                    + "        <!-- Latest compiled and minified JavaScript -->\n"
                    + "        <script src=\"https://code.jquery.com/jquery-3.2.1.min.js\" crossorigin=\"anonymous\"></script>\n"
                    + "        <script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js\" crossorigin=\"anonymous\"></script>\n"
                    + "    </body>\n"
                    + "</html>"
            );

        } catch (DAOException ex) {
            out.println(
                    "<!DOCTYPE html>\n"
                    + "<html>\n"
                    + "    <head>\n"
                    + "        <title>Lab 07: Users List</title>\n"
                    + "        <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n"
                    + "        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">\n"
                    + "        <!-- Latest compiled and minified CSS -->\n"
                    + "        <link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css\" crossorigin=\"anonymous\">\n"
                    + "    </head>\n"
                    + "    <body>\n"
                    + "        <div class=\"jumbotron\">\n"
                    + "            <div class=\"container\">\n"
                    + "                <div class=\"card border-danger\">\n"
                    + "                    <div class=\"card-header bg-danger text-white\">\n"
                    + "                        <h3 class=\"card-title\">Users</h3>\n"
                    + "                    </div>\n"
                    + "                    <div class=\"card-body\">\n"
                    + "                        Error in retriving users list: " + ex.getMessage() + "<br>\n"
                    + "                    </div>\n"
                    + "                    <div class=\"card-footer\">Copyright &copy; 2018 - Stefano Chirico</div>\n"
                    + "                </div>\n"
                    + "            </div>\n"
                    + "        </div>\n"
                    + "        <!-- Latest compiled and minified JavaScript -->\n"
                    + "        <script src=\"https://code.jquery.com/jquery-3.2.1.min.js\" crossorigin=\"anonymous\"></script>\n"
                    + "        <script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js\" crossorigin=\"anonymous\"></script>\n"
                    + "    </body>\n"
                    + "</html>"
            );
        }
    }
}
