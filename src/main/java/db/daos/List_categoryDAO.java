/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos;

import db.entities.List_category;
import db.entities.Prod_category;
import db.exceptions.DAOException;
import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public interface List_categoryDAO extends DAO<List_category, Integer> {

    public List<Prod_category> getProd_categories(List_category list_category) throws DAOException;

    public void insertProd_category(List_category list_category, Prod_category prod_category) throws DAOException;

    public void removeProd_category(List_category list_category, Prod_category prod_category) throws DAOException;
}
