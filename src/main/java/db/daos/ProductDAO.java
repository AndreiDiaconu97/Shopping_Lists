/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos;

import db.daos.jdbc.JDBC_utility.SortBy;
import db.entities.Product;
import db.entities.Prod_category;
import db.entities.User;
import db.exceptions.DAOException;
import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public interface ProductDAO extends DAO<Product, Integer> {
    public List<Product> filterProducts(String name, Prod_category prod_category, User user, boolean includePublics, SortBy sortby) throws DAOException;
}
