#!/bin/bash

echo 'Starting setup script for database setup...'
echo '-------------------------------------------'

echo 'Starting processing for Admin-Service...'

docker compose exec admin_service /bin/bash -c 'bin/rails db:create && bin/rails db:migrate'

echo 'Precompiling assets for the Admin-Service web interface...'

docker compose exec admin_service /bin/bash -c 'source $HOME/.bashrc && bin/rails assets:precompile'

echo 'Starting processing for Saver...'

docker compose exec saver /bin/bash -c 'bin/rails db:create && bin/rails db:migrate'

echo 'All processing steps were successfully completed!'
