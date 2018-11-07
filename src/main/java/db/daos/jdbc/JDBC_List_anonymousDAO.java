/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import static db.daos.jdbc.JDBC_utility.getCountFor;
import db.entities.Product;
import db.entities.List_anonymous;
import db.exceptions.DAOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import static db.daos.jdbc.JDBC_utility.resultSetToList_anonymous;
import db.daos.List_anonymousDAO;

/**
 *
 * @author Andrei Diaconu
 */
public class JDBC_List_anonymousDAO extends JDBC_DAO<List_anonymous, Integer> implements List_anonymousDAO {

    public JDBC_List_anonymousDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        return getCountFor("LISTS_ANONYMOUS", CON);
    }

    @Override
    public List<List_anonymous> getAll() throws DAOException {
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM LISTS_ANONYMOUS")) {
            try (ResultSet rs = stm.executeQuery()) {
                List<List_anonymous> lists_anonymous = new ArrayList<>();
                while (rs.next()) {
                    lists_anonymous.add(resultSetToList_anonymous(rs));
                }
                return lists_anonymous;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get all the list_anonymous", ex);
        }
    }

    @Override
    public void insert(List_anonymous entity) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void delete(List_anonymous entity) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void update(List_anonymous entity) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public List_anonymous getByPrimaryKey(Integer primaryKey) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public List<Product> getProducts(List_anonymous list_anonymous) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

}
