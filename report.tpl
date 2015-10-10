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
    body {
      background: #111;
    }
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
      margin: 0;
      font-weight: bold;
      text-align: center;
      vertical-align: middle;
      font-size: 8pt;
    }

    .mdl-card__title {
      padding-bottom: 0;
    }

    .mdl-card__supporting-text {
      padding-top: 0;
    }

    .container {
      width: 808px;
      margin: 0 auto;
      padding-top: 20px;
    }

    .mdl-card {
      width: 100%;
    }

    .card-holder {
      width: 100%;
      float: left;
    }
    .mdl-cell--6-col {
      margin-right: 8px;
    }
  </style>
</head>

<body>
  <a href="https://github.com/averrin/github_profile_analysis">
    <img style="position: absolute; top: 0; right: 0; border: 0;" src="https://camo.githubusercontent.com/38ef81f8aca64bb9a64448d0d70f1308ef5341ab/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6461726b626c75655f3132313632312e706e67"
    alt="Fork me on GitHub" data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_darkblue_121621.png">
  </a>
  <div class="container mdl-grid">
    <div class="mdl-cell--6-col">
      <div class="card-holder mdl-cell">
        <div class="github-card" data-github="{{user_name}}" data-width="400" data-height="316" data-theme="medium"></div>
        <script src="https://cdn.jsdelivr.net/github-cards/latest/widget.js"></script>
      </div>
      {% if user_content%} {{user_content}} {%endif%}
    </div>
    <div class="mdl-cell mdl-cell--6-col">
      <div class="mdl-card mdl-shadow--2dp">
        <div class="mdl-card__title">
          <h3 class="mdl-card__title-text">Github Info</h3>
        </div>
        <div class="mdl-card__supporting-text">
          <ul>
            <li><b>Joined:</b> {{user.created_at}} ({{user.duration}})</li>
            <li><b>Last activity:</b> {{user.last_activity}}</li>
            <li><b>Repositories:</b> {{user.public_repos}} (Forks: {{repos.forks}})</li>
            <li><b>Repos stats (w/ forks):</b> {{repos.stars}} stars, {{repos.watchers}} watchers</li>
            <li><b>Repos languages (w/ forks):</b>
              <div class="langs">
                {% for l in repos.languages %}
                <span style="width: {{l[1][1]}}; background: {{l[1][2]}}" id="repo_{{l[0]}}" title="{{l[0]}}"></span>
                <div class="mdl-tooltip" for="repo_{{l[0]}}">{{l[0]}} ({{l[1][1]}})</div>
                {%endfor%}
              </div>
              <ul>
                {% for l in repos.languages[:5] %}
                <li><b>{{l[0]}}:</b> {{l[1][0]}} repos ({{l[1][1]}})</li>
                {%endfor%} {% if repos.languages|length > 6 %}
                <li><b>Rest:</b> {{repos.language_names[5:]|join(', ')}}</li>
                {%endif%}
              </ul>
            </li>
            <li><b>Pull requests (w/ own repos):</b> {{repos.pulls|length}} (Merged: <b>{{repos.pulls_merged}}</b>)
              <div class="langs">
                <span style="width: {{repos.pulls_unmerged_per}}; background: #ccc; color: #111" id="unmerged">{{repos.pulls_unmerged_per}}</span>
                <div class="mdl-tooltip" for="unmerged">unmerged</div>
                <span style="width: {{repos.pulls_merged_per}}; background: #6e5494; color: #ccc" id="merged">{{repos.pulls_merged_per}}</span>
                <div class="mdl-tooltip" for="merged">merged</div>
              </div>
            </li>
            <li><b>PR stats:</b> {{repos.pr_info.commits}} commits, {{repos.pr_info.additions}} additions, {{repos.pr_info.deletions}} deletions, {{repos.pr_info.changed_files}} changed files</li>
            <li><b>PR languages:</b>
              <div class="langs">
                {% for l in repos.pulls_languages %}
                <span style="width: {{l[1][1]}}; background: {{l[1][2]}}" id="pr_{{l[0]}}" title="{{l[0]}}"></span>
                <div class="mdl-tooltip" for="pr_{{l[0]}}">{{l[0]}} ({{l[1][1]}})</div>
                {%endfor%}
              </div>
              <ul>
                {% for l in repos.pulls_languages[:5] %}
                <li><b>{{l[0]}}:</b> {{l[1][0]}} PRs ({{l[1][1]}})</li>
                {%endfor%} {% if repos.pulls_languages|length > 6 %}
                <li><b>Rest:</b> {{repos.pulls_language_names[5:]|join(', ')}}</li>
                {%endif%}
              </ul>
            </li>
            <li><b>Issues in foregin repos:</b> {{issues|length}}</li>
            <li><b>Starred repos:</b> {{stars|length}}</li>
          </ul>
        </div>
        <div class="mdl-card__actions mdl-card--border">
          <small><b>Generated:</b> {{timestamp}}</small>
        </div>
      </div>
    </div>
  </div>
</body>

</html>
