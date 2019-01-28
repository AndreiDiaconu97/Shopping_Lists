/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.List_regDAO;
import static db.daos.jdbc.JDBC_utility.*;
import db.entities.List_reg;
import db.entities.Message;
import db.entities.Product;
import db.entities.User;
import db.exceptions.DAOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

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
        return getCountFor(L_TABLE, CON);
    }

    @Override
    public List<List_reg> getAll() throws DAOException {
        return getAllFor(L_TABLE, CON, List_reg.class);
    }

    @Override
    public List_reg getByPrimaryKey(Integer id) throws DAOException {
        try {
            return getList_reg(id, CON);
        } catch (SQLException ex) {
            throw new DAOException("Cannot get list_reg by id " + id, ex);
        }
    }

    @Override
    public List<List_reg> getByOwner(User owner) throws DAOException {
        checkParam(owner, true);

        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM " + L_TABLE + " WHERE OWNER = ?")) {
            stm.setInt(1, owner.getId());
            try (ResultSet rs = stm.executeQuery()) {
                List<List_reg> lists = new ArrayList<>();

                while (rs.next()) {
                    lists.add(resultSetToList_reg(rs, CON));
                }
                return lists;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get lists for the passed owner", ex);
        }
    }

    @Override
    public void shareListToUser(List_reg list_reg, User user, AccessLevel accessLevel) throws DAOException {
        checkParam(list_reg, true);
        checkParam(user, true);
        if (accessLevel == null) {
            throw new DAOException("Cannot share: AccessLevel null");
        }

        if (user.equals(list_reg.getOwner())) {
            throw new DAOException("User is arleady owner of the given list_reg.");
        }

        String query = "INSERT INTO " + L_SHARING_TABLE + " (LIST, USER, ACCESS) VALUES (?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_reg.getId());
            stm.setInt(2, user.getId());
            stm.setInt(3, (accessLevel == AccessLevel.FULL) ? 2 : (accessLevel == AccessLevel.PRODUCTS ? 1 : 0));
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to share list to user", ex);
        }
    }

    @Override
    public void insertProduct(List_reg list_reg, Product product, Integer amount) throws DAOException {
        checkParam(list_reg, true);
        checkParam(product, true);

        String query_cat = "SELECT * FROM " + L_P_CAT_TABLE + " WHERE LIST_CAT=? AND PRODUCT_CAT=?";
        try (PreparedStatement stm = CON.prepareStatement(query_cat)) {
            stm.setInt(1, list_reg.getCategory().getId());
            stm.setInt(2, product.getCategory().getId());

            if (!stm.executeQuery().next()) {
                throw new SQLException("L_cat does not have this p_cat");
            }
        } catch (Exception ex) {
            throw new DAOException("List category does not allow this product's category");
        }

        String query = "INSERT INTO " + L_P_TABLE + " (LIST, PRODUCT, AMOUNT) VALUES (?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stm.setInt(1, list_reg.getId());
            stm.setInt(2, product.getId());
            stm.setInt(3, amount);
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to add new product", ex);
        }
    }

    @Override
    public void removeProduct(List_reg list_reg, Product product) throws DAOException {
        checkParam(list_reg, true);
        checkParam(product, true);

        String query = "DELETE FROM " + L_P_TABLE + " WHERE LIST = ? AND PRODUCT = ?";
        try (PreparedStatement stm = CON.prepareStatement(query, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stm.setInt(1, list_reg.getId());
            stm.setInt(2, product.getId());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to remove product from list", ex);
        }
    }

    @Override
    public List<Product> getProducts(List_reg list_reg) throws DAOException {
        checkParam(list_reg, true);

        String query = "SELECT * FROM " + P_TABLE + " WHERE ID IN (SELECT PRODUCT FROM " + L_P_TABLE + " WHERE LIST = ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_reg.getId());
            try (ResultSet rs = stm.executeQuery()) {
                List<Product> products = new ArrayList<>();
                while (rs.next()) {
                    products.add(resultSetToProduct(rs, CON));
                }
                return products;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the products for the passed list_reg" + ex, ex);
        }
    }

    @Override
    public void delete(List_reg list_reg) throws DAOException {
        checkParam(list_reg, true);

        String query = "DELETE FROM " + L_TABLE + " WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_reg.getId());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to remove list_reg", ex);
        }
    }

    @Override
    public void insert(List_reg list_reg) throws DAOException {
        checkParam(list_reg, false);

        String query = "INSERT INTO " + L_TABLE + "(name, description, category, owner) VALUES(?, ?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stm.setString(1, list_reg.getName());
            stm.setString(2, list_reg.getDescription());
            stm.setInt(3, list_reg.getCategory().getId());
            stm.setInt(4, list_reg.getOwner().getId());
            stm.executeUpdate();

            try (ResultSet rs = stm.getGeneratedKeys()) {
                if (rs.next()) {
                    list_reg.setId(rs.getInt(1));
                }
            }
        } catch (SQLException ex) {
            System.err.println(ex.getMessage());
            throw new DAOException("Impossible to add list_reg to DB", ex);
        }
    }

    @Override
    public void update(List_reg list_reg) throws DAOException {
        checkParam(list_reg, true);

        String query = "UPDATE " + L_TABLE + " SET NAME = ?, DESCRIPTION = ?, CATEGORY = ? WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, list_reg.getName());
            stm.setString(2, list_reg.getDescription());
            stm.setInt(3, list_reg.getCategory().getId());
            stm.setInt(4, list_reg.getId());

            int count = stm.executeUpdate();
            if (count != 1) {
                throw new DAOException("list_reg update affected an invalid number of records: " + count);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the list_reg: " + ex, ex);
        }
    }

    @Override
    public List<User> getUsersSharedTo(List_reg list_reg) throws DAOException {
        checkParam(list_reg, true);

        String query = "SELECT * FROM " + U_TABLE + " WHERE ID IN (SELECT USER_ID FROM " + L_SHARING_TABLE + " WHERE LIST = ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_reg.getId());
            try (ResultSet rs = stm.executeQuery()) {
                List<User> users = new ArrayList<>();

                while (rs.next()) {
                    users.add(resultSetToUser(rs, CON));
                }
                return users;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the users for the passed list_reg", ex);
        }
    }

    @Override
    public Integer getAmountTotal(List_reg list_reg, Product product) throws DAOException {
        checkParam(list_reg, true);
        checkParam(product, true);

        String query = "SELECT AMOUNT FROM " + L_P_TABLE + " WHERE LIST=? AND PRODUCT=?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_reg.getId());
            stm.setInt(2, product.getId());

            try (ResultSet rs = stm.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                } else {
                    throw new DAOException("Total amount not found, list " + list_reg.getId() + ", product " + product.getId());
                }
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get total amount", ex);
        }
    }

    @Override
    public Integer getAmountPurchased(List_reg list_reg, Product product) throws DAOException {
        checkParam(list_reg, true);
        checkParam(product, true);

        String query = "SELECT PURCHASED FROM " + L_P_TABLE + " WHERE LIST=? AND PRODUCT=?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_reg.getId());
            stm.setInt(2, product.getId());

            try (ResultSet rs = stm.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                } else {
                    throw new DAOException("Purchased amount not found, list " + list_reg.getId() + ", product " + product.getId());
                }
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get purchased amount", ex);
        }
    }

    @Override
    public Timestamp getLastPurchase(List_reg list_reg, Product product) throws DAOException {
        checkParam(list_reg, true);
        checkParam(product, true);

        String query = "SELECT LAST_PURCHASE FROM " + L_P_TABLE + " WHERE LIST=? AND PRODUCT=?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_reg.getId());
            stm.setInt(2, product.getId());

            try (ResultSet rs = stm.executeQuery()) {
                if (rs.next()) {
                    return rs.getTimestamp(1);
                } else {
                    throw new DAOException("Last_purchase date not found, list " + list_reg.getId() + ", product " + product.getId());
                }
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get last_purchase date", ex);
        }
    }

    @Override
    public void updateAmountTotal(List_reg list_reg, Product product, Integer total) throws DAOException {
        checkParam(list_reg, true);
        checkParam(product, true);

        String query = "UPDATE " + L_P_TABLE + " SET TOTAL=? WHERE LIST=? AND PRODUCT=?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, total);
            stm.setInt(2, list_reg.getId());
            stm.setInt(3, product.getId());
            int count = stm.executeUpdate();
            if (count != 1) {
                throw new DAOException("Total amount updated affected an invalid number of records: " + count);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to update total amount", ex);
        }
    }

    @Override
    public void updateAmountPurchased(List_reg list_reg, Product product, Integer purchased) throws DAOException {
        checkParam(list_reg, true);
        checkParam(product, true);

        String query = "UPDATE " + L_P_TABLE + " SET PURCHASED=?, SET LAST_PURCHASE=? WHERE LIST=? AND PRODUCT=?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, purchased);
            stm.setInt(2, list_reg.getId());
            stm.setTimestamp(3, new Timestamp((new Date()).getTime()));
            stm.setInt(4, product.getId());
            int count = stm.executeUpdate();
            if (count != 1) {
                throw new DAOException("Purchased amount updated affected an invalid number of records: " + count);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to update purchased amount", ex);
        }
    }

    @Override
    public void insertMessage(Message message) throws DAOException {
        checkParam(message);

        String query = "INSERT INTO " + CHATS_TABLE + " (LIST, USER_ID, MESSAGE, IS_LOG) VALUES (?,?,?,?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, message.getList().getId());
            stm.setInt(2, message.getUser().getId());
            stm.setString(3, message.getText());
            stm.setBoolean(4, message.getIsLog());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to add message to list chat: " + ex);
        }
    }

    @Override
    public List<Message> getMessages(List_reg list_reg) throws DAOException {
        checkParam(list_reg, true);

        String query = "SELECT * FROM " + CHATS_TABLE + " WHERE LIST = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_reg.getId());
            try (ResultSet rs = stm.executeQuery()) {
                List<Message> messages = new ArrayList<>();
                while (rs.next()) {
                    Message m = new Message();
                    m.setList(list_reg);
                    m.setUser(getUser(rs.getInt("USER_ID"), CON));
                    m.setTime(rs.getTimestamp("TIME"));
                    m.setText(rs.getString("MESSAGE"));
                    m.setIsLog(rs.getBoolean("IS_LOG"));
                    messages.add(m);
                }
                return messages;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get messages for given list", ex);
        }
    }

    @Override
    public void inviteUser(List_reg list_reg, User user, AccessLevel accessLevel) throws DAOException {
        checkParam(list_reg, true);
        checkParam(user, true);
        if (accessLevel == null) {
            throw new DAOException("Cannot invite: AccessLevel null");
        }

        if (user.equals(list_reg.getOwner())) {
            throw new DAOException("Owner cannot self invite");
        }
        if (user.getIs_admin()) {
            throw new DAOException("Cannot invite admins");
        }

        String query = "INSERT INTO " + INVITES_TABLE + " (LIST, INVITED, ACCESS) VALUES (?,?,?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_reg.getId());
            stm.setInt(2, user.getId());
            stm.setInt(3, (accessLevel == AccessLevel.FULL) ? 2 : (accessLevel == AccessLevel.PRODUCTS ? 1 : 0));
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to invite user to list", ex);
        }
    }

    @Override
    public void cancelInvite(List_reg list_reg, User user) throws DAOException {
        checkParam(list_reg, true);
        checkParam(user, true);

        String query = "DELETE FROM " + INVITES_TABLE + " WHERE LIST = ? AND INVITED = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_reg.getId());
            stm.setInt(2, user.getId());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to cancel invite: " + ex);
        }
    }

    @Override
    public void acceptInvite(List_reg list_reg, User user) throws DAOException {
        checkParam(list_reg, true);
        checkParam(user, true);

        String query = "SELECT ACCESS FROM " + INVITES_TABLE + " WHERE LIST = ? AND INVITED = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_reg.getId());
            stm.setInt(2, user.getId());
            try(ResultSet rs = stm.executeQuery()){
                if(rs.next()){
                    int accessLevel = rs.getInt(1);
                    cancelInvite(list_reg, user);
                    shareListToUser(list_reg, user, intToAccessLevel(accessLevel));
                } else {
                    throw new DAOException("Cannot find invite");
                }
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to cancel invite: " + ex);
        }
    }
}
