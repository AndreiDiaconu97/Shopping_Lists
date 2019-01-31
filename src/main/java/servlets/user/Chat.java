/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets.user;

import db.daos.List_regDAO;
import db.entities.List_reg;
import db.entities.Message;
import db.entities.User;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author Andrea Mattè
 */
public class Chat extends HttpServlet {

    private List_regDAO list_regDao;

    @Override
    public void init() throws ServletException {

        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new ServletException("Impossible to get dao factory");
        }
        try {
            list_regDao = daoFactory.getDAO(List_regDAO.class);
        } catch (DAOFactoryException ex) {
            throw new ServletException("Impossible to get dao for list_reg", ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }

        try {
            HttpSession session = request.getSession(false);
            User user = (User) session.getAttribute("user");
            Integer list_id = Integer.parseInt(request.getParameter("list_id"));
            List_reg list = list_regDao.getByPrimaryKey(list_id);
            if(!list.getOwner().equals(user) && !list_regDao.getUsersSharedTo(list).contains(user)){
                throw new Exception("No access to this list");
            }
            Message message = new Message();
            message.setList(list);
            message.setUser(user);
            message.setIsLog(false);
            message.setText(request.getParameter("text"));            
            list_regDao.insertMessage(message);
            
            response.sendRedirect(contextPath+"restricted/shopping.list.html?listID="+list.getId());
            
        } catch (Exception e) {
            System.err.println("Cannot chat: " + e);
            response.sendRedirect(contextPath+"error.html");
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
