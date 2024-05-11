package com.vegAppTest.Entities;

import jakarta.persistence.*;
import lombok.Data;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Data

@Entity // mark the class as JPA entity
// A garden has only one secondary category with a particular name
@Table(name = "category_secondary", uniqueConstraints = { @UniqueConstraint(columnNames = { "garden_id", "name" }) })
public class CategorySecondary {

    public enum Color {
        RED,
        GREEN,
        BLUE,
        ORANGE,
        PURPLE,
        YELLOW,
        BROWN,
        GREY,
        WHITE,
        BLACK
    }

    @Id // mark the field id as the primary key of the entity
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "name", length = 255)
    private String name;

    @Column(name = "color")
    @Enumerated(EnumType.STRING)
    private Color color;

    /* Relation Garden - Category */
    @ManyToOne
    @JoinColumn(name = "garden_id")
    @JsonIgnore
    private Garden garden;

    @Transient
    private Long garden_id;

    /* Relation Category - Veggie */
    @OneToMany(mappedBy = "category_secondary", cascade = CascadeType.DETACH)
    @JsonIgnore
    private List<Veggie> veggies;

    public CategorySecondary() {

    }

    public CategorySecondary(String name, Color color) {
        this.name = name;
        this.color = color;
    }

}
