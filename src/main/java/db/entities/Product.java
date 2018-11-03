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
public class Product {

    private PrimaryKey primaryKey;
    private Integer id;
    private String description;
    private String logo;
    private String photo;
    private Float rating;
    private Integer num_votes;
    private Boolean is_public;
    //private List<Shop_list_NR> shop_l_NR;  // not meant for user display
    //private List<Shopping_list> shop_l;    // not meant for user display

    public String getName() {
        return primaryKey.getName();
    }

    public void setName(String name) {
        this.primaryKey.setName(name);
    }

    public String getCategory() {
        return primaryKey.getCategory();
    }

    public void setCategory(String category) {
        this.primaryKey.setCategory(category);
    }

    public String getCreator() {
        return primaryKey.getCreator();
    }

    public void setCreator(String creator) {
        this.primaryKey.setCreator(creator);
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

    public class PrimaryKey {

        private String name;
        private String category;
        private String creator;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getCategory() {
            return category;
        }

        public void setCategory(String category) {
            this.category = category;
        }

        public String getCreator() {
            return creator;
        }

        public void setCreator(String creator) {
            this.creator = creator;
        }
    }
}
