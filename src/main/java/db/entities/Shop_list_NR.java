/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.entities;

import java.sql.Timestamp;
import java.util.List;

/**
 *
 * @author Andrei Diaconu
 */
public class Shop_list_NR {

    private Integer ID;
    private String name;
    private String description;
    private String image;
    private String category;
    private Timestamp last_seen;
    //private List<Product> products;

    public Integer getID() {
        return ID;
    }

    public void setID(Integer ID) {
        this.ID = ID;
    }

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

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public Timestamp getLast_seen() {
        return last_seen;
    }

    public void setLast_seen(Timestamp last_seen) {
        this.last_seen = last_seen;
    }
}
