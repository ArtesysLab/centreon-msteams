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
my $notificationtype;
my $hostname;
my $hoststate;
my $hostaddress;
my $hostoutput;
my $longdatetime;
my $webUrl = '';
my $proxyUrl = '';

my %color = ( 'OK' => '008000', 'WARNING' => 'ffff00', 'UNKNOWN' => '808080','CRITICAL' => 'ff0000',
              'UP' => '008000', 'DOWN' => 'ff0000', 'UNREACHABLE' => 'ff8700');

#
# Get command-line options
#
GetOptions (
"wh=s" => \$webhook,
"nt=s" => \$notificationtype,
"hn=s" => \$hostname,
"hs:s" => \$hoststate,
"ha=s" => \$hostaddress,
"ho=s" => \$hostoutput,
"dt=s" => \$longdatetime,
"wu:s" => \$webUrl,
"pu:s" => \$proxyUrl
)
or die("Error in command line arguments\n");

#
# Format message card
#

$event{'title'} = "Centreon Notification";
$event{'@type'} = "MessageCard";
$event{'@context'} = "https://schema.org/extensions";

$event{'themecolor'} = $color{"$hoststate"};
$event{'title'} = "Host $hoststate alert for $hostname !";
$event{'summary'} = $event{'title'};
my @facts = ({
  'name' => "Type:",
  'value' => "$notificationtype"
},{
  'name' => "Host:",
  'value' => "$hostname"
},{
  'name' => "State:",
  'value' => "$hoststate"
},{
  'name' => "Address:",
  'value' => "$hostaddress"
},{
  'name' => "Info:",
  'value' => "$hostoutput"
},{
  'name' => "Date/Time:",
  'value' => "$longdatetime"
});

my %section;
%section = ( 'facts' => \@facts );
push(@sections, \%section);
$event{'sections'} = \@sections;

# add button if -wu option is used

if ($webUrl ne '') {
  #replace / with %2F
  $hostname =~ s/\//%2F/g;
  my $encodedURL =  "$webUrl/main.php?p=20202&o=hd&host_name=${hostname}";
  my %target = (
        'os' => 'default',
	'uri' => $encodedURL
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
