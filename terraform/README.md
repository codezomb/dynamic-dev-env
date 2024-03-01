**Run the terraform script:**

A wrapper script it used to decrypt and call terraform in a single command. This script is simply called `run`.

```shell
./run -w <workspace> -d <directory> <terraform command and arguments>
```

To view the output information from terraform:

```shell
./run -w <workspace> -d <directory> output
```
