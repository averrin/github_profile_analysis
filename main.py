#!env python3
import requests
from requests.auth import HTTPBasicAuth
import jinja2
import os
import sys
import dateutil.parser
from creds import login, token
CWD = os.path.abspath(os.path.split(sys.argv[0])[0])

user = sys.argv[1]

#TODO: fetch_list func (per page)
#TODO: repos/pr lang and value analysis

info = requests.get('https://api.github.com/users/%s' % user, auth=HTTPBasicAuth(login, token)).json()
events = requests.get(info['events_url'].replace('{/privacy}', ''), auth=HTTPBasicAuth(login, token)).json()
stars = requests.get(info['starred_url'].replace('{/owner}{/repo}', '?page=1&per_page=1000'), auth=HTTPBasicAuth(login, token)).json()
_issues = requests.get('https://api.github.com/search/issues?q=author:%s&page=1&per_page=1000' % user, auth=HTTPBasicAuth(login, token)).json()
issues = filter(lambda x: user not in x['url'] and 'pull_request' not in x, _issues['items'])
pulls = filter(lambda x: 'pull_request' in x, _issues['items'])
for p in pulls:
    p['info'] = requests.get(p['pull_request']['url']+'?page=1&per_page=1000', auth=HTTPBasicAuth(login, token)).json()

_repos = requests.get(info['repos_url']+'?page=1&per_page=1000', auth=HTTPBasicAuth(login, token)).json()
repos = {
    'items': _repos,
    'forks': len(filter(lambda x: x['fork'], _repos)),
    'pulls': []
}
repos['pulls'].extend(pulls)
repos['pulls_merged'] = len(filter(lambda x: x['info']['merged_at'] is not None, repos['pulls']))

info['last_activity'] = dateutil.parser.parse(filter(lambda x: x['actor']['login'] == user, events)[0]['created_at']).strftime('%d.%m.%Y')
info['created_at'] = dateutil.parser.parse(info['created_at']).strftime('%d.%m.%Y')


template = jinja2.Template(open(os.path.join(CWD, 'report.tpl'), 'r').read())
report = template.render({
    "user": info,
    'repos': repos,
    'issues': issues,
    'stars': stars
})

report_file = 'report.html'
with open(report_file, 'w') as f:
    f.write(report)
