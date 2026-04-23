package com.postgres.demopg.models;
import java.util.Set;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Entity
@Table( name = "tweets")

public class Tweet {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;


  @NotBlank
  @Size(max = 140)
  private String tweet;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "posted_by", referencedColumnName = "id")
  @JsonIgnore
  private User postedBy;



  public User getPostedBy() {
    return postedBy;
  }

  public void setPostedBy(User postedBy) {
    this.postedBy = postedBy;
  }

  public Tweet() {
  }

  public  Tweet (String tweet) {
    this.tweet = tweet;
  }

  // getters and setters

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }


  public String getTweet() {
    return tweet;
}


  public void setTweet(String tweet) {
    this.tweet = tweet;
  }

  @OneToMany(mappedBy = "tweet")
  Set<TweetReaction> likes;

  public Set<TweetReaction> getLikes() {
    return likes;
  }

  public void setLikes(Set<TweetReaction> likes) {
    this.likes = likes;
  }



}