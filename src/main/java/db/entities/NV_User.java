/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.entities;

import db.daos.jdbc.JDBC_utility;
import java.security.SecureRandom;

/**
 *
 * @author Andrei Diaconu
 */
public class NV_User {

    private String email;
    private String password;
    private String salt;
    private String firstname;
    private String lastname;
    private String avatar;
    private String code;
    
    private static final int salt_size = 100;
    private static final int code_size = 50;

    public static int getSalt_size() {
        return salt_size;
    }

    public static int getCode_size() {
        return code_size;
    }

    public NV_User() {
    }
    
    public NV_User(String email, String password, String firstname, String lastname, String avatar, String code) {
        this.email = email;
        this.firstname = firstname;
        this.lastname = lastname;
        this.avatar = avatar;
        this.code = code;
        setPassword(password);
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

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        // this.salt = create random 200len string
        this.salt = JDBC_utility.randomString(salt_size-5);
        // this.password = hash64 on salt+password
        this.password = JDBC_utility.secureHash(password, this.salt);
    }

    public String getSalt() {
        return salt;
    }

    public void setSalt(String salt) {
        this.salt = salt;
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

}
