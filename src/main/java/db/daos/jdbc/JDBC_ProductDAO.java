/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.ProductDAO;
import static db.daos.jdbc.JDBC_utility.*;
import db.entities.Product;
import db.exceptions.DAOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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
    public void insert(Product product) throws DAOException {
        if (product == null) {
            throw new DAOException("Given product is null");
        }
        if (product.getId() != null) {
            throw new DAOException("Cannot insert product: it has arleady an id");
        }

        String query = "INSERT INTO ?(name, description, category, creator, is_public, logo, photo, num_votes, rating) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, P_TABLE);
            stm.setString(2, product.getName());
            stm.setString(3, product.getDescription());
            stm.setString(4, product.getCategory());
            stm.setInt(5, product.getCreator());
            stm.setBoolean(6, product.getIs_public());
            stm.setString(7, product.getLogo());
            stm.setString(8, product.getPhoto());
            stm.setInt(9, product.getNum_votes());
            stm.setFloat(10, product.getRating());
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
        if (product == null) {
            throw new DAOException("Given product is null");
        }
        String query = "DELETE FROM ? WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, P_TABLE);
            stm.setInt(2, product.getId());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to remove product", ex);
        }
    }

    @Override
    public void update(Product product) throws DAOException {
        if (product == null) {
            throw new DAOException("Given reg_user is null");
        }

        Integer productId = product.getId();
        if (productId == null) {
            throw new DAOException("Product is not valid", new NullPointerException("Product id is null"));
        }

        String query = "UPDATE ? SET NAME = ?, DESCRIPTION = ?, CATEGORY = ?, CREATOR = ?, IS_PUBLIC = ?, LOGO = ?, PHOTO = ?, NUM_VOTES = ?, RATING = ? WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, P_TABLE);
            stm.setString(2, product.getName());
            stm.setString(3, product.getDescription());
            stm.setString(4, product.getCategory());
            stm.setInt(5, product.getCreator());
            stm.setBoolean(6, product.getIs_public());
            stm.setString(7, product.getLogo());
            stm.setString(8, product.getPhoto());
            stm.setInt(9, product.getNum_votes());
            stm.setFloat(10, product.getRating());
            stm.setInt(11, product.getId());

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
        if (id == null) {
            throw new DAOException("Given id is empty");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM ? WHERE ID = ?")) {
            stm.setString(1, P_TABLE);
            stm.setInt(2, id);
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? resultSetToProduct(rs) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the product for the passed id", ex);
        }
    }
}
