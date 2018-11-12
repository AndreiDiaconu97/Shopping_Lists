/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets;

import db.daos.List_regDAO;
import db.daos.NV_UserDAO;
import db.daos.Reg_UserDAO;
import db.entities.List_reg;
import db.entities.Reg_User;
import db.exceptions.DAOException;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class ShoppingListServlet extends HttpServlet {

    private Reg_UserDAO reg_userDao;
    private NV_UserDAO nv_userDao;
    private List_regDAO list_regDao;
    
    @Override
    public void init() throws ServletException {
        
        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new ServletException("Impossible to get dao factory");
        }
        try {
            reg_userDao = daoFactory.getDAO(Reg_UserDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for reg_user", ex);
        }
        try {
            nv_userDao = daoFactory.getDAO(NV_UserDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for nv_user", ex);
        }
        try {
            list_regDao = daoFactory.getDAO(List_regDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for reg_user", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
       
        if (request.getParameter("create") != null) {
            HttpSession session = request.getSession(false);
            Reg_User reg_user = null;
            if (session != null) {
                reg_user = (Reg_User) session.getAttribute("reg_user");
                //reg_user cannot be null cause filter /restricted
            }
            Integer id = reg_user.getId();
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String category = request.getParameter("category");

            List_reg list = new List_reg();
            list.setName(name);
            list.setDescription(description);
            list.setCategory(category);
            list.setOwner(id);

            try {
                list_regDao.insert(list);
                System.err.println("Ok. Id della lista inserita:" + list.getId());
            } catch (Exception e) {
                System.err.println("Errore. Id della lista inserita:" + list.getId());
            }

        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
