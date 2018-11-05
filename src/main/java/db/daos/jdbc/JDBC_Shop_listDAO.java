/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.entities.Product;
import db.entities.Reg_User;
import db.entities.Shop_list;
import db.exceptions.DAOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import db.daos.Shop_listDAO;

/**
 *
 * @author Andrei Diaconu
 */
public class JDBC_Shop_listDAO extends JDBC_DAO<Shop_list, Shop_list.PrimaryKey> implements Shop_listDAO {

    public JDBC_Shop_listDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public Shop_list getByPrimaryKey(Shop_list.PrimaryKey primaryKey) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public List<Shop_list> getAll() throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public boolean linkShoppingListToReg_User(Shop_list shoppingList, Reg_User user) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public Shop_list getByID(Integer id) throws DAOException {
        if (id == null) {
            throw new DAOException("id parameter is null");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM LISTS WHERE ID = ?")) {
            stm.setInt(1, id);
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? JDBC_utility.resultSetToShopping_list(rs) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the shopping_list for the passed id", ex);
        }
    }

    @Override
    public List<Shop_list> getByOwner(String owner) throws DAOException {
        if (owner == null) {
            throw new DAOException("owner parameter is null");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM LISTS WHERE OWNER = ?")) {
            stm.setString(1, owner);
            try (ResultSet rs = stm.executeQuery()) {
                List<Shop_list> shopping_lists = new ArrayList<>();

                while (rs.next()) {
                    shopping_lists.add(JDBC_utility.resultSetToShopping_list(rs));
                }
                return shopping_lists;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the shopping_list for the passed owner", ex);
        }
    }

    @Override
    public List<Reg_User> getListUsers(Shop_list shopping_list) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public List<Product> getListProducts(Shop_list shopping_list) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void delete(Shop_list entity) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void insert(Shop_list entity) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

}
