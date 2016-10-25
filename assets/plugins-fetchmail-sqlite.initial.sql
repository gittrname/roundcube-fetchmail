CREATE TABLE IF NOT EXISTS  `fetchmail` (
  `id` integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  `mailbox` text(255) NOT NULL,
  `active` integer(1) NOT NULL DEFAULT '1',
  `src_server` text NOT NULL,
  `src_auth` text NOT NULL DEFAULT 'password',
  `src_user` text NOT NULL,
  `src_password` text NOT NULL,
  `src_folder` text NOT NULL,
  `poll_time` integer(11) NOT NULL DEFAULT '10',
  `fetchall` integer(1) NOT NULL DEFAULT '0',
  `keep` integer(1) NOT NULL DEFAULT '1',
  `protocol` text NOT NULL DEFAULT 'IMAP',
  `usessl` integer(1) NOT NULL DEFAULT '1',
  `sslcertck` integer(1) NOT NULL DEFAULT '0',
  `sslcertpath` text /*!40100 CHARACTER SET utf8 */ DEFAULT '',
  `sslfingerprint` text /*!40100 CHARACTER SET latin1 */ DEFAULT '',
  `extra_options` text,
  `returned_text` text,
  `mda` text NOT NULL DEFAULT '',
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  check (`src_auth` = 'password' or `src_auth` = 'kerberos_v5' or `src_auth` = 'kerberos' or `src_auth` = 'kerberos_v4' or `src_auth` = 'gssapi' or `src_auth` = 'cram-md5' or `src_auth` = 'otp' or `src_auth` = 'ntlm' or `src_auth` = 'msn' or `src_auth` = 'ssh' or `src_auth` = 'any'),
  check (`protocol` = 'POP3' or `protocol` = 'IMAP' or `protocol` = 'POP2' or `protocol` = 'ETRN' or `protocol` = 'AUTO')
);

--CREATE TRIGGER `t_date_upd`
--AFTER UPDATE ON `fetchmail`
--BEGIN
--  UPDATE `date`
--  SET UPDATE_TIMESTAMP=DATETIME('NOW', 'LOCALTIME')
--  WHERE NODE_ID=NEW.NODE_ID;
--END;

