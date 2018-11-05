/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.Reg_UserDAO;
import db.entities.Product;
import db.entities.Reg_User;
import db.entities.Shopping_list;
import db.exceptions.DAOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public class JDBC_Reg_UserDAO extends JDBC_DAO<Reg_User, String> implements Reg_UserDAO {

    public JDBC_Reg_UserDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        try (Statement stmt = CON.createStatement()) {
            ResultSet counter = stmt.executeQuery("SELECT COUNT(*) FROM REG_USERS");
            if (counter.next()) {
                return counter.getLong(1);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to count users", ex);
        }

        return 0L;
    }

    @Override
    public Reg_User getByPrimaryKey(String email) throws DAOException {
        if (email == null) {
            throw new DAOException("primaryKey is null");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM REG_USERS WHERE EMAIL = ?")) {
            stm.setString(1, email);

            try (ResultSet rs = stm.executeQuery()) {
                rs.next();
                Reg_User reg_user = resultSetToUser(rs);
                /*
                try (PreparedStatement todoStatement = CON.prepareStatement("SELECT count(*) FROM USERS_SHOPPING_LISTS WHERE id_user = ?")) {
                    todoStatement.setInt(1, reg_user.getId());

                    ResultSet counter = todoStatement.executeQuery();
                    counter.next();
                    reg_user.setShoppingListsCount(counter.getInt(1));
                }
                 */
                return reg_user;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the user for the passed primary key", ex);
        }
    }

    @Override
    public List<Reg_User> getAll() throws DAOException {
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM REG_USERS")) {
            try (ResultSet rs = stm.executeQuery()) {
                List<Reg_User> reg_users = new ArrayList<>();

                while (rs.next()) {
                    Reg_User reg_user = resultSetToUser(rs);
                    reg_users.add(reg_user);
                }
                return reg_users;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get all the users");
        }
    }

    @Override
    public Reg_User getByEmailAndPassword(String email, String password) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public Reg_User getByEmail(String email) throws DAOException {
        return getByPrimaryKey(email);
    }

    @Override
    public Reg_User getByID(Integer id) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public List<Product> getProductsCreated(Reg_User reg_user) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public List<Shopping_list> getOwningShopLists(Reg_User reg_user) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public List<Shopping_list> getShopLists(Reg_User reg_user) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    private Reg_User resultSetToUser(ResultSet rs) throws SQLException {
        Reg_User reg_user = new Reg_User();
        reg_user.setAvatar(rs.getString("AVATAR"));
        reg_user.setEmail(rs.getString("EMAIL"));
        reg_user.setId(rs.getInt("ID"));
        reg_user.setIs_admin(rs.getBoolean("IS_ADMIN"));
        reg_user.setName(rs.getString(("NAME")));
        reg_user.setPassword(rs.getString("PASSWORD"));
        reg_user.setSurname(rs.getString("SURNAME"));

        return reg_user;
    }

}

/*
// QUERY FUNCTION TEMPLATE //
@Override
    public List<Reg_User> getAll() throws DAOException {
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM REG_USERS")) {
            try (ResultSet rs = stm.executeQuery()) {
                List<Reg_User> reg_users = new ArrayList<>();

                while (rs.next()) {
                    Reg_User reg_user = new Reg_User();

                    reg_users.add(reg_user);
                }
            }

        } catch (SQLException ex) {
            throw new DAOException("Impossible to get all the users");
        }
        return ;
    }
 */
