package com.vegAppTest.Entities;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
// A plot has only one vegetable planted at a particular location
@Table(name = "plant", uniqueConstraints = { @UniqueConstraint(columnNames = { "plot_id", "vegetable_location" }) })
public class Plant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "plot_id")
    private Long plot_id;

    @Column(name = "veggie_id")
    private Long veggie_id;

    @Column(name = "vegetable_location") // where is the veggie for ex 1.2 (1st principal line 2nd secondary line)
    private String vegetable_location;

    public void setPlotId(Long plot_id) {
        this.plot_id = plot_id;
    }

    public void setVegetableId(Long veggie_id) {
        this.veggie_id = veggie_id;
    }

    public void setLocation(String vegetable_location) {
        this.vegetable_location = vegetable_location;
    }

}
