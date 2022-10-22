# SkillUp

When your character experiences a skill up this addon will display a message as a highlighted line of floating text just above your character. If the action for which a skillup was awarded also resulted in acquiring an item (a herb, ore, leather, etc.,) then a second line of text is displayed showing what was acquired. For example, suppose your character's cooking skill increases to 51. The following text will be displayed above your character:

"Your skill in cooking has increased to 51"

This notice also appears in the Chat Frame (in fact, the addon simply reproduces what is displayed in the Chat Frame). SkillUp reacts to all profession and combat skillups (weapon skillups, defense skillups, etc.,). I wrote the addon for my own use, but it turned out to quite useful because, for me anyway, I do not like having to look down to the Chat window to see what's going on.

ASIDE:

Skillup employs WoWThreads, an asynchronous non-preemptive multithread library for World of Warcraft addon Development. In truth, this addon could have been implemented much more simply without the threads, but I was looking to write a addon that illustrated a solution to a very simple producer-consumer problem. Here's the control flow: 


