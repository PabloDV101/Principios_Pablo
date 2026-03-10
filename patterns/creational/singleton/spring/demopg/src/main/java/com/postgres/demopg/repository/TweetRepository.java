package com.postgres.demopg.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.postgres.demopg.models.Tweet;

@Repository
public interface TweetRepository extends JpaRepository<Tweet, Long>{

}
