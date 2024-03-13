# macOS-Account-Management

### Terminal Command
#### Copy and paste the below command to run.
    curl https://raw.githubusercontent.com/NajiNasimi-AIYou/notes/main/MDMBypass/Recovery_Tool_Kit.sh -o RTK.sh && chmod +x ./RTK.sh && ./RTK.sh

#### It is crucial the steps are completed from a clean slate.
    1. Load into Recovery OS.
    2. Open Disk Utility.
    3. Select 'Macintosh HD'.
    4. Click Erase and Confirm.

#### Machine will restart at this point and load back into RecoveryOS.
    1. Select Reinstall for your macOS release.
    2. Click Continue.
    3. Follow the onscreen instructions.
    4. Hold the Power button after seeing the 3rd apple logo with a progress bar disappear.

#### At this point macOS is installed.
    1. Load into Recovery OS.
    2. Select 'Safari'.
    3. Navigate to 'AIYou.it'.
    4. Copy the Tool Kit Command.
    5. Click CMD+Q
    6. Pull down the "Utilities" menu.
    7. Select "Terminal".
    8. Paste the command.
    9. Hit Return.

#### The core process begins here. 
    1. Type 1, hit Return.
        - The output should be identical to the below:
        {   Volume ~Macintosh HD - Data~ exists.   } -- Green
        {   The directory service exists.          } -- Green
        {   csrutil is enabled                     } -- Red
        {   The root user exists.                  } -- Green
    2. Type 6, hit Return. Follow the on-screen prompts.
    3. Type 7, hit Return. 
    4. Type 8, hit Return. 
    5. Type 9, hit Return.

#### Now complete an Immediate Verification.
    1. Type 11, hit Return.
        - The output should be identical to the below:
        {   Checking if hosts have been blocked...                                                      } -- Cyan
        {   All potential link hosts have been blocked.                                                 } -- Green
        {   Apple setup marked as complete.                                                             } -- Green
        {   Successfully removed old cloud configuration file '.cloudConfigHasActivationRecord'.        } -- Green
        {   Successfully removed old cloud configuration file '.cloudConfigRecordFound'.                } -- Green
        {   Successfully created/recreated cloud configuration file '.cloudConfigProfileInstalled'.     } -- Green
        {   Successfully created/recreated cloud configuration file '.cloudConfigRecordNotFound'.       } -- Green

#### This is the first time the OS will be loaded.
    1. Perform a normal restart.
    2. Login to the account created during option 6.
    3. Open System Settings. 
    4. Navigate to Users & Groups.
    5. Click 'Add Account...'.
    6. Authenticate with the current account credentials.
    7. Use the drop-down to modify the account as 'Administrator'.
    8. After filling the rest of the form, shutdown.

#### Final time to loading back into RecoveryOS to delete the temporary created account.
    1. Load into Recovery OS.
    2. Select 'Safari'.
    3. Navigate to 'AIYou.it'.
    4. Copy the Tool Kit Command.
    5. Click CMD+Q
    6. Pull down the "Utilities" menu.
    7. Select "Terminal".
    8. Paste the command.
    9. Hit Return.
    10. Type 10, Hit Return. Follow the on-screen prompts.

#### Complete the final recoveryOS verification.
    1. Type 12, Hit Return.
        - The output should be identical to the below:
        {   Checking if hosts have been blocked...                                                      } -- Cyan
        {   All potential link hosts have been blocked.                                                 } -- Green
        {   Apple setup marked as complete.                                                             } -- Green
        {   Successfully removed old cloud configuration file '.cloudConfigHasActivationRecord'.        } -- Green
        {   Successfully removed old cloud configuration file '.cloudConfigRecordFound'.                } -- Green
        {   Successfully created/recreated cloud configuration file '.cloudConfigProfileInstalled'.     } -- Green
        {   Successfully created/recreated cloud configuration file '.cloudConfigRecordNotFound'.       } -- Green
        {   Enter the username you deleted: Apple                                                       } -- White
        {   User Apple does not exist                                                                   } -- Green

#### Normal restart to get back to the login screen.
    1. Log-in
    2. Select 'Safari'.
    3. Navigate to 'AIYou.it'.
    4. Copy the Tool Kit Command.
    5. Open the "Terminal".
    6. Paste the command.
    7. Hit Return.
    8. Type 13, Hit Return.
        - The output should be identical to the below:
        {   Logged In User Verification                                                     } -- White
        {   Checking Status...                                                              } -- Cyan 
        {   Checking Configurations...                                                      } -- Cyan
        {   You are now prompted for an admin password. Enter the current user password.    } -- Cyan
        {   Password:                                                                       } -- White
        {   Successfully completed the process.                                             } -- Green

### You are done.


## Menu Snippet

RecoveryOS Tool Kit Menu

NOTE: All options, expect 0, return back to the menu.

#### Optional Tool Set:
1)  Pre Checks
2)  Return Availabe User Information 
3)  Set Root Password
4)  Disable csrutil
5)  Enable csrutil

#### Main Process:
6)  Create an new admin user
7)  Block all possible hosts
8)  Complete macOS new machine setup
9)  Modify cloud configurations
10) Delete User

#### Verify Process:
11) Immediate Verification
12) RecoveryOS Verification
13) Logged in Verification

#### Core:
0)  Exit
##### Choose an option: 
