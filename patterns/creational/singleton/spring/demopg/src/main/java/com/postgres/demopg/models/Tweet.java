package com.postgres.demopg.models;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Entity
@Table(name="tweets")
public class Tweet{
@Id
@GeneratedValue(strategy = GenerationType.IDENTITY)
private Long id;

@NotBlank
@Size(max=140)
private String tweet;
public Tweet(){}
public Tweet (String tweet){
	this.tweet=tweet;
}

public Long getId(){
	return id;
}
public void setId(Long id){
this.id = id;
}

public String getTweet(){
return tweet;
}

public void setTweet(String tweet){
this.tweet=tweet;
}

}
