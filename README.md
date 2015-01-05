btrfs-auto-snapshot
===================

BTRFS Automatic Snapshot Service for Linux

Usage
-----
<pre>
btrfs-auto-snapshot [foo]
</pre>

btrfs-auto-snapshot is a Bash script to bring as much of the functionality
of the wonderful ZFS snapshot tool zfs-auto-snapshot to BTRFS. Designed to
cron from cron (using /etc/cron.{daily,hourly,weekly}) it automatically
creates a snapshot of th specified BTRFS filesystem (or, optionally, all of
them) and then automatically purges the oldest snapshots of that type
(hourly, daily, et al) based on a user-defined retention policy.

Snapshots are stored in a '.btrfs' directory at the root of the BTRFS
filesystem being snapped and are read-only by default.

Requirements
------------
GNU Bash
<br>GNU Coreutils
<br>GNU grep
<br>GNU gawk
<br>btrfs-progs

Bugs
----
Find a bug? Please create an issue here on GitHub at:
https://github.com/hunleyd/btrf-auto-snapshot/issues

Twitter
-------
Keep up to date on announcements and more by following Doug on Twitter, 
<a href="http://twitter.com/hunleyd">@hunleyd</a>

Authors
-------
** Douglas J Hunley**
+ G: http://goo.gl/sajR3
+ Twitter: http://twitter.com/hunleyd
+ GitHub: http://github.com/hunleyd

Copyright and license
---------------------
Copyright 2014 Douglas J Hunley.

Licensed under the GNU GPL License, Version 2.0 (the "License"); you may not use this work
except in compliance with the License. You may obtain a copy of the License in the
LICENSE file.

Unless required by applicable law or agreed to in writing, software distributed under the
License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
either express or implied. See the License for the specific language governing
permissions and limitations under the License.
