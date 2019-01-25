/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.Prod_categoryDAO;
import static db.daos.jdbc.JDBC_utility.*;
import db.entities.Prod_category;
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
public class JDBC_Prod_categoryDAO extends JDBC_DAO<Prod_category, Integer> implements Prod_categoryDAO {

    public JDBC_Prod_categoryDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        return getCountFor(P_CAT_TABLE, CON);
    }

    @Override
    public List<Prod_category> getAll() throws DAOException {
        return getAllFor(P_CAT_TABLE, CON, Prod_category.class);
    }

    @Override
    public Prod_category getByPrimaryKey(Integer id) throws DAOException {
        try{
            return getProd_category(id, CON);
        } catch(SQLException ex){
            throw new DAOException("Cannot get prod_category by id " + id, ex);
        }
    }

    @Override
    public void insert(Prod_category prod_category) throws DAOException {
        checkParam(prod_category, false);
        
        String query = "INSERT INTO " + P_CAT_TABLE + " (NAME, DESCRIPTION, RENEW_TIME) VALUES (?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stm.setString(1, prod_category.getName());
            stm.setString(2, prod_category.getDescription());
            stm.setInt(3, prod_category.getRenewtime());
            stm.executeUpdate();

            try (ResultSet rs = stm.getGeneratedKeys()) {
                if (rs.next()) {
                    prod_category.setId(rs.getInt(1));
                }
            } catch (SQLException ex) {
                System.err.println("Errore in rs:" + ex);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to add prod_category to DB", ex);
        }
    }

    @Override
    public void delete(Prod_category prod_category) throws DAOException {
        throw new DAOException("Product category does not support DELETE operations");
    }

    @Override
    public void update(Prod_category prod_category) throws DAOException {
        checkParam(prod_category, true);

        String query = "UPDATE " + P_CAT_TABLE + " SET NAME = ?, DESCRIPTION = ?, RENEW_TIME = ? WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, prod_category.getName());
            stm.setString(2, prod_category.getDescription());
            stm.setInt(3, prod_category.getRenewtime());
            stm.setInt(4, prod_category.getId());

            int count = stm.executeUpdate();
            if (count != 1) {
                throw new DAOException("prod_category update affected an invalid number of records: " + count);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the prod_category", ex);
        }
    }
}
