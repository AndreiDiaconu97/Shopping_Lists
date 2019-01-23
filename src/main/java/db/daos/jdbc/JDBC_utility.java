/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.entities.NV_User;
import db.entities.Product;
import db.entities.User;
import db.entities.List_reg;
import db.entities.List_anonymous;
import db.entities.List_category;
import db.entities.Message;
import db.entities.Prod_category;
import db.exceptions.DAOException;
import java.security.SecureRandom;
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
public abstract class JDBC_utility {

    /// ALL TABLES OF THE DATABASE ///
    public static final String L_TABLE = "LISTS";
    public static final String L_ANONYM_TABLE = "LISTS_ANONYMOUS";
    public static final String L_ANONYM_P_TABLE = "LISTS_ANONYMOUS_PRODUCTS";
    public static final String L_CAT_TABLE = "LISTS_CATEGORIES";
    public static final String L_P_TABLE = "LISTS_PRODUCTS";
    public static final String L_SHARING_TABLE = "LISTS_SHARING";
    public static final String U_NV_TABLE = "NV_USERS";
    public static final String U_TABLE = "USERS";
    public static final String P_TABLE = "PRODUCTS";
    public static final String P_CAT_TABLE = "PRODUCTS_CATEGORIES";
    public static final String L_P_CAT_TABLE = "LISTS_PRODUCTS_CATEGORIES";
    public static final String CHATS_TABLE = "CHATS";

    private static final String SYMBOLS = "ABCDEFGJKLMNPRSTUVWXYZ0123456789";
    private static final SecureRandom RANDOM = new SecureRandom();

    public static String randomString(int length) {
        char buf[] = new char[length];
        for (int idx = 0; idx < buf.length; idx++) {
            buf[idx] = SYMBOLS.charAt(RANDOM.nextInt(SYMBOLS.length()));
        }
        return new String(buf);
    }

    public static Long getCountFor(String table, Connection con) throws DAOException {
        try (PreparedStatement stm = con.prepareStatement("SELECT COUNT(*) FROM " + table)) {
            ResultSet rs = stm.executeQuery();
            return rs.next() ? rs.getLong(1) : 0L;
        } catch (SQLException ex) {
            throw new DAOException("Impossible to count " + table + " elements", ex);
        }
    }

    public static <T> List<T> getAllFor(String table, Connection con, Class<T> returnType) throws DAOException { // should be tested
        try (PreparedStatement stm = con.prepareStatement("SELECT * FROM " + table)) {
            try (ResultSet rs = stm.executeQuery()) {
                List<T> Tlist = new ArrayList<>();
                if (returnType == List_anonymous.class) {
                    while (rs.next()) {
                        Tlist.add(returnType.cast(resultSetToList_anonymous(rs, con)));
                    }
                } else if (returnType == List_category.class) {
                    while (rs.next()) {
                        Tlist.add(returnType.cast(resultSetToList_category(rs, con)));
                    }
                } else if (returnType == List_reg.class) {
                    while (rs.next()) {
                        Tlist.add(returnType.cast(resultSetToList_reg(rs, con)));
                    }
                } else if (returnType == NV_User.class) {
                    while (rs.next()) {
                        Tlist.add(returnType.cast(resultSetToNV_User(rs, con)));
                    }
                } else if (returnType == Prod_category.class) {
                    while (rs.next()) {
                        Tlist.add(returnType.cast(resultSetToProd_category(rs, con)));
                    }
                } else if (returnType == Product.class) {
                    while (rs.next()) {
                        Tlist.add(returnType.cast(resultSetToProduct(rs, con)));
                    }
                } else if (returnType == User.class) {
                    while (rs.next()) {
                        Tlist.add(returnType.cast(resultSetToUser(rs, con)));
                    }
                } else {
                    throw new Error("Invalid class of argument!");
                }
                return Tlist;
            }
        } catch (SQLException ex) {
            throw new DAOException("Impossible to get all the elements of" + table + " table.", ex);
        }
    }

    public static User getUser(Integer id, Connection con) throws SQLException {
        if (id == null) {
            throw new SQLException("Given id is empty");
        }
        String query = "SELECT * FROM " + U_TABLE + " WHERE ID = ?";
        PreparedStatement stm = con.prepareStatement(query);
        stm.setInt(1, id);
        ResultSet rs = stm.executeQuery();
        
        return rs.next() ? resultSetToUser(rs, con) : null;
    }

    public static User resultSetToUser(ResultSet rs, Connection con) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("ID"));
        user.setEmail(rs.getString("EMAIL"));
        user.setHashed_password(rs.getString("PASSWORD"));
        user.setFirstname(rs.getString(("FIRSTNAME")));
        user.setLastname(rs.getString("LASTNAME"));
        user.setAvatar(rs.getString("AVATAR"));
        user.setIs_admin(rs.getBoolean("IS_ADMIN"));
        return user;
    }

    public static Product getProduct(Integer id, Connection con) throws SQLException {
        if (id == null) {
            throw new SQLException("Given id is empty");
        }
        String query = "SELECT * FROM " + P_TABLE + " WHERE ID = ?";
        PreparedStatement stm = con.prepareStatement(query);
        stm.setInt(1, id);
        ResultSet rs = stm.executeQuery();
        
        return rs.next() ? resultSetToProduct(rs, con) : null;
    }
    
    public static Product resultSetToProduct(ResultSet rs, Connection con) throws SQLException {
        Product product = new Product();
        product.setCategory(getProd_category(rs.getInt("CATEGORY"), con));
        product.setCreator(getUser(rs.getInt("CREATOR"), con));
        product.setDescription(rs.getString("DESCRIPTION"));
        product.setId(rs.getInt("ID"));
        product.setLogo(rs.getString("LOGO"));
        product.setName(rs.getString("NAME"));
        product.setNum_votes(rs.getInt("NUM_VOTES"));
        product.setPhoto(rs.getString("PHOTO"));
        product.setRating(rs.getFloat("RATING"));
        return product;
    }
    
    public static List_reg getList_reg(Integer id, Connection con) throws SQLException {
        if (id == null) {
            throw new SQLException("Given id is empty");
        }
        String query = "SELECT * FROM " + L_TABLE + " WHERE ID = ?";
        PreparedStatement stm = con.prepareStatement(query);
        stm.setInt(1, id);
        ResultSet rs = stm.executeQuery();
        
        return rs.next() ? resultSetToList_reg(rs, con) : null;
    }

    public static List_reg resultSetToList_reg(ResultSet rs, Connection con) throws SQLException {
        List_reg list_reg = new List_reg();
        list_reg.setCategory(getList_category(rs.getInt("CATEGORY"), con));
        list_reg.setDescription(rs.getString("DESCRIPTION"));
        list_reg.setId(rs.getInt("ID"));
        list_reg.setLogo(rs.getString("LOGO"));
        list_reg.setName(rs.getString("NAME"));
        list_reg.setOwner(getUser(rs.getInt("OWNER"), con));
        return list_reg;
    }

    public static NV_User getNV_User(String email, Connection con) throws SQLException {
        if (email == null) {
            throw new SQLException("Given email is empty");
        }
        String query = "SELECT * FROM " + U_NV_TABLE + " WHERE EMAIL = ?";
        PreparedStatement stm = con.prepareStatement(query);
        stm.setString(1, email);
        ResultSet rs = stm.executeQuery();
        
        return rs.next() ? resultSetToNV_User(rs, con) : null;
    }
    
    public static NV_User resultSetToNV_User(ResultSet rs, Connection con) throws SQLException {
        NV_User nv_user = new NV_User();
        nv_user.setEmail(rs.getString("EMAIL"));
        nv_user.setHashed_password(rs.getString("PASSWORD"));
        nv_user.setFirstname(rs.getString(("FIRSTNAME")));
        nv_user.setLastname(rs.getString("LASTNAME"));
        nv_user.setAvatar(rs.getString("AVATAR"));
        nv_user.setCode(rs.getString("VERIFICATION_CODE"));
        return nv_user;
    }
    
    public static List_anonymous getList_anonymous(Integer id, Connection con) throws SQLException {
        if (id == null) {
            throw new SQLException("Given id is empty");
        }
        String query = "SELECT * FROM " + L_ANONYM_TABLE + " WHERE ID = ?";
        PreparedStatement stm = con.prepareStatement(query);
        stm.setInt(1, id);
        ResultSet rs = stm.executeQuery();
        
        return rs.next() ? resultSetToList_anonymous(rs, con) : null;
    }

    public static List_anonymous resultSetToList_anonymous(ResultSet rs, Connection con) throws SQLException {
        List_anonymous list_anonymous = new List_anonymous();
        list_anonymous.setCategory(getList_category(rs.getInt("CATEGORY"), con));
        list_anonymous.setDescription(rs.getString("DESCRIPTION"));
        list_anonymous.setId(rs.getInt("ID"));
        list_anonymous.setLogo(rs.getString("LOGO"));
        list_anonymous.setLast_seen(rs.getTimestamp("LAST_SEEN"));
        list_anonymous.setName(rs.getString("NAME"));
        return list_anonymous;
    }
    
    public static List_category getList_category(Integer id, Connection con) throws SQLException {
        if (id == null) {
            throw new SQLException("Given id is empty");
        }
        String query = "SELECT * FROM " + L_CAT_TABLE + " WHERE ID = ?";
        PreparedStatement stm = con.prepareStatement(query);
        stm.setInt(1, id);
        ResultSet rs = stm.executeQuery();
        
        return rs.next() ? resultSetToList_category(rs, con) : null;
    }

    public static List_category resultSetToList_category(ResultSet rs, Connection con) throws SQLException {
        List_category list_category = new List_category();
        list_category.setId(rs.getInt("ID"));
        list_category.setName(rs.getString("NAME"));
        list_category.setDescription(rs.getString("DESCRIPTION"));
        list_category.setLogo(rs.getString("LOGO"));
        return list_category;
    }
    
    public static Prod_category getProd_category(Integer id, Connection con) throws SQLException {
        if (id == null) {
            throw new SQLException("Given id is empty");
        }
        String query = "SELECT * FROM " + P_CAT_TABLE + " WHERE ID = ?";
        PreparedStatement stm = con.prepareStatement(query);
        stm.setInt(1, id);
        ResultSet rs = stm.executeQuery();
        
        return rs.next() ? resultSetToProd_category(rs, con) : null;
    }

    public static Prod_category resultSetToProd_category(ResultSet rs, Connection con) throws SQLException {
        Prod_category prod_category = new Prod_category();
        prod_category.setId(rs.getInt("ID"));
        prod_category.setName(rs.getString("NAME"));
        prod_category.setDescription(rs.getString("DESCRIPTION"));
        prod_category.setLogo(rs.getString("LOGO"));
        return prod_category;
    }

    public enum AccessLevel {
        READ,
        PRODUCTS,
        FULL
    }
    
    public enum SortBy{
        NAME,
        RATING,
        POPULARITY
    }

    public static AccessLevel intToAccessLevel(Integer a) {
        switch (a) {
            case 2:
                return AccessLevel.FULL;
            case 1:
                return AccessLevel.PRODUCTS;
            default:
                return AccessLevel.READ;
        }
    }

    public static void checkParam(User user, boolean expectID) throws DAOException {
        if (user == null) {
            throw new DAOException("Passed user is null");
        }
        if (expectID && user.getId() == null) {
            throw new DAOException("Passed user has no ID");
        }
        if (!expectID && user.getId() != null) {
            throw new DAOException("Passed user has ID but it shouldn't (probably insert operation)");
        }
    }

    public static void checkParam(List_reg list_reg, boolean expectID) throws DAOException {
        if (list_reg == null) {
            throw new DAOException("Passed list_reg is null");
        }
        if (expectID && list_reg.getId() == null) {
            throw new DAOException("Passed list_reg has no ID");
        }
        if (!expectID && list_reg.getId() != null) {
            throw new DAOException("Passed list_reg has ID but it shouldn't (probably insert operation)");
        }
    }

    public static void checkParam(NV_User nv_user) throws DAOException {
        if (nv_user == null) {
            throw new DAOException("Passed nv_user is null");
        }
    }

    public static void checkParam(List_category list_cat, boolean expectID) throws DAOException {
        if (list_cat == null) {
            throw new DAOException("Passed list_cat is null");
        }
        if (expectID && list_cat.getId() == null) {
            throw new DAOException("Passed list_cat has no ID");
        }
        if (!expectID && list_cat.getId() != null) {
            throw new DAOException("Passed list_cat has ID but it shouldn't (probably insert operation)");
        }
    }

    public static void checkParam(Prod_category prod_cat, boolean expectID) throws DAOException {
        if (prod_cat == null) {
            throw new DAOException("Passed prod_cat is null");
        }
        if (expectID && prod_cat.getId() == null) {
            throw new DAOException("Passed prod_cat has no ID");
        }
        if (!expectID && prod_cat.getId() != null) {
            throw new DAOException("Passed prod_cat has ID but it shouldn't (probably insert operation)");
        }
    }

    public static void checkParam(Product prod, boolean expectID) throws DAOException {
        if (prod == null) {
            throw new DAOException("Passed prod is null");
        }
        if (expectID && prod.getId() == null) {
            throw new DAOException("Passed prod has no ID");
        }
        if (!expectID && prod.getId() != null) {
            throw new DAOException("Passed prod has ID but it shouldn't (probably insert operation)");
        }
    }

    public static void checkParam(List_anonymous list_anonymous, boolean expectID) throws DAOException {
        if (list_anonymous == null) {
            throw new DAOException("Passed list_anonymous is null");
        }
        if (expectID && list_anonymous.getId() == null) {
            throw new DAOException("Passed list_anonymous has no ID");
        }
        if (!expectID && list_anonymous.getId() != null) {
            throw new DAOException("Passed list_anonymmous has ID but it shouldn't (probably insert operation)");
        }
    }

    public static void checkParam(Message message) throws DAOException {
        if (message == null) {
            throw new DAOException("Passed message is null");
        }
    }
}
