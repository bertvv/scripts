#!/bin/sh
#
# Amend the author in Git commits
#
# Usage:
# 1. Git clone --bare REPO
# 2. cd LOCAL_REPO
# 3. git-rewrite-author
# 4. cd ..; rm -rf LOCAL_REPO
# 5. bbclone REPO
#
# Source: https://help.github.com/articles/changing-author-info/

git filter-branch --env-filter '
OLD_EMAIL="bert.vanvreckem@gmail.com"
CORRECT_NAME="Bert Van Vreckem"
CORRECT_EMAIL="bert.vanvreckem@hogent.be"
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags

echo "Done! Check the git log in another terminal."
echo "Push to repository? [y/N] "
read answer
if [ "${answer}" = "y" ]; then
  git push --force --tags origin 'refs/heads/*'
else
  echo "To push yourself, do:"
  echo "  git push --force --tags origin 'refs/heads/*'"
fi


