
# Automatic gridION

This system check for new files and download from the gridION to the computer.
A pipeline is trigger once new samples are found.

## Passwordless

Create a new keygen from the computer.

```
ssh-keygen
# Pick a location with a new name
# Enter nothing for the passphrase

```

Copy the new id to the gridION

```
ssh-copy-id ~/.ssh/gridKey.pub gridUsername@ip.address.
# Enter password to confirm
```

Test the new connection with

```
ssh gridUsername@ip.address.
```
