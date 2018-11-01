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
public class List_category {

    private String name;
    private String description;
    private String image;
    private List<Shop_list_NR> shop_l_NR;   // not meant for user display
    private List<Shopping_list> shop_l;     // not meant for user display

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

    public List<Shop_list_NR> getShop_l_NR_found_in() {
        return shop_l_NR;
    }

    public void setShop_l_NR_found_in(List<Shop_list_NR> shop_l_NR_found_in) {
        this.shop_l_NR = shop_l_NR_found_in;
    }

    public List<Shopping_list> getShop_l_found_in() {
        return shop_l;
    }

    public void setShop_l_found_in(List<Shopping_list> shop_l_found_in) {
        this.shop_l = shop_l_found_in;
    }

}
