#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper; $Data::Dumper::Indent = 1;
use utf8;
use Env qw( HOME );
use JSON qw( decode_json encode_json );
use JSON::MaybeXS;
use Data::Diver qw( Dive );
use Getopt::Long;

my $host;
my $user;
my $password;
my $force_save;
GetOptions(
           'host=s'     => \$host,
           'user=s'     => \($user = 'root'),
           'password=s' => \$password,
           'force-save' => \$force_save,
          ) or die("Invalid options passed to $0\n");

my $tbg_ssh_json_file = "$HOME/.tbg/tbg_ssh/tbg_ssh.json";
my $tbg_ssh_data = do {
    open(my $json_fh, "<", $tbg_ssh_json_file) or die($!);
    local $/;
    <$json_fh>
};
my $tbg_ssh_json = decode_json($tbg_ssh_data) // {};

sub ssh_login {
    my ($host, $user, $password, $force_save) = @_;

    if (!defined($host) || !defined($user)) {
        die("ssh login failed, param is invaild.");
    }

    my $is_update = 1;
    if (!defined($password)) {
         die("ssh login failed, no password found.") if(!defined(Dive($tbg_ssh_json, $host, $user)));
         $password = $tbg_ssh_json->{$host}->{$user};
         $is_update = 0;
    }

    my @cmd_args = ("sshpass", "-p", "$password", "ssh", "-o", "StrictHostKeyChecking=no", "$user\@$host");
    print "SSH-CMD: " . Dumper(\@cmd_args);
    if (system(@cmd_args) == 0) {
        write_json_conf($host, $user, $password) if($is_update);
        return;
    }
    write_json_conf($host, $user, $password) if($is_update && $force_save);
    die("system @cmd_args failed: $?");
}

sub write_json_conf {
    my ($host, $user, $password) = @_;

    if (!defined($host) || !defined($user) || !defined($password)) {
        die("write json conf failed, param is invaild.");
    }

    if (!exists($tbg_ssh_json->{$host})) {
        $tbg_ssh_json->{$host} = { $user => $password };
    } else {
        $tbg_ssh_json->{$host}->{$user} = $password;
    }

    open(my $json_fh, ">", $tbg_ssh_json_file) or die($!);
    print $json_fh JSON::MaybeXS->new(utf8 => 1, pretty => 1)->encode($tbg_ssh_json);
    close($json_fh);
}

ssh_login($host, $user, $password, $force_save);
