/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.entities.Product;
import db.entities.Reg_User;
import db.entities.List_reg;
import db.exceptions.DAOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import static db.daos.jdbc.JDBC_utility.getCountFor;
import db.daos.List_regDAO;

/**
 *
 * @author Andrei Diaconu
 */
public class JDBC_List_regDAO extends JDBC_DAO<List_reg, Integer> implements List_regDAO {

    public JDBC_List_regDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        return getCountFor("LISTS", CON);
    }

    @Override
    public List<List_reg> getAll() throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public boolean linkShoppingListToReg_User(List shoppingList, Reg_User user) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public List_reg getByPrimaryKey(Integer id) throws DAOException {
        if (id == null) {
            throw new DAOException("id parameter is null");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM LISTS WHERE ID = ?")) {
            stm.setInt(1, id);
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? JDBC_utility.resultSetToList_reg(rs) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the shopping_list for the passed id", ex);
        }
    }

    @Override
    public List<List_reg> getByOwner(Integer owner) throws DAOException {
        if (owner == null) {
            throw new DAOException("owner parameter is null");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM LISTS WHERE OWNER = ?")) {
            stm.setInt(1, owner); // QUESTO DA CAMBIARE
            try (ResultSet rs = stm.executeQuery()) {
                List<List_reg> shopping_lists = new ArrayList<>();

                while (rs.next()) {
                    shopping_lists.add(JDBC_utility.resultSetToList_reg(rs));
                }
                return shopping_lists;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the shopping_list for the passed owner", ex);
        }
    }

    @Override
    public List<Reg_User> getUsers(List shopping_list) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public List<Product> getProducts(List shopping_list) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void delete(List_reg entity) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void insert(List_reg entity) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void update(List_reg entity) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

}
