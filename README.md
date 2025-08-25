https://roadmap.sh/projects/github-user-activity
# GitHub User Activity Tracker

A Ruby application that fetches and displays a GitHub user's recent activity using the GitHub API.

## Features

- Fetches recent activity from GitHub's public events API
- Displays activity in a human-readable format
- Supports various event types:
  - Push events (commits)
  - Issues (opened, closed, reopened)
  - Stars (watch events)
  - Forks
  - Repository/branch/tag creation and deletion
  - Pull requests (opened, closed, merged)
  - Releases
  - Comments and reviews
  - Member additions

## Usage

Run the application from the command line with a GitHub username:

```bash
ruby app/main.rb <username>
```

### Examples

```bash
# View activity for the octocat user
ruby app/main.rb octocat

# View activity for any GitHub user
ruby app/main.rb kamranahmedse
```

## Sample Output

```
Recent GitHub Activity:
----------------------------------------
- Pushed 3 commits to kamranahmedse/developer-roadmap
- Opened a new issue in kamranahmedse/developer-roadmap: "Add new frontend framework section"
- Starred microsoft/vscode
- Forked facebook/react
- Created branch 'feature-update' in kamranahmedse/developer-roadmap
```

## Error Handling

The application handles common errors:

- Invalid usernames (404 error)
- API rate limiting (403 error)
- Network connectivity issues
- Empty activity (no recent events)

## API Information

This application uses the GitHub Events API:

- Endpoint: `https://api.github.com/users/<username>/events`
- No authentication required for public events
- Rate limit: 60 requests per hour for unauthenticated requests

## Requirements

- Ruby (built-in libraries: net/http, json, uri)
- Internet connection
