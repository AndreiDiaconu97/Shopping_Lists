/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.entities;

import db.daos.jdbc.JDBC_utility;
import java.io.Serializable;
import java.security.SecureRandom;
import java.util.Objects;
import org.springframework.security.crypto.bcrypt.BCrypt;

/**
 *
 * @author Andrei Diaconu
 */
public class NV_User implements Serializable{

    private String email;
    private String hashed_password;
    private String firstname;
    private String lastname;
    private String avatar;
    private String code;
    
    private static final int CODE_SIZE = 50;

    public static int getCODE_SIZE() {
        return CODE_SIZE;
    }

    public NV_User() {
    }
    
    public NV_User(String email, String normal_password, String firstname, String lastname, String avatar) {
        this.email = email;
        this.firstname = firstname;
        this.lastname = lastname;
        this.avatar = avatar;
        generateCode();
        createHashedPassword(normal_password);
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getHashed_password() {
        return hashed_password;
    }
    
    public void setHashed_password(String hashed_password){
        this.hashed_password = hashed_password;
    }

    private void createHashedPassword(String password) {
        if(password == null){
            System.err.println("Creating hash for null psw!!");
            return;
        }
        this.hashed_password = BCrypt.hashpw(password, BCrypt.gensalt());
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public String getFirstname() {
        return firstname;
    }

    public void setFirstname(String firstname) {
        this.firstname = firstname;
    }

    public String getLastname() {
        return lastname;
    }

    public void setLastname(String lastname) {
        this.lastname = lastname;
    }

    private void generateCode() {
        this.code = JDBC_utility.randomString(CODE_SIZE);
    }

    @Override
    public int hashCode() {
        int hash = 3;
        hash = 43 * hash + Objects.hashCode(this.email);
        return hash;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final NV_User other = (NV_User) obj;
        if (!Objects.equals(this.email, other.email)) {
            return false;
        }
        return true;
    }

}
