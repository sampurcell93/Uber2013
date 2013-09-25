Decisions, Reasoning
====================
The biggest engineering decision I felt I had to make here was how to store the data here. I knew that I could pull from the SFdata API whenever I wanted to, but unfortunately this data doesn't come with coordinates and I had to rely on Google Maps geocoding. I decided to store each object from the API in a mongoDB database. I understand that there are pros and cons to this choice, but I wanted to use a system that would allow me to get up and running quickly and allow me to write all of my data (pulled from Google and SODATA) quickly. I also didn't see much relational stuff going on in the scope of this project. While at small scales, I do know that Mongo's read capabilities are limited, I plan to do my autocompletion on the client. So I'm not too worried about that.

I reasoned that because the last update to this data set was in February of 2013, there was no need to pull from the API every time the page was loaded - the data is relatively static. A feature in the future could be a backend "cron" type job to check for updates to the data set, or a button on the interface to check for updates.

Architecture
===========
I saw the need for a model hierarchy here. We have the obvious data model, a movie, but we also have multiple copies of each model in the dataset, with only the location changed. Therefore, it seemed sensible to blend all of the copies into one model, whose coordinates are a collection of location models. This way, we can interact with each location as a separate model, while keeping them unified under a single movie. This allows for features like location favoriting, custom icons for movies, and all kinds of other interaction with locations. I have provided a mongodump if you care to look at the data structure.


Other Notes
==========
I obtained all of the coordinate data from google maps, using a setTimeout function to ensure that I didn't overload my quota. Maps did not provide coordinates for all of the locations in the set, but it got a significant amount of them. The 890 objects in the original set were compressed to 247 models, most with location data.