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
import static db.daos.jdbc.JDBC_utility.resultSetToList_reg;

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
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM LISTS")) {
            try (ResultSet rs = stm.executeQuery()) {
                List<List_reg> lists_reg = new ArrayList<>();
                while (rs.next()) {
                    lists_reg.add(resultSetToList_reg(rs));
                }
                return lists_reg;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get all the list_reg", ex);
        }
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
            throw new DAOException("Impossible to get the list_reg for the passed id", ex);
        }
    }

    @Override
    public List<List_reg> getByOwner(Integer owner) throws DAOException {
        if (owner == null) {
            throw new DAOException("owner parameter is null");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM LISTS WHERE OWNER = ?")) {
            stm.setInt(1, owner);
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
    public void shareShoppingListToReg_User(List_reg list_reg, Reg_User reg_user) throws DAOException {
        String msg = "";
        if ((list_reg == null) || (list_reg.getId() == null)) {
            msg += "Given list_reg is empty or non valid. ";
        }
        if (reg_user == null || (reg_user.getId() == null)) {
            msg += "Given user is empty or non valid. ";
        }
        if (msg.length()
                > 1) {
            throw new DAOException(msg);
        }

        if (list_reg.getOwner() == reg_user.getId()) {
            throw new DAOException("Reg_user is arleady owner of the given list_reg.");
        }

        String query = "INSERT INTO LISTS_SHARING(list, reg_user) VALUES(?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_reg.getId());
            stm.setInt(2, reg_user.getId());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the shopping_list for the passed id", ex);
        }
    }

    @Override
    public List<Product> getProducts(List_reg list_reg) throws DAOException {
        if (list_reg == null) {
            throw new DAOException("list_reg parameter is null");
        }
        String query = "SELECT * FROM PRODUCTS WHERE ID IN (SELECT PRODUCT FROM LISTS_PRODUCTS WHERE LIST = ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_reg.getId());
            try (ResultSet rs = stm.executeQuery()) {
                List<Product> products = new ArrayList<>();

                while (rs.next()) {
                    products.add(JDBC_utility.resultSetToProduct(rs));
                }
                return products;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the products for the passed list_reg", ex);
        }
    }

    @Override
    public void delete(List_reg list_reg) throws DAOException {
        if (list_reg == null) {
            throw new DAOException("Given list_reg is null");
        }
        String query = "DELETE FROM LISTS WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_reg.getId());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to remove list_reg", ex);
        }
    }

    @Override
    public void insert(List_reg list_reg) throws DAOException {
        if (list_reg == null) {
            throw new DAOException("Given list_reg is null");
        }
        if (list_reg.getId() != null) {
            throw new DAOException("Cannot insert list_reg: it has arleady an id");
        }

        String query = "INSERT INTO LISTS(name, description, category, owner, logo) VALUES(?, ?, ?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, list_reg.getName());
            stm.setString(2, list_reg.getDescription());
            stm.setString(3, list_reg.getCategory());
            stm.setInt(4, list_reg.getOwner());
            stm.setString(5, list_reg.getLogo());
            stm.executeUpdate();

            ResultSet rs = stm.getGeneratedKeys();
            if (rs.next()) {
                list_reg.setId(rs.getInt(1));
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to add list_reg to DB", ex);
        }
    }

    @Override
    public void update(List_reg list_reg) throws DAOException {
        if (list_reg == null) {
            throw new DAOException("Given list_reg is null");
        }

        Integer list_regId = list_reg.getId();
        if (list_regId == null) {
            throw new DAOException("List_reg is not valid", new NullPointerException("List_reg id is null"));
        }

        String query = "UPDATE LISTS SET NAME = ?, DESCRIPTION = ?, CATEGORY = ?, OWNER = ?, LOGO = ? WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, list_reg.getName());
            stm.setString(2, list_reg.getDescription());
            stm.setString(3, list_reg.getCategory());
            stm.setInt(4, list_reg.getOwner());
            stm.setString(5, list_reg.getLogo());
            stm.setInt(6, list_reg.getId());

            int count = stm.executeUpdate();
            if (count != 1) {
                throw new DAOException("list_reg update affected an invalid number of records: " + count);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the list_reg", ex);
        }
    }

    @Override
    public List<Reg_User> getReg_UsersSharedTo(List_reg list_reg) throws DAOException {
        if (list_reg == null) {
            throw new DAOException("list_reg parameter is null");
        }
        String query = "SELECT * FROM REG_USERS WHERE ID IN (SELECT REG_USER FROM LISTS_SHARING WHERE LIST = ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_reg.getId());
            try (ResultSet rs = stm.executeQuery()) {
                List<Reg_User> reg_users = new ArrayList<>();

                while (rs.next()) {
                    reg_users.add(JDBC_utility.resultSetToReg_User(rs));
                }
                return reg_users;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the reg_users for the passed list_reg", ex);
        }
    }
}
