#!/bin/bash

# Help menu
print_help() {
cat <<-HELP
This script is used to fix the file permissions of a Drupal platform. You need
to provide the following argument:

  --root: Path to the root of your Drupal installation.

Usage: (sudo) ${0##*/} --root=PATH
Example: (sudo) ${0##*/} --drupal_path=/var/aegir/platforms/drupal-7.50
HELP
exit 0
}

if [ $(id -u) != 0 ]; then
  printf "Error: You must run this with sudo or root.\n"
  exit 1
fi

drupal_root=${1%/}

# Parse Command Line Arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --root=*)
        drupal_root="${1#*=}"
        ;;
    --help) print_help;;
    *)
      printf "Error: Invalid argument, run --help for valid arguments.\n"
      exit 1
  esac
  shift
done

if [ -z "${drupal_root}" ] || [ ! -d "${drupal_root}/sites" ] || [ ! -f "${drupal_root}/core/modules/system/system.module" ] && [ ! -f "${drupal_root}/modules/system/system.module" ]; then
  printf "Error: Please provide a valid Drupal root directory.\n"
  print_help
  exit 1
fi

cd $drupal_root

printf "Changing permissions of all directories inside "${drupal_root}" to "750"...\n"
find . -type d -exec chmod 750 '{}' \;

printf "Changing permissions of all files inside "${drupal_root}" to "640"...\n"
find . -type f -exec chmod 640 '{}' \;

printf "Changing permissions of "files" directories in "${drupal_root}/sites" to "770"...\n"
cd sites
find . -type d -name files -exec chmod 770 '{}' \;

printf "Changing permissions of all files inside all "files" directories in "${drupal_root}/sites" to "660"...\n"
printf "Changing permissions of all directories inside all "files" directories in "${drupal_root}/sites" to "770"...\n"
for x in ./*/files; do
  find ${x} -type f -exec chmod 660 '{}' \;
  find ${x} -type d -exec chmod 770 '{}' \;
done
echo "Done setting proper permissions on files and directories."
