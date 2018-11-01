/*
 * AA 2017-2018
 * Introduction to Web Programming
 * Lab 07 - ShoppingList List
 * UniTN
 */
package db.entities;

/**
 * The entity that describe a {@code user} entity.
 * 
 * @author Stefano Chirico &lt;stefano dot chirico at unitn dot it&gt;
 * @since 2018.03.30
 */
public class User {
    private Integer id;
    private String email;
    private String password;
    private String firstName;
    private String lastName;
    private Boolean isAdmin;
    private Integer shoppingListsCount;
    
    public Boolean getIsAdmin() {
        return isAdmin;
    }

    public void setIsAdmin(Boolean isAdmin) {
        this.isAdmin = isAdmin;
    }

    /**
     * Returns the primary key of this user entity.
     * @return the id of the user entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public Integer getId() {
        return id;
    }
    
    /**
     * Sets the new primary key of this user entity.
     * @param id the new id of this user entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public void setId(Integer id) {
        this.id = id;
    }
    
    /**
     * Returns the unique email of this user entity.
     * @return the email of this user entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public String getEmail() {
        return email;
    }

    /**
     * Sets the new email of this user entity.
     * @param email the new email of this user entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public void setEmail(String email) {
        this.email = email;
    }

    /**
     * Returns the password of this user entity.
     * @return the password of this user entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public String getPassword() {
        return password;
    }

    /**
     * Sets the new password of this user entity.
     * @param password the new password of this user entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public void setPassword(String password) {
        this.password = password;
    }

    /**
     * Returns the first name of this user entity.
     * @return the first name of this user entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public String getFirstName() {
        return firstName;
    }

    /**
     * Sets the new first name of this user entity.
     * @param firstName the new first name of this user entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    /**
     * Returns the last name of this user entity.
     * @return the last name of this user entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public String getLastName() {
        return lastName;
    }

    /**
     * Sets the new last name of this user entity.
     * @param lastName the new last name of this user entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public void setLastName(String lastName) {
        this.lastName = lastName;
    }
    
    /**
     * Returns the number of shopping-lists shared with this user entity.
     * @return the number of shopping-lists shared with this user entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public Integer getShoppingListsCount() {
        return shoppingListsCount;
    }
    
    /**
     * Sets the new amount of shopping-lists shared with this user entity.
     * @param shoppingListsCount the new amount of shopping-lists shared with this user entity.
     * 
     * @author Stefano Chirico
     * @since 1.0.180330
     */
    public void setShoppingListsCount(Integer shoppingListsCount) {
        this.shoppingListsCount = shoppingListsCount;
    }
}