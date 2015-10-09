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
    /*cursor: pointer;*/
    -webkit-user-select: none;
    height: 15px;
  }
  .langs span {
    display: table-cell;
    line-height: 8px;
  }
  .mdl-card__title {
    padding-bottom: 0;
  }
  .mdl-card__supporting-text {
    padding-top: 0;
  }

  </style>
</head>

<body>
  <div class="" style="width: 808px; margin: 0 auto; padding-top: 20px;">
    <div style="width: 400px; float: left; margin-right: 8px">
      <div class="github-card" data-github="{{user_name}}" data-width="400" data-height="316" data-theme="medium"></div>
      <script src="https://cdn.jsdelivr.net/github-cards/latest/widget.js"></script>
    </div>
    <div class="demo-card-wide mdl-card mdl-shadow--2dp" style="width: 400px;">
      <div class="mdl-card__title">
        <h3 class="mdl-card__title-text">Github Info</h3>
      </div>
      <div class="mdl-card__supporting-text">
        <ul>
          <li><b>Joined:</b> {{user.created_at}} ({{user.duration}})</li>
          <li><b>Last activity:</b> {{user.last_activity}}</li>
          <li><b>Repos:</b> {{user.public_repos}} (Forks: {{repos.forks}})</li>
          <li><b>Repos stats:</b> {{repos.stars}} stars, {{repos.watchers}} watchers</li>
          <li><b>Repos Languages (w/ forks):</b>
            <div class="langs">
              {% for l in repos.languages %}
                <span style="width: {{l[1][1]}}; background: {{l[1][2]}}" title="{{l[0]}}"></span>
              {%endfor%}
            </div>
            <ul>
            {% for l in repos.languages[:5] %}
            <li>{{l[0]}}: {{l[1][0]}} repos ({{l[1][1]}})</li>
            {%endfor%}
            {% if repos.languages|length > 6 %}
              <li>Others...</li>
            {%endif%}
          </ul></li>
          <li><b>Pull requests:</b> {{repos.pulls|length}} (Merged: <b>{{repos.pulls_merged}}</b>)</li>
          <li><b>PR stats:</b> {{repos.pr_info.commits}} commits, {{repos.pr_info.additions}} additions, {{repos.pr_info.deletions}} deletions, {{repos.pr_info.changed_files}} changed files</li>
          <li><b>Pulls Languages:</b>
            <div class="langs">
              {% for l in repos.pulls_languages %}
                <span style="width: {{l[1][1]}}; background: {{l[1][2]}}" title="{{l[0]}}"></span>
              {%endfor%}
            </div>
            <ul>
            {% for l in repos.pulls_languages %}
            <li>{{l[0]}}: {{l[1][0]}} PRs ({{l[1][1]}})</li>
            {%endfor%}
          </ul></li>
          <li><b>Issues in foregin repos:</b> {{issues|length}}</li>
          <li><b>Starred repos:</b> {{stars|length}}</li>
        </ul>
      </div>
      <div class="mdl-card__actions mdl-card--border">
        <small><b>Generated:</b> {{timestamp}}</small>
      </div>
    </div>
  </div>
</body>

</html>
