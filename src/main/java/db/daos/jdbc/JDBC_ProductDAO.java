/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.ProductDAO;
import static db.daos.jdbc.JDBC_utility.*;
import db.entities.Prod_category;
import db.entities.Product;
import db.entities.User;
import db.exceptions.DAOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public class JDBC_ProductDAO extends JDBC_DAO<Product, Integer> implements ProductDAO {

    public JDBC_ProductDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        return getCountFor(P_TABLE, CON);
    }

    @Override
    public List<Product> getAll() throws DAOException {
        return getAllFor(P_TABLE, CON, Product.class);
    }

    @Override
    public List<Product> filterProducts(String name, Prod_category prod_category, User user, boolean includePublics, SortBy sortby) throws DAOException {
        if (sortby == null) {
            throw new DAOException("Passed sortby is null");
        }
        if (user == null && includePublics == false) {
            throw new DAOException("No user and no public products");
        }
        if (user != null) {
            checkParam(user, true);
        }
        if (name == null) {
            name = "";
        }
        name = name.toUpperCase();
        String query = "";
        if (sortby == SortBy.POPULARITY) {
            query = "SELECT ID, NAME, DESCRIPTION, CATEGORY, CREATOR, NUM_VOTES, RATING FROM " + P_TABLE;
            query += " LEFT OUTER JOIN " + L_P_TABLE + " ON " + P_TABLE + ".ID=" + L_P_TABLE + ".PRODUCT\n";
        } else {
            query = "SELECT * FROM " + P_TABLE + "\n";
        }
        query += "WHERE UPPER_NAME LIKE '%' || ? || '%'\n";
        query += "AND (CREATOR = ? ";
        if (includePublics) {
            query += " OR CREATOR IN (SELECT ID FROM " + U_TABLE + " WHERE IS_ADMIN=TRUE) ";
        }
        query += ")\n";
        if (prod_category != null) {
            checkParam(prod_category, true);
            query += "AND CATEGORY = ?\n";
        }
        switch (sortby) {
            case POPULARITY:
                query += "GROUP BY ID, NAME, UPPER_NAME, DESCRIPTION, CATEGORY, CREATOR, NUM_VOTES, RATING\n";
                query += "ORDER BY COALESCE(SUM(TOTAL), 0) DESC";
                break;
            case NAME:
                query += "ORDER BY UPPER_NAME";
                break;
            default:
                query += "ORDER BY RATING DESC";
                break;
        }
        //System.err.println("Filter products query: " + query);
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, name);
            stm.setInt(2, user == null ? -1 : user.getId());
            if (prod_category != null) {
                stm.setInt(3, prod_category.getId());
            }
            try (ResultSet rs = stm.executeQuery()) {
                List<Product> products = new ArrayList<>();
                while (rs.next()) {
                    products.add(resultSetToProduct(rs, CON));
                }
                return products;
            }
        } catch (SQLException ex) {
            throw new DAOException("Cannot get fitered products" + ex, ex);
        }
    }

    @Override
    public void insert(Product product) throws DAOException {
        checkParam(product, false);

        String query = "INSERT INTO " + P_TABLE + " (name, description, category, creator) VALUES (?, ?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stm.setString(1, product.getName());
            stm.setString(2, product.getDescription());
            stm.setInt(3, product.getCategory().getId());
            stm.setInt(4, product.getCreator().getId());
            stm.executeUpdate();

            ResultSet rs = stm.getGeneratedKeys();
            if (rs.next()) {
                product.setId(rs.getInt(1));
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to add product to DB", ex);
        }
    }

    @Override
    public void delete(Product product) throws DAOException {
        checkParam(product, true);

        String query = "DELETE FROM " + P_TABLE + " WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, product.getId());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to remove product", ex);
        }
    }

    @Override
    public void update(Product product) throws DAOException {
        checkParam(product, true);

        String query = "UPDATE " + P_TABLE + " SET NAME = ?, DESCRIPTION = ?, CATEGORY = ?, NUM_VOTES = ?, RATING = ? WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, product.getName());
            stm.setString(2, product.getDescription());
            stm.setInt(3, product.getCategory().getId());
            stm.setInt(4, product.getNum_votes());
            stm.setFloat(5, product.getRating());
            stm.setInt(6, product.getId());

            int count = stm.executeUpdate();
            if (count != 1) {
                throw new DAOException("product update affected an invalid number of records: " + count);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the product", ex);
        }
    }

    @Override
    public Product getByPrimaryKey(Integer id) throws DAOException {
        try {
            return getProduct(id, CON);
        } catch (SQLException ex) {
            throw new DAOException("Cannot get product by id " + id, ex);
        }
    }
}
