#!/usr/bin/perl

use DBI;
use MIME::Base64;
# use Data::Dumper;
use File::Temp qw/ mkstemp /;
use Sys::Syslog;
# require liblockfile-simple-perl
use LockFile::Simple qw(lock trylock unlock);

######################################################################
########## Change the following variables to fit your needs ##########

# database settings

# database backend - uncomment one of these
#our $db_type = 'Pg';
#my $db_type = 'mysql';
our $db_type = 'SQLite';

# host name
our $db_host="/var/mail/roundcube/sqlite.db";
# database name
our $db_name="";
# database username
our $db_username="";
# database password
our $db_password="";

# instead of changing this script, you can put your settings to /etc/mail/postfixadmin/fetchmail.conf
# just use perl syntax there to fill the variables listed above (without the "our" keyword). Example:
# $db_username = 'mail';
if (-f "/etc/mail/postfixadmin/fetchmail.conf") {
	require "/etc/mail/postfixadmin/fetchmail.conf";
}


#################### Don't change anything below! ####################
######################################################################

openlog("fetchmail-all", "pid", "mail");

sub log_and_die {
	my($message) = @_;
  syslog("err", $message);
  die $message;
}

# read options and arguments

$configfile = "/etc/fetchmail-all/config";

@ARGS1 = @ARGV;

while ($_ = shift @ARGS1) {
    if (/^-/) {
        if (/^--config$/) {
            $configfile = shift @ARGS1
        }
    }
}

$run_dir="/var/run/fetchmail";

# use specified config file
if (-e $configfile) {
    do $configfile;
}

if($db_type eq "Pg" || $db_type eq "mysql") {
	$dsn = "DBI:$db_type:database=$db_name;host=$db_host";
} elsif ($db_type eq "SQLite") {
	$dsn = "DBI:$db_type:dbname=$db_host";
} else {
	log_and_die "unsupported db_type $db_type";
}

$lock_file=$run_dir . "/fetchmail-all.lock";

$lockmgr = LockFile::Simple->make(-autoclean => 1, -max => 1);
$lockmgr->lock($lock_file) || log_and_die "can't lock ${lock_file}";

# database connect
if($db_type eq "Pg" || $db_type eq "mysql") {
	$dbh = DBI->connect($dsn, $db_username, $db_password) || log_and_die "cannot connect the database";
} elsif ($db_type eq "SQLite") {
	$dbh = DBI->connect($dsn) || log_and_die "cannot connect the database";
} 

if($db_type eq "Pg") {
	$sql_cond = "active = 't' AND date_part('epoch',now())-date_part('epoch',date) > poll_time*60";
} elsif($db_type eq "mysql") {
	$sql_cond = "active = 1 AND unix_timestamp(now())-unix_timestamp(date) > poll_time*60";
} elsif($db_type eq "SQLite") {
	$sql_cond = "active = 1";
}

$sql = "
	SELECT id,mailbox,src_server,src_auth,src_user,src_password,src_folder,fetchall,keep,protocol,mda,extra_options,usessl, sslcertck, sslcertpath, sslfingerprint
	FROM fetchmail
	WHERE $sql_cond
	";

my (%config);
map{
	my ($id,$mailbox,$src_server,$src_auth,$src_user,$src_password,$src_folder,$fetchall,$keep,$protocol,$mda,$extra_options,$usessl,$sslcertck,$sslcertpath,$sslfingerprint)=@$_;

	syslog("info","fetch ${src_user}@${src_server} for ${mailbox}");

	$cmd="user '${src_user}' there with password '".decode_base64($src_password)."'";
	$cmd.=" mda \"/usr/sbin/sendmail ${mailbox}\"";

	$cmd.=" keep" if ($keep);
	$cmd.=" fetchall" if ($fetchall);
	$cmd.=" ssl" if ($usessl);
	$cmd.=" sslcertck" if($sslcertck);
	$cmd.=" sslcertpath $sslcertpath" if ($sslcertck && $sslcertpath);
	$cmd.=" sslfingerprint \"$sslfingerprint\"" if ($sslfingerprint);
	$cmd.=" ".$extra_options if ($extra_options);

	$text=<<TXT;
set postmaster "postmaster"
set nobouncemail
set no spambounce
set properties ""
set syslog

poll ${src_server} with proto ${protocol}
	$cmd

TXT

  ($file_handler, $filename) = mkstemp( "/tmp/fetchmail-all-XXXXX" ) or log_and_die "cannot open/create fetchmail temp file";
  print $file_handler $text;
  close $file_handler;

  $ret=`/usr/bin/fetchmail -f $filename -i $run_dir/fetchmail.pid`;

  unlink $filename;

  if($db_type eq "Pg") {
        $sql="UPDATE fetchmail SET returned_text=".$dbh->quote($ret).", date=now() WHERE id=".$id;
  } elsif($db_type eq "mysql") {
        $sql="UPDATE fetchmail SET returned_text=".$dbh->quote($ret).", date=now() WHERE id=".$id;
  } elsif($db_type eq "SQLite") {
        $sql="UPDATE fetchmail SET returned_text=".$dbh->quote($ret).", date=datetime('now') WHERE id=".$id;
  }
  $dbh->do($sql);
}@{$dbh->selectall_arrayref($sql)};

$lockmgr->unlock($lock_file);
closelog();
