/*
 * AA 2017-2018
 * Introduction to Web Programming
 * Lab 07 - ShoppingList List
 * UniTN
 */
package listeners;

import db.exceptions.DAOFactoryException;
import db.factories.DAOFactory;
import db.factories.jdbc.JDBCDAOFactory;
import java.util.logging.Logger;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

/**
 * Web application lifecycle listener.
 *
 * @author Stefano Chirico &lt;stefano dot chirico at unitn dot it&gt;
 * @since 2018.04.04
 */
public class WebAppContextListener implements ServletContextListener {

    /**
     * The serlvet container call this method when initializes the application for the first time.
     *
     * @param sce the event fired by the servlet container when initializes the application
     *
     * @author Stefano Chirico
     * @since 1.0.180404
     */
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        String realPath = sce.getServletContext().getRealPath("/");
        realPath = realPath.substring(0, realPath.lastIndexOf("\\target"));
        String dburl = "jdbc:derby:" + realPath + "\\" + sce.getServletContext().getInitParameter("relative_dburl");
        dburl = dburl.replace('\\', '/');
        System.err.println("DBURL IS: " + dburl);
        sce.getServletContext().setInitParameter("dburl", dburl);
        System.err.println("dburl in context: " + sce.getServletContext().getInitParameter("relative_dburl"));
        
        try {
            JDBCDAOFactory.configure(dburl);
            DAOFactory daoFactory = JDBCDAOFactory.getInstance();
            sce.getServletContext().setAttribute("daoFactory", daoFactory);
        } catch (DAOFactoryException ex) {
            Logger.getLogger(getClass().getName()).severe(ex.toString());
            throw new RuntimeException(ex);
        }
    }

    /**
     * The servlet container call this method when destroyes the application.
     *
     * @param sce the event generated by the servlet container when destroyes the application.
     *
     * @author Stefano Chirico
     * @since 1.0.180404
     */
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        DAOFactory daoFactory = (DAOFactory) sce.getServletContext().getAttribute("daoFactory");
        if (daoFactory != null) {
            daoFactory.shutdown();
        }
        daoFactory = null;
    }
}
