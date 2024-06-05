# Firewall

This screen allows configuration of firewall rules. Any rules already configured are displayed on this screen on two tabs, ACCEPT/DROP RULES and FORWARD RULES.

## Creating a new rule

1. Tap the + ADD RULE button
2. Select the type of rule to create: Accept, Drop or Forward.
3. Select the protocol for the rule, TCP or UDP.
4. Enter the data specific for the rule.
5. Tap Create.

The following configuration options are offered...

**Actions**

Select **Accept**, **Drop** or **Forward**

For Accept or Drop rules, the following options are offered...

**Protocol**
Select **TCP** or **UDP**.

**Source IP Address**
Enter the IP address to be accepted or dropped.

**Port or Port Range**
Enter the Port or Port Range. A Port range is entered as P1:P2, where P1 is the first port number in the range and P2 is the last port number.

For Forward rules, the following options are slightly different...

**Protocol**
Select **TCP** or **UDP**.

**Port or Port Range**
Enter the Port or Port Range. A Port range is entered as P1:P2, where P1 is the first port number in the range and P2 is the last port number.

**Source IP address**
Enter the IP address to be forwarded.

**Local Port**
Enter the Local Port to be forwarded too.

## Deleting a firewall Rule

To delete a firewall rule, tap Remove against the rule.

