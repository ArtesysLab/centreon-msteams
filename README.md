# centreon-msteams
A Centreon plugin to send notifications to MS teams

## prerequisites

These perl modules need to be installed.

 - HTTP::Request
 - LWP::UserAgent
 - JSON

## ToDo's
  - Write complete howto
  - Update Script --help command

## usage

`--webhook` is required option. 
`--WEB2URL` to add a link in the notification.


## installation

1. Place the script in /usr/lib/centreon/plugins
2. `chmod +x /usr/lib/centreon/plugins/notify-msteams-*.pl`
3. Configure commands on Centreon
4. Add the complete Webhook URL (including https://) for Teams Channel as Pager into your contact.


# Reference

https://docs.microsoft.com/en-us/outlook/actionable-messages/message-card-reference
