/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.entities.NV_User;
import db.entities.Product;
import db.entities.Reg_User;
import db.entities.Shopping_list;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 *
 * @author Andrei Diaconu
 */
public class JDBC_utility {

    public static Reg_User resultSetToReg_User(ResultSet rs) throws SQLException {
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

    public static Product resultSetToProduct(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setCategory(rs.getString("CATEGORY"));
        product.setCreator(rs.getString("CREATOR"));
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

    public static Shopping_list resultSetToShopping_list(ResultSet rs) throws SQLException {
        Shopping_list shopping_list = new Shopping_list();
        shopping_list.setCategory(rs.getString("CATEGORY"));
        shopping_list.setDescription(rs.getString("DESCRIPTION"));
        shopping_list.setId(rs.getInt("ID"));
        shopping_list.setImage(rs.getString("LOGO"));
        shopping_list.setName(rs.getString("NAME"));
        shopping_list.setOwner(rs.getString("OWNER"));
        return shopping_list;
    }
    
    public static NV_User resultSetToNV_User(ResultSet rs) throws SQLException {
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
