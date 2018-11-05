/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos;

import db.entities.NV_User;
import db.entities.Product;
import db.entities.Reg_User;
import db.entities.Shopping_list;
import db.exceptions.DAOException;
import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public interface NV_UserDAO extends DAO<NV_User, String> {

    public NV_User getByEmail(String email) throws DAOException;
    
    public NV_User getByCode(String code) throws DAOException;
    
    public Reg_User registerUsingCode(String code) throws DAOException;
    
}
