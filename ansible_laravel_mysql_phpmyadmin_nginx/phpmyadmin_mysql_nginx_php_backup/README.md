<!-- @format -->

1. sshcopy id dan masukan inventory pastikan sudah past
   ssh-copy-id -f "-o IdentityFile ./main-key2.pem" ubuntu@52.62.92.196

check vars

check task

deploy public 2 server
ansible-playbook -i inventory/phpmyadmin.ini playbook/phpmyadmin/deploy/phpmyadmin-deploy.yaml
ansible-playbook -i inventory/phpmyadmin.ini playbook/phpmyadmin/bind_address/bind_address.yaml
ansible-playbook -i inventory/laravel_after_phpmyadmin.ini playbook/laravel/deploy/laravel_after_phpmyadmin.yaml

ansible-playbook -i inventory/private_mysql_laravel_bastion_nginx.ini playbook/phpmyadmin/deploy/phpmyadmin-deploy.yaml

destroy
ansible-playbook -i inventory/phpmyadmin.ini playbook/phpmyadmin/destroy/phpmyadmin---destroy.yaml
============================
autoback up

1. ke aws
2. ke ami
   create user alls3 allowed

3. buat iam user di aws ec2
   access key dan namekey

4. buat s3 storage
   create [option]
   Object Ownership
   ACLs disabled (recommended)

block all public access

bucket versioning disable

default encryption
Server-side encryption with Amazon S3 managed keys (SSE-S3)

bucket key
enable

object lock
disable

create
test.auto

3. click ami user lalu ke bagian key generate
   use cli

4. masukan vars
   access key , key , region

cek \_region nya tentukan mau dimana

5. masukan database mana yang ingin di back up vars

   db_name

6. \*PENTING tentukan crontab berapa kali back up nya
7. masukan s3_bucket nya

ansible-playbook -i inventory/phpmyadmin.ini playbook/phpmyadmin/backup_s3/phpmyadmin-autobackup.yaml

ansible-playbook -i inventory/phpmyadmin.ini playbook/phpmyadmin/backup_s3/phpmyadmin-destroy-autobackup.yaml -vvv

====================================
ip bind
change ip di vars
host_ip_bind_address

ansible-playbook -i inventory/phpmyadmin.ini playbook/phpmyadmin/bind_address/bind_address.yaml
