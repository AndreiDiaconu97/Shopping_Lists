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
        checkParam(product, false);

        String query = "INSERT INTO " + P_TABLE + " (name, description, category, creator, is_public, logo, photo, num_votes, rating) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stm.setString(1, product.getName());
            stm.setString(2, product.getDescription());
            stm.setInt(3, product.getCategory().getId());
            stm.setInt(4, product.getCreator().getId());
            stm.setBoolean(5, product.getIs_public());
            stm.setString(6, product.getLogo());
            stm.setString(7, product.getPhoto());
            stm.setInt(8, product.getNum_votes());
            stm.setFloat(9, product.getRating());
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

        String query = "UPDATE " + P_TABLE + " SET NAME = ?, DESCRIPTION = ?, CATEGORY = ?, CREATOR = ?, IS_PUBLIC = ?, LOGO = ?, PHOTO = ?, NUM_VOTES = ?, RATING = ? WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, product.getName());
            stm.setString(2, product.getDescription());
            stm.setInt(3, product.getCategory().getId());
            stm.setInt(4, product.getCreator().getId());
            stm.setBoolean(5, product.getIs_public());
            stm.setString(6, product.getLogo());
            stm.setString(7, product.getPhoto());
            stm.setInt(8, product.getNum_votes());
            stm.setFloat(9, product.getRating());
            stm.setInt(10, product.getId());

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
        try{
            return getProduct(id, CON);
        } catch(SQLException ex){
            throw new DAOException("Cannot get product by id " + id, ex);
        }
    }
}
