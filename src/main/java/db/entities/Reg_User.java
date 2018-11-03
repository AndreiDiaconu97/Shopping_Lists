/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.entities;

import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public class Reg_User {

    private Integer id;
    private String email;
    private String password;
    private String avatar;
    private String name;
    private Boolean is_admin;
    private List<Product> products_created;
    private List<Shopping_list> owning_shop_lists;
    private List<Shopping_list> shared_shop_lists;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
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
        this.password = password;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Boolean getIs_admin() {
        return is_admin;
    }

    public void setIs_admin(Boolean is_admin) {
        this.is_admin = is_admin;
    }

    public List<Product> getProducts_created() {
        return products_created;
    }

    public void setProducts_created(List<Product> products_created) {
        this.products_created = products_created;
    }

    public List<Shopping_list> getOwning_shop_lists() {
        return owning_shop_lists;
    }

    public void setOwning_shop_lists(List<Shopping_list> owning_shop_lists) {
        this.owning_shop_lists = owning_shop_lists;
    }

    public List<Shopping_list> getShared_shop_lists() {
        return shared_shop_lists;
    }

    public void setShared_shop_lists(List<Shopping_list> shared_shop_lists) {
        this.shared_shop_lists = shared_shop_lists;
    }

}
