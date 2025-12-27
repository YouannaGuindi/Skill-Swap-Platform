package com.ProjAdvAndWeb.model;


public class Skill {
    private int id;
    private java.lang.String name;
    private java.lang.String category;
    private java.lang.String description;
    private java.lang.String offeredUsername; // Needed for linking a skill instance to a user

	public Skill() {
    }

    public Skill(int id, String name, String category, String description, String offeredUsername) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.description = description;
        this.offeredUsername=offeredUsername;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getOfferedUsername() {
		return offeredUsername;
	}

	public void setOfferedUsername(String offeredUsername) {
		this.offeredUsername = offeredUsername;
	}

}