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
public class Prod_category implements Serializable {

    private Integer id;
    private String name;
    private String description;
    private Integer renewtime;

    public Prod_category() {
    }

    public Prod_category(String name, String description, Integer renewtime) {
        this.name = name;
        this.description = description;
        this.renewtime = renewtime;
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

    public Integer getRenewtime() {
        return renewtime;
    }

    public void setRenewtime(Integer renewtime) {
        this.renewtime = renewtime;
    }

    @Override
    public int hashCode() {
        int hash = 7;
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
        final Prod_category other = (Prod_category) obj;
        if (!Objects.equals(this.id, other.id)) {
            return false;
        }
        return true;
    }

    public JSONObject toJSON() {
        JSONObject obj = new JSONObject();
        obj.put("id", id);
        obj.put("name", name);
        obj.put("description", description);
        obj.put("renewtime", renewtime);
        return obj;
    }

    public static JSONObject toJSON(Prod_category prod_category) {
        return prod_category == null ? null : prod_category.toJSON();
    }

    public static JSONArray toJSON(Collection<Prod_category> coll) {
        JSONArray arr = new JSONArray();
        for (Prod_category p_c : coll) {
            arr.put(Prod_category.toJSON(p_c));
        }
        return arr;
    }
}
