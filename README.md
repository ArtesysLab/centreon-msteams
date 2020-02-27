# centreon-msteams
A Centreon plugin to send notifications to MS Teams


## Prerequisites

These perl modules need to be installed.

 - HTTP::Request
 - LWP::UserAgent
 - JSON


## ToDo's
  - Write complete howto
  - Update Script --help command


## Installation

1. Place the script in /usr/lib/centreon/plugins
2. `chmod +x /usr/lib/centreon/plugins/notify-msteams-*.pl`
3. Configure commands on Centreon
4. Add the complete Webhook URL (including https://) for Teams Channel as Pager into your contact.


## Usage

Examples:

Command Name: host-notify-by-msteams  
Command Type: Notification  
Command Line: $CENTREONPLUGINS$/notify-msteams-host.pl -wh 'https://outlook.office.com/webhook/CHANGEME' -nt $NOTIFICATIONTYPE$ -hn $HOSTNAME$ -hs $HOSTSTATE$ -ha $HOSTADDRESS$ -ho $HOSTOUTPUT$ -dt $DATE$  
Enable shell: Yes  

Command Name: service-notify-by-msteams  
Command Type: Notification  
Command Line: $CENTREONPLUGINS$/notify-msteams-service.pl -wh 'https://outlook.office.com/webhook/CHANGEME' -nt $NOTIFICATIONTYPE$ -sd $SERVICEDESC$ -hn $HOSTALIAS$ -ha $HOSTADDRESS$ -ss $SERVICESTATE$ -dt $DATE$ -so $SERVICEOUTPUT$  
Enable shell: Yes  


# Reference

https://docs.microsoft.com/en-us/outlook/actionable-messages/message-card-reference
