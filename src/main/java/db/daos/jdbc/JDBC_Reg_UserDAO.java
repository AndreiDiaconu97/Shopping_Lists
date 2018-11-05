/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.Reg_UserDAO;
import db.entities.Product;
import db.entities.Reg_User;
import db.entities.Shop_list;
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
public class JDBC_Reg_UserDAO extends JDBC_DAO<Reg_User, String> implements Reg_UserDAO {

    public JDBC_Reg_UserDAO(Connection con) {
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
        String msg = "";
        if (email == null || "".equals(email)){
            msg += "Given email is empty. ";
        }
        if (password == null || "".equals(password)) {
            msg += "Given password is empty.";
        }
        if (msg.length() > 1){
            throw new DAOException(msg);
        }
        String query = "SELECT * FROM REG_USERS WHERE EMAIL = ? AND PASSWORD = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
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
        String query = "SELECT * FROM REG_USERS WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
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
        String query = "SELECT * FROM PRODUCTS WHERE CREATOR = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
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
    public List<Shop_list> getOwningShopLists(Reg_User reg_user) throws DAOException {
        if (reg_user == null) {
            throw new DAOException("Given reg_user is null");
        }
        String query = "SELECT * FROM LISTS WHERE OWNER = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, reg_user.getEmail());

            try (ResultSet rs = stm.executeQuery()) {
                List<Shop_list> shopping_lists = new ArrayList<>();
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
    public List<Shop_list> getShopLists(Reg_User reg_user) throws DAOException {
        if (reg_user == null) {
            throw new DAOException("Given reg_user is null");
        }
        String query = "SELECT * FROM LISTS WHERE ID IN (SELECT LIST FROM LISTS_SHARING WHERE REG_USER = ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, reg_user.getEmail());
            try (ResultSet rs = stm.executeQuery()) {
                List<Shop_list> shopping_lists = new ArrayList<>();
                while (rs.next()) {
                    shopping_lists.add(JDBC_utility.resultSetToShopping_list(rs));
                }
                return shopping_lists;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get shopping lists for the passed reg_user", ex);
        }
    }
    
    @Override
    public void insert(Reg_User reg_user) throws DAOException{
        if (reg_user == null) {
            throw new DAOException("Given reg_user is null");
        }
        String query = "INSERT INTO REG_USERS(email, password, firstname, lastname, is_admin, avatar) VALUES(?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, reg_user.getEmail());
            stm.setString(2, reg_user.getPassword());
            stm.setString(3, reg_user.getFirstname());
            stm.setString(4, reg_user.getLastname());
            stm.setBoolean(5, reg_user.getIs_admin());
            stm.setString(6, reg_user.getAvatar());
            stm.executeQuery();
            reg_user.setId(getByEmail(reg_user.getEmail()).getId());
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
        try(PreparedStatement stm = CON.prepareStatement(query)){
            stm.setInt(1, reg_user.getId());
            stm.executeQuery();
        }
        catch(SQLException ex){
            throw new DAOException("Impossible to remove reg_user");
        }
    }
}
