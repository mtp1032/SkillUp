# SkillUp

When your character experiences a skill up this addon will display a message as a highlighted line of floating text just above your character. If the action for which a skillup was awarded also resulted in acquiring an item (a herb, ore, leather, etc.,) then a second line of text indicated what was acquired is also displayed. For example, suppose your character's cooking skill increases to 51. The following text will be displayed above your character:

"Your skill in cooking has increased to 51"

This notice also appears in the Chat Frame (in fact, the addon simply reproduces what is displayed in the Chat Frame). SkillUp reacts to all profession and combat skillups (weapon skillups, defense skillups, etc.,). I wrote the addon for my own use, but it turned out to quite useful because, for me anyway, I do not like having to look down to the Chat window to see what's going on.

ASIDE:

Skillup employs WoWThreads, an asynchronous non-preemptive multithread library for World of Warcraft addon Development. In truth, this addon could have been implemented much more simply without the threads, but I was looking to write a addon that illustrated a solution to a very simple producer-consumer problem. Here's the control flow: 

(1) The main_h control thread is created by the WoW client (a thread in its own right). 

(2) The publisherThread_h is created by the control thread (main_h). 

(3) The publisherThread_h enters a wait loop waiting for a SIG_WAKEUP signal. 

(4) The main_h control thread enters a wait loop waiting for a SIG_TERMINATE signal. 

(5) The WoW client waits for the CHAT_MSG_SKILL or the CHAT_MSG_LOOT event. Upon receipt, the WoW Client inserts the skill up message (and the loot message if available) into a table and signals (SIG_WAKEUP) the publisherThread_h that an entry is available for processing. 

(6) The publisherThread_h wakes up, removes the entries from the table and publishes/writes it to display.


