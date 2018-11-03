/*
 * AA 2017-2018
 * Introduction to Web Programming
 * Lab 07 - ShoppingList List
 * UniTN
 */
package servlets;

import db.daos.Reg_UserDAO;
import db.daos.Shopping_listDAO;
import db.entities.Reg_User;
import db.entities.Shopping_list;
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
import javax.servlet.http.HttpSession;

/**
 * Servlet that handles the shopping-lists web page.
 *
 * @author Stefano Chirico &lt;stefano dot chirico at unitn dot it&gt;
 * @since 2018.04.04
 */
public class ShoppingListsServlet extends HttpServlet {

    private Shopping_listDAO shopping_listDao;
    private Reg_UserDAO reg_userDao;

    @Override
    public void init() throws ServletException {
        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new ServletException("Impossible to get dao factory for user storage system");
        }
        try {
            shopping_listDao = daoFactory.getDAO(Shopping_listDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao factory for shopping-list storage system", ex);
        }
        try {
            reg_userDao = daoFactory.getDAO(Reg_UserDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao factory for user storage system", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer userId = Integer.valueOf(request.getParameter("idUser"));
        String name = request.getParameter("name");
        String descriptiopn = request.getParameter("description");

        try {
            Shopping_list shopping_list = new Shopping_list();
            shopping_list.setName(name);
            shopping_list.setDescription(descriptiopn);

            Reg_User reg_user = reg_userDao.getByID(userId);

            shopping_listDao.insert(shopping_list);
            shopping_listDao.linkShoppingListToReg_User(shopping_list, reg_user);
        } catch (DAOException ex) {
            //TODO: log exception
        }

        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }

        response.sendRedirect(response.encodeRedirectURL(contextPath + "restricted/shopping.lists.handler?id=" + userId));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        Integer userId = null;
        Reg_User reg_user = null;
        try {
            userId = Integer.valueOf(request.getParameter("id"));
        } catch (RuntimeException ex) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                reg_user = (Reg_User) session.getAttribute("reg_user");
            }
            if (reg_user != null) {
                userId = reg_user.getId();
            }
        }
        if (userId == null) {
            String contextPath = getServletContext().getContextPath();
            if (!contextPath.endsWith("/")) {
                contextPath += "/";
            }
            if (!response.isCommitted()) {
                response.sendRedirect(response.encodeRedirectURL(contextPath + "login.handler"));
            }
        }

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        try {
            if (reg_user == null) {
                reg_user = reg_userDao.getByID(userId);
            }
            List<Shopping_list> shopping_lists = reg_userDao.getOwningShopLists(reg_user);

            out.println(
                    "<!DOCTYPE html>\n"
                    + "<html>\n"
                    + "    <head>\n"
                    + "        <title>Lab 07: Shopping lists shared with " + reg_user.getName() + "</title>\n"
                    + "        <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n"
                    + "        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">\n"
                    + "        <!-- Latest compiled and minified CSS -->\n"
                    + "        <link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css\" crossorigin=\"anonymous\">\n"
                    + "        <link rel=\"stylesheet\" href=\"https://use.fontawesome.com/releases/v5.0.8/css/all.css\" crossorigin=\"anonymous\">\n"
                    + "        <link rel=\"stylesheet\" href=\"../css/floating-labels.css\">\n"
                    + "    </head>\n"
                    + "    <body>\n"
                    //                    + "        <div class=\"jumbotron jumbotron-fluid\">\n"
                    + "            <div class=\"container-fluid\">\n"
                    + "                <div class=\"card border-primary\">\n"
                    + "                    <div class=\"card-header bg-primary text-white\">\n"
                    + "                        <h5 class=\"card-title float-left\">Shopping Lists</h5><button type=\"button\" class=\"btn btn-outline-light bg-light text-primary btn-sm float-right\" data-toggle=\"modal\" data-target=\"#myModal\"><span class=\"fas fa-plus\" aria-hidden=\"true\"></span></button>\n"
                    + "                    </div>\n"
                    + "                    <div class=\"card-body\">\n"
                    + "                        The following table lists all the shopping-lists shared with &quot;" + reg_user.getName() + "&quot;.<br>\n"
                    + "                    </div>\n"
                    + "\n"
                    + "                    <!-- Shopping Lists cards -->\n"
                    + "                    <div id=\"accordion\">\n"
            );
            int index = 1;
            for (Shopping_list shopping_list : shopping_lists) {
                out.println(
                        "                        <div class=\"card\">\n"
                        + "                            <div class=\"card-header\" id=\"heading" + (index) + "\">\n"
                        + "                                <h5 class=\"mb-0\">\n"
                        + "                                    <button class=\"btn btn-link\" data-toggle=\"collapse\" data-target=\"#collapse" + (index) + "\" aria-expanded=\"true\" aria-controls=\"collapse" + (index) + "\">\n"
                        + "                                        " + shopping_list.getName() + "\n"
                        + "                                    </button>\n"
                        + "                                </h5>\n"
                        + "                            </div>\n"
                        + "                            <div id=\"collapse" + (index) + "\" class=\"collapse" + (index == 1 ? " show" : "") + "\" aria-labelledby=\"heading" + (index++) + "\" data-parent=\"#accordion\">\n"
                        + "                                <div class=\"card-body\">\n"
                        + "                                    " + shopping_list.getDescription() + "\n"
                        + "                                </div>\n"
                        + "                            </div>\n"
                        + "                        </div>\n"
                );
            }
            out.println(
                    "                    </div>\n"
                    + "                    \n"
                    + "                    <div class=\"card-footer\"><span class=\"float-left\">Copyright &copy; 2018 - Stefano Chirico</span><a class=\"float-right\" href=\"users.handler\"><button type=\"button\" class=\"btn btn-primary btn-sm\">Go to Users List</button></a></div>\n"
                    + "                </div>\n"
                    + "            </div>\n"
            //                    + "        </div>\n"
            );
            out.println(
                    "        <!-- Modal -->\n"
                    + "        <form action=\"shopping.lists.handler\" method=\"POST\">\n"
                    + "            <div class=\"modal fade\" id=\"myModal\" tabindex=\"-1\" role=\"dialog\" aria-labelledby=\"myModalLabel\">\n"
                    + "                <div class=\"modal-dialog modal-dialog-centered\" role=\"document\">\n"
                    + "                    <div class=\"modal-content\">\n"
                    + "                        <div class=\"modal-header\">\n"
                    + "                            <h3 class=\"modal-title\" id=\"myModalLabel\">Create new Shopping List</h3>\n"
                    + "                            <button type=\"button\" class=\"close\" data-dismiss=\"modal\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button>\n"
                    + "                        </div>\n"
                    + "                        <div class=\"modal-body\">\n"
                    + "                            <input type=\"hidden\" name=\"idUser\" value=\"" + reg_user.getId() + "\">\n"
                    + "                            <div class=\"form-label-group\">\n"
                    + "                                <input type=\"text\" name=\"name\" id=\"name\" class=\"form-control\" placeholder=\"Name\" required autofocus>\n"
                    + "                                <label for=\"name\">Name</label>\n"
                    + "                            </div>\n"
                    + "                            <div class=\"form-label-group\">\n"
                    + "                               <input type=\"text\" name=\"description\" id=\"description\" class=\"form-control\" placeholder=\"Description\" required>\n"
                    + "                               <label for=\"description\">Description</label>\n"
                    + "                            </div>\n"
                    + "                        </div>\n"
                    + "                        <div class=\"modal-footer\">\n"
                    + "                            <button type=\"submit\" class=\"btn btn-primary\">Create</button>\n"
                    + "                            <button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Cancel</button>\n"
                    + "                        </div>\n"
                    + "                    </div>\n"
                    + "                </div>\n"
                    + "            </div>\n"
                    + "        </form>\n"
            );
            out.println(
                    "        <!-- Latest compiled and minified JavaScript -->\n"
                    + "        <script src=\"https://code.jquery.com/jquery-3.2.1.min.js\" crossorigin=\"anonymous\"></script>\n"
                    + "        <script src=\"https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.18.1/moment.min.js\" crossorigin=\"anonymous\"></script>\n"
                    + "        <script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js\" crossorigin=\"anonymous\"></script>\n"
                    + "    </body>\n"
                    + "</html>"
            );
        } catch (DAOException ex) {
            out.println(
                    "<!DOCTYPE html>\n"
                    + "<html>\n"
                    + "    <head>\n"
                    + "        <title>Lab 07: Shopping list</title>\n"
                    + "        <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n"
                    + "        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">\n"
                    + "        <!-- Latest compiled and minified CSS -->\n"
                    + "        <link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css\" crossorigin=\"anonymous\">\n"
                    + "    </head>\n"
                    + "    <body>\n"
                    + "        <div class=\"jumbotron\">\n"
                    + "            <div class=\"container\">\n"
                    + "                <div class=\"card border-danger\">\n"
                    + "                    <div class=\"card-header\">\n"
                    + "                        <h3 class=\"card-title bg-danger text-white\">Shopping Lists</h3>\n"
                    + "                    </div>\n"
                    + "                    <div class=\"card-body\">\n"
                    + "                        Error in retriving shopping lists: " + ex.getMessage() + "<br>\n"
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
