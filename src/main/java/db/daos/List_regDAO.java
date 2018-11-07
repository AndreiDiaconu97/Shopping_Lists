/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos;

import db.entities.Product;
import db.entities.Reg_User;
import db.entities.List_reg;
import db.exceptions.DAOException;
import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public interface List_regDAO extends DAO<List_reg, Integer> {

    public boolean linkShoppingListToReg_User(List shoppingList, Reg_User user) throws DAOException;

    public List<List_reg> getByOwner(Integer owner) throws DAOException;

    public List<Reg_User> getUsers(List shopping_list) throws DAOException;

    public List<Product> getProducts(List shopping_list) throws DAOException;
}
