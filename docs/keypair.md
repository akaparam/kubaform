# SSH Key Pair Guide

The lab expects an SSH public key string for the `public_key_for_key_pair` Terraform variable. That key is injected into the EC2 instances so you can SSH into them.

If you do not already have a key pair, generate one with:

```bash
ssh-keygen -t ed25519 -C "kubaform" -f ~/.ssh/kubaform_id_ed25519
```

Then use the contents of `~/.ssh/kubaform_id_ed25519.pub` as the public key value in your Terraform variables.

Using an Ed25519 key is a good fit for this lab because it is secure and easy to reproduce. It avoids the older RSA defaults and keeps the SSH configuration simple.
