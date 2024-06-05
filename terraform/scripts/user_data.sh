#!/bin/bash -e

export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
EC2_INSTANCE_ID=$(curl -s http://instance-data/latest/meta-data/instance-id)

DATA_STATE="unknown"
until [ "$${DATA_STATE}" == "attached" ]; do
  DATA_STATE=$(aws ec2 describe-volumes \
    --filters \
        Name=attachment.instance-id,Values=$${EC2_INSTANCE_ID} \
        Name=attachment.device,Values=/dev/sdh \
    --query Volumes[].Attachments[].State \
    --output text)

  sleep 5
done

# Setup /etc/fstab to automount the volume at the users home directory
echo '/dev/nvme1n1 /home/ubuntu ext4 defaults,nofail 0 2' | tee -a /etc/fstab

# Format and mount the volume, copy the data and unmount
if [[ "$(lsblk -no FSTYPE /dev/nvme1n1)" != "ext4" ]]; then
  mkfs -t ext4 /dev/nvme1n1 && mount /dev/nvme1n1 /mnt
  cp -pR /home/ubuntu/. /mnt/ && umount /mnt
fi

# Mount all volumes
mount -a

# Setup docker credentials helper
mkdir -p /home/ubuntu/.docker/
chown -R ubuntu:ubuntu /home/ubuntu/.docker/.docker

cat <<EOF > /home/ubuntu/.docker/config.json
{
  "credHelpers" : {
    "${account_id}.dkr.ecr.us-west-2.amazonaws.com" : "ecr-login"
  }
}
EOF

# Setup user SSH
echo "${ssh_key}" > /home/ubuntu/.ssh/authorized_keys
