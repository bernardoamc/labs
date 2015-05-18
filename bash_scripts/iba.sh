function tga {
  cd "$HOME/src/private/iba/store"
  script/toggle active
}

function tge {
  cd "$HOME/src/private/iba/store"
  script/toggle enable $1
}

function tgd {
  cd "$HOME/src/private/iba/store"
  script/toggle disable $1
}

function iba_mongo_restore {
  for db in admin catalogue commerce profiles subscriptions; do
    if [ -d "$HOME/Downloads/mongo-dump/${db}_development" ]; then
      mongorestore --port 17017 --drop --noIndexRestore --db ${db}_development ~/Downloads/mongo-dump/${db}_development
    else
      echo $db
      mongorestore --port 17017 --drop --noIndexRestore --db ${db}_development ~/Downloads/mongo-dump/$db
    fi
  done

  boxen --no-pull --restart-service mongodb
}

function iba_admin {
  cd "$HOME/src/private/iba/admin"
  bundle exec rake db:create_admin_user
}

function iba_run {
  cd  "$HOME/src/private/iba/"
  bundle exec rake stop
  bundle exec rake run:catalogue run:commerce run:profiles run:orders run:subscriptions run:store run:admin
}

function iba_update {
  services=("catalogue" "commerce" "profiles" "orders" "subscriptions" "store" "admin")

  for service in ${services[@]}; do
    cd "$HOME/src/private/iba/$service"

    echo "---------------------------------"
    echo "Updating $service..."
    echo "---------------------------------"

    git pull
    HTTP_PROXY=http://actor.ptec.me:8888 bundle install
  done
}
