<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Github profile: {{user.name}} [{{user.login}}]</title>
  </head>
  <body>
    <div class="github-card" data-github="{{user.name}}" data-width="400" data-height="316" data-theme="medium"></div>
    <script src="//cdn.jsdelivr.net/github-cards/latest/widget.js"></script>
    <ul>
      <li>Joined: {{user.created_at}}</li>
      <li>Last activity: {{user.last_activity}}</li>
      <li>Repos: {{user.public_repos}} (Forks: {{repos.forks}})</li>
      <li>Pull requests: {{repos.pulls|length}} (Merged: {{repos.pulls_merged}})</li>
      <li>Issues in foregin repos: {{issues|length}}</li>
      <li>Stars: {{stars|length}}</li>
    </ul>
  </body>
</html>
