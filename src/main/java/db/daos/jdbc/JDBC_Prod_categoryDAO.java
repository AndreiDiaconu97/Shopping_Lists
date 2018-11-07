/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.Prod_categoryDAO;
import static db.daos.jdbc.JDBC_utility.*;
import db.entities.Prod_category;
import db.exceptions.DAOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public class JDBC_Prod_categoryDAO extends JDBC_DAO<Prod_category, String> implements Prod_categoryDAO {

    public JDBC_Prod_categoryDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        return getCountFor(P_CAT_TABLE, CON);
    }

    @Override
    public List<Prod_category> getAll() throws DAOException {
        return getAllFor(P_CAT_TABLE, CON, Prod_category.class);
    }

    @Override
    public void insert(Prod_category entity) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void delete(Prod_category entity) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void update(Prod_category entity) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public Prod_category getByPrimaryKey(String primaryKey) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

}
