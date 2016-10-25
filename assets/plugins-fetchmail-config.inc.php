<?php

// max external accounts to fetch per mailbox
$rcmail_config ['fetchmail_limit'] = 10;

// allow remote folder setting
$rcmail_config ['fetchmail_folder'] = false;

// mda for fetchmail
$rcmail_config ['fetchmail_mda'] = getenv('ROUNDCUBE_SMTP_HOST');

?>
