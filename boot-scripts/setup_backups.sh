#!/bin/bash
set -eux

if ! rpm -qa | grep -q cloudcoreo-directory-backup; then
    yum install -y cloudcoreo-directory-backup
fi

MY_AZ="$(curl -sL 169.254.169.254/latest/meta-data/placement/availability-zone)"
MY_REGION="$(echo ${MY_AZ%?})"

## lets set up pre and post restore scripts
script_dir="/var/tmp/cloudcoreo-directory-backup-scripts"
mkdir -p "$script_dir"
cat <<EOF > "${script_dir}/pre-restore.sh"
#!/bin/bash
/etc/init.d/jenkins stop

EOF
cat <<EOF > "${script_dir}/post-restore.sh"
#!/bin/bash
exit 0
EOF

## now we need to perform the restore
(
    cd /opt/; 
    python cloudcoreo-directory-backup.py --s3-backup-region ${BACKUP_BUCKET_REGION} --s3-backup-bucket ${BACKUP_BUCKET} --s3-prefix ${MY_REGION}/jenkins/${ENV}/${JENKINS_NAME} --directory /var/lib/jenkins --dump-dir /tmp --restore --post-restore-script "${script_dir}/post-restore.sh" --pre-restore-script "${script_dir}/pre-restore.sh"
)

## now that we are restored, lets set up the backups
echo "${JENKINS_BACKUP_CRON} ps -fwwC python | grep -q cloudcoreo-directory-backup || { cd /opt/; nohup python cloudcoreo-directory-backup.py --s3-backup-region ${BACKUP_BUCKET_REGION} --s3-backup-bucket ${BACKUP_BUCKET} --s3-prefix ${MY_REGION}/jenkins/${ENV}/${JENKINS_NAME} --directory /var/lib/jenkins --dump-dir /tmp --exclude '.*/.m2.*' --exclude '.*/workspace/.*' --exclude '.*/jobs/.*/modules/.*' & }" | crontab
