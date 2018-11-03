/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.Shopping_listDAO;
import db.entities.Product;
import db.entities.Reg_User;
import db.entities.Shopping_list;
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
public class JDBCShopping_listDAO extends JDBCDAO<Shopping_list, Shopping_list.PrimaryKey> implements Shopping_listDAO {

    public JDBCShopping_listDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public Shopping_list getByPrimaryKey(Shopping_list.PrimaryKey primaryKey) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public List<Shopping_list> getAll() throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public Integer insert(Shopping_list shoppingList) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public boolean linkShoppingListToReg_User(Shopping_list shoppingList, Reg_User user) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public Shopping_list getByID(Integer id) throws DAOException {
        if (id == null) {
            throw new DAOException("id parameter is null");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM LISTS WHERE ID = ?")) {
            stm.setInt(1, id);

            try (ResultSet rs = stm.executeQuery()) {
                Shopping_list shopping_list = new Shopping_list();
                shopping_list.setId(rs.getInt("ID"));
                shopping_list.setCategory(rs.getString("CATEGORY"));
                shopping_list.setDescription(rs.getString("DESCRIPTION"));
                shopping_list.setImage(rs.getString("LOGO"));
                shopping_list.setName(rs.getString("NAME"));
                shopping_list.setOwner(rs.getString("OWNER"));

                return shopping_list;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the shopping_list for the passed primary key", ex);
        }
    }

    @Override
    public List<Shopping_list> getByOwner(String owner) throws DAOException {
        if (owner == null) {
            throw new DAOException("owner parameter is null");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM LISTS WHERE OWNER = ?")) {
            stm.setString(1, owner);
            try (ResultSet rs = stm.executeQuery()) {
                List<Shopping_list> shopping_lists = new ArrayList<>();

                while (rs.next()) {
                    Shopping_list shopping_list = new Shopping_list();
                    shopping_list.setId(rs.getInt("ID"));
                    shopping_list.setCategory(rs.getString("CATEGORY"));
                    shopping_list.setDescription(rs.getString("DESCRIPTION"));
                    shopping_list.setImage(rs.getString("LOGO"));
                    shopping_list.setName(rs.getString("NAME"));
                    shopping_list.setOwner(rs.getString("OWNER"));

                    shopping_lists.add(shopping_list);
                }
                return shopping_lists;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the shopping_list for the passed owner", ex);
        }
    }

    @Override
    public List<Reg_User> getListUsers(Shopping_list shopping_list) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public List<Product> getListProducts(Shopping_list shopping_list) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

}
