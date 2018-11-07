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
    
    private static final int SALT_SIZE = 100;
    private static final int CODE_SIZE = 50;

    public static int getSALT_SIZE() {
        return SALT_SIZE;
    }

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

    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password){
        this.password = password;
    }

    private void createHashedPassword(String password) {
        if(password == null){
            System.err.println("Creating hash for null psw!!");
            return;
        }
        // this.salt = create random 200len string
        this.salt = JDBC_utility.randomString(SALT_SIZE);
        this.password = JDBC_utility.secureHash(password, this.salt);
        System.err.println("CREATED PASSWORD = " + this.password + " USING " + password);
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

    private void generateCode() {
        this.code = JDBC_utility.randomString(CODE_SIZE);
    }

}
