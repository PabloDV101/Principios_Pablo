package com.postgres.demopg.models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "reactions")
public class Reaction {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  @Enumerated(EnumType.STRING)
  @Column(length = 20)
  private EReaction description;

  public Reaction() {
  }

  public Reaction(EReaction description) {
    this.description = description;
  }

  // getters and setters

  public EReaction getDescription() {
    return description;
  }

  public void setDescription(EReaction description) {
    this.description = description;
  }

}