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
public class Shopping_list {

    private String name;
    private String description;
    private String image;
    private Reg_User owner;
    private List_category category;
    private List<Reg_User> users;
    private List<Product> products;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public Reg_User getOwner() {
        return owner;
    }

    public void setOwner(Reg_User owner) {
        this.owner = owner;
    }

    public List_category getCategory() {
        return category;
    }

    public void setCategory(List_category category) {
        this.category = category;
    }

    public List<Reg_User> getUsers() {
        return users;
    }

    public void setUsers(List<Reg_User> users) {
        this.users = users;
    }

    public List<Product> getProducts() {
        return products;
    }

    public void setProducts(List<Product> products) {
        this.products = products;
    }
}
