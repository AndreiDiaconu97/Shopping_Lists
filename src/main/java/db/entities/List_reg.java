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
public class List_reg implements Serializable {

    private Integer id;
    private String name;
    private User owner;
    private List_category category;
    private String description;

    public List_reg() {
    }

    public List_reg(String name, User owner, List_category category, String description) {
        this.name = name;
        this.owner = owner;
        this.category = category;
        this.description = description;
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

    public User getOwner() {
        return owner;
    }

    public void setOwner(User owner) {
        if (owner == null) {
            this.owner = owner;
        }
    }

    public List_category getCategory() {
        return category;
    }

    public void setCategory(List_category category) {
        this.category = category;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
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
        final List_reg other = (List_reg) obj;
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
        obj.put("owner", User.toJSON(owner));
        return obj;
    }

    public static JSONObject toJSON(List_reg list) {
        return list == null ? null : list.toJSON();
    }

    public static JSONArray toJSON(Collection<List_reg> coll) {
        JSONArray arr = new JSONArray();
        for (List_reg list : coll) {
            arr.put(List_reg.toJSON(list));
        }
        return arr;
    }
}
