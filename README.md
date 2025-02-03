# Introduction
This mutator prevents enemies from spawning at currently contested flags. This means that if you are capturing an enemy flag, enemies will no longer spawn at flag and sneak up on you and assassinate you.

A flag is considered contested when the flag is in the process of being captured. E.g. 2 Eagles vs 4 Ravens at a Eagle flag. IT IS NOT CONTESTED when the amount of friendlies to enemies is equivalent or less. A good way to determine when it is contested without counting is determining whether the flag's capture progress is moving.

This mutator does not affect the player. You can still spawn at contested flags.

## Isn't this just a copy of "Limit bot respawn?"
While this mutator DOES appear to do the same thing as "Limit bot respawn," it handles enemies spawning at contested flags a bit differently. According to what I've seen on the mutator's comment page, it silently kills enemies that spawn at contested flags. That means triggering other mutators that listen to kills AND potentially imbalancing the game because those enemies do not spawn anywhere else.

In this mutator, enemies that spawn at a flag that is being contested WILL be teleported to other non-contested flags INSTEAD of being killed. If all flags for the team are contested, then the members of that team will not be killed and are disabled UNTIL a flag is available for them to spawn at. If preferable, you can configure this for enemies to spawn anyways regardless of contested status.

# FAQ
### Is this mutator laggy?
If you are experiencing performance drops due to this mutator, that is because all flags for a team are currently being contested. When all flags for a team are being contested, the mutator has to constantly check to see if any flags are available for dead enemies to spawn at. As such, this MAY cause some lag HOWEVER it should not be enough to CAUSE massive performance drops. It is also such a niche scenario that a player will not encounter often so you will likely never experience this.

There might be an FPS hit whenever bots spawn; however, this should only be the case if you have a poor-performing or low end computer. From my experience, it is unnoticable.

# Source?
Source code can be found [here](https://github.com/MianReplicate/No-Spawning-on-Contested)
