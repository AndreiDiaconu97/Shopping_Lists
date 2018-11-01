/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.List_categoryDAO;
import db.entities.List_category;
import db.exceptions.DAOException;
import java.sql.Connection;
import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public class JDBCList_categoryDAO extends JDBCDAO<List_category, Integer> implements List_categoryDAO {

    public JDBCList_categoryDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public List_category getByPrimaryKey(Integer primaryKey) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public List<List_category> getAll() throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

}
