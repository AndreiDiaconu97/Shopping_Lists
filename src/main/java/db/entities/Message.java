/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db.entities;

import java.sql.Timestamp;
import java.util.Objects;

/**
 *
 * @author Andrea Mattè
 */
public class Message {

    private List_reg list;
    private User user;
    private Timestamp time;
    private String text;
    private boolean isLog;

    public List_reg getList() {
        return list;
    }

    public void setList(List_reg list) {
        this.list = list;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Timestamp getTime() {
        return time;
    }

    public void setTime(Timestamp time) {
        this.time = time;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public boolean getIsLog() {
        return isLog;
    }

    public void setIsLog(boolean isLog) {
        this.isLog = isLog;
    }

    @Override
    public int hashCode() {
        int hash = 7;
        hash = 23 * hash + Objects.hashCode(this.list);
        hash = 23 * hash + Objects.hashCode(this.user);
        hash = 23 * hash + Objects.hashCode(this.time);
        hash = 23 * hash + Objects.hashCode(this.text);
        hash = 23 * hash + (this.isLog ? 1 : 0);
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
        final Message other = (Message) obj;
        if (this.isLog != other.isLog) {
            return false;
        }
        if (!Objects.equals(this.text, other.text)) {
            return false;
        }
        if (!Objects.equals(this.list, other.list)) {
            return false;
        }
        if (!Objects.equals(this.user, other.user)) {
            return false;
        }
        if (!Objects.equals(this.time, other.time)) {
            return false;
        }
        return true;
    }
    
    
}
