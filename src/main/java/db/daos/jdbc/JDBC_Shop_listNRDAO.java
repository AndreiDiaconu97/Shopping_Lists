/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.daos.jdbc;

import db.daos.Shop_list_NRDAO;
import db.entities.Shop_list_NR;
import db.exceptions.DAOException;
import java.sql.Connection;
import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public class JDBC_Shop_listNRDAO extends JDBC_DAO<Shop_list_NR, Integer> implements Shop_list_NRDAO {

    public JDBC_Shop_listNRDAO(Connection con) {
        super(con);
    }

    @Override
    public Long getCount() throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public Shop_list_NR getByPrimaryKey(Integer primaryKey) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public List<Shop_list_NR> getAll() throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void insert(Shop_list_NR entity) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public void delete(Shop_list_NR entity) throws DAOException {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

}
