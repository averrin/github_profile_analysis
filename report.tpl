<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="https://storage.googleapis.com/code.getmdl.io/1.0.5/material.indigo-pink.min.css">
  <script src="https://storage.googleapis.com/code.getmdl.io/1.0.5/material.min.js"></script>
  <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
  <title>Github profile: {{user.name}} [{{user.login}}]</title>

  <style media="screen">
  .langs {
    display: table;
    width: 100%;
    overflow: hidden;
    white-space: nowrap;
    cursor: pointer;
    -webkit-user-select: none;
    height: 15px;
  }
  .langs span {
    display: table-cell;
    line-height: 8px;
  }

  </style>
</head>

<body>
  <div class="" style="width: 400px; margin: 40px auto;">
    <div class="github-card" data-github="{{user.name}}" data-width="400" data-height="316" data-theme="medium"></div>
    <script src="https://cdn.jsdelivr.net/github-cards/latest/widget.js"></script>
    <div class="demo-card-wide mdl-card mdl-shadow--2dp" style="width: 400px; margin-top: 20px">
      <div class="mdl-card__title">
        <h3 class="mdl-card__title-text">Github Info</h3>
      </div>
      <div class="mdl-card__supporting-text">
        <ul>
          <li>Joined: {{user.created_at}} ({{user.duration}})</li>
          <li>Last activity: {{user.last_activity}}</li>
          <li>Repos: {{user.public_repos}} (Forks: {{repos.forks}})</li>
          <li>Repos Languages:
            <div class="langs">
              {% for l in repos.languages %}
                <span style="width: {{l[1][1]}}; background: {{l[1][2]}}"></span>
              {%endfor%}
            </div>
            <ul>
            {% for l in repos.languages %}
            <li>{{l[0]}}: {{l[1][0]}} repos ({{l[1][1]}})</li>
            {%endfor%}
          </ul></li>
          <li>Pull requests: {{repos.pulls|length}} (Merged: {{repos.pulls_merged}})</li>
          <li>Pulls Languages:
            <div class="langs">
              {% for l in repos.pulls_languages %}
                <span style="width: {{l[1][1]}}; background: {{l[1][2]}}"></span>
              {%endfor%}
            </div>
            <ul>
            {% for l in repos.pulls_languages %}
            <li>{{l[0]}}: {{l[1][0]}} repos ({{l[1][1]}})</li>
            {%endfor%}
          </ul></li>
          <li>Issues in foregin repos: {{issues|length}}</li>
          <li>Stars: {{stars|length}}</li>
        </ul>
      </div>
      <div class="mdl-card__actions mdl-card--border">
        <small><b>Generated:</b> {{timestamp}}</small>
      </div>
    </div>
  </div>
</body>

</html>
