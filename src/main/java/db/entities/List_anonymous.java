/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.entities;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.Collection;
import java.util.Objects;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 *
 * @author Andrei Diaconu
 */
public class List_anonymous implements Serializable {

    private Integer id;
    private String name;
    private String description;
    private List_category category;
    private Timestamp last_seen;
    private Integer purchased;
    private Integer total;

    public List_anonymous() {
    }

    public List_anonymous(String name, String description, List_category category) {
        this.name = name;
        this.description = description;
        this.category = category;
        this.purchased = 0;
        this.total = 0;
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

    public Integer getPurchased() {
        return purchased;
    }

    public void setPurchased(Integer purchased) {
        this.purchased = purchased;
    }

    public Integer getTotal() {
        return total;
    }

    public void setTotal(Integer total) {
        this.total = total;
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
    
    public JSONObject toJSON() {
        JSONObject obj = new JSONObject();
        obj.put("id", id);
        obj.put("name", name);
        obj.put("category", List_category.toJSON(category));
        obj.put("description", description);
        obj.put("purchased", purchased);
        obj.put("total", total);
        return obj;
    }

    public static JSONObject toJSON(List_anonymous list) {
        return list == null ? null : list.toJSON();
    }

    public static JSONArray toJSON(Collection<List_anonymous> coll) {
        JSONArray arr = new JSONArray();
        for (List_anonymous list : coll) {
            arr.put(List_anonymous.toJSON(list));
        }
        return arr;
    }
}
