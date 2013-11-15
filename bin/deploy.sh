#setup variables
script_dir="$( cd "$( dirname "$0" )" && pwd )"
deploy_env="prod"
init=""
if [ "$#" -ge 1 ]; then init=$1; fi
rsync_args="-arvuz $script_dir/../ prod@monomyth.io:/home/prod/public/reliefdb.org --exclude-from $script_dir/exclude.txt"
site_dir="reliefdb.org"
error_output="error: deployment aborted"

#deploy
cd $script_dir
echo "\033[0;36m"
echo "deployment started to $site_dir"

#copy web files
echo "\033[0;33m"
echo "step one: copying website to server"
echo "\033[0m"
rsync $rsync_args
res=$?
[ $res -ne 0 ] && echo "\033[0;31m" && echo $error_output && echo "\033[0m" && exit 1

#run bundler
echo "\033[0;33m"
echo "step two: run bundler on server"
echo "\033[0m"
ssh $deploy_env@monomyth.io "bash -l -c 'cd ./public/$site_dir;pwd;which bundle;bundle install --without development --path vendor/bundle --binstubs bin/'"
res=$?
[ $res -ne 0 ] && echo "\033[0;31m" && echo $error_output && echo "\033[0m" && exit 1

#run assets precompile
echo "\033[0;33m"
echo "step three: run assets precompile on server"
echo "\033[0m"
ssh $deploy_env@monomyth.io "bash -l -c 'cd ./public/$site_dir;rake assets:precompile RAILS_ENV=production'"
res=$?
[ $res -ne 0 ] && echo "\033[0;31m" && echo $error_output && echo "\033[0m" && exit 1

#init db
if [ "$init" == "init" ]; then
  echo "\033[0;33m"
  echo "db init: creating database"
  echo "\033[0m"
  ssh $deploy_env@monomyth.io "bash -l -c 'cd ./public/$site_dir;rake db:create RAILS_ENV=production'"
  res=$?
  [ $res -ne 0 ] && echo "\033[0;31m" && echo $error_output && echo "\033[0m" && exit 1
fi

#run migrations
echo "\033[0;33m"
echo "step four: run migrations on database"
echo "\033[0m"
ssh $deploy_env@monomyth.io "bash -l -c 'cd ./public/$site_dir;rake db:migrate RAILS_ENV=production'"
res=$?
[ $res -ne 0 ] && echo "\033[0;31m" && echo $error_output && echo "\033[0m" && exit 1

#restart web server
if [ "$deploy_env" == "prod" ]; then
echo "\033[0;33m"
echo "step five: restart nginx on server"
echo "\033[0m"
ssh -tt $deploy_env@monomyth.io "bash -l -c 'sudo /etc/init.d/nginx restart'"
res=$?
[ $res -ne 0 ] && echo "\033[0;31m" && echo $error_output && echo "\033[0m" && exit 1
fi

#finished
echo "\033[0;32m"
echo "deployment finished to $site_dir"
echo "\033[0m"