/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos;

import db.daos.jdbc.JDBC_utility.AccessLevel;
import db.entities.Product;
import db.entities.User;
import db.entities.List_reg;
import db.exceptions.DAOException;
import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public interface UserDAO extends DAO<User, Integer> {

    public User getByEmailAndPassword(String email, String password) throws DAOException;

    public User getByEmail(String email) throws DAOException;

    public List<Product> getProductsCreated(User user) throws DAOException;

    public List<List_reg> getOwnedLists(User user) throws DAOException;

    public List<List_reg> getSharedLists(User user) throws DAOException;

    public AccessLevel getAccessLevel(User user, List_reg list_reg) throws DAOException;
    
    public List<User> getFriends(User user) throws DAOException;
    
    public List<List_reg> getInvites(User user) throws DAOException;

}
