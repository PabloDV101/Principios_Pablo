package com.postgres.demopg.repository;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.postgres.demopg.models.TweetReaction;


@Repository
public interface TweetReactionRepository extends JpaRepository<TweetReaction, Long> {

}