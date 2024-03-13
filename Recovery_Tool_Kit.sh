#!/bin/bash

# Color Code
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NOCOLOUR='\033[0m'

# Global Variables
ds_path="/Volumes/Macintosh HD - Data/private/var/db/dslocal/nodes/Default"
user_path="/Local/Default/Users"

ColourRed(){
    echo -ne $RED$1$NOCOLOUR
    # ColourRed 'comment goes here\n'
}
ColourGreen(){
	echo -ne $GREEN$1$NOCOLOUR
    # ColourGreen 'comment goes here\n'
}
ColourCyan(){
	echo -ne $CYAN$1$NOCOLOUR
    # ColourCyan 'comment goes here\n'
}

check_root_user_exists() {
  if dscl -f "$ds_path" localhost -read $user_path/root > /dev/null 2>&1; then
    ColourGreen "The root user exists.\n"
    if dscl -f "$ds_path" localhost -read $user_path/root UserShell | grep -v "/usr/bin/false" > /dev/null; then
      ColourGreen "The root user is an authorized user with a valid shell.\n"
    else
      ColourRed "The root user is not authorized or has no valid shell.\n"
    fi
  else
    ColourRed "The root user does not exist.\n"
  fi
}

check_csrutil_status(){
    if csrutil status | grep -q ' enabled'; then
        ColourRed "csrutil is enabled\n"
    else
        ColourGreen "csrutil is disabled\n"
    fi
}

check_drive_exists(){
    if diskutil list | grep -q ' Macintosh HD - Data '; then
        ColourGreen 'Volume ~Macintosh HD - Data~ exists.\n'
    else
        ColourRed 'Volume ~Macintosh HD - Data~ does not exist.\n'
    fi
}

check_directory_exists(){
  if [[ -d "$ds_path" ]]; then
    ColourGreen 'The directory service exists.\n'
  else
    ColourRed 'The directory service does not exist.\n'
  fi
}

returnUserInfo(){
    dscl -f "$ds_path" localhost -list $user_path | grep -v '^_' | while read user; do
        ColourCyan "[Start]----------------\n"
        ColourCyan "User: $user\n"
        RealName="$(dscl -f "$ds_path" localhost -read $user_path/"$user" RealName)"
        UniqueID="$(dscl -f "$ds_path" localhost -read $user_path/"$user" UniqueID)"
        PrimaryGroupID="$(dscl -f "$ds_path" localhost -read $user_path/"$user" PrimaryGroupID)"
        NFSHomeDirectory="$(dscl -f "$ds_path" localhost -read $user_path/"$user" NFSHomeDirectory)"
        RecordName="$(dscl -f "$ds_path" localhost -read $user_path/"$user" RecordName)"
        GroupMembership="$(id -Gn "$user")"

        echo "$RealName"
        echo "$UniqueID"
        echo "$PrimaryGroupID"
        echo "GroupMembership: $GroupMembership"
        echo "$NFSHomeDirectory"
        echo "$RecordName"
        ColourCyan "[End]----------------\n"
    done
}

pre_checks(){
    check_drive_exists
    check_directory_exists
    check_csrutil_status
    check_root_user_exists
}

setRootPassword() {
    if [ -d "$ds_path" ]; then
        ColourCyan "Setting root password...\n"
        read -s -p "Please enter the new root password: " root_password
        echo
        if dscl -f "$ds_path" localhost -passwd "$user_path/root" "$root_password"; then
            ColourGreen "Root password set successfully.\n"
        else
            ColourRed "Failed to set root password. Please check the username and try again.\n"
        fi
    else
        ColourRed "Directory '$ds_path' does not exist. Cannot set root password.\n"
    fi
}

check_user_account() {
    local user_check=$(dscl -f "$ds_path" localhost -list "$user_path" | grep -w "$1")
    if [ "$user_check" != "" ]; then
        ColourRed "User $1 exists.\n"
        return 1
    else
        ColourGreen "User $1 does not exist\n"
    fi
}

