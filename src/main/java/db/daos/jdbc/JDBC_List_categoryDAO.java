/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.List_categoryDAO;
import static db.daos.jdbc.JDBC_utility.*;
import db.entities.List_category;
import db.entities.Prod_category;
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
public class JDBC_List_categoryDAO extends JDBC_DAO<List_category, Integer> implements List_categoryDAO {

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
    public List_category getByPrimaryKey(Integer id) throws DAOException {
        try{
            return getList_category(id, CON);
        } catch(SQLException ex){
            throw new DAOException("Cannot get list_category by id " + id, ex);
        }
    }

    @Override
    public void insert(List_category list_category) throws DAOException {
        checkParam(list_category, false);
        
        String query = "INSERT INTO " + L_CAT_TABLE + " (name, description, logo) VALUES (?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stm.setString(1, list_category.getName());
            stm.setString(2, list_category.getDescription());
            stm.setString(3, list_category.getLogo());
            stm.executeUpdate();

            try (ResultSet rs = stm.getGeneratedKeys()) {
                if (rs.next()) {
                    list_category.setId(rs.getInt(1));
                }
            } catch (SQLException ex) {
                System.err.println("Errore in rs:" + ex);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to add list_category to DB", ex);
        }
    }

    @Override
    public void delete(List_category list_category) throws DAOException {
        throw new DAOException("List category does not support DELETE operations");
    }

    @Override
    public void update(List_category list_category) throws DAOException {
        checkParam(list_category, true);

        String query = "UPDATE " + L_CAT_TABLE + " SET NAME = ?, DESCRIPTION = ?, LOGO = ? WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, list_category.getName());
            stm.setString(2, list_category.getDescription());
            stm.setString(3, list_category.getLogo());
            stm.setInt(4, list_category.getId());

            int count = stm.executeUpdate();
            if (count != 1) {
                throw new DAOException("list_category update affected an invalid number of records: " + count);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the list_category", ex);
        }
    }

    @Override
    public List<Prod_category> getProd_categories(List_category list_category) throws DAOException {
        checkParam(list_category, true);

        String query = "SELECT * FROM " + P_CAT_TABLE + " WHERE ID IN (SELECT ID FROM " + L_P_CAT_TABLE + " WHERE LIST_CAT = ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_category.getId());

            try (ResultSet rs = stm.executeQuery()) {
                List<Prod_category> prod_categories = new ArrayList<>();

                while (rs.next()) {
                    prod_categories.add(resultSetToProd_category(rs, CON));
                }
                return prod_categories;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get prod_categories for given list_category", ex);
        }
    }

    @Override
    public void insertProd_category(List_category list_category, Prod_category prod_category) throws DAOException {
        checkParam(list_category, true);
        checkParam(prod_category, true);

        String query = "INSERT INTO " + L_P_CAT_TABLE + " (LIST_CAT, PRODUCT_CAT) VALUES (?,?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_category.getId());
            stm.setInt(2, prod_category.getId());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to add prod_category to list_category");
        }
    }

    @Override
    public void removeProd_category(List_category list_category, Prod_category prod_category) throws DAOException {
        checkParam(list_category, true);
        checkParam(prod_category, true);
        
        String query = "DELETE FROM " + L_P_CAT_TABLE + " WHERE LIST_CAT = ? AND PRODUCT_CAT = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_category.getId());
            stm.setInt(2, prod_category.getId());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to remove prod_category from list_category");
        }
    }
}
