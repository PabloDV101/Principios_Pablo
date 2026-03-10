package com.postgres.demopg.controllers;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.postgres.demopg.models.Tweet;
import com.postgres.demopg.repository.TweetRepository;

import jakarta.validation.Valid;


@CrossOrigin(origins = "*", maxAge=3600)
@RestController
@RequestMapping("/api/tweets")

public class TweetController{
@Autowired
private TweetRepository tweetRepository;

@GetMapping("")
public Page<Tweet> getTweet(Pageable pageable){
	return tweetRepository.findAll(pageable);

}
@PostMapping("")
public Tweet createTweet(@Valid @RequestBody Tweet tweet) {
    Tweet myTweet = new Tweet(tweet.getTweet());
	tweetRepository.save(myTweet) ;
    
    return tweet;
}

}
