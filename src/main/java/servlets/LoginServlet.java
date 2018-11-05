package servlets;

import db.daos.Reg_UserDAO;
import db.daos.NV_UserDAO;
import db.entities.Reg_User;
import db.exceptions.DAOException;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


public class LoginServlet extends HttpServlet {

    private Reg_UserDAO reg_userDao;
    private NV_UserDAO nv_userDao;

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
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        // email and password can't be empty because input is "required"
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
