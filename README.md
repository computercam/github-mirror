# Simple Github Mirroring Script

`.mirror.sh` is a simple lightweight bash script to create a mirror of entire user's or organizations' github repositories.



## Simply create a `.conf` file and add the following configurations:

**For Organizations:**
```bash
TYPE=orgs
NAME=B00merang-Project
```

**For Users:**

```bash
TYPE=users
NAME=foobarian
CRED=foobarian:f33717f56dc045482cc26f9a8b83d1a9
```

*CRED is only needed to clone private repos, you can omit it if you don't need them.*



## Then run the script.

```bash
./mirror.sh
```



## Run it regularly to create a backup mirror.

Copy this to your `/etc/contab` to regularly execute the script everyday at 12 noon

```
0 12 * * * username cd /path/to/github/mirror/directory && ./mirror.sh
```

