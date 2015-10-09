#!env python3
import requests
from requests.auth import HTTPBasicAuth
import jinja2
import os
import sys
import dateutil.parser
from creds import login, token
import json
from datetime import datetime, timedelta
import time
import random
r = lambda: random.randint(0,255)

CWD = os.path.abspath(os.path.split(sys.argv[0])[0])

user = sys.argv[1]
if not os.path.isfile('cache.json'):
    json.dump({}, open('cache.json', 'w'))
cache = json.load(open('cache.json', 'r'))
colors = {}


def td_format(td_object):
    seconds = int(td_object.total_seconds())
    periods = [
        ('year',        60 * 60 * 24 * 365),
        ('month',       60 * 60 * 24 * 30),
        ('day',         60 * 60 * 24),
        # ('hour',        60 * 60),
        # ('minute',      60),
        # ('second',      1)
    ]

    strings = []
    for period_name, period_seconds in periods:
        if seconds > period_seconds:
            period_value, seconds = divmod(seconds, period_seconds)
            if period_value == 1:
                strings.append("%s %s" % (period_value, period_name))
            else:
                strings.append("%s %ss" % (period_value, period_name))

    return ", ".join(strings)

def fetch(_url, paginate=False, getter=None):
    print('Fetching: ' + _url)
    if _url in cache:
        if datetime.fromtimestamp(cache[_url]['timestamp']) - datetime.now() < timedelta(hours=1):
            print('From cache')
            return cache[_url]['content']
    p = 1
    if paginate:
        url = _url % p
    else:
        url = _url
    items = requests.get(url, auth=HTTPBasicAuth(login, token)).json()
    if getter is not None:
        items = getter(items)
    if paginate and len(items) == 100:
        p += 1
        new_items = requests.get(_url % p, auth=HTTPBasicAuth(login, token)).json()
        items.extend(new_items)
        while new_items:
            p += 1
            new_items = requests.get(_url % p, auth=HTTPBasicAuth(login, token)).json()
            items.extend(new_items)

    cache[_url] = {
        "content": items,
        "timestamp": time.mktime(datetime.now().timetuple())
    }
    return items

# TODO: repos/pr lang and value analysis

info = fetch('https://api.github.com/users/%s' % user)
_issues = fetch('https://api.github.com/search/issues?q=author:%s&page=%%s&per_page=100' % user, True, lambda x: x['items'])
issues = [x for x in _issues if user not in x[
    'url'] and 'pull_request' not in x]
pulls = [x for x in _issues if 'pull_request' in x]
for p in pulls:
    p['info'] = fetch(p['pull_request']['url'])

_repos = fetch(info['repos_url'] + '?page=%s&per_page=1000', True)
repos = {
    'items': _repos,
    'forks': len([x for x in _repos if x['fork']]),
    'pulls': [],
    'pr_info': {
        'commits': 0,
        'additions': 0,
        'deletions': 0,
        'changed_files': 0,
    },
    '_languages': {},
    '_pulls_languages': {},
    'stars': 0,
    'watchers': 0
}
for repo in _repos:
    if repo['fork']:
        continue
    l = repo['language']
    repos['stars'] += repo['stargazers_count']
    repos['watchers'] += repo['watchers']
    if l is None:
        l = 'Unknown'
    if l not in repos['_languages']:
        c = '#%02X%02X%02X' % (r(),r(),r())
        colors[l] = c
        repos['_languages'][l] = [0, 0, c]
    repos['_languages'][l][0] += 1
    repos['_languages'][l][1] = '%s%%' % int(repos['_languages'][l][0] / len(_repos) * 100)
repos['languages'] = sorted(repos['_languages'].items(), key=lambda x: x[1][0], reverse=True)

repos['pulls'].extend(pulls)
repos['pulls_merged'] = len(
    [x for x in repos['pulls'] if x['info']['merged_at'] is not None])
for pr in repos['pulls']:
  #print(json.dumps(pr, indent=4))
    l = pr['info']['base']['repo']['language']
    repos['pr_info']['commits'] += pr['info']['commits']
    repos['pr_info']['additions'] += pr['info']['additions']
    repos['pr_info']['deletions'] += pr['info']['deletions']
    repos['pr_info']['changed_files'] += pr['info']['changed_files']
    if l is None:
        l = 'Unknown'
    if l not in repos['_pulls_languages']:
        repos['_pulls_languages'][l] = [0, 0, colors.get(l, '#%02X%02X%02X' % (r(),r(),r()))]
    repos['_pulls_languages'][l][0] += 1
    repos['_pulls_languages'][l][1] = '%s%%' % int(repos['_pulls_languages'][l][0] / len(_repos) * 100)
repos['pulls_languages'] = sorted(repos['_pulls_languages'].items(), key=lambda x: x[1][0], reverse=True)

events = fetch(info['events_url'].replace('{/privacy}', ''))
info['last_activity'] = dateutil.parser.parse(
    [x for x in events if x['actor']['login'] == user][0]['created_at']
).strftime('%d.%m.%Y')
info['duration'] = td_format(datetime.now() - dateutil.parser.parse(
    info['created_at']
).replace(tzinfo=None))
info['created_at'] = dateutil.parser.parse(
    info['created_at']
).strftime('%d.%m.%Y')

stars = fetch(info['starred_url'].replace('{/owner}{/repo}', '?page=%s&per_page=100'), True)
template = jinja2.Template(open(os.path.join(CWD, 'report.tpl'), 'r').read())
print('Rendering')
context = {
    'user': info,
    'repos': repos,
    'issues': issues,
    'stars': stars,
    'timestamp': datetime.now()
}
report = template.render(context)

report_file = 'report.html'

json.dump(cache, open('cache.json', 'w'))
with open(report_file, 'w') as f:
    f.write(report)
#context['timestamp'] = ''
#json.dump(context, open('info.json', 'w'))
