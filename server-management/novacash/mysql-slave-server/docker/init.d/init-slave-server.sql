/****
STOP SLAVE;
RESET SLAVE;
CHANGE MASTER TO MASTER_HOST='<hostname?>',  MASTER_PORT=3306, MASTER_USER='<repl_user?>', MASTER_PASSWORD='<password?>', MASTER_AUTO_POSITION=1 FOR CHANNEL '<novacash-channel-name?>';
START SLAVE FOR channel '<novacash-channel-name?>';
****/