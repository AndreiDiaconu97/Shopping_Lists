package db.daos;

import db.exceptions.DAOException;
import db.exceptions.DAOFactoryException;
import java.util.List;

public interface DAO<ENTITY_CLASS, PRIMARY_KEY_CLASS> {

    public Long getCount() throws DAOException;

    public List<ENTITY_CLASS> getAll() throws DAOException;
    
    public ENTITY_CLASS getByPrimaryKey(PRIMARY_KEY_CLASS primaryKey) throws DAOException;

    public void insert(ENTITY_CLASS entity) throws DAOException;

    public void delete(ENTITY_CLASS entity) throws DAOException;

    public void update(ENTITY_CLASS entity) throws DAOException;

    public <DAO_CLASS extends DAO> DAO_CLASS getDAO(Class<DAO_CLASS> daoClass) throws DAOFactoryException;
}
