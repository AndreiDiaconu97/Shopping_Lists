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
import db.entities.Message;
import db.exceptions.DAOException;
import java.sql.Timestamp;
import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public interface List_regDAO extends DAO<List_reg, Integer> {

    public void shareListToUser(List_reg list_reg, User user, AccessLevel accessLevel) throws DAOException;

    public List<User> getUsersSharedTo(List_reg list_reg) throws DAOException;

    public List<List_reg> getByOwner(User owner) throws DAOException;

    public List<Product> getProducts(List_reg list_reg) throws DAOException;

    public void insertProduct(List_reg list_reg, Product product, Integer amount) throws DAOException;
    
    public void removeProduct(List_reg list_reg, Product product) throws DAOException;

    public Integer getAmountTotal(List_reg list_reg, Product product) throws DAOException;

    public Integer getAmountPurchased(List_reg list_reg, Product product) throws DAOException;
    
    public Timestamp getLastPurchase(List_reg list_reg, Product product) throws DAOException;

    public void updateAmountTotal(List_reg list_reg, Product product, Integer total) throws DAOException;

    public void updateAmountPurchased(List_reg list_reg, Product product, Integer purchased) throws DAOException;

    public void insertMessage(Message message) throws DAOException;

    public List<Message> getMessages(List_reg list_reg) throws DAOException;
    
    public void inviteUser(List_reg list_reg, User user, AccessLevel accessLevel) throws DAOException;
    
    public void cancelInvite(List_reg list_reg, User user) throws DAOException;
    
    public void acceptInvite(List_reg list_reg, User user) throws DAOException;
}
