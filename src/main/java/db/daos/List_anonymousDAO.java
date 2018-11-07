/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos;

import db.entities.Product;
import db.entities.List_anonymous;
import db.exceptions.DAOException;
import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public interface List_anonymousDAO extends DAO<List_anonymous, Integer> {

    public List<Product> getProducts(List_anonymous list_anonymous) throws DAOException;

}