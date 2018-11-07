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
    public void insert(List_anonymous list_anonymous) throws DAOException {
        if (list_anonymous == null) {
            throw new DAOException("Given list_anonymous is null");
        }
        if (list_anonymous.getId() != null) {
            throw new DAOException("Cannot insert list_anonymous: it has arleady an id");
        }

        String query = "INSERT INTO LISTS_ANONYMOUS(name, description, category, logo, last_seen) VALUES(?, ?, ?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, list_anonymous.getName());
            stm.setString(2, list_anonymous.getDescription());
            stm.setString(3, list_anonymous.getCategory());
            stm.setString(4, list_anonymous.getLogo());
            stm.setTimestamp(5, list_anonymous.getLast_seen());
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
        if (list_anonymous == null) {
            throw new DAOException("Given list_anonymous is null");
        }
        String query = "DELETE FROM LISTS_ANONYMOUS WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_anonymous.getId());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to remove list_anonymous", ex);
        }
    }

    @Override
    public void update(List_anonymous list_anonymous) throws DAOException {
        if (list_anonymous == null) {
            throw new DAOException("Given list_anonymous is null");
        }

        Integer list_anonymousId = list_anonymous.getId();
        if (list_anonymousId == null) {
            throw new DAOException("List_anonymous is not valid", new NullPointerException("List_anonymous id is null"));
        }

        String query = "UPDATE LISTS SET NAME = ?, DESCRIPTION = ?, CATEGORY = ?, LOGO = ?, LAST_SEEN = ? WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, list_anonymous.getName());
            stm.setString(2, list_anonymous.getDescription());
            stm.setString(3, list_anonymous.getCategory());
            stm.setString(4, list_anonymous.getLogo());
            stm.setTimestamp(5, list_anonymous.getLast_seen());
            stm.setInt(6, list_anonymous.getId());

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
        if (id == null) {
            throw new DAOException("id parameter is null");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM LISTS_ANONYMOUS WHERE ID = ?")) {
            stm.setInt(1, id);
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? JDBC_utility.resultSetToList_anonymous(rs) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the list_anonymous for the passed id", ex);
        }
    }

    @Override
    public List<Product> getProducts(List_anonymous list_anonymous) throws DAOException {
        if (list_anonymous == null) {
            throw new DAOException("list_anonymous parameter is null");
        }
        String query = "SELECT * FROM PRODUCTS WHERE ID IN (SELECT PRODUCT FROM LISTS_ANONYMOUS_PRODUCTS WHERE LIST_ANONYMOUS = ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_anonymous.getId());
            try (ResultSet rs = stm.executeQuery()) {
                List<Product> products = new ArrayList<>();

                while (rs.next()) {
                    products.add(JDBC_utility.resultSetToProduct(rs));
                }
                return products;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the products for the passed list_anonymous", ex);
        }
    }

}