create_user() {
    ColourCyan "Create a new user\n"
    read -p "Enter Real Name (Default: User):" realName
    realName="${realName:=User}"
    read -p "Enter username (WRITE WITHOUT SPACES) (Default: User):" username
    username="${username:=User}"

    check_user_account $username

    if dscl -f "$ds_path" localhost -create "$user_path/$username"; then
        ColourGreen "User $username created.\n"
    else
        ColourRed "Failed to create user $username.\n"
        return 1
    fi

    dscl -f "$ds_path" localhost -create "$user_path/$username" UserShell "/bin/zsh"
    dscl -f "$ds_path" localhost -create "$user_path/$username" RealName "$realName"
    dscl -f "$ds_path" localhost -create "$user_path/$username" UniqueID "501"
    dscl -f "$ds_path" localhost -create "$user_path/$username" PrimaryGroupID "20"
    mkdir -p "/Volumes/Macintosh HD - Data/Users/$username" && \
    dscl -f "$ds_path" localhost -create "$user_path/$username" NFSHomeDirectory "/Users/$username"
    read -s -p "Please enter the new password for $username (MUST ENTER PASSWORD): " password
    echo
    if dscl -f "$ds_path" localhost -passwd "$user_path/$username" "$password"; then
        ColourGreen "Password set for $username.\n"
    else
        ColourRed "Failed to set password for $username.\n"
        return 1
    fi
    if dscl -f "$ds_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"; then
        ColourGreen "User $username added to admin group.\n"
    else
        ColourRed "Failed to add $username to admin group.\n"
        return 1
    fi
}

disableCsrutil() {
    read -p "Enter Authorized User (Default: root):" authorizedUser
    authorizedUser="${authorizedUser:=root}"
    echo "Checking if csrutil is enabled..."
    if csrutil status | grep -q "enabled"; then
        ColourCyan "Attempting to disable csrutil...\n"
        printf "y\n$authorizedUser\n" | csrutil disable
        if csrutil status | grep -q "disabled"; then
            ColourGreen "csrutil has been disabled.\n"
        fi
    else
        ColourRed "csrutil is already disabled or not available in this mode.\n"
    fi
}

enableCsrutil() {
    read -p "Enter Authorized User (Default: root):" authorizedUser
    authorizedUser="${authorizedUser:=root}"
    echo "Checking if csrutil is disabled..."
    if csrutil status | grep -q "disabled"; then
        ColourCyan "Attempting to enable csrutil...\n"
        printf "y\n$authorizedUser\n" | csrutil enable
        if csrutil status | grep -q "enabled"; then
            ColourGreen "csrutil has been enabled.\n"
        fi
    else
        ColourRed "csrutil is already enabled or not available in this mode.\n"
    fi
}

block_hosts() {
    local host='/Volumes/Macintosh HD/etc/hosts'
    if echo "0.0.0.0 gdmf.apple.com" >> "$host" &&
        # echo "0.0.0.0 identity.apple.com" >> "$host" &&
        # echo "0.0.0.0 *.business.apple.com" >> "$host" &&
        # echo "0.0.0.0 *.school.apple.com" >> "$host" &&
        # echo "0.0.0.0 axm-adm-enroll.apple.com" >> "$host" &&
        # echo "0.0.0.0 axm-adm-mdm.apple.com" >> "$host" &&
        # echo "0.0.0.0 axm-adm-scep.apple.com" >> "$host" &&
        echo "0.0.0.0 acmdm.apple.com" >> "$host" &&
        echo "0.0.0.0 albert.apple.com" >> "$host" &&
        echo "0.0.0.0 deviceenrollment.apple.com" >> "$host" &&
        echo "0.0.0.0 mdmenrollment.apple.com" >> "$host" &&
        echo "0.0.0.0 iprofiles.apple.com" >> "$host"; then
        ColourGreen "Hosts blocked successfully.\n"
    else
        ColourRed "Failed to block hosts.\n"
    fi
}

check_hosts_block() {
    ColourCyan "Checking if hosts have been blocked...\n"
    local host='/Volumes/Macintosh HD/etc/hosts'
    local domains=(
        "0.0.0.0 gdmf.apple.com"
        # "0.0.0.0 identity.apple.com"
        # "0.0.0.0 *.business.apple.com"
        # "0.0.0.0 *.school.apple.com"
        # "0.0.0.0 axm-adm-enroll.apple.com"
        # "0.0.0.0 axm-adm-mdm.apple.com"
        # "0.0.0.0 axm-adm-scep.apple.com"
        "0.0.0.0 acmdm.apple.com"
        "0.0.0.0 albert.apple.com"
        "0.0.0.0 deviceenrollment.apple.com"
        "0.0.0.0 mdmenrollment.apple.com"
        "0.0.0.0 iprofiles.apple.com"
    )
    
    for domain in "${domains[@]}"; do
        if ! grep -q "$domain" "$host"; then
            ColourRed "Link host ~$domain~ is not blocked, potential leaks on domains exist.\n"
            return 1
        fi
    done
    
    ColourGreen "All potential link hosts have been blocked.\n"
    return 0
}

complete_setup() {
    if touch /Volumes/Macintosh\ HD\ -\ Data/private/var/db/.AppleSetupDone; then
        ColourGreen "Apple setup marked as complete.\n"
    else
        ColourRed "Failed to mark Apple setup as complete.\n"
    fi
}

check_apple_setup() {
    local file_path='/Volumes/Macintosh HD - Data/private/var/db/.AppleSetupDone'
    if [[ -e "$file_path" ]]; then
        ColourGreen "Apple setup marked as complete.\n"
    else
        ColourRed "Failed to mark Apple setup as complete.\n"
    fi
}

cloud_config() {
    local config_path='/Volumes/Macintosh HD/var/db/ConfigurationProfiles/Settings'
    if [ -f "$config_path/.cloudConfigHasActivationRecord" ] || [ -f "$config_path/.cloudConfigRecordFound" ]; then
        rm -f "$config_path/.cloudConfigHasActivationRecord" &&
        rm -f "$config_path/.cloudConfigRecordFound" &&
        ColourGreen "Old cloud configuration files removed successfully.\n"
    fi
    touch "$config_path/.cloudConfigProfileInstalled" &&
    touch "$config_path/.cloudConfigRecordNotFound" &&
    ColourGreen "Cloud configuration files created/recreated successfully.\n" ||
    { ColourRed "Failed to modify cloud configuration.\n"; return 1; }
}

check_cloud_config() {
    local config_path='/Volumes/Macintosh HD/var/db/ConfigurationProfiles/Settings'
    local old_files=(
        ".cloudConfigHasActivationRecord"
        ".cloudConfigRecordFound"
    )
    local new_files=(
        ".cloudConfigProfileInstalled"
        ".cloudConfigRecordNotFound"
    )
    
    for old_file in "${old_files[@]}"; do
        if [[ -e "$config_path/$old_file" ]]; then
            ColourRed "Failed to remove old cloud configuration file '$old_file'.\n"
        else
            ColourGreen "Successfully removed old cloud configuration file '$old_file'.\n"
        fi
    done

    for new_file in "${new_files[@]}"; do
        if [[ ! -e "$config_path/$new_file" ]]; then
            ColourRed "Failed to create/recreate cloud configuration file '$new_file'.\n"
        else
            ColourGreen "Successfully created/recreated cloud configuration file '$new_file'.\n"
        fi
    done
}

delete_user() {
    read -p "Enter the username to delete: " username

    home_dir="/Volumes/Macintosh HD/Users/$username"
    full_user_path="$user_path/$username"
    uniqueID="$(dscl -f "$ds_path" localhost -read "$full_user_path" UniqueID | cut -d ' ' -f 2)"

    if [ -d "$home_dir" ]; then
    echo "Removing home directory for user $username..."
    rm -rf "$home_dir" && ColourGreen "Directory removed successfully.\n" || { ColourRed "Failed to remove directory.\n"; return 1; }
    else
    ColourCyan "Home directory for $username does not exist. Skipping removal.\n"
    fi

    if dscl -f "$ds_path" localhost -read "$full_user_path" &>/dev/null; then
    echo "Deleting user $username from dscl..."
    dscl -f "$ds_path" localhost -delete "$full_user_path" && ColourGreen "User deleted successfully.\n" || { ColourRed "Failed to delete user.\n"; return 1; }
    else
    ColourCyan "User $username does not exist in dscl. Skipping deletion."
    fi

    if [ -n "$uniqueID" ]; then
        echo "Checking if UniqueID $uniqueID for user ~$username~ is freed..."
        if ! dscl -f "$ds_path" localhost -list $full_user_path UniqueID | grep -q "$uniqueID" &>/dev/null; then
            ColourGreen "UniqueID $uniqueID is freed."
        else
            ColourRed "UniqueID $uniqueID is still in use."
        fi
    else
        echo "No UniqueID found for user $username."
    fi
}

check_deleted_user() {
    read -p "Enter the username you deleted: " username
    check_user_account $username
}

post_check() {
    check_hosts_block
    check_apple_setup
    check_cloud_config
    check_deleted_user
}

immediate_check() {
    check_hosts_block
    check_apple_setup
    check_cloud_config
}

check_enrollment_status() {
    echo
    echo "Logged In User Verification"
    ColourCyan "Checking Status...\n"
    ColourCyan "Checking Configurations...\n"
    local status_output=$(profiles status -type enrollment &> /dev/null)
    ColourCyan "You are now prompted for an admin password. Enter the current user password.\n"
    local show_output=$(sudo profiles show -type enrollment &> /dev/null)

    if [[ "$status_output" == *"Enrolled via DEP: Yes"* ]] && \
       [[ "$status_output" == *"MDM enrollment: Yes"* ]] && \
       [[ "$show_output" == *"ConfigurationURL"* ]]; then
        ColourRed "Process failed and this machine has remote configurations.\n"
    else
        ColourGreen "Successfully completed the process.\n"
    fi
}

menu(){
echo -ne "
$(ColourCyan 'RecoveryOS Tool Kit Menu')

NOTE: All options, expect 0, return back to the menu.

$(ColourCyan 'Optional Tool Set:')
$(ColourGreen '1)')  Pre Checks
$(ColourGreen '2)')  Return Availabe User Information 
$(ColourGreen '3)')  Set Root Password
$(ColourGreen '4)')  Disable csrutil
$(ColourGreen '5)')  Enable csrutil

$(ColourCyan 'Main Process:')
$(ColourGreen '6)')  Create an new admin user
$(ColourGreen '7)')  Block all possible hosts
$(ColourGreen '8)')  Complete macOS new machine setup
$(ColourGreen '9)')  Modify cloud configurations
$(ColourGreen '10)') Delete User

$(ColourCyan 'Verify Process:')
$(ColourGreen '11)') Immediate Verification
$(ColourGreen '12)') RecoveryOS Verification
$(ColourGreen '13)') Logged in Verification

$(ColourCyan 'Core:')
$(ColourGreen '0)')  Exit
$(ColourCyan 'Choose an option:') "
        read a
        case $a in
            1) pre_checks ; menu ;;
            2) returnUserInfo ; menu ;;
            3) setRootPassword ; menu ;;
            4) disableCsrutil ; menu ;;
            5) enableCsrutil ; menu ;;
            6) create_user ; menu ;;
            7) block_hosts ; menu ;;
            8) complete_setup ; menu ;;
            9) cloud_config ; menu ;;
            10) delete_user ; menu ;;
            11) immediate_check ; menu ;;
            12) post_check ; menu ;;
            13) check_enrollment_status ; menu ;;
			0) exit 0 ;;
			*) echo -e $RED"Wrong option."$NOCOLOUR; menu;;
        esac
}

menu
