/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.entities;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.Objects;

/**
 *
 * @author Andrei Diaconu
 */
public class List_anonymous implements Serializable {

    private Integer id;
    private String name;
    private String description;
    private String logo;
    private List_category category;
    private Timestamp last_seen;

    public List_anonymous() {
    }

    public List_anonymous(String name, String description, String logo, List_category category, Timestamp last_seen) {
        this.name = name;
        this.description = description;
        this.logo = logo;
        this.category = category;
        this.last_seen = last_seen;
    }

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

    public List_category getCategory() {
        return category;
    }

    public void setCategory(List_category category) {
        this.category = category;
    }

    public Timestamp getLast_seen() {
        return last_seen;
    }

    public void setLast_seen(Timestamp last_seen) {
        this.last_seen = last_seen;
    }

    @Override
    public int hashCode() {
        int hash = 3;
        hash = 83 * hash + Objects.hashCode(this.id);
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
        final List_anonymous other = (List_anonymous) obj;
        if (!Objects.equals(this.id, other.id)) {
            return false;
        }
        return true;
    }
}
