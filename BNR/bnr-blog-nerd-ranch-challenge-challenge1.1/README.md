# Big Nerd Ranch iOS Coding Challenge
Thanks for your interest in joining Big Nerd Ranch! This repository has a half-
finished app in it. There are some bugs, there's missing functionality, and
there's a lot of room for improvement.

Your task is to make this app better. There are some specific issues we'd like
you to be sure you fix, but how you choose to improve the app beyond that is
entirely up to you. This lets you show your coding ability without being at
a whiteboard or having someone look over your shoulder while you code.

Please use up to 4 hours to work on the project. At the conclusion of your time,
write up a small summary explaining the path you took and what you would do next
if more time was allotted. Remember, we are observing your work as a client might,
so please keep us updated on your plans and progress.

# Blog Nerd Ranch
We've begun to build an app to showcase all our amazing content from the [Big
Nerd Ranch Blog](https://www.bignerdranch.com/resources/blog/). A user of our
app should be able to:

1. View a quick summary of all of our blog posts
2. Group & sort these summaries by author, publish date, or title
3. Read a selected blog post in its entirety

## Getting Started
Open the project file & run the code on the simulator to see the current state
of the app. You should be able to see the title cards of a number of blog posts,
and tap into them to see their contents.

## Known Issues
We're midway through development on this app. And while we've got a good amount
of it written, there are a few things we know we need to fix before we can ship
it:

- [ ] Our collection view just shows the blog title for each post. It should
show title, author, summary, and publish date. We recommend you build this view
in a xib or storyboard.
- [ ] Grouping & sorting are both broken. The menus come up, but the order of
the summaries doesn't change when I make a selection.
- [ ] Archibald's _massive_ blog post takes a long time to download from the server,
and it's slowing the whole app down. We should delay downloading that post
unless we have to, and maybe add a loading state to improve the experience.
- [ ] Our unit & UI tests are pretty bare-bones right now. We should add
more tests to improve test coverage.

## The APIs
There are 2 REST APIs that this app uses. The first one provides metadata on
blog posts. This includes things like the author, a short summary, and the date
that the post was published.

### The `post-metadata` API
```
GET /post-metadata/42
```
```json
{
  "id": "42",
  "title": "Morbi congue diam eu magna",
  "publishDate": "2018-07-15T23:03:29Z",
  "postId": "1042",
  "summary": "Donec dictum ligula purus, ut suscipit arcu cursus ut.",
  "author": {
    "name": "Kerri Ferguson",
    "image": "/images/authors/kerri.jpg",
    "title": "iOS Engineer"
  }
}
```

Here's what each of these fields represent:

* `id` - The ID of the metadata object. It will always match the ID in the URL.
* `title` - The title of the blog post
* `publishDate` - An ISO 8061 timestamp when the post was first published.
* `postId` - The ID of the post object this metadata references. Usually it will
be the same as the `id` value, but that's not guaranteed.
* `summary` - A short description of the blog post.
* `author` - An object with author data, specifically:
  - `name` - The author's name
  - `title` - The author's title
  - `image` - An absolute path to an image of the author. This should be
  interpreted as hosted on the same domain as the API.

You can also get a list of all metadata objects by issuing a GET request without
an ID.

```
GET /post-metadata
```

### The `post` api
The second API is for retrieving the full content of the blog post:

```
GET /post/1042
```
```json
{
  "id": "1042",
  "metadata": {
    "id": "42",
    "...": "..."
  },
  "body": "Lorem ipsum dolor ... posuere lacus tincidunt."
}
```

Here's what each of these fields represent:

* `id` - The ID of the post object. It will always match the ID in the URL.
* `metadata` - The metadata for this blog post. All properties on this object
match those from the `post-metadata` API.
* `body` - The content of the blog post.

You can also get a list of all post objects by issuing a GET request without an
ID:

```
GET /post
```

## Mock server
While the Services team is building the production API, we have a mock server we
can run locally. This provides the same interface that our production API will
and includes some sample data.

This is already hooked up to the Run and the Test actions in Xcode. When you
launch the app & when you run UI tests, the mock server will be automatically
launched.

If you want to start the mock server without Xcode, just run the
`start-mocks.sh` script. To stop it, run `stop-mocks.sh`. This launches the
mock server at `http://localhost:8106`.

The API design is locked, so you shouldn't need to change the mock server at
all.
