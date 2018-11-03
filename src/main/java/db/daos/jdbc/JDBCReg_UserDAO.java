/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.Reg_UserDAO;
import db.entities.Product;
import db.entities.Reg_User;
import db.entities.Shopping_list;
import db.exceptions.DAOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public class JDBCReg_UserDAO extends JDBCDAO<Reg_User, String> implements Reg_UserDAO {

    public JDBCReg_UserDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        try (Statement stmt = CON.createStatement()) {
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM REG_USERS");
            return rs.next() ? rs.getLong(1) : 0L;
        } catch (SQLException ex) {
            throw new DAOException("Impossible to count users", ex);
        }
    }

    @Override
    public Reg_User getByPrimaryKey(String email) throws DAOException {
        if ("".equals(email) || email == null) {
            throw new DAOException("Given email is empty");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM REG_USERS WHERE EMAIL = ?")) {
            stm.setString(1, email);
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? JDBC_utility.resultSetToReg_User(rs) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the user for the passed email", ex);
        }
    }

    @Override
    public List<Reg_User> getAll() throws DAOException {
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM REG_USERS")) {
            try (ResultSet rs = stm.executeQuery()) {
                List<Reg_User> reg_users = new ArrayList<>();
                while (rs.next()) {
                    reg_users.add(JDBC_utility.resultSetToReg_User(rs));
                }
                return reg_users;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get users list", ex);
        }
    }

    @Override
    public Reg_User getByEmailAndPassword(String email, String password) throws DAOException {

        if (("".equals(email) || email == null) && (!"".equals(password) && password != null)) {
            throw new DAOException("Given email is empty");
        }
        if (("".equals(password) || password == null) && (!"".equals(email) && email != null)) {
            throw new DAOException("Given password is empty");
        }
        if (("".equals(email) || email == null) && ("".equals(password) || password == null)) {
            throw new DAOException("Given email and password are empty");
        }

        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM REG_USERS WHERE EMAIL = ? AND PASSWORD = ?")) {
            stm.setString(1, email);
            stm.setString(2, password);
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? JDBC_utility.resultSetToReg_User(rs) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the user for the passed email and password", ex);
        }
    }

    @Override
    public Reg_User getByEmail(String email) throws DAOException {
        return getByPrimaryKey(email);
    }

    @Override
    public Reg_User getByID(Integer id) throws DAOException {
        if (id == null) {
            throw new DAOException("Given id is empty");
        }

        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM REG_USERS WHERE ID = ?")) {
            stm.setInt(1, id);
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? JDBC_utility.resultSetToReg_User(rs) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the user for the passed id", ex);
        }
    }

    @Override
    public List<Product> getProductsCreated(Reg_User reg_user) throws DAOException {
        if (reg_user == null) {
            throw new DAOException("Given reg_user is null");
        }

        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM PRODUCTS WHERE CREATOR = ?")) {
            stm.setString(1, reg_user.getEmail());

            try (ResultSet rs = stm.executeQuery()) {
                List<Product> products = new ArrayList<>();
                while (rs.next()) {
                    products.add(JDBC_utility.resultSetToProduct(rs));
                }
                return products;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get products for the passed reg_user", ex);
        }
    }

    @Override
    public List<Shopping_list> getOwningShopLists(Reg_User reg_user) throws DAOException {
        if (reg_user == null) {
            throw new DAOException("Given reg_user is null");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM LISTS WHERE OWNER = ?")) {
            stm.setString(1, reg_user.getEmail());

            try (ResultSet rs = stm.executeQuery()) {
                List<Shopping_list> shopping_lists = new ArrayList<>();
                while (rs.next()) {
                    shopping_lists.add(JDBC_utility.resultSetToShopping_list(rs));
                }
                return shopping_lists;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get owning shopping list for the passed reg_user", ex);
        }
    }

    @Override
    public List<Shopping_list> getShopLists(Reg_User reg_user) throws DAOException {
        if (reg_user == null) {
            throw new DAOException("Given reg_user is null");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM LISTS WHERE ID IN (SELECT LIST FROM LISTS_SHARING WHERE REG_USER = ?)")) {
            stm.setString(1, reg_user.getEmail());
            try (ResultSet rs = stm.executeQuery()) {
                List<Shopping_list> shopping_lists = new ArrayList<>();
                while (rs.next()) {
                    shopping_lists.add(JDBC_utility.resultSetToShopping_list(rs));
                }
                return shopping_lists;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get shopping lists for the passed reg_user", ex);
        }
    }
}
