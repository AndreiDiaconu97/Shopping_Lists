/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos;

import db.entities.NV_User;
import db.entities.User;
import db.exceptions.DAOException;

/**
 *
 * @author Andrei Diaconu
 */
public interface NV_UserDAO extends DAO<NV_User, String> {

    public NV_User getByEmail(String email) throws DAOException;

    public User validateUsingEmailAndCode(String email, String code) throws DAOException;

}
