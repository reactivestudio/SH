#!/bin/bash

# Project
##########################################################
httpDir="/Users/admin/www"
projectDir=""
drupalProfile="standard"
##########################################################

# Site
##########################################################
siteName='Reactive Clean'
siteSlogan='WOW WOW WOW WOW WOW'
siteLocale="ru"
##########################################################

# Database
##########################################################
dbHost="localhost"
dbName="drupal_db"
dbUser="root"
dbPassword="qwerty111"
##########################################################

# Admin
##########################################################
adminUsername="admin"
adminPassword="styereese"
adminEmail="dima.bushin@gmail.com"
##########################################################

# Modules
##########################################################
jqueryVersion="1.7"
modulesInstall=""
##########################################################

# Drush .make
##########################################################
makefile="drupal-reactive-build.make"


while [[ $# -gt 0 ]]; do
    opt="$1"
    shift;
    current_arg="$1"

    case $opt in
        "--httpDir"        ) httpDir="$1"; shift;;
        "--projectDir"     ) projectDir="$1"; shift;;
        "--drupalProfile"  ) drupalProfile="$1"; shift;;
        "--siteName"       ) siteName="$1"; shift;;
        "--siteSlogan"     ) siteSlogan="$1"; shift;;
        "--siteLocale"     ) siteLocale="$1"; shift;;
        "--dbHost"         ) dbHost="$1"; shift;;
        "--dbName"         ) dbName="$1"; shift;;
        "--dbUser"         ) dbUser="$1"; shift;;
        "--dbPassword"     ) dbPassword="$1"; shift;;
        "--adminUsername"  ) adminUsername="$1"; shift;;
        "--adminPassword"  ) adminPassword="$1"; shift;;
        "--adminEmail"     ) adminEmail="$1"; shift;;
        "--jqueryVersion"  ) jqueryVersion="$1"; shift;;
        "--modulesInstall" ) modulesInstall="$1"; shift;;
        *                  ) echo "ERROR: Invalid option: \""$opt"\"" >&2
                            exit 1;;
    esac
done


echo "Installing drupal core with $drupalProfile profile...";

# Download core
drush dl -y --destination=$httpDir --drupal-project-rename=$projectDir;

cd $httpDir/$projectDir;

# Install core, create db
drush site-install -y $drupalProfile --account-mail=$adminEmail --account-name=$adminUsername --account-pass=$adminPassword --site-name="$siteName" --site-mail=$adminEmail --locale=$siteLocale --db-url=mysql://$dbUser:$dbPassword@$dbHost/$dbName;

chmod 777 $httpDir/$projectDir"/sites/default/files";


echo "Installing modules...";

# Install drush language pack
drush dl drush_language -y


# # Install config modules
# drush -y dl \
# adminimal_admin_menu \
# append_file_info \
# backup_migrate \
# devel \
# entity \
# ckeditor \
# ctools \
# fast_dblog \
# fences \
# field_collection_fieldset \
# field_group \
# filefield_paths \
# globalredirect \
# google_analytics \
# httprl \
# jquery_update \
# l10n_update \
# lightbox2 \
# menu_block \
# metatag \
# module_filter \
# pathauto \
# redirect \
# token \
# transliteration \
# views \
# views_bulk_operations \
# webform \
# xmlsitemap \
# yamaps;


# # Install useful modules
# drush -y en \
# adminimal_admin_menu \
# append_file_info \
# entity \
# ckeditor \
# ctools \
# fast_dblog \
# fences \
# field_collection_fieldset \
# field_group \
# filefield_paths \
# globalredirect \
# googleanalytics \
# httprl \
# image \
# jquery_update \
# l10n_update \
# list \
# lightbox2 \
# menu_block \
# metatag \
# module_filter \
# number \
# pathauto \
# redirect \
# text \
# token \
# transliteration \
# views \
# views_bulk_operations \
# webform \
# xmlsitemap \
# yamaps;

drush make --no-core --contrib-destination=$httpDir/$projectDir $makefile




echo "Installing themes...";

# Install themes
drush -y dl omega maps_admin;
drush -y en omega ohm;
drush vset admin_theme maps_admin;
drush vset theme_default omega;





echo "Disabling some contrib modules and themes...";

# Disable some core modules
drush -y dis \
dblog \
color \
overlay \
toolbar \
search \
shortcut \
bartik \
seven;









echo "Installing and configure Development environment: modules and settings...";

drush -y dl \
backup_migrate \
devel \
drushify \
features \
module_builder;

drush -y en \
backup_migrate \
devel \
features \
module_builder;








echo "Setting language and download translations...";

# Set language
drush language-add $siteLocale;
drush language-default $siteLocale;
drush l10n-update;


# Pre configure settings
# disable user pictures
drush vset -y user_pictures 0;
# allow only admins to register users
drush vset -y user_register 0;
# set site slogan
drush vset -y site_slogan "$siteSlogan";

# Configure JQuery update
drush vset -y jquery_update_compression_type "min";
drush vset -y jquery_update_jquery_cdn "google";
drush -y eval "variable_set('jquery_update_jquery_version', strval($jqueryVersion));"


drush -y cron;
drush cc drush;
drush cc all -y;

echo "Install Completed.";
