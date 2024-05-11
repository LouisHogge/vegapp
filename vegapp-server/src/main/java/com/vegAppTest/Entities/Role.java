package com.vegAppTest.Entities;

import jakarta.persistence.*;
import lombok.Data;

@Data

@Entity // mark the class as JPA entity

// A gardener has only one role for a garden
@Table(name = "role", uniqueConstraints = { @UniqueConstraint(columnNames = { "garden_id", "gardener_id" }) })

public class Role {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "garden_id")
    private Long garden_id;

    @Column(name = "gardener_id")
    private Long gardener_id;

    @Column(name = "role")
    private int role; // 1 for admin and 2 for observer
}