/*
 * AA 2017-2018
 * Introduction to Web Programming
 * Lab 07 - ShoppingList List
 * UniTN
 */
package db.entities;

/**
 * The entity that describe a {@code shopping-list} entity.
 * 
 * @author Stefano Chirico &lt;stefano dot chirico at unitn dot it&gt;
 * @since 2018.03.30
 */
public class ShoppingList {
    private Integer id;
    private String name;
    private String description;

    /**
     * Returns the primary key of this to-do entity.
     * @return the id of the shopping-list entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public Integer getId() {
        return id;
    }
    
    /**
     * Sets the new primary key of this shopping-list entity.
     * @param id the new id of this shopping-list entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public void setId(Integer id) {
        this.id = id;
    }

    /**
     * Returns the name of this to-do entity.
     * @return the name of this to-do entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the new name of this to-do entity.
     * @param name the new name of this to-do entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * Returns the description of this to-do entity.
     * @return the description of this to-do entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public String getDescription() {
        return description;
    }

    /**
     * Sets the new description of this to-do entity.
     * @param description the new description of this to-do entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public void setDescription(String description) {
        this.description = description;
    }
}
