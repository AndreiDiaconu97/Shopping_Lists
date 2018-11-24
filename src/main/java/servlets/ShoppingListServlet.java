/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets;

import db.daos.List_regDAO;
import db.daos.ProductDAO;
import db.entities.List_reg;
import db.entities.Product;
import db.entities.Reg_User;
import db.exceptions.DAOException;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.json.JSONArray;
import org.json.JSONObject;

public class ShoppingListServlet extends HttpServlet {

    private List_regDAO list_regDao;
    private ProductDAO productDao;

    @Override
    public void init() throws ServletException {

        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new ServletException("Impossible to get dao factory");
        }
        try {
            list_regDao = daoFactory.getDAO(List_regDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for reg_user", ex);
        }
        try {
            productDao = daoFactory.getDAO(ProductDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for product", ex);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }
        
        if(request.getParameter("getList") != null){
            int id = Integer.parseInt(request.getParameter("getList"));
            try{
                List_reg list = list_regDao.getByPrimaryKey(id);
                JSONObject listJSON = new JSONObject();
                listJSON.put("id", list.getId());
                listJSON.put("name", list.getName());
                listJSON.put("description", list.getDescription());
                JSONArray productsJSON = new JSONArray();
                for(Product p : list_regDao.getProducts(list)){
                    JSONObject productJSON = new JSONObject();
                    productJSON.put("name", p.getName());
                    productJSON.put("description", p.getDescription());
                    productsJSON.put(productJSON);
                }
                listJSON.put("products", productsJSON);
                response.setCharacterEncoding("UTF-8");
                response.getWriter().print(listJSON);
            } catch(DAOException ex){
                System.err.println("Impossible to get further info for list with id=" + id);
            }
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
                HttpSession session = request.getSession(false);
                Reg_User reg_user = reg_user = (Reg_User) session.getAttribute("reg_user");
                Integer id = reg_user.getId();
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String category = request.getParameter("category");

                List_reg list = new List_reg(name, id, category, description, null);

                try {
                    list_regDao.insert(list);
                    System.err.println("Ok. Id della lista inserita:" + list.getId());
                } catch (DAOException ex) {
                    System.err.println("Errore. Id della lista inserita:" + list.getId());
                }
                break;
            }
            case "edit": {
                HttpSession session = request.getSession(false);
                Reg_User reg_user = (Reg_User) session.getAttribute("reg_user");
                Integer id = reg_user.getId();
                String name = request.getParameter("name");
                String description = request.getParameter("description");
                String category = request.getParameter("category");
                List_reg list = new List_reg(name, id, category, description, null);
                list.setId(Integer.parseInt(request.getParameter("listID")));
                try {
                    list_regDao.update(list);
                    System.err.println("Ok, lista modificata:" + list.getId());
                } catch (DAOException ex) {
                    System.err.println("Errore. Lista inserita:" + list.getId());
                }
                break;
            }
            case "delete": {
                Integer id = Integer.parseInt(request.getParameter("list_id"));
                try {
                    List_reg list = list_regDao.getByPrimaryKey(id);
                    try {
                        list_regDao.delete(list);
                        System.err.println("List deleted");
                    } catch (DAOException ex) {
                        System.err.println("Impossible to delete selected list");
                    }
                } catch (DAOException ex) {
                    System.err.println("Impossible to retrieve list by given ID");
                }
                break;
            }
            case "add": {
                String name = request.getParameter("object_name");
                String id = request.getParameter("list_id");
                Product product = new Product();
                List_reg list_reg = new List_reg();
                try {
                    list_reg = list_regDao.getByPrimaryKey(Integer.parseInt(id));
                    product = productDao.getByName(name);
                    System.err.println(list_reg.getName());
                } catch (Exception e) {
                    System.err.println(e);
                }
                if (product != null) {
                    try {
                        list_regDao.insertProduct(list_reg, product);
                    } catch (DAOException e) {
                        System.err.println("Impossible to insert given product");
                    }
                }
                break;
            }
            default:
                System.err.println("ShoppingListServlet: unsupported parameter");
                break;
        }
        response.sendRedirect(contextPath + "restricted/shopping.lists.html");
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
