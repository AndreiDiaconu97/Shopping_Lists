/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.entities;

import java.io.Serializable;
import java.util.Objects;

/**
 *
 * @author Andrei Diaconu
 */
public class Product implements Serializable {

    private Integer id;
    private String name;
    private Prod_category category;
    private User creator;
    private String description;
    private String logo;
    private String photo;
    private Float rating;
    private Integer num_votes;
    private Boolean is_public;

    public Product() {
    }

    public Product(String name, Prod_category category, User creator, String description, String logo, String photo, Boolean is_public) {
        this.name = name;
        this.category = category;
        this.creator = creator;
        this.description = description;
        this.logo = logo;
        this.photo = photo;
        this.is_public = is_public;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Prod_category getCategory() {
        return category;
    }

    public void setCategory(Prod_category category) {
        this.category = category;
    }

    public User getCreator() {
        return creator;
    }

    public void setCreator(User creator) {
        this.creator = creator;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
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

    public String getPhoto() {
        return photo;
    }

    public void setPhoto(String photo) {
        this.photo = photo;
    }

    public Float getRating() {
        return rating;
    }

    public void setRating(Float rating) {
        this.rating = rating;
    }

    public Integer getNum_votes() {
        return num_votes;
    }

    public void setNum_votes(Integer num_votes) {
        this.num_votes = num_votes;
    }

    public Boolean getIs_public() {
        return is_public;
    }

    public void setIs_public(Boolean is_public) {
        this.is_public = is_public;
    }

    @Override
    public int hashCode() {
        int hash = 7;
        hash = 47 * hash + Objects.hashCode(this.id);
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
        final Product other = (Product) obj;
        if (!Objects.equals(this.id, other.id)) {
            return false;
        }
        return true;
    }

}
