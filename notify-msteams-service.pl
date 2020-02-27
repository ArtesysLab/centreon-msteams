#!/usr/bin/perl
# version 0.1
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# forked from https://github.com/NeverUsedID/icinga2-msteams
# and modified for Centreon

use warnings;
use strict;
#use URI::Encode;

use Getopt::Long;
use HTTP::Request::Common qw(POST);
use HTTP::Status qw(is_client_error);
use LWP::UserAgent;
use JSON;

my %event;
my @sections;
my @actions;
my @targets;
my $webhook;
my $web2url = "https://monitoring.mydomane.com/centreon";
my $proxyUrl = '';
my %color = ( 'OK' => '008000', 'WARNING' => 'ffff00', 'UNKNOWN' => '808080','CRITICAL' => 'ff0000',
              'UP' => '008000', 'DOWN' => 'ff0000', 'UNREACHABLE' => 'ff8700');
my $webhookuid;
my $longdatetime;
my $servicename;
my $hostname;
my $hostdisplayname;
my $serviceoutput;
my $servicestate;
my $notificationtype;
my $servicedisplayname;
my $hostaddress;
my $hostaddress6;
my $notificationauthorname;
my $notificationcomment;

#
# Get command-line options
#
GetOptions (
"p=s" => \$webhook,
"WEB2URL:s" => \$web2url,
"d=s"  => \$longdatetime,
"e:s"  => \$servicename,
"l=s"  => \$hostname,
"n=s"  => \$hostdisplayname,
"o=s"  => \$serviceoutput,
"s:s"  => \$servicestate,
"t=s"  => \$notificationtype,
"u=s"  => \$servicedisplayname,
"4=s"  => \$hostaddress,
"6=s"  => \$hostaddress6,
"b=s"  => \$notificationauthorname,
"c=s"  => \$notificationcomment
)
or die("Error in command line arguments\n");

#
# Format message card
#

$event{'title'} = "Centreon Notification";
$event{'@type'} = "MessageCard";
$event{'@context'} = "https://schema.org/extensions";

$event{'themecolor'} = $color{"$servicestate"};
$event{'title'} = "$hostdisplayname : $servicename is $servicestate";
$event{'summary'} = $event{'title'};
my @facts = ({
    'name' => "Host:",
    'value' => "$hostdisplayname"
   },{
    'name' => "Service:",
    'value' => "$servicename"
   },{
    'name' => "Details:",
    'value' => "$serviceoutput"
});

my %section;
if (not length($notificationcomment)) {
 %section = ( 'facts' => \@facts );
} else {
 %section = ( 'text' => "Comment: $notificationcomment | Author: $notificationauthorname", 'facts' => \@facts );
}

push(@sections, \%section);
$event{'sections'} = \@sections;

if ($web2url ne '') {
  #replace / with %2F
  $servicename =~ s/\//%2F/g;
  $hostname =~ s/\//%2F/g;
  my $encodedURL =  "${web2url}/main.php?p=20201&o=svcd&host_name=${hostname}&service_description=${servicename}";
  
  my %target = (
        'os' => 'default',
	'uri' => "$encodedURL"
  );
  push(@targets, \%target);
  my %link = (
      '@type' => 'OpenUri',
      'name' => 'Open in Centreon',
      'targets' => \@targets
  );
  push(@actions, \%link);
  $event{'potentialAction'} = \@actions;
}
my $json = encode_json \%event;


#
# Make the request
#

my $ua = LWP::UserAgent->new;
if ($proxyUrl ne '') {
  $ua->proxy(['http','https'], "$proxyUrl");
};
$ua->timeout(15);

my $req = HTTP::Request->new('POST', $webhook);
$req->header('Content-Type' => 'application/json');
$req->content($json);
print($json);

my $s = $req->as_string;
print STDERR "Request:\n$s\n";

my $resp = $ua->request($req);
$s = $resp->as_string;
print STDERR "Response:\n$s\n";
