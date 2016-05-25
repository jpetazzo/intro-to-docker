<!SLIDE>
# Lesson ~~~SECTION:MAJOR~~~: Ambassadors

## Objectives

At the end of this lesson, you will be able to understand the ambassador pattern.

Ambassadors abstract the connection details for your services:

* discovery (where is my service actually running?)
* migration (what if my service has to be moved while I use it?)
* fail over (what if my service has a replication system, and I need to connect to the right instance?)
* load balancing (what if there are multiple instances of my service?)
* authentication (what if my service requires credentials, certificates, or otherwise?)

