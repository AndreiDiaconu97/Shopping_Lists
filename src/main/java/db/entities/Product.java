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
    private List<Shop_list_NR> shop_l_NR;  // not meant for user display
    private List<Shopping_list> shop_l;    // not meant for user display

    public String getName() {
        return primaryKey.getName();
    }

    public void setName(String name) {
        this.primaryKey.setName(name);
    }

    public Prod_category getCategory() {
        return primaryKey.getCategory();
    }

    public void setCategory(Prod_category category) {
        this.primaryKey.setCategory(category);
    }

    public Reg_User getCreator() {
        return primaryKey.getCreator();
    }

    public void setCreator(Reg_User creator) {
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

    public List<Shop_list_NR> getShop_l_NR() {
        return shop_l_NR;
    }

    public void setShop_l_NR(List<Shop_list_NR> shop_l_NR) {
        this.shop_l_NR = shop_l_NR;
    }

    public List<Shopping_list> getShop_l() {
        return shop_l;
    }

    public void setShop_l(List<Shopping_list> shop_l) {
        this.shop_l = shop_l;
    }

    public class PrimaryKey {

        private String name;
        private Prod_category category;
        private Reg_User creator;

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

        public Reg_User getCreator() {
            return creator;
        }

        public void setCreator(Reg_User creator) {
            this.creator = creator;
        }
    }
}
