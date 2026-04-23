package com.postgres.demopg.repository;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.postgres.demopg.models.Reaction;


@Repository
public interface ReactionRepository extends JpaRepository<Reaction, Long> {

}