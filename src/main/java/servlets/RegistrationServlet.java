/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlets;

import db.daos.NV_UserDAO;
import db.daos.Reg_UserDAO;
import db.entities.NV_User;
import db.exceptions.DAOException;
import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author andrea
 */
public class RegistrationServlet extends HttpServlet {

    Reg_UserDAO reg_userDao;
    NV_UserDAO nv_userDao;

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
        String firstname = request.getParameter("firstname");
        String lastname = request.getParameter("lastname");
        // email and password can't be empty because input is "required"

        String contextPath = getServletContext().getContextPath();
        if (!contextPath.endsWith("/")) {
            contextPath += "/";
        }

        try {
            if (reg_userDao.getByEmail(email) != null) {
                // already registered
                response.sendRedirect(contextPath + "registration.html?alreadyRegistered=true");
            } else if(nv_userDao.getByEmail(email) != null){
                // already registered, need verification
                response.sendRedirect(contextPath + "registration.html?needToVerify=true");
            } else {
                NV_User nv_user = new NV_User(email, password, firstname, lastname, nv_userDao.generateCode(NV_User.getCODE_SIZE()));
                // send email with code
            }
        } catch(DAOException ex){
            request.getServletContext().log("Impossible to check if user is already registered", ex);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet for register form submission";
    }

}
