
This project is for setting up remote development environments in AWS using EC2 and EBS. It can easily be expanded to incorporate other AWS services.

## Build the docker container

All dependencies are installed via docker container and bash script. You will need, at minimum docker installed. If you want to use encrypted terraform values, then you will need [sops](https://github.com/getsops/sops). This run script will handle descrypting the file for you. I recommend AWS KMS for the encryption key.

```shell
docker build -t dev-env .
```

## Build the amazon image

Once the docker image is built, you may shell into the container.

```shell
docker run --rm -it  -v <path to .aws folder>:/root/.aws -v $PWD:/workspace dev-env bash
```

Once inside the container you can build the development image. This image is setup for some basic depenendcies including, Ruby, NodeJS, and Docker. It is setup with SSH access and uses Google Authenticator and private keys to handle authentication. This image is built using packer, and can be customized, or new custom images can be defined and built.

```shell
cd /workspace/ami-image
packer init .
packer build -var prefix=<uniq prefix> .
```

## Launch the environment

Before launching the environment create a file in `terraform/terraform.tfvars`, or if you prefer to have an encrypted version you can create a file in `terraform/secrets/<workspace>.tfvars` and encrypt it using `sops`.

The file should look like the following, you can customize as necessary:

```hcl
prefix = "<unique index>"
user = {
  ssh_key       = "<public SSH key>"
  instance_type = "t2.micro"
  volume_size   = 500
}
```

To launch the development environment first run a plan.

```shell
./terraform/run plan
```

If everything looks good apply the plan.

```shell
./terraform/run apply
```
