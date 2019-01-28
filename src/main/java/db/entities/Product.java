/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.entities;

import java.io.Serializable;
import java.util.Collection;
import java.util.Objects;
import org.json.JSONArray;
import org.json.JSONObject;

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
    private Float rating;
    private Integer num_votes;

    public Product() {
    }

    public Product(String name, Prod_category category, User creator, String description) {
        this.name = name;
        this.category = category;
        this.creator = creator;
        this.description = description;
        this.rating = 0F;
        this.num_votes = 0;
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
        if (this.creator == null) {
            this.creator = creator;
        }
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

    public JSONObject toJSON() {
        JSONObject obj = new JSONObject();
        obj.put("id", id);
        obj.put("name", name);
        obj.put("category", Prod_category.toJSON(category));
        obj.put("description", description);
        obj.put("creator", User.toJSON(creator));
        obj.put("rating", rating);
        obj.put("num_votes", num_votes);
        return obj;
    }

    public static JSONObject toJSON(Product product) {
        return product==null ? null : product.toJSON();
    }
    
    public static JSONArray toJSON(Collection<Product> coll){
        JSONArray arr = new JSONArray();
        for(Product p : coll){
            arr.put(Product.toJSON(p));
        }
        return arr;
    }
}
