# 🧠 Secure SSH with Windows Hello

**By [Coding Stephan](https://svrooij.io)**
📅 *January 1, 2024*
🔗 [Original Source](https://svrooij.io/2024/01/01/secure-ssh-windows-hello/)

---

## 🔒 Overview

You probably have hardware security keys that can store SSH private keys securely to prevent theft.
But what if you could use your **face, fingerprint, or PIN** to unlock your SSH keys?
Well — you can, and it’s surprisingly simple to set up using **Windows Hello**.

---

## 🧩 Prerequisites

Make sure you have the following:

* Windows 10 or Windows 11
* TPM 2.0 (Trusted Platform Module — most modern PCs have this)
* Windows Hello (face, fingerprint, or PIN authentication enabled)
* OpenSSH for Windows **v8.9.0.0p1-Beta** or newer
* (Optional) Windows Terminal

---

## ⚙️ Install OpenSSH for Windows

The built-in OpenSSH version in Windows is outdated and doesn’t support this feature.
To get the latest version, install it using **Winget**:

```powershell
winget install --id=Microsoft.OpenSSH.Beta
```

This installs the latest beta version (at the time of writing: **v9.5.0.0p1-Beta**).
Even though it’s labeled *beta*, it’s been stable for years.
If you encounter issues, you can easily uninstall it.

> 💡 **Tip:** Restart your PC after installing OpenSSH.
> Some users report that the `ssh-agent` service doesn’t start until after a reboot.

Check your version:

```powershell
ssh -V
# Output example:
# OpenSSH_for_Windows_9.5p1, LibreSSL 3.8.2
```

---

## 🧰 (Optional) Upgrade PowerShell

This isn’t required but recommended for convenience.

```powershell
winget install --id=Microsoft.PowerShell
```

---

## 🔑 Generate a Secure SSH Key

Now for the interesting part — creating a **TPM-backed SSH key**.

Run one of the following commands:

```powershell
ssh-keygen -t ecdsa-sk
# or for a different key type:
ssh-keygen -t ed25519-sk
```

The `-t` flag defines the key type, and the `-sk` part is crucial — it instructs SSH to store the private key securely inside your TPM (or on a USB security key).

---

## 🧾 View Your Public Key

To display your new public key:

```powershell
cat ~\.ssh\id_ecdsa_sk.pub
```

Example output:

```
sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLW___moresymbols___c3NoOg== user@host
```

This is the key you’ll need to add to your server’s `~/.ssh/authorized_keys` file.

---

## 🚀 Copy Public Key to Server

Send your public key to your server:

```powershell
ssh-copy-id -i .\.ssh\id_ecdsa_sk.pub user@server
```

Replace `user@server` with your actual credentials.
You’ll be asked for the server password — this is likely the last time you’ll need it!

Alternatively, manually paste your public key into the `~/.ssh/authorized_keys` file, or add it via your hosting control panel.

---

## 🧠 Connect to the Server

Once your key is on the server, test your SSH login:

```powershell
ssh user@server
```

You’ll be prompted to confirm your presence via Windows Hello — e.g., by looking into your webcam or touching your fingerprint sensor.

If successful, you’ll see a message like:

```
User presence confirmed
```

✅ **You are now securely logged in with Windows Hello authentication.**

---

## 🛡️ Make It Even More Secure

You can improve security by disabling password authentication on the server:

```bash
# Disable password authentication in sshd_config
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# Or manually edit the file
sudo nano /etc/ssh/sshd_config
```

Restart the SSH service afterward:

```bash
sudo systemctl restart sshd -v
```

This ensures that **only key-based logins** (secured via Windows Hello) are allowed.

---

## ✅ Summary

* Installed **OpenSSH Beta**
* Generated a **TPM-backed SSH key**
* Added it to your server
* Logged in using **Windows Hello** (face/fingerprint/PIN)
* Disabled password login for extra protection

Now your SSH logins are both **secure** and **frictionless** — using **biometric verification**.

---

**Source:** [Coding Stephan – Secure SSH with Windows Hello](https://svrooij.io/2024/01/01/secure-ssh-windows-hello/)
© 2025 Coding Stephan

---
