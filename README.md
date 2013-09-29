Application found at: http://uber2013.herokuapp.com

Decisions, Reasoning
====================
The biggest engineering decision I felt I had to make here was how to store the data here. I knew that I could pull from the SFdata API whenever I wanted to, but unfortunately this data doesn't come with coordinates and I had to rely on Google Maps geocoding. I decided to store each object from the API in a mongoDB database. I understand that there are pros and cons to this choice, but I wanted to use a system that would allow me to get up and running quickly and allow me to write all of my data (pulled from Google and SODATA) quickly. 

I reasoned that because the last update to this data set was in February of 2013, there was no need to pull from the API every time the page was loaded - the data is relatively static. A feature in the future could be a backend "cron" type job to check for updates to the data set, or a button on the interface to check for updates.

I called the movies and the locations using fetch for two reasons. First, I wanted to show ya'll that I know how to make AJAX calls. In this case, I could have passed the data from the server directly, but I thought I'd just use the native model.parse() function from the server. Another cool "feature" of this approach is that we can give users a real sense of what's going on. The modal that loads and shows you that data is being pulled is, in my opinion, always nice to see. I didn't have time to implement it, but I would really like to change the loader from a straight infinite loop to an actual progresss bar - not really hard using the HTML5 <progress> element, and since we know the length of the location collection, we could make it really useful.

Architecture / Data Structures
==============================
I am storing my data in two collections (tables). The first is a table of movies, each with a title, director, etc. The most important part, however, is the array of ids. This is a big reason why I am now regretting my decision to use mongo - I want to relate each movie to its locations. However, it's not so bad - Backbone.js comes to the rescue with the collection's _byId table, which allows me to link movies to their locations, and vice versa in O(1). 

My reasoning for separating the data into locations and movies is based on a few important points. As the developer, I will make no assumptions about what a user wants from the data set. If I had combined movies and their locations, returning an array of only locations would be convoluted. Furthermore, there would be data replication as multiple movies referenced the same object, but only by value. If neither movies nor locations take precedence, and we want to access and modify both (IE favoriting, tagging, etc), then they need to be separate. It makes for a clean API.

For autocomplete, I thought it best to get data on the client, for the simple reason that the page displays all of the points by default. There's no reason to issue a call to the server if my data is already there. Twitter typeahead was my solution here. I would like to say that I have written a basic autocompleter before, but due to the scope of this challenge, and for usability purposes, I saw no reason to reinvent the wheel here.

URL scheme: you can render a movie with #movies/:id, a location with the same pattern, or see your favorites with #favorites. I would really like to expand this application's RESTful API and add more features.

Problems
========
While autocomplete does technically return movies whose constituents match the query (IE, "Nich" returns Bicentennial Man because Nicholas Kazan wrote it), it does so ambiguously, simply returning the movie with no explanation. A good feature in the future would be the refinement of the result. I can think of a way to do it within an underscore template using the string.indexOf() method, but I have no more time.

Other Notes
==========
Look into public/src for the actual coffeescript used, with comments. App.coffee for same.

I obtained all of the coordinate data from google maps, using a throttling function to ensure that I didn't overload my quota. Maps did not provide coordinates for all of the locations in the set, but it got a significant amount of them. The 890 objects in the original set were compressed to 247 models, and 260 unique locations were compiled.

Credit for the image in the background goes to user rozne on wallbase.cc - source: http://wallpapers.wallbase.cc/rozne/wallpaper-1529749.jpg

Other Links
===========
My portfolio, resume, and github can be found at http://sampurcell.herokuapp.com. Please excuse any pageload delay, gotta wait for them dynos
 
I'm pretty proud of the code I wrote for this project, but my github has a couple more examples. Unfortunately, a good portion of my best code is in private repositories because of proprietary reasons, but I'd be willing to show you if you contact me about it.

News Map - an ongoing project - this project pulls news data from google and yahoo news, and plots each story on a map using parsed data from OpenCalais. Then, users can sort the stories by date using a slider. See the code at https://github.com/sampurcell93/StoryMap/ and the demo at http://intense-crag-4732.herokuapp.com/.

Drag and Drop - this is an ongoing project to make a WYSIWYG editor. Written in coffeescript and backbone. It's not done, and I can't display the UI at the moment (proprietary) but the code can be found at https://github.com/sampurcell93/Drag-and-Drop