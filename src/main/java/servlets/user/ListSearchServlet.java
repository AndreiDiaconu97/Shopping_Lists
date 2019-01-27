/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets.user;

import db.daos.List_categoryDAO;
import db.daos.List_regDAO;
import db.daos.UserDAO;
import db.entities.List_category;
import db.entities.List_reg;
import db.entities.User;
import db.exceptions.DAOException;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 *
 * @author Andrea Mattè
 */
public class ListSearchServlet extends HttpServlet {

    private List_regDAO list_regDao;
    private List_categoryDAO list_categoryDao;
    private UserDAO userDao;

    @Override
    public void init() throws ServletException {

        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new ServletException("Impossible to get dao factory");
        }
        try {
            list_regDao = daoFactory.getDAO(List_regDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for lists", ex);
        }
        try {
            list_categoryDao = daoFactory.getDAO(List_categoryDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for list_categories", ex);
        }
        try {
            userDao = daoFactory.getDAO(UserDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for users", ex);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }

        try {
            HttpSession session = request.getSession(false);
            User user = (User) session.getAttribute("user");
            String shared = request.getParameter("shared");
            String name = request.getParameter("name");
            String cat_s = request.getParameter("category");
            String sortby_s = request.getParameter("sortby");
            Integer cat_id = Integer.parseInt(cat_s != null ? cat_s : "-1");
            List_category list_category = list_categoryDao.getByPrimaryKey(cat_id);

            List<List_reg> searched = ("true".equals(shared)) ? userDao.getSharedLists(user) : userDao.getOwnedLists(user);
            if (name != null) {
                searched.removeIf(item -> !(item.getName().toUpperCase().contains(name.toUpperCase())));
            }
            if (list_category != null) {
                searched.removeIf(item -> !(item.getCategory().equals(list_category)));
            }
            switch (sortby_s) {
                case "Completion >":
                    searched.sort((l, r) -> {
                        try {
                            int p_l = list_regDao.getFullyPurchasedCount(l);
                            int t_l = list_regDao.getProducts(l).size();
                            int p_r = list_regDao.getFullyPurchasedCount(r);
                            int t_r = list_regDao.getProducts(r).size();
                            return (100 * ++p_r / ++t_r) - (100 * ++p_l / ++t_l);
                        } catch (DAOException ex) {
                            return 0;
                        }
                    });
                    break;
                case "Completion <":
                    searched.sort((l, r) -> {
                        try {
                            int p_l = list_regDao.getFullyPurchasedCount(l);
                            int t_l = list_regDao.getProducts(l).size();
                            int p_r = list_regDao.getFullyPurchasedCount(r);
                            int t_r = list_regDao.getProducts(r).size();
                            return (100 * ++p_l / ++t_l) - (100 * ++p_r / ++t_r);
                        } catch (DAOException e) {
                            return 0;
                        }
                    });
                    break;
                default:// name or nothing
                    searched.sort((l, r) -> l.getName().compareTo(r.getName()));
                    break;
            }

            JSONArray searchedJSON = List_reg.toJSON(searched);

            for (int i = 0; i < searchedJSON.length(); i++) {
                JSONObject list = searchedJSON.getJSONObject(i);
                list.put("purchased", list_regDao.getFullyPurchasedCount(list_regDao.getByPrimaryKey(list.getInt("id"))));
                list.put("total", list_regDao.getProducts(list_regDao.getByPrimaryKey(list.getInt("id"))).size());
            }

            response.setCharacterEncoding("UTF-8");
            response.getWriter().print(searchedJSON);
        } catch (Exception ex) {
            System.err.println("Error in list search servlet: " + ex);
            response.sendRedirect(contextPath + "error.html?prodsearch");
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
