# Contabo VPS Snapshot

Simple bash script to snapshot your [Contabo VPS](https://contabo.com/en/vps/) using [Contabo API](https://api.contabo.com/).

To use it:

- `git clone`
- copy `config.conf.template` to `config.conf`
- put your Contabo credentials in `config.conf` 
- excecute the script: `./contabo_snapshot.sh`
- that's all

The script delete the oldest snapshot and create a new snapshot.
