/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.List_categoryDAO;
import static db.daos.jdbc.JDBC_utility.*;
import db.entities.List_category;
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
public class JDBC_List_categoryDAO extends JDBC_DAO<List_category, String> implements List_categoryDAO {

    public JDBC_List_categoryDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        return getCountFor(L_CAT_TABLE, CON);
    }

    @Override
    public List<List_category> getAll() throws DAOException {
        return getAllFor(L_CAT_TABLE, CON, List_category.class);
    }

    @Override
    public List_category getByPrimaryKey(String name) throws DAOException {
        if (name == null) {
            throw new DAOException("name parameter is null");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM " + L_CAT_TABLE + " WHERE NAME = ?")) {
            stm.setString(1, name);
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? JDBC_utility.resultSetToList_category(rs) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the list_category for the passed id", ex);
        }
    }

    @Override
    public void insert(List_category list_category) throws DAOException {
        if (list_category == null) {
            throw new DAOException("Given list_category is null");
        }
        String query = "INSERT INTO " + L_CAT_TABLE + "(name, description, logo) VALUES(?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, list_category.getName());
            stm.setString(2, list_category.getDescription());
            stm.setString(3, list_category.getLogo());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to add list_category to DB", ex);
        }
    }

    @Override
    public void delete(List_category list_category) throws DAOException {
        if (list_category == null) {
            throw new DAOException("Given list_category is null");
        }
        String query = "DELETE FROM " + L_CAT_TABLE + " WHERE NAME = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, list_category.getName());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to remove list_category", ex);
        }
    }

    @Override
    public void update(List_category list_category) throws DAOException {
        if (list_category == null) {
            throw new DAOException("Given list_category is null");
        }

        String list_regId = list_category.getName();
        if (list_regId == null) {
            throw new DAOException("List_category is not valid", new NullPointerException("List_category name is null"));
        }
        //!! cannot change name without extra argument or without adding an id as primary key !!//
        String query = "UPDATE " + L_CAT_TABLE + " SET DESCRIPTION = ?, LOGO = ? WHERE NAME = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, list_category.getDescription());
            stm.setString(2, list_category.getLogo());
            stm.setString(3, list_category.getName());

            int count = stm.executeUpdate();
            if (count != 1) {
                throw new DAOException("list_category update affected an invalid number of records: " + count);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the list_category", ex);
        }
    }
}
