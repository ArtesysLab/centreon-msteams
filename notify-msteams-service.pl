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
my $servicedesc;
my $hostname;
my $hostaddress;
my $servicestate;
my $longdatetime;
my $serviceoutput;
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
"sd=s" => \$servicedesc,
"hn=s" => \$hostname,
"ha=s" => \$hostaddress,
"ss=s" => \$servicestate,
"dt=s" => \$longdatetime,
"so=s" => \$serviceoutput,
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

$event{'themecolor'} = $color{"$servicestate"};
$event{'title'} = "$notificationtype alert - $hostname/$servicedesc is $servicestate";
$event{'summary'} = $event{'title'};
my @facts = ({
  'name' => "Notification Type:",
  'value' => "$notificationtype"
},{
  'name' => "Service:",
  'value' => "$servicedesc"
},{
  'name' => "Host:",
  'value' => "$hostname"
},{
  'name' => "Address:",
  'value' => "$hostaddress"
},{
  'name' => "State:",
  'value' => "$servicestate"
},{
  'name' => "Date/Time:",
  'value' => "$longdatetime"
},{
  'name' => "Additional Info:",
  'value' => "$serviceoutput"
});

my %section;
%section = ( 'facts' => \@facts );
push(@sections, \%section);
$event{'sections'} = \@sections;

# add button if -wu option is used

if ($webUrl ne '') {
  #replace / with %2F
  $servicedesc =~ s/\//%2F/g;
  $hostname =~ s/\//%2F/g;
  my $encodedURL =  "${webUrl}/main.php?p=20201&o=svcd&host_name=${hostname}&service_description=${servicedesc}";
  
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
