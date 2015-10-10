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
from dateutil import tz
import time
import random


def get_random_color(pastel_factor=0.5):
    return [
        (x + pastel_factor) / (1.0 + pastel_factor) for x in [
            random.uniform(0, 1.0) for _ in [1, 2, 3]
        ]
    ]


def color_distance(c1, c2):
    return sum([abs(x[0] - x[1]) for x in zip(c1, c2)])


def generate_new_color(existing_colors, pastel_factor=0.5):
    max_distance = None
    best_color = None
    for _ in range(0, 100):
        color = get_random_color(pastel_factor=pastel_factor)
        if not existing_colors:
            return color
        best_distance = min([color_distance(color, c)
                             for c in existing_colors])
        if not max_distance or best_distance > max_distance:
            max_distance = best_distance
            best_color = color
    return best_color

CWD = os.path.abspath(os.path.split(sys.argv[0])[0])
to_zone = tz.tzlocal()

user = sys.argv[1]
if not os.path.isfile('cache.json'):
    json.dump({"user": user}, open('cache.json', 'w'))
cache = json.load(open('cache.json', 'r'))
if cache['user'] != user:
    cache = {"user": user}
colors = {}


def td_format(td_object, v=False):
    seconds = int(td_object.total_seconds())
    periods = [
        ('year', 60 * 60 * 24 * 365),
        ('month', 60 * 60 * 24 * 30),
        ('day', 60 * 60 * 24),
    ]
    if v:
        periods.extend([
            ('hour', 60 * 60),
            ('minute', 60),
            # ('second',      1)
        ])

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
        new_items = requests.get(
            _url % p, auth=HTTPBasicAuth(login, token)).json()
        items.extend(new_items)
        while new_items:
            p += 1
            new_items = requests.get(
                _url % p, auth=HTTPBasicAuth(login, token)).json()
            items.extend(new_items)

    cache[_url] = {
        "content": items,
        "timestamp": time.mktime(datetime.now().timetuple())
    }
    return items


def retrieveIssues():
    _issues = fetch('https://api.github.com/search/issues?q=author:%s&page=%%s&per_page=100' %
                    user, True, lambda x: x['items'])
    issues = [x for x in _issues if user not in x[
        'url'] and 'pull_request' not in x]
    _pulls = [x for x in _issues if 'pull_request' in x]
    pulls = []
    for p in _pulls:
        p['info'] = fetch(p['pull_request']['url'])
        if p['info']['base']['repo']['owner']['login'] != user:
            pulls.append(p)
    return issues, pulls


def retrieveRepos(info):
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
            c = generate_new_color(colors.values(), pastel_factor=0.5)
            colors[l] = c
            repos['_languages'][l] = [0, 0, c]
        repos['_languages'][l][0] += 1
        repos['_languages'][l][1] = '%s%%' % int(
            repos['_languages'][l][0] / (len(_repos) - repos['forks']) * 100)
    repos['languages'] = sorted(
        repos['_languages'].items(), key=lambda x: x[1][0], reverse=True)
    for r in repos['languages']:
        r[1][2] = '#%02X%02X%02X' % tuple([x * 255.0 for x in r[1][2]])
    repos['language_names'] = [x[0] for x in repos['languages']]
    return repos


def processPulls(pulls, repos):
    repos['pulls'].extend(pulls)
    repos['pulls_merged'] = len(
        [x for x in repos['pulls'] if x['info']['merged_at'] is not None])
    repos['pulls_merged_per'] = '%s%%' % int(repos['pulls_merged'] / len(repos['pulls']) * 100)
    repos['pulls_unmerged_per'] = '%s%%' % int((len(repos['pulls']) - repos['pulls_merged']) / len(repos['pulls']) * 100)
    for pr in repos['pulls']:
        l = pr['info']['base']['repo']['language']
        repos['pr_info']['commits'] += pr['info']['commits']
        repos['pr_info']['additions'] += pr['info']['additions']
        repos['pr_info']['deletions'] += pr['info']['deletions']
        repos['pr_info']['changed_files'] += pr['info']['changed_files']
        if l is None:
            l = 'Unknown'
        if l not in repos['_pulls_languages']:
            repos['_pulls_languages'][l] = [
                0, 0, colors.get(l, generate_new_color(colors.values(), pastel_factor=0.5))]
        repos['_pulls_languages'][l][0] += 1
        repos['_pulls_languages'][l][1] = '%s%%' % int(
            repos['_pulls_languages'][l][0] / len(repos['pulls']) * 100)
    repos['pulls_languages'] = sorted(
        repos['_pulls_languages'].items(), key=lambda x: x[1][0], reverse=True)
    for pr in repos['pulls_languages']:
        pr[1][2] = '#%02X%02X%02X' % tuple([x * 255.0 for x in pr[1][2]])
    repos['pulls_language_names'] = [x[0] for x in repos['pulls_languages']]
    return repos


def renderReport(context):
    print('Rendering')
    template = jinja2.Template(open(os.path.join(CWD, 'report.tpl'), 'r').read())
    report = template.render(context)
    report_file = 'report.html'
    with open(report_file, 'w') as f:
        f.write(report)


def main():
    info = fetch('https://api.github.com/users/%s' % user)
    issues, pulls = retrieveIssues()
    repos = retrieveRepos(info)
    repos = processPulls(pulls, repos)
    events = fetch(info['events_url'].replace('{/privacy}', ''))
    info['last_activity'] = dateutil.parser.parse(
        [x for x in events if x['actor']['login'] == user][0]['created_at']
    )
    info['last_activity'] = info['last_activity'].strftime('%d.%m.%Y') +\
        ' (%s ago)' % td_format(
            (datetime.now().replace(tzinfo=to_zone) - info['last_activity']
        ), True)
    info['duration'] = td_format(datetime.now().replace(tzinfo=to_zone) - dateutil.parser.parse(
        info['created_at']
    ).replace(tzinfo=to_zone))
    info['created_at'] = dateutil.parser.parse(
        info['created_at']
    ).replace(tzinfo=to_zone).strftime('%d.%m.%Y')

    stars = fetch(info['starred_url'].replace(
        '{/owner}{/repo}', '?page=%s&per_page=100'), True)
    add_content = ''
    if os.path.isfile('content_%s.html' % user):
        with open('content_%s.html' % user, 'r') as f:
            add_content = f.read()

    context = {
        'user': info,
        'repos': repos,
        'issues': issues,
        'stars': stars,
        'timestamp': datetime.now().strftime('%H:%M %d.%m.%Y'),
        'user_name': user,
        'user_content': add_content
    }
    renderReport(context)
    json.dump(cache, open('cache.json', 'w'))

if __name__ == '__main__':
    main()
