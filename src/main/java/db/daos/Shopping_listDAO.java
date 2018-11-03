/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos;

import db.entities.Product;
import db.entities.Reg_User;
import db.entities.Shopping_list;
import db.entities.Shopping_list.PrimaryKey;
import db.exceptions.DAOException;
import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public interface Shopping_listDAO extends DAO<Shopping_list, PrimaryKey> {

    public Integer insert(Shopping_list shoppingList) throws DAOException;

    public boolean linkShoppingListToReg_User(Shopping_list shoppingList, Reg_User user) throws DAOException;

    public Shopping_list getByID(Integer id) throws DAOException;

    public List<Shopping_list> getByOwner(String owner) throws DAOException;

    public List<Reg_User> getListUsers(Shopping_list shopping_list) throws DAOException;

    public List<Product> getListProducts(Shopping_list shopping_list) throws DAOException;
}
