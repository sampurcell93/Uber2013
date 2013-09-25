About
=====

I've always been partial to a little skeuomorphism, and movie sites are no exception. In fact, I have always felt that movie sites go really well with *shiny skeumorphism*. So much of hollywood is bright and shiny that it seems like a perfect fit. Additionally, the movie industry is all about *new*. New movies are always coming out, and even old movies have the sheen of nostaliga and reverence covering them. So, I immediately gravitated toward shiny.

The real code
=============

I like to use preprocessors for my CSS, Coffeescript for my JS, and Jade for my HTML. Therfore, you'll find all of the stuff I wrote (comments and all), in the following folders:
1. Coffee -> Javascript: public/src
2. SCSS -> CSS: public/sass
3. Jade -> HTML: views

Problems
=========

How do I convert string addresses to lat/long reliably, without running constant calls to Google Maps geocoder (2500 per day maximum)? I decided to use MongoDB to store locations and their data - a hash table of lat long objects. Every time the page is loaded, the server sends back the table, and when each model parses its response, it will only geocode if its location is not in the table. This seems like a fair balance of caching and requesting to me - and I can't just store all of the results from SODATA in my db once and for all, because I don't know when it will update, how often it will update, or when.