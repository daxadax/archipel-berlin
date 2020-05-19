release: bundle exec rake db:migrate
web: bundle exec puma -R config.ru -p ${PORT:-3000} -e ${RACK_ENV:-development}
