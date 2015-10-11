<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="https://storage.googleapis.com/code.getmdl.io/1.0.5/material.indigo-pink.min.css">
  <script src="https://storage.googleapis.com/code.getmdl.io/1.0.5/material.min.js"></script>
  <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
  <link href='https://fonts.googleapis.com/css?family=Ubuntu:300,400,600,700' rel='stylesheet' type='text/css'>
  <link href='https://fonts.googleapis.com/css?family=Montserrat' rel='stylesheet' type='text/css'>
  <link href="{{user.avatar_url}}" rel="shortcut icon">
  <link rel="stylesheet" href="style.css">
  <title>{% if user.name%}{{user.name}}{%else%}{{user_name}}{%endif%}'s Profile</title>

</head>

<body>
  <a href="https://github.com/averrin/github_profile_analysis">
    <img style="position: absolute; top: 0; right: 0; border: 0; z-index: 100;" src="https://camo.githubusercontent.com/38ef81f8aca64bb9a64448d0d70f1308ef5341ab/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6461726b626c75655f3132313632312e706e67"
    alt="Fork me on GitHub" data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_darkblue_121621.png">
  </a>
  <div class="container mdl-grid">
    <div class="mdl-cell--6-col">
      <div class="mdl-card mdl-shadow--2dp mdl-cell">
        <div class="mdl-grid">
          <div class="mdl-cell mdl-cell--4-col mdl-cell--2-col-phone">
            <img src="{{user.avatar_url}}" alt="{% if user.name%}{{user.name}}{%else%}{{user_name}}{%endif%}" style="width: 100%">
          </div>
          <div class="mdl-cell mdl-cell--8-col mdl-cell--4-col-phone">
            <div class="card-content">
              <h4>{% if user.name%}{{user.name}}{%else%}{{user_name}}{%endif%}</h4>
              <ul class="status">
                <li><a href="https://github.com/{{user_name}}?tab=repositories" target="_top"><strong>{{user.public_repos}}</strong>Repos</a></li>
                <li><a href="https://gist.github.com/{{user_name}}" target="_top"><strong>{{user.public_gists}}</strong>Gists</a></li>
                <li><a href="https://github.com/{{user_name}}/followers" target="_top"><strong>{{user.followers}}</strong>Followers</a></li>
              </ul>
            </div>
          </div>
        </div>
        <ul>
            <li><b>Joined:</b> {{user.created_at}} ({{user.duration}})</li>
            <li><b>Last activity:</b> {{user.last_activity}}</li>
        </ul>
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
            <li><b>Repositories:</b> {{user.public_repos}} (Forks: {{repos.forks}})</li>
            <li><b>Repos stats (w/ forks):</b> {{repos.stars}} stars, {{repos.watchers}} watchers</li>
            <li><b>Repos languages (w/ forks):</b>
              <div class="langs">
                {% for l in repos.languages %}
                  <span style="width: {{l[1][1]}}; background: {{l[1][2]}}" id="repo_{{l[0]}}" title="{{l[0]}}">
                    {%if l[1][0] / (user.public_repos - repos.forks) > 0.15%}
                      {{l[1][1]}}
                    {%endif%}
                  </span>
                {%endfor%}
                {% for l in repos.languages %}
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
                <span style="width: {{repos.pulls_unmerged_per}}; background: #ccc; color: #111" id="unmerged">{%if repos.pulls_unmerged%}{{repos.pulls_unmerged_per}}{%endif%}</span>
                <span style="width: {{repos.pulls_merged_per}}; background: #6e5494; color: #eee" id="merged">{%if repos.pulls_merged%}{{repos.pulls_merged_per}}{%endif%}</span>
                <div class="mdl-tooltip" for="unmerged">unmerged</div>
                <div class="mdl-tooltip" for="merged">merged</div>
              </div>
            </li>
            <li><b>PR stats:</b> {{repos.pr_info.commits}} commits, {{repos.pr_info.additions}} additions, {{repos.pr_info.deletions}} deletions, {{repos.pr_info.changed_files}} changed files</li>
            <li><b>PR languages:</b>
              <div class="langs">
                {% for l in repos.pulls_languages %}
                  <span style="width: {{l[1][1]}}; background: {{l[1][2]}}" id="pr_{{l[0]}}" title="{{l[0]}}">
                    {%if l[1][0] / repos.pulls|length > 0.15%}
                      {{l[1][1]}}
                    {%endif%}
                  </span>
                {%endfor%}
                {% for l in repos.pulls_languages %}
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
