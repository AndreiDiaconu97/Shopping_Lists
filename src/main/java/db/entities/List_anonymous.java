/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.entities;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 *
 * @author Andrei Diaconu
 */
public class List_anonymous implements Serializable{

    private Integer id;
    private String name;
    private String description;
    private String logo;
    private String category;
    private Timestamp last_seen;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
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

    public String getLogo() {
        return logo;
    }

    public void setLogo(String logo) {
        this.logo = logo;
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
