/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos;

import db.entities.Reg_User;
import db.exceptions.DAOException;

/**
 *
 * @author Andrei Diaconu
 */
public interface Reg_UserDAO extends DAO<Reg_User, String> {

    public Reg_User getByEmailAndPassword(String email, String password) throws DAOException;
}
