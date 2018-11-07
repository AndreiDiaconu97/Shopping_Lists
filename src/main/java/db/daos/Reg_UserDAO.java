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
public interface Reg_UserDAO extends DAO<Reg_User, Integer> {

    public Reg_User getByEmailAndPassword(String email, String password) throws DAOException;

    public Reg_User getByEmail(String email) throws DAOException;

    public List<Product> getProductsCreated(Reg_User reg_user) throws DAOException;

    public List<List_reg> getOwningShopLists(Reg_User reg_user) throws DAOException;

    public List<List_reg> getShopLists(Reg_User reg_user) throws DAOException;

}
