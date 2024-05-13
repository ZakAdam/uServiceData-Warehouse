#!/bin/bash

echo 'Starting setup script for database setup...'
echo '-------------------------------------------'

echo 'Starting processing for Admin-Service...'

docker exec -it 'uservicedata-warehouse-admin_service-1' /bin/bash -c 'bin/rails db:create && bin/rails db:migrate'

echo 'Precompiling assets for the Admin-Service web interface...'

docker exec -it 'uservicedata-warehouse-admin_service-1' /bin/bash -c 'source $HOME/.bashrc && bin/rails assets:precompile'

echo 'Starting processing for Saver...'

docker exec -it 'uservicedata-warehouse-saver-1' /bin/bash -c 'bin/rails db:create && bin/rails db:migrate'

echo 'All processing steps were successfully completed!'

