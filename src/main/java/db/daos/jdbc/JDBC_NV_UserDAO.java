/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.NV_UserDAO;
import static db.daos.jdbc.JDBC_utility.*;
import db.entities.NV_User;
import db.entities.User;
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
public class JDBC_NV_UserDAO extends JDBC_DAO<NV_User, String> implements NV_UserDAO {

    public JDBC_NV_UserDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        return getCountFor(U_NV_TABLE, CON);
    }

    @Override
    public List<NV_User> getAll() throws DAOException {
        return getAllFor(U_NV_TABLE, CON, NV_User.class);
    }

    @Override
    public NV_User getByPrimaryKey(String email) throws DAOException {
        try {
            return getNV_User(email, CON);
        } catch (SQLException ex) {
            throw new DAOException("Cannot get nv_user by email " + email, ex);
        }
    }

    @Override
    public NV_User getByEmail(String email) throws DAOException {
        return getByPrimaryKey(email);
    }

    @Override
    public User validateUsingEmailAndCode(String email, String code) throws DAOException {
        NV_User nv_user = getByEmail(email);
        if (nv_user == null) {
            throw new DAOException("Passed verification code is invalid");
        }
        String query = "INSERT INTO " + U_TABLE + " (email, password, firstname, lastname, is_admin) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, nv_user.getEmail());
            stm.setString(2, nv_user.getHashed_password());
            stm.setString(3, nv_user.getFirstname());
            stm.setString(4, nv_user.getLastname());
            stm.setBoolean(5, false);
            stm.executeUpdate();

            // remove nv_user
            delete(nv_user);
        } catch (SQLException ex) {
            throw new DAOException("Impossible to validate nv_user", ex);
        }

        query = "SELECT * FROM " + U_TABLE + " WHERE EMAIL = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, nv_user.getEmail());
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? resultSetToUser(rs, CON) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get validated nv_user as user", ex);
        }
    }

    @Override
    public void insert(NV_User nv_user) throws DAOException {
        checkParam(nv_user);

        String query = "INSERT INTO " + U_NV_TABLE + " (email, password, firstname, lastname, verification_code) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, nv_user.getEmail());
            stm.setString(2, nv_user.getHashed_password());
            stm.setString(3, nv_user.getFirstname());
            stm.setString(4, nv_user.getLastname());
            stm.setString(5, nv_user.getCode());
            stm.executeUpdate();
        } catch (SQLException ex) {
            System.err.println(ex.toString());
            System.err.println(ex.getMessage());
            throw new DAOException("Impossible to add nv_user to DB", ex);
        }
    }

    @Override
    public void delete(NV_User nv_user) throws DAOException {
        checkParam(nv_user);

        String query = "DELETE FROM " + U_NV_TABLE + " WHERE EMAIL = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, nv_user.getEmail());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to remove nv_user", ex);
        }
    }

    @Override
    public void update(NV_User nv_user) throws DAOException {
        checkParam(nv_user);

        String query = "UPDATE " + U_NV_TABLE + " SET PASSWORD = ?, FIRSTNAME = ?, LASTNAME = ?, VERIFICATION_CODE = ? WHERE EMAIL = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, nv_user.getHashed_password());
            stm.setString(2, nv_user.getFirstname());
            stm.setString(3, nv_user.getLastname());
            stm.setString(4, nv_user.getCode());
            stm.setString(5, nv_user.getEmail());

            int count = stm.executeUpdate();
            if (count != 1) {
                throw new DAOException("nv_user update affected an invalid number of records: " + count);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the nv_user", ex);
        }
    }
}
