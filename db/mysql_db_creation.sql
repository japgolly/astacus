DROP DATABASE IF EXISTS astacus_test;
CREATE DATABASE astacus_test CHARACTER SET utf8 COLLATE utf8_unicode_ci;
GRANT ALL ON astacus_test.* TO 'astacus_test'@'localhost' IDENTIFIED BY 'astacus_test';
FLUSH PRIVILEGES;

DROP DATABASE IF EXISTS astacus_dev;
CREATE DATABASE astacus_dev CHARACTER SET utf8 COLLATE utf8_unicode_ci;
GRANT ALL ON astacus_dev.* TO 'astacus_dev'@'localhost' IDENTIFIED BY 'astacus_dev';
FLUSH PRIVILEGES;

