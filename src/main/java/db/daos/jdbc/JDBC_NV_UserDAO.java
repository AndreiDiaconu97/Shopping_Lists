/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.NV_UserDAO;
import db.daos.NV_UserDAO;
import db.entities.NV_User;
import db.entities.Product;
import db.entities.NV_User;
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
public class JDBC_NV_UserDAO extends JDBC_DAO<NV_User, String> implements NV_UserDAO {

    public JDBC_NV_UserDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        try (Statement stmt = CON.createStatement()) {
            ResultSet counter = stmt.executeQuery("SELECT COUNT(*) FROM NV_USERS");
            if (counter.next()) {
                return counter.getLong(1);
            } else {
                return 0L;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to count nv_users", ex);
        }
    }

    @Override
    public NV_User getByPrimaryKey(String email) throws DAOException {
        if (email == null) {
            throw new DAOException("email is null");
        }
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM NV_USERS WHERE EMAIL = ?")) {
            stm.setString(1, email);
            try (ResultSet rs = stm.executeQuery()) {
                return rs.next() ? resultSetToNV_User(rs) : null;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get the nv_user for the passed primary key", ex);
        }
    }

    @Override
    public List<NV_User> getAll() throws DAOException {
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM NV_USERS")) {
            ResultSet rs = stm.executeQuery();
            List<NV_User> nv_users = new ArrayList<>();
            while (rs.next()) {
                nv_users.add(resultSetToNV_User(rs));
            }
            return nv_users;
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get all the nv_users");
        }
    }

    @Override
    public NV_User getByEmail(String email) throws DAOException {
        return getByPrimaryKey(email);
    }

    @Override
    public NV_User getByCode(String code) throws DAOException {
        try (PreparedStatement stm = CON.prepareStatement("SELECT * FROM NV_USERS WHERE CODE = ?")) {
            stm.setString(1, code);
            ResultSet rs = stm.executeQuery();
            return rs.next() ? resultSetToNV_User(rs) : null;
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get nv_user by code");
        }
    }

    @Override
    public Reg_User registerUsingCode(String code) throws DAOException {
        NV_User nv_user = getByCode(code);

    }

    private NV_User resultSetToNV_User(ResultSet rs) throws SQLException {
        NV_User nv_user = new NV_User();
        nv_user.setEmail(rs.getString("EMAIL"));
        nv_user.setPassword(rs.getString("PASSWORD"));
        nv_user.setName(rs.getString(("NAME")));
        nv_user.setSurname(rs.getString("SURNAME"));
        nv_user.setAvatar(rs.getString("AVATAR"));
        nv_user.setCode(rs.getString("CODE"));
        return nv_user;
    }
}
