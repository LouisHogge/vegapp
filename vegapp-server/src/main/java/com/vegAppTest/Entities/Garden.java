package com.vegAppTest.Entities;

import jakarta.persistence.*;
import lombok.Data;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Data

@Entity // mark the class as JPA entity
// A gardener has only one garden with a particular name
@Table(name = "garden", uniqueConstraints = { @UniqueConstraint(columnNames = { "name", "gardener_id" }) })
public class Garden {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "name", length = 255)
    private String name;

    /* Relation Garden - Plot */
    @OneToMany(fetch = FetchType.LAZY, mappedBy = "garden", cascade = CascadeType.ALL)
    @JsonIgnore
    private List<Plot> plots;

    /* Relation Garden - Plot */
    @OneToMany(fetch = FetchType.LAZY, mappedBy = "garden", cascade = CascadeType.ALL)
    @JsonIgnore
    private List<CategoryPrimary> category_primaries;

    /* Relation Garden - Plot */
    @OneToMany(fetch = FetchType.LAZY, mappedBy = "garden", cascade = CascadeType.ALL)
    @JsonIgnore
    private List<CategorySecondary> category_secondaries;

    /* Relation Gardener - Garden */
    @ManyToOne
    @JoinColumn(name = "gardener_id")
    @JsonIgnore
    private Gardener gardener;

    public Garden() {
        this.name = null;
    }

    public Garden(Long id, String name, Gardener gardener) {
        this.id = id;
        this.name = name;
        this.gardener = gardener;
    }

}