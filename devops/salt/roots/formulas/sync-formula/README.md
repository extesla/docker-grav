sync-formula
============

The `sync-formula` is designed as a means of installing and configuring the [lsyncd]() service on a box. By using this service you can configure synchronization between local-and-remote (or local-and-local) directories native to the environment being provisioned without manually having to run `rsync` when files change.

Why `sync-formula`?
-------------------
As part of my regular development with Vagrant, I moved to using rsync'd folders due to the poor performance of Virtual Box shared files. While this solved my initial problem (the server became blazingly fast!) it did not solve the frustration of `rsync` on Windows (via cygwin) locking up sometimes and otherwise just being somewhat cumbersome to manage.

I.e. I really disliked having to remember to type: `vagrant rsync-auto` because, invariably I would forget.

The `sync-formula`, via `lsyncd` was conceived as a means of removing yet another barrier in development, moving progressively toward the most automated system for development environment setup as possible.
