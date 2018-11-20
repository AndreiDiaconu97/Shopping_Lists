/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.entities;

import java.io.Serializable;

/**
 *
 * @author Andrei Diaconu
 */
public class List_category implements Serializable{

    private String name;
    private String description;
    private String logo;

    public List_category() {
    }

    public List_category(String name, String description, String logo) {
        this.name = name;
        this.description = description;
        this.logo = logo;
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

    @Override
    public boolean equals(Object obj) {
        if(obj==null){
            return false;
        }
        List_category obj_c = (List_category) obj;
        return this.getName().equals(obj_c.getName());
    }

    @Override
    public int hashCode() {
        return this.getName().hashCode();
    }
    
    
}
