/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.entities;

/**
 *
 * @author Andrei Diaconu
 */
public class Shop_list {

    private PrimaryKey primaryKey = new PrimaryKey();
    private Integer id;
    private String description;
    private String image;

    public String getName() {
        return primaryKey.getName();
    }

    public void setName(String name) {
        this.primaryKey.setName(name);
    }

    public String getOwner() {
        return primaryKey.getOwner();
    }

    public void setOwner(String owner) {
        this.primaryKey.setOwner(owner);
    }

    public String getCategory() {
        return primaryKey.getCategory();
    }

    public void setCategory(String category) {
        this.primaryKey.setCategory(category);
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

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public class PrimaryKey {

        private String name;
        private String owner;
        private String category;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getOwner() {
            return owner;
        }

        public void setOwner(String owner) {
            this.owner = owner;
        }

        public String getCategory() {
            return category;
        }

        public void setCategory(String category) {
            this.category = category;
        }
    }
}
