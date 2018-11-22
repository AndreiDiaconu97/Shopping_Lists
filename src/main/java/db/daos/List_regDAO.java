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

    public void shareShoppingListToReg_User(List_reg shoppingList, Reg_User user) throws DAOException;

    public List<Reg_User> getReg_UsersSharedTo(List_reg list_reg) throws DAOException;

    public List<List_reg> getByOwner(Integer owner) throws DAOException;

    public List<Product> getProducts(List_reg list_reg) throws DAOException;
    
    public void insertProduct(List_reg list_reg, Product product) throws DAOException;
    
    public Boolean isPurchased(List_reg list_reg, Product product) throws DAOException;
}
