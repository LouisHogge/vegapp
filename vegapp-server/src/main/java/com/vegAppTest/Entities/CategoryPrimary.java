
package com.vegAppTest.Entities;

import jakarta.persistence.*;
import lombok.Data;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Data

@Entity // mark the class as JPA entity
// A garden has only one primary category with a particular name
@Table(name = "category_primary", uniqueConstraints = { @UniqueConstraint(columnNames = { "garden_id", "name" }) })
public class CategoryPrimary {

    @Id // mark the field id as the primary key of the entity
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "name", length = 255)
    private String name;

    /* Relation Garden - Category */
    @ManyToOne
    @JoinColumn(name = "garden_id")
    @JsonIgnore
    private Garden garden;

    @Transient
    private Long garden_id;

    /* Relation Category - Veggie */
    @OneToMany(fetch = FetchType.LAZY, mappedBy = "category_primary", cascade = CascadeType.ALL)
    @JsonIgnore
    private List<Veggie> veggies;

    public CategoryPrimary() {

    }

    public CategoryPrimary(String name) {
        this.name = name;
    }

}
