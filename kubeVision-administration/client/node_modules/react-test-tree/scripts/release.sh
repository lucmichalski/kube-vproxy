if [[ $(git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3) != "master" ]]
then
  echo "Can only release from master";
  exit 1;
fi

if [[ -n $(git status --porcelain) ]];
then
  echo "Repo is dirty. please commit before releasing";
  exit 1;
fi

if [ -z "$inc" ];
then
  inc="patch";
fi

echo "update version"
npm version $inc

echo "pushing changes"
git push origin master
git push origin --tags

echo "publishing to NPM"
npm publish