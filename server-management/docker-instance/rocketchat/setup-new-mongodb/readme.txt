Tạo mới container: bash /var/docker/deploy_mongodb.sh rocketchat_33 16601 mongodb-net
Reset lại từ đầu: bash /var/docker/deploy_mongodb.sh rocketchat_33 16601 mongodb-net --reset
Xoá hoàn toàn & thoát: bash /var/docker/deploy_mongodb.sh rocketchat_33 16601 mongodb-net --delete
==================================================
Setup replication: bash /var/docker/init_rs.sh rocketchat_rs rocketchat_33 admin admin 10.18.200.182:16601 10.18.200.182:16602
