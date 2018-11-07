/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.Reg_UserDAO;
import static db.daos.jdbc.JDBC_utility.getCountFor;
import static db.daos.jdbc.JDBC_utility.resultSetToProduct;
import static db.daos.jdbc.JDBC_utility.resultSetToReg_User;
import db.entities.Product;
import db.entities.Reg_User;
import db.exceptions.DAOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import static db.daos.jdbc.JDBC_utility.resultSetToList_reg;
import db.entities.List_reg;
import java.sql.Statement;

/**
 *
 * @author Andrei Diaconu
 */
public class JDBC_Reg_UserDAO extends JDBC_DAO<Reg_User, Integer> implements Reg_UserDAO {

    public JDBC_Reg_UserDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        return getCountFor("REG_USERS", CON);
    }

    @Override
    public List<Reg_User> getAll() throws DAOException {
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM REG_USERS")) {
            try (ResultSet rs = stm.executeQuery()) {
                List<Reg_User> reg_users = new ArrayList<>();
                while (rs.next()) {
                    reg_users.add(resultSetToReg_User(rs));
                }
                return reg_users;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get users list", ex);
        }
    }

    @Override
    public Reg_User getByEmailAndPassword(String email, String password) throws DAOException {
        String msg = "";
        if (email == null || "".equals(email)) {
            msg += "Given email is empty. ";
        }
        if (password == null || "".equals(password)) {
            msg += "Given password is empty.";
        }
        if (msg.length() > 1) {
            throw new DAOException(msg);
        }
        String query = "SELECT * FROM REG_USERS WHERE EMAIL = '" + email + "'";
        String salt;
        String hashed_psw;
        try (Statement stm = CON.createStatement()) {
            try (ResultSet rs = stm.executeQuery(query)) {
                if (rs.next()) {
                    salt = rs.getString("SALT");
                    hashed_psw = rs.getString("PASSWORD");
                } else {
                    return null;
                }
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the user for the passed email and password", ex);
        }

        if (!JDBC_utility.secureHashEquals(password, salt, hashed_psw)) {
            System.err.println("HASH IS DIFFERENT");
            return null;
        }
        query = "SELECT * FROM REG_USERS WHERE EMAIL = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, email);
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? resultSetToReg_User(rs) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the user for the passed email and password", ex);
        }
    }

    @Override
    public Reg_User getByPrimaryKey(Integer id) throws DAOException {
        if (id == null) {
            throw new DAOException("Given id is empty");
        }
        String query = "SELECT * FROM REG_USERS WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, id);
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? resultSetToReg_User(rs) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the user for the passed id", ex);
        }
    }

    @Override
    public Reg_User getByEmail(String email) throws DAOException {
        if ("".equals(email) || email == null) {
            throw new DAOException("Given email is empty");
        }
        String query = "SELECT * FROM REG_USERS WHERE EMAIL = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, email);
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? resultSetToReg_User(rs) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the user for the passed email", ex);
        }
    }

    @Override
    public List<Product> getProductsCreated(Reg_User reg_user) throws DAOException {
        if (reg_user == null) {
            throw new DAOException("Given reg_user is null");
        }
        String query = "SELECT * FROM PRODUCTS WHERE CREATOR = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, reg_user.getId());

            try (ResultSet rs = stm.executeQuery()) {
                List<Product> products = new ArrayList<>();
                while (rs.next()) {
                    products.add(resultSetToProduct(rs));
                }
                return products;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get products for the passed reg_user", ex);
        }
    }

    @Override
    public List<List_reg> getOwningShopLists(Reg_User reg_user) throws DAOException {
        if (reg_user == null) {
            throw new DAOException("Given reg_user is null");
        }
        String query = "SELECT * FROM LISTS WHERE OWNER = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, reg_user.getId());

            try (ResultSet rs = stm.executeQuery()) {
                List<List_reg> shopping_lists = new ArrayList<>();
                while (rs.next()) {
                    shopping_lists.add(resultSetToList_reg(rs));
                }
                return shopping_lists;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get owning shopping list for the passed reg_user", ex);
        }
    }

    @Override
    public List<List_reg> getSharedShopLists(Reg_User reg_user) throws DAOException {
        if (reg_user == null) {
            throw new DAOException("Given reg_user is null");
        }
        String query = "SELECT * FROM LISTS WHERE ID IN (SELECT LIST FROM LISTS_SHARING WHERE REG_USER = ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, reg_user.getId());
            try (ResultSet rs = stm.executeQuery()) {
                List<List_reg> shopping_lists = new ArrayList<>();
                while (rs.next()) {
                    shopping_lists.add(resultSetToList_reg(rs));
                }
                return shopping_lists;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get shopping lists for the passed reg_user", ex);
        }
    }

    @Override
    public void insert(Reg_User reg_user) throws DAOException {
        if (reg_user == null) {
            throw new DAOException("Given reg_user is null");
        }
        if (reg_user.getId() != null) {
            throw new DAOException("Cannot insert reg_user: it has arleady an id");
        }

        String query = "INSERT INTO REG_USERS(email, password, salt, firstname, lastname, is_admin, avatar) VALUES(?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, reg_user.getEmail());
            stm.setString(2, reg_user.getPassword());
            stm.setString(3, reg_user.getSalt());
            stm.setString(4, reg_user.getFirstname());
            stm.setString(5, reg_user.getLastname());
            stm.setBoolean(6, reg_user.getIs_admin());
            stm.setString(7, reg_user.getAvatar());
            stm.executeUpdate();

            // This should avoid using an extra query for id retrieving
            // OLD: reg_user.setId(getByEmail(reg_user.getEmail()).getId());
            ResultSet rs = stm.getGeneratedKeys();
            if (rs.next()) {
                reg_user.setId(rs.getInt(1));
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to add reg_user to DB", ex);
        }
    }

    @Override
    public void delete(Reg_User reg_user) throws DAOException {
        if (reg_user == null) {
            throw new DAOException("Given reg_user is null");
        }
        String query = "DELETE FROM REG_USERS WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, reg_user.getId());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to remove reg_user", ex);
        }
    }

    @Override
    public void update(Reg_User reg_user) throws DAOException {
        if (reg_user == null) {
            throw new DAOException("Given reg_user is null");
        }

        Integer reg_userId = reg_user.getId();
        if (reg_userId == null) {
            throw new DAOException("Reg_User is not valid", new NullPointerException("Reg_User id is null"));
        }

        String query = "UPDATE REG_USERS SET EMAIL = ?, PASSWORD = ?, FIRSTNAME = ?, LASTNAME = ?, IS_ADMIN = ?, AVATAR = ? WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, reg_user.getEmail());
            stm.setString(2, reg_user.getPassword());
            stm.setString(3, reg_user.getFirstname());
            stm.setString(4, reg_user.getLastname());
            stm.setBoolean(5, reg_user.getIs_admin());
            stm.setString(6, reg_user.getAvatar());
            stm.setInt(7, reg_user.getId());

            int count = stm.executeUpdate();
            if (count != 1) {
                throw new DAOException("reg_user update affected an invalid number of records: " + count);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the reg_user", ex);
        }
    }
}
