# Plex

## Give permission to Plex to scan your video files

Plex is run under `plex` username, so you may encounter the following permission issues:

- Ubuntu restricts access to `/media/$USER` through ACL (that's the "+" when you `ls -l /media`). Solution below.
- Your drives may not be mounted to allow plex user to read it. Check it with `ls -l` on the drive or folder that cause issue, to see the group owner, group permissions and user permissions. Solution below.
- Your folder may not allow plex user or group to read it. Use `sudo chmod -R u+r FOLDER` to allow all users. Or add flex user to the folder group (see below) and use `sudo chmod -R g+r FOLDER`.

### Fix permissions to allow Plex to access `/media/$USER`

Check which group you and plex belong to:

```
groups
groups plex
```

Now, add `plex` user to your user group, and allow this group to access `/media/$USER`:

```
MYGROUP="$USER"
sudo usermod -a -G $MYGROUP plex
sudo chown $USER:$MYGROUP /media/$USER
sudo chmod 750 /media/$USER
sudo setfacl -m g:$MYGROUP:rwx /media/$USER
sudo service plexmediaserver restart
```

### Fix permissions of NTFS partitions

NTFS partitions must be mounted with appropriate read rights in `/etc/fstab`:

Check your user and group id (1000 and 1000 in example):

```
id
```

Edit `/etc/fstab` to mount the drive with read permissions for your user group and for all users (cf. umask, which is 777 less the desired "chmod" number):

```
UUID="XXXXXX" /media/USERNAME/MOUNTPOINT ntfs rw,nosuid,nodev,allow_other,default_permissions,uid=1000,gid=1000,umask=002 0 0
```

### Fix permissions of mdadm RAID disks

If you're using mdadm, this may be needed in `/etc/mdadm/mdadm.conf`:

```
CREATE mode=0775
```
