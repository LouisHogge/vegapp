package com.vegAppTest.Entities;

import jakarta.persistence.*;
import lombok.Data;

import java.util.Date;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Data

@Entity // mark the class as JPA entity
// A garden has only one plot with a particular name and a particular version
@Table(name = "plot", uniqueConstraints = { @UniqueConstraint(columnNames = { "name", "version", "garden_id" }) })
public class Plot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "name", length = 255) // horizontal or vertical for principal lines
    private String name;

    @Column(name = "nb_of_lines")
    private String nb_of_lines; // -> ex 1.0/2.1/3.5

    @Temporal(TemporalType.DATE) // For date only
    @Column(name = "creation_date")
    private Date creation_date;

    @Column(name = "version")
    private int version;

    @Column(name = "orientation") // horizontal (0) or vertical (1) for principal lines
    private int orientation;

    @Column(name = "in_calendar") // plot shown in calendar or not
    private int in_calendar; // 0 or 1

    @Column(name = "note", length = 1024)
    private String note;

    /* Relation Garden - Plot */
    @ManyToOne
    @JoinColumn(name = "garden_id")
    @JsonIgnore
    private Garden garden;

    @Transient
    private Long garden_id; 

    /* Relation Plot - Veggie */
    @ManyToMany
    @JoinTable(name = "plant", joinColumns = { @JoinColumn(name = "plot_id") }, inverseJoinColumns = {
            @JoinColumn(name = "veggie_id") })
    @JsonIgnore
    private List<Veggie> veggies;

    public Plot() {
        this.name = "";
        this.nb_of_lines = "1.0/2.1/3.5";
        this.creation_date = new Date();
        this.version = 0;
        this.orientation = 0;
        this.in_calendar = 0;
        this.note = "";
    }

    public List<Veggie> getVeggies() {
        return veggies;
    }
}