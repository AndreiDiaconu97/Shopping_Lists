/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.Reg_UserDAO;
import db.entities.Reg_User;
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
public class JDBCReg_UserDAO extends JDBCDAO<Reg_User, String> implements Reg_UserDAO {

    public JDBCReg_UserDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        try (Statement stmt = CON.createStatement()) {
            ResultSet counter = stmt.executeQuery("SELECT COUNT(*) FROM Reg_Users");
            if (counter.next()) {
                return counter.getLong(1);
            }

        } catch (SQLException ex) {
            throw new DAOException("Impossible to count users", ex);
        }

        return 0L;
    }

    @Override
    public List<Reg_User> getAll() throws DAOException {
        List<Reg_User> users = new ArrayList<>();

        try (Statement stm = CON.createStatement()) {
            try (ResultSet rs = stm.executeQuery("SELECT * FROM REG_USERS ORDER BY name")) {

                PreparedStatement shoppingListsStatement = CON.prepareStatement("SELECT count(*) FROM SHOPPING_LISTS WHERE id_user = ?");

                while (rs.next()) {
                    Reg_User user = new Reg_User();
                    user.setEmail(rs.getString("email"));
                    user.setPassword(rs.getString("password"));
                    user.setName(rs.getString("name"));
                    user.setIs_admin(rs.getBoolean("admin"));
                    //System.err.println("Getboolean: " + rs.getBoolean("admin"));

                    shoppingListsStatement.setString(1, user.getEmail());

                    // TODO
                    /*
                    ResultSet counter = shoppingListsStatement.executeQuery();
                    counter.next();
                    user.setShoppingListsCount(counter.getInt(1));
                     */
                    users.add(user);
                }
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the list of users", ex);
        }

        return users;

    }

    @Override
    public Reg_User getByPrimaryKey(String primaryKey) throws DAOException {
        if (primaryKey == null) {
            throw new DAOException("primaryKey is null");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM users WHERE email = ?")) {
            stm.setString(1, primaryKey);
            try (ResultSet rs = stm.executeQuery()) {

                rs.next();
                Reg_User user = new Reg_User();
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setAvatar(rs.getString("avatar"));
                user.setName(rs.getString("name"));
                user.setIs_admin(rs.getBoolean("is_admin"));
                // TODO: implement remaining attributes
                //System.err.println("Getboolean: " + rs.getBoolean("admin"));

                // ! to implement
                /*
                try (PreparedStatement todoStatement = CON.prepareStatement("SELECT count(*) FROM SHOPPING_LIST WHERE email = ?")) {
                    todoStatement.setString(1, user.getEmail());

                    ResultSet counter = todoStatement.executeQuery();
                    counter.next();
                    user.setShoppingListsCount(counter.getInt(1));
                }
                 */
                return user;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the user for the passed primary key", ex);
        }
    }

    @Override
    public Reg_User getByEmailAndPassword(String email, String password) throws DAOException {
        if ((email == null) || (password == null)) {
            throw new DAOException("Email and password are mandatory fields", new NullPointerException("email or password are null"));
        }

        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM REG_USERS WHERE email = ? AND password = ?")) {
            stm.setString(1, email);
            stm.setString(2, password);
            try (ResultSet rs = stm.executeQuery()) {
                PreparedStatement shoppingListStatement = CON.prepareStatement("SELECT count(*) FROM SHOPPING_LIST WHERE id_user = ?");

                int count = 0;
                while (rs.next()) {
                    count++;
                    if (count > 1) {
                        throw new DAOException("Unique constraint violated! There are more than one user with the same email! WHY???");
                    }
                    Reg_User user = new Reg_User();
                    user.setEmail(rs.getString("email"));
                    user.setPassword(rs.getString("password"));
                    user.setName(rs.getString("name"));
                    user.setIs_admin(rs.getBoolean("admin"));
                    // TODO: implement remaining attributes
                    //System.err.println("Getboolean: " + rs.getBoolean("admin"));

                    shoppingListStatement.setString(1, user.getEmail());

                    /*
                    ResultSet counter = shoppingListStatement.executeQuery();
                    counter.next();
                    user.setShoppingListsCount(counter.getInt(1));
                     */
                    return user;
                }

                if (!shoppingListStatement.isClosed()) {
                    shoppingListStatement.close();
                }

                return null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the list of users", ex);
        }
    }

}
