<!-- @format -->

ubah domain di inverntory.ini

ubah domain di cloudflare
durection IP

setting dev or prod nya

setting vars nya sesuaikan dengan isinya

check env
db host
username
password
ssl
domain

===============================
check juga untuk file path ssl

isi dengan key dan pem nya

================================

ansible-playbook -i inventory/laravel_after_phpmyadmin.ini playbook/laravel/deploy/laravel_after_phpmyadmin.yaml

destroy
ansible-playbook -i inventory/laravel_after_phpmyadmin.ini playbook/laravel/destroy/laravel---destroy.yaml

pull repository
ansible-playbook -i inventory/laravel_after_phpmyadmin.ini playbook/laravel/pull/laravel---pull.yaml

=================================
cek dns nya domain agarlangsung connect
