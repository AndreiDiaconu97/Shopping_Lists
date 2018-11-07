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
public class JDBC_Prod_categoryDAO extends JDBC_DAO<Prod_category, String> implements Prod_categoryDAO {

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
    public Prod_category getByPrimaryKey(String name) throws DAOException {
        if (name == null) {
            throw new DAOException("name parameter is null");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM ? WHERE NAME = ?")) {
            stm.setString(1, P_CAT_TABLE);
            stm.setString(2, name);
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? JDBC_utility.resultSetToProd_category(rs) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the prod_category for the passed id", ex);
        }
    }

    @Override
    public void insert(Prod_category prod_category) throws DAOException {
        if (prod_category == null) {
            throw new DAOException("Given prod_category is null");
        }
        String query = "INSERT INTO ?(name, description, logo) VALUES(?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, P_CAT_TABLE);
            stm.setString(2, prod_category.getName());
            stm.setString(3, prod_category.getDescription());
            stm.setString(4, prod_category.getLogo());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to add prod_category to DB", ex);
        }
    }

    @Override
    public void delete(Prod_category prod_category) throws DAOException {
        if (prod_category == null) {
            throw new DAOException("Given prod_category is null");
        }
        String query = "DELETE FROM ? WHERE NAME = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, P_CAT_TABLE);
            stm.setString(2, prod_category.getName());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to remove prod_category", ex);
        }
    }

    @Override
    public void update(Prod_category prod_category) throws DAOException {
        if (prod_category == null) {
            throw new DAOException("Given prod_category is null");
        }

        String list_regId = prod_category.getName();
        if (list_regId == null) {
            throw new DAOException("Prod_category is not valid", new NullPointerException("Prod_category name is null"));
        }
        //!! cannot change name without extra argument or without adding an id as primary key !!//
        String query = "UPDATE ? SET DESCRIPTION = ?, LOGO = ? WHERE NAME = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, P_CAT_TABLE);
            stm.setString(2, prod_category.getDescription());
            stm.setString(3, prod_category.getLogo());
            stm.setString(4, prod_category.getName());

            int count = stm.executeUpdate();
            if (count != 1) {
                throw new DAOException("prod_category update affected an invalid number of records: " + count);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the prod_category", ex);
        }
    }
}
