/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import static db.daos.jdbc.JDBC_utility.*;
import db.entities.Product;
import db.entities.User;
import db.exceptions.DAOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import db.entities.List_reg;
import org.springframework.security.crypto.bcrypt.BCrypt;
import db.daos.UserDAO;

/**
 *
 * @author Andrei Diaconu
 */
public class JDBC_UserDAO extends JDBC_DAO<User, Integer> implements UserDAO {

    public JDBC_UserDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        return getCountFor(U_TABLE, CON);
    }

    @Override
    public List<User> getAll() throws DAOException {
        return getAllFor(U_TABLE, CON, User.class);
    }

    @Override
    public User getByEmailAndPassword(String email, String password) throws DAOException {
        String msg = "";
        if (email == null || "".equals(email)) {
            msg += "Given email is empty. ";
        }
        if (password == null || "".equals(password)) {
            msg += "Given password is empty.";
        }
        if (msg.length() > 1) {
            throw new DAOException(msg);
        }

        User user = getByEmail(email);
        if(user==null){
            return null;
        }
        
        // CHECK IF HASH IS MATCHING
        if (BCrypt.checkpw(password, user.getHashed_password())) {
            return user;
        } else {
            System.err.println("HASH IS DIFFERENT (probably wrong password)");
            return null;
        }
    }

    @Override
    public User getByPrimaryKey(Integer id) throws DAOException {
        try {
            return getUser(id, CON);
        } catch (SQLException ex) {
            throw new DAOException("Cannot get user by id " + id, ex);
        }
    }

    @Override
    public User getByEmail(String email) throws DAOException {
        if ("".equals(email) || email == null) {
            throw new DAOException("Given email is empty");
        }
        String query = "SELECT * FROM " + U_TABLE + " WHERE EMAIL = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, email);
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? resultSetToUser(rs, CON) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the user for the passed email", ex);
        }
    }

    @Override
    public List<Product> getProductsCreated(User user) throws DAOException {
        checkParam(user, true);

        String query = "SELECT * FROM " + P_TABLE + " WHERE CREATOR = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, user.getId());
            try (ResultSet rs = stm.executeQuery()) {
                List<Product> products = new ArrayList<>();
                while (rs.next()) {
                    products.add(resultSetToProduct(rs, CON));
                }
                return products;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get products for the passed user", ex);
        }
    }

    @Override
    public List<List_reg> getOwnedLists(User user) throws DAOException {
        checkParam(user, true);

        String query = "SELECT * FROM " + L_TABLE + " WHERE OWNER = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, user.getId());
            try (ResultSet rs = stm.executeQuery()) {
                List<List_reg> lists = new ArrayList<>();
                while (rs.next()) {
                    lists.add(resultSetToList_reg(rs, CON));
                }
                return lists;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get owned lists for the passed user", ex);
        }
    }

    @Override
    public List<List_reg> getSharedLists(User user) throws DAOException {
        checkParam(user, true);

        String query = "SELECT * FROM " + L_TABLE + " WHERE ID IN (SELECT LIST FROM " + L_SHARING_TABLE + " WHERE USER_ID = ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, user.getId());
            try (ResultSet rs = stm.executeQuery()) {
                List<List_reg> lists = new ArrayList<>();
                while (rs.next()) {
                    lists.add(resultSetToList_reg(rs, CON));
                }
                return lists;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get shared lists for the passed user", ex);
        }
    }

    @Override
    public void insert(User user) throws DAOException {
        checkParam(user, false);

        String query = "INSERT INTO " + U_TABLE + " (email, password, firstname, lastname, is_admin) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stm.setString(1, user.getEmail());
            stm.setString(2, user.getHashed_password());
            stm.setString(3, user.getFirstname());
            stm.setString(4, user.getLastname());
            stm.setBoolean(5, user.getIs_admin());
            stm.executeUpdate();

            ResultSet rs = stm.getGeneratedKeys();
            if (rs.next()) {
                user.setId(rs.getInt(1));
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to add user to DB", ex);
        }
    }

    @Override
    public void delete(User user) throws DAOException {
        throw new DAOException("User does not support DELETE operations");
    }

    @Override
    public void update(User user) throws DAOException {
        checkParam(user, true);

        String query = "UPDATE " + U_TABLE + " SET EMAIL = ?, PASSWORD = ?, FIRSTNAME = ?, LASTNAME = ?, IS_ADMIN = ? WHERE ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, user.getEmail());
            stm.setString(2, user.getHashed_password());
            stm.setString(3, user.getFirstname());
            stm.setString(4, user.getLastname());
            stm.setBoolean(5, user.getIs_admin());
            stm.setInt(6, user.getId());

            int count = stm.executeUpdate();
            if (count != 1) {
                throw new DAOException("user update affected an invalid number of records: " + count);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the user", ex);
        }
    }

    @Override
    public AccessLevel getAccessLevel(User user, List_reg list_reg) throws DAOException {
        checkParam(user, true);
        checkParam(list_reg, true);

        String query = "SELECT ACCESS FROM " + L_SHARING_TABLE + " WHERE LIST = ? AND USER_ID = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setInt(1, list_reg.getId());
            stm.setInt(2, user.getId());
            try (ResultSet rs = stm.executeQuery()) {
                if (rs.next()) {
                    return intToAccessLevel(rs.getInt(1));
                } else {
                    throw new DAOException("Bad access level on user " + user.getId() + " and list " + list_reg.getId());
                }
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the user", ex);
        }
    }
}
