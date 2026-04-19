# Backend Configuration

This repo is set up to use an S3 backend by default. That means when the lab is running normally, Terraform keeps state in S3 so you don't have to manage local state files.

But if you want to try the lab without creating an S3 bucket, or you just want to play around locally without making a big infra change, you can use `-backend=false`.

That is basically a "I just want to validate the code" mode.

```bash
terraform init -backend=false
```

I personally wouldn't recommend this for using the lab in long-term. If you are actually provisioning anything, the S3 backend is still the intended setup. The `-backend=false` option is more like a convenience escape hatch for quick local work.
