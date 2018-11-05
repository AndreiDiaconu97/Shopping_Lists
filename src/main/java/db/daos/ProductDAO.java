/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos;

import db.entities.Product;
import db.entities.Product.PrimaryKey;
import db.exceptions.DAOException;

/**
 *
 * @author Andrei Diaconu
 */
public interface ProductDAO extends DAO<Product, PrimaryKey> {

    public Product getByID(Integer id) throws DAOException;

}