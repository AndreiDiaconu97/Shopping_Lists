/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.NV_UserDAO;
import static db.daos.jdbc.JDBC_utility.getCountFor;
import static db.daos.jdbc.JDBC_utility.resultSetToNV_User;
import static db.daos.jdbc.JDBC_utility.resultSetToReg_User;
import db.entities.NV_User;
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
public class JDBC_NV_UserDAO extends JDBC_DAO<NV_User, String> implements NV_UserDAO {

    public JDBC_NV_UserDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        return getCountFor("NV_USERS", CON);
    }

    @Override
    public List<NV_User> getAll() throws DAOException {
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM NV_USERS")) {
            try (ResultSet rs = stm.executeQuery()) {
                List<NV_User> nv_users = new ArrayList<>();
                while (rs.next()) {
                    nv_users.add(resultSetToNV_User(rs));
                }
                return nv_users;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get all the nv_users", ex);
        }
    }

    @Override
    public NV_User getByPrimaryKey(String email) throws DAOException {
        if ("".equals(email) || email == null) {
            throw new DAOException("Given email is empty");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM NV_USERS WHERE EMAIL = ?")) {
            stm.setString(1, email);
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? resultSetToNV_User(rs) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the nv_user for the passed email", ex);
        }
    }

    @Override
    public NV_User getByEmail(String email) throws DAOException {
        return getByPrimaryKey(email);
    }

    @Override
    public NV_User getByCode(String code) throws DAOException {
        if ("".equals(code) || code == null) {
            throw new DAOException("Given code is empty");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM NV_USERS WHERE CODE = ?")) {
            stm.setString(1, code);
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? resultSetToNV_User(rs) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get nv_user by code", ex);
        }
    }

    @Override
    public Reg_User validateUsingCode(String code) throws DAOException {
        NV_User nv_user = getByCode(code);
        if (nv_user == null) {
            throw new DAOException("Passed verification code is invalid");
        }
        String query = "INSERT INTO REG_USERS(email, password, firstname, lastname, is_admin, avatar) VALUES(?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, nv_user.getEmail());
            stm.setString(2, nv_user.getPassword());
            stm.setString(3, nv_user.getFirstname());
            stm.setString(4, nv_user.getLastname());
            stm.setBoolean(5, false);
            stm.setString(6, nv_user.getAvatar());
            stm.executeUpdate();
            delete(nv_user);
        } catch (SQLException ex) {
            throw new DAOException("Impossible to validate nv_user", ex);
        }

        query = "SELECT * FROM REG_USERS WHERE EMAIL = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, nv_user.getEmail());
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? resultSetToReg_User(rs) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get validated nv_user as reg_user", ex);
        }
    }

    @Override
    public void insert(NV_User nv_user) throws DAOException {
        if (nv_user == null) {
            throw new DAOException("Given nv_user is null");
        }

        String query = "INSERT INTO NV_USERS VALUES(?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, nv_user.getEmail());
            stm.setString(2, nv_user.getPassword());
            stm.setString(3, nv_user.getFirstname());
            stm.setString(4, nv_user.getLastname());
            stm.setString(5, nv_user.getAvatar());
            stm.setString(6, nv_user.getCode());
            stm.executeUpdate();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to add nv_user to DB", ex);
        }
    }

    @Override
    public void delete(NV_User nv_user) throws DAOException {
        if (nv_user == null) {
            throw new DAOException("Given nv_user is null");
        }
        String query = "DELETE FROM NV_USERS WHERE EMAIL = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, nv_user.getEmail());
            stm.executeQuery();
        } catch (SQLException ex) {
            throw new DAOException("Impossible to remove nv_user", ex);
        }
    }

    @Override
    public void update(NV_User nv_user) throws DAOException {
        if (nv_user == null) {
            throw new DAOException("Given nv_user is null");
        }
        String query = "UPDATE NV_USERS SET PASSWORD = ?, FIRSTNAME = ?, LASTNAME = ?, AVATAR = ?, VERIFICATION_CODE = ? WHERE EMAIL = ?";
        try (PreparedStatement stm = CON.prepareStatement(query)) {
            stm.setString(1, nv_user.getPassword());
            stm.setString(2, nv_user.getFirstname());
            stm.setString(3, nv_user.getLastname());
            stm.setString(4, nv_user.getAvatar());
            stm.setString(5, nv_user.getCode());
            stm.setString(6, nv_user.getEmail());

            int count = stm.executeUpdate();
            if (count != 1) {
                throw new DAOException("nv_user update affected an invalid number of records: " + count);
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to update the nv_user", ex);
        }
    }

    @Override
    public String generateCode(int code_size) throws DAOException {
        String code;
        try (Statement stm = CON.createStatement()) {
            while (true) {
                code = JDBC_utility.randomString(code_size);
                try (ResultSet rs = stm.executeQuery("SELECT * FROM NV_USERS WHERE VERIFICATION_CODE = " + code)) {
                    if (!rs.next()) { // se non trovo elementi con quel code, ritorno
                        return code;
                    }
                } catch (SQLException ex) {
                    System.err.println("FAILED GENERATING CODE, IN QUERY EXEC");
                    throw ex;
                }
            }
        } catch (SQLException ex) {
            throw new DAOException("Failed to generate verification code");
        }
    }
}
