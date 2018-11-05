/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos;

import db.entities.Product;
import db.entities.Reg_User;
import db.entities.Shop_list;
import db.entities.Shop_list.PrimaryKey;
import db.exceptions.DAOException;
import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public interface Shop_listDAO extends DAO<Shop_list, PrimaryKey> {

    public boolean linkShoppingListToReg_User(Shop_list shoppingList, Reg_User user) throws DAOException;

    public Shop_list getByID(Integer id) throws DAOException;

    public List<Shop_list> getByOwner(Integer owner) throws DAOException;

    public List<Reg_User> getListUsers(Shop_list shopping_list) throws DAOException;

    public List<Product> getListProducts(Shop_list shopping_list) throws DAOException;
}
