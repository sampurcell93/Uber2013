Decisions, Reasoning
====================
The biggest engineering decision I felt I had to make here was how to store the data here. I knew that I could pull from the SFdata API whenever I wanted to, but unfortunately this data doesn't come with coordinates and I had to rely on Google Maps geocoding. I decided to store each object from the API in a mongoDB database. I understand that there are pros and cons to this choice, but I wanted to use a system that would allow me to get up and running quickly and allow me to write all of my data (pulled from Google and SODATA) quickly. I also didn't see much relational stuff going on in the scope of this project. While at small scales, I do know that Mongo's read capabilities are limited, so I plan to do my autocompletion on the client.

I reasoned that because the last update to this data set was in February of 2013, there was no need to pull from the API every time the page was loaded - the data is relatively static. A feature in the future could be a backend "cron" type job to check for updates to the data set, or a button on the interface to check for updates.

Architecture
===========
I saw the need for a model hierarchy here. We have the obvious data model, a movie, but we also have multiple copies of each model in the dataset, with only the location changed. Therefore, it seemed sensible to blend all of the copies into one model, whose coordinates are a collection of location models. This way, we can interact with each location as a separate model, while keeping them unified under a single movie. This allows for features like location favoriting, custom icons for movies, and all kinds of other interaction with locations. I have provided a mongodump if you care to look at the data structure (though it's echoed in the client).

Additionally, I decided to do most of my algorithms on the front end. The reasoning here is that since the page should display ALL movie data on page load, I would have all of the data stored in the client anyway. I used Twitter's plugin typeahead, because I felt reinventing the wheel here would be overkill. This adoption was not without its challenges, however. I did not encounter a way to easily link each autocomplete result with its Backbone model (either a location or a movie), so I went into the twitter source and wrote a simple _makeBackbone function which parses the option, uses the global hashtable to make a view, and link the view up to the element. This way, we can organize our events a lot better, it only took 23 lines of code (typeahead.js 722-745), and better, all references in autocomplete are still linked to their model.

Data Structures
===============
On the server, my data structures are simple: Each movie has a writer, producer, title, and the rest of the string attributes - but it also has an array of locations, each with a title, and a set of coordinates. There is one problem with this: Movies often share filming locations, and there is therefore object replication in my database. Because Mongo is nonrelational, I decided to solve this problem on the client using hashtables.



Other Notes
==========
I obtained all of the coordinate data from google maps, using a throttling function to ensure that I didn't overload my quota. Maps did not provide coordinates for all of the locations in the set, but it got a significant amount of them. The 890 objects in the original set were compressed to 247 models, most with location data. 