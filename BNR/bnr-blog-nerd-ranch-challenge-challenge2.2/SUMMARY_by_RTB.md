# BNR iOS Challenge Summary by Todd Bruss
Thank you for allowing me to take this challenge. 

Here is summary of path I took with this Application.

I first read over the readme file and launched the mock API. I then tested mock API in the browser and ran some commands listed on the API. The mock API worked wonderfully. I did have to one tweak and that was launch the start mock shell script via sudo. Otherwise the mock API would crash after each the the I compiled the app.

I then proceeded to get familar with the project and I saw right away that UICollectionViews were used. I was given the choice of and Xcode Interface Builder file (.XIB) or a Storyboard. The solution seemed simple enough to use a reusable cell and I could still do some basic layout visually within the xib file.

My next task was getting the sort and group to function. I broken the problem down to its lowest fruits. I figured sorting would be way easier to do, so I proceeded with that and got a six sorting methods to work.n

After that was accomplished. Performance issues with app itself started to bother me. We want this app to scale! So I looked a code and it was downloading the entire contents and then it was filtering out the post that was clicked on. On top of this it was doing this before it could segue into the next view. I also looked a the next view and it appeared that it was loaded the contents twice into the view. The fix was to use the id of the post and only fetch the post that was needed. And since the UI was being blocked during the load and we feltt pretty confident the content will load, we decided to go ahead and segue into the next view while loading the contents in the background. And for all but 1 post this was extremely fast and efficient.

Then There was one pesky post by Archibald Sweet that seems to load on a delay. We either have a really bad connection or we have an issue with our API which we can't fix. My solution there was to add Loading... test and a spinner in the middle of the screen to let the user know it is loading the content soon. It still gives some feedback. And because we are no longer loading tihs Archibald Sweet post constantly our entire app is now very fast.

Ideally if I had more time, I would probably load at what is display in the view and preload the posts. Setup kind of a predictive AI on what the user might click on. This could possibly help with slow network connections and still have a zippy response time.

Next, I decided to back on track and get the groups working. I first worked on a Month group and had something roughed out but i wasn't quite happy with it. I was grouping by actual months and not including the year and I read the comments in the source code that it was Month and Year which made way more sense. So I put it down for a bit and proceeded to work on the Author group. There I used a Set of each other's name and later converted that to an Array for sorting purposes. Sets work very fast and they connect contain duplicates; great for making a list of names. Sets however cannot sort but you can easilly make a set an Array and then sort that array. The rest of the grouping was building using a dictionary to store the posts for each group. This way its contents can be sorted prior to adding it to the groups object.

I also setup a little bit if a hierachy for the sorting engine. For instance, the user groups the authors, sorts by author Z to A and then sorts by title, the system knows which way the author is sorted at and keeps that setting while shuffling around the other contents.

Now that the groups and sorts are working, I decided to take a break and work on the main view. Since we have the Author's work title and a photo, I thought I would be a nice addition to the app to show this on the main view. Since each picture was a perfect square this was a very good opportunity to turn those photos into circles.

If I had more time, would have worked on the article view some more. maybe get the text to look a little more elegant on the page, but since it was meeting the requirements of the app, I decided to get back to the groups and sorting and get those to mesh well together. I also would add a separator between each post and alternate the background color.

I also did not have time to flush out the unit and UI tests. Possibly after showing a round to the customer for changes, unit testing could begin at that point especially while waiting for feedback from the customer.
