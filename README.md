# Travis Deploy Tool

Deployment tool for Travis CI

Currently supports the following commands:

    $ travis deploy [remote] # deploy to remote
    $ travis config [remote] # sync the local config file from travis-keychain and push the config to remote

The tool relies on git remotes being defined in `.git/config`. So, in order to deploy to production there needs to be a `production` remote repository defined in the git config.

## Deployment

Deploying to `staging` will just push to staging and run the migrations if `-m` was given. One can also pass `-c` in order to configure the app.

    Deploying to production.
    $ git push staging HEAD:master
    Running migrations.
    $ heroku run rake db:migrate -r staging

Deploying to production will also update the production branch and tag the current commit.

    Updating production branch.
    $ git checkout production
    $ git reset --hard master
    $ git push origin production -f
    Tagging deploy 2011-12-11 16:04.
    $ git tag -a 'deploy.2011-12-11.16-04' -m 'deploy 2011-12-11 16:04'
    $ git push --tags
    $ git checkout master
    Deploying to production.
    $ git push production HEAD:master -f
    Running migrations.
    $ heroku run rake db:migrate -r production

WARNING:

The production branch is updated using `git reset --hard [branch]` and pushed using `git push origin production -f`.

That means that all commits in the `production` branch that are not present in the target branch (e.g. `master`) will be removed from the history of `production`.

**So never commit to the production branch directly!**

