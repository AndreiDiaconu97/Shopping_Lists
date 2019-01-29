/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.List_anonymousDAO;
import static db.daos.jdbc.JDBC_utility.*;
import db.entities.List_anonymous;
import db.entities.Product;
import db.exceptions.DAOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

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
        return getCountFor(L_ANONYM_TABLE, CON);
    }

    @Override
    public List<List_anonymous> getAll() throws DAOException {
        return getAllFor(L_ANONYM_TABLE, CON, List_anonymous.class);
    }

    @Override
    public void insert(List_anonymous list_anonymous) throws DAOException {
        checkParam(list_anonymous, false);

        String query = "INSERT INTO " + L_ANONYM_TABLE + " (name, description, category, last_seen) VALUES (?, ?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stm.setString(1, list_anonymous.getName());
            stm.setString(2, list_anonymous.getDescription());
            stm.setInt(3, list_anonymous.getCategory().getId());
            stm.setTimestamp(4, list_anonymous.getLast_seen());
            stm.executeUpdate();

            ResultSet rs = stm.getGeneratedKeys();
            if (rs.next()) {
                list_anonymous.setId(rs.getInt(1));
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to add list_anonymous to DB", ex);
        }
    }

    @Override
    public void delete(List_anonymous list_anonymous) throws DAOException {
        checkParam(list_anonymous, true);

        String query = "DELETE FROM " + L_ANONYM_TABLE + " WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_anonymous.getId());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to remove list_anonymous", ex);
        }
    }

    @Override
    public void update(List_anonymous list_anonymous) throws DAOException {
        checkParam(list_anonymous, true);

        String query = "UPDATE " + L_ANONYM_TABLE + " SET NAME = ?, DESCRIPTION = ?, CATEGORY = ?, LAST_SEEN = ? WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, list_anonymous.getName());
            stm.setString(2, list_anonymous.getDescription());
            stm.setInt(3, list_anonymous.getCategory().getId());
            stm.setTimestamp(4, list_anonymous.getLast_seen());
            stm.setInt(5, list_anonymous.getId());

            int count = stm.executeUpdate();
            if (count != 1) {
                throw new DAOException("list_anonymous update affected an invalid number of records: " + count);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the list_anonymous", ex);
        }
    }

    @Override
    public List_anonymous getByPrimaryKey(Integer id) throws DAOException {
        try {
            return getList_anonymous(id, CON);
        } catch (SQLException ex) {
            throw new DAOException("Cannot get list_anonymous by id " + id, ex);
        }
    }

    @Override
    public void insertProduct(List_anonymous list_anonymous, Product product, Integer amount) throws DAOException {
        checkParam(list_anonymous, true);
        checkParam(product, true);

        String query_cat = "SELECT * FROM " + L_P_CAT_TABLE + " WHERE LIST_CAT=? AND PRODUCT_CAT=?";
        try (PreparedStatement stm = CON.prepareStatement(query_cat)) {
            stm.setInt(1, list_anonymous.getCategory().getId());
            stm.setInt(2, product.getCategory().getId());

            if (!stm.executeQuery().next()) {
                throw new SQLException("L_cat does not have this p_cat");
            }
        } catch (Exception ex) {
            throw new DAOException("List_anonymous category does not allow this product's category");
        }

        String query = "INSERT INTO " + L_ANONYM_P_TABLE + " (LIST_ANONYMOUS, PRODUCT, AMOUNT) VALUES (?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stm.setInt(1, list_anonymous.getId());
            stm.setInt(2, product.getId());
            stm.setInt(3, amount);
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to add new product", ex);
        }
    }

    @Override
    public List<Product> getProducts(List_anonymous list_anonymous) throws DAOException {
        checkParam(list_anonymous, true);

        String query = "SELECT * FROM " + P_TABLE + " WHERE ID IN (SELECT PRODUCT FROM " + L_ANONYM_P_TABLE + " WHERE LIST_ANONYMOUS = ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_anonymous.getId());
            try (ResultSet rs = stm.executeQuery()) {
                List<Product> products = new ArrayList<>();

                while (rs.next()) {
                    products.add(resultSetToProduct(rs, CON));
                }
                return products;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the products for the passed list_anonymous", ex);
        }
    }

    @Override
    public Integer getAmountTotal(List_anonymous list_anonymous, Product product) throws DAOException {
        checkParam(list_anonymous, true);
        checkParam(product, true);

        String query = "SELECT AMOUNT FROM " + L_ANONYM_P_TABLE + " WHERE LIST_ANONYMOUS=? AND PRODUCT=?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_anonymous.getId());
            stm.setInt(2, product.getId());

            try (ResultSet rs = stm.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                } else {
                    throw new DAOException("Total amount not found, list " + list_anonymous.getId() + ", product " + product.getId());
                }
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get total amount", ex);
        }
    }

    @Override
    public Integer getAmountPurchased(List_anonymous list_anonymous, Product product) throws DAOException {
        checkParam(list_anonymous, true);
        checkParam(product, true);

        String query = "SELECT PURCHASED FROM " + L_ANONYM_P_TABLE + " WHERE LIST_ANONYMOUS=? AND PRODUCT=?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_anonymous.getId());
            stm.setInt(2, product.getId());

            try (ResultSet rs = stm.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                } else {
                    throw new DAOException("Purchased amount not found, list " + list_anonymous.getId() + ", product " + product.getId());
                }
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get purchased amount", ex);
        }
    }

    @Override
    public Timestamp getLastPurchase(List_anonymous list, Product product) throws DAOException {
        checkParam(list, true);
        checkParam(product, true);

        String query = "SELECT LAST_PURCHASE FROM " + L_ANONYM_P_TABLE + " WHERE LIST=? AND PRODUCT=?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list.getId());
            stm.setInt(2, product.getId());

            try (ResultSet rs = stm.executeQuery()) {
                if (rs.next()) {
                    return rs.getTimestamp(1);
                } else {
                    throw new DAOException("Last_purchase date not found, list_anonym " + list.getId() + ", product " + product.getId());
                }
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get last_purchase date", ex);
        }
    }

    @Override
    public void updateAmountTotal(List_anonymous list_anonymous, Product product, Integer total) throws DAOException {
        checkParam(list_anonymous, true);
        checkParam(product, true);

        String query = "UPDATE " + L_ANONYM_P_TABLE + " SET TOTAL=? WHERE LIST_ANONYMOUS=? AND PRODUCT=?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, total);
            stm.setInt(2, list_anonymous.getId());
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
    public void updateAmountPurchased(List_anonymous list_anonymous, Product product, Integer purchased) throws DAOException {
        checkParam(list_anonymous, true);
        checkParam(product, true);

        String query = "UPDATE " + L_ANONYM_P_TABLE + " SET PURCHASED=? WHERE LIST_ANONYMOUS=? AND PRODUCT=?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, purchased);
            stm.setInt(2, list_anonymous.getId());
            stm.setInt(3, product.getId());
            int count = stm.executeUpdate();
            if (count != 1) {
                throw new DAOException("Purchased amount updated affected an invalid number of records: " + count);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to update purchased amount", ex);
        }
    }
}
