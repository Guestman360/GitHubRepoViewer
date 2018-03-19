# GitHubRepoViewer

Here is my attempt at a coding test, in which my task was to create a GitHub repository viewer. More details below.

<img src="https://user-images.githubusercontent.com/19701503/37573575-9d66412a-2ad6-11e8-8079-5cd02a9328fb.png" width="300">

I chose to keep it simple so I went with MVC design pattern for this project. After that, the next order of business was to find a way to get data from GitHub, so I looked at documentation to see if there is a url/route I could make a request to for data. I found `/users/:username/repos` which is exactly what I needed to make request with the owners name to fetch their repositories.

A repo owner may have multiple pages of content so upon digging I found the issue of pagination, which I would need to make use of a `Link` response header (All of this is in the [GitHub API](https://developer.github.com/v3/#pagination)) to be able to retrieve any additional pages of a user's repo.

After loading the repo pages and data I was able to map the data into a data structure that would hold the language name (String) and hold an array of Repo structs (objects that would hold information like, name, description, language, stars/forks count etc...), this allowed me to easily split up a tableview into relevant sections.

I also added small design details such as a searchbar in the navigation bar, custom Xib for section header, activity indicator, custom app icon and I designed the table view cells with stack views to make the UI easier to work with and look good on all screen sizes. 
