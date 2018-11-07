/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.entities.NV_User;
import db.entities.Product;
import db.entities.Reg_User;
import db.entities.List_reg;
import db.entities.List_anonymous;
import db.exceptions.DAOException;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Random;
import org.apache.commons.codec.digest.DigestUtils;

/**
 *
 * @author Andrei Diaconu
 */
public class JDBC_utility {

    private static final String SYMBOLS = "ABCDEFGJKLMNPRSTUVWXYZ0123456789";
    private static final Random RANDOM = new SecureRandom();

    public static String randomString(int length) {
        char buf[] = new char[length];
        for (int idx = 0; idx < buf.length; ++idx) {
            buf[idx] = SYMBOLS.charAt(RANDOM.nextInt(SYMBOLS.length()));
        }
        return new String(buf);
    }

    public static String secureHash(String password, String salt) {
        // should implement using slow hash function
        return DigestUtils.sha256Hex(password.concat(salt));
    }

    public static boolean secureHashEquals(String password, String salt, String hashed) {
        return hashed.equals(DigestUtils.sha512Hex(password.concat(salt)));
    }

    public static Long getCountFor(String table, Connection con) throws DAOException {
        try (PreparedStatement stm = con.prepareStatement("SELECT COUNT(*) FROM ?")) {
            stm.setString(1, table);
            ResultSet rs = stm.executeQuery();
            return rs.next() ? rs.getLong(1) : 0L;
        } catch (SQLException ex) {
            throw new DAOException("Impossible to count " + table + " elements", ex);
        }
    }

    public static Reg_User resultSetToReg_User(ResultSet rs) throws SQLException {
        Reg_User reg_user = new Reg_User();
        reg_user.setId(rs.getInt("ID"));
        reg_user.setEmail(rs.getString("EMAIL"));
        reg_user.setFirstname(rs.getString(("FIRSTNAME")));
        reg_user.setLastname(rs.getString("LASTNAME"));
        reg_user.setAvatar(rs.getString("AVATAR"));
        reg_user.setIs_admin(rs.getBoolean("IS_ADMIN"));
        return reg_user;
    }

    public static Product resultSetToProduct(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setCategory(rs.getString("CATEGORY"));
        product.setCreator(rs.getInt("CREATOR"));
        product.setDescription(rs.getString("DESCRIPTION"));
        product.setId(rs.getInt("ID"));
        product.setIs_public(rs.getBoolean("IS_PUBLIC"));
        product.setLogo(rs.getString("LOGO"));
        product.setName(rs.getString("NAME"));
        product.setNum_votes(rs.getInt("NUM_VOTES"));
        product.setPhoto(rs.getString("PHOTO"));
        product.setRating(rs.getFloat("RATING"));
        return product;
    }

    public static List_reg resultSetToList_reg(ResultSet rs) throws SQLException {
        List_reg shopping_list = new List_reg();
        shopping_list.setCategory(rs.getString("CATEGORY"));
        shopping_list.setDescription(rs.getString("DESCRIPTION"));
        shopping_list.setId(rs.getInt("ID"));
        shopping_list.setLogo(rs.getString("LOGO"));
        shopping_list.setName(rs.getString("NAME"));
        shopping_list.setOwner(rs.getInt("OWNER"));
        return shopping_list;
    }

    public static NV_User resultSetToNV_User(ResultSet rs) throws SQLException {
        NV_User nv_user = new NV_User();
        nv_user.setEmail(rs.getString("EMAIL"));
        nv_user.setPassword(rs.getString("PASSWORD"));
        nv_user.setFirstname(rs.getString(("FIRSTNAME")));
        nv_user.setLastname(rs.getString("LASTNAME"));
        nv_user.setAvatar(rs.getString("AVATAR"));
        nv_user.setCode(rs.getString("VERIFICATION_CODE"));
        return nv_user;
    }

    public static List_anonymous resultSetToList_anonymous(ResultSet rs) throws SQLException {
        List_anonymous list_anonymous = new List_anonymous();
        list_anonymous.setCategory(rs.getString("CATEGORY"));
        list_anonymous.setDescription(rs.getString("DESCRIPTION"));
        list_anonymous.setId(rs.getInt("ID"));
        list_anonymous.setLogo(rs.getString("LOGO"));
        list_anonymous.setLast_seen(rs.getTimestamp("LAST_SEEN"));
        list_anonymous.setName(rs.getString("NAME"));
        return list_anonymous;
    }

}
