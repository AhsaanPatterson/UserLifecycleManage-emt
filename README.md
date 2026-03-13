<h1>Active Directory IAM User Lifecycle Lab</h1>

<h2>Description</h2>
<p>
In this project you will be presented a walk through how I created an Active Directory IAM User Lifecycle Lab using Oracle Virtual Box, Windows Server 2022, Windows 11, Active Directory, PowerShell, and CSV automation. Configuring and running this lab helped develop my understanding of user provisioning, deprovisioning, group based access control, and how identity lifecycle management works inside an Active Directory environment.
</p>

<h2>Languages and Utilities Used</h2>
<ul>
  <li>PowerShell</li>
  <li>Oracle Virtual Box</li>
  <li>Active Directory Domain Services</li>
  <li>CSV Files</li>
</ul>

<h2>Environments Used</h2>
<ul>
  <li>Windows Server 2022</li>
  <li>Windows 11</li>
</ul>

<p><b>Step 1:</b> Install Active Directory Domain Services on the Windows Server virtual machine. Inside Server Manager I selected <b>Add Roles and Features</b> and chose the role-based installation option to begin preparing the server to become the domain controller.</p>
<img src="Screenshot 2026-02-28 224946.png" alt="Install Active Directory role" width="900">

<p><b>Step 2:</b> Install the Windows 11 client virtual machine. During the setup I selected the installation option for Windows 11 to begin building the client machine that would later be joined to the domain.</p>
<img src="Screenshot 2026-03-01 122824.png" alt="Windows 11 setup option" width="900">

<p><b>Step 3:</b> Bypass the Windows 11 TPM and Secure Boot requirement inside Virtual Box. Since the VM did not meet the normal hardware requirements, I opened the registry during setup and created the required LabConfig values so the installation could continue successfully.</p>
<img src="Screenshot 2026-03-05 202636.png" alt="Windows 11 registry bypass" width="900">

<p><b>Step 4:</b> Complete the Windows 11 client installation and log into the machine locally. After the setup completed, the client was ready to be configured and joined to the Active Directory domain.</p>
<img src="Screenshot 2026-03-05 213454.png" alt="Windows 11 desktop" width="900">

<p><b>Step 5:</b> Test logging into the domain from the Windows 11 client. This confirmed the workstation was joined to the domain and domain credentials could be used to sign in successfully.</p>
<img src="Screenshot 2026-03-05 221903.png" alt="Domain login screen" width="900">

<p><b>Step 6:</b> Create the CSV file for the Joiner process. I created a <b>new_users.csv</b> file that contained the first name, last name, username, department, and role of each user that would be onboarded into Active Directory.</p>
<img src="newuserscsv.png" alt="new users csv" width="900">

<pre>
FirstName,LastName,Username,Department,Role
Mike,Ross,mross,HR,Coordinator
Havery,Spector,hspecy,Trading,Trader
Huey,Freeman,hfreeman,Finance,Analyst
</pre>

<p><b>Step 7:</b> Build the Joiner PowerShell script. I created the <b>Provision-Users.ps1</b> script inside PowerShell ISE and defined the configuration values, CSV path, log path, target path, and default password used in the automation.</p>
<img src="JoinerScriptp1.png" alt="Joiner script part 1" width="900">

<p><b>Step 8:</b> Add validation logic to the Joiner script. In this section of the script I validated that the CSV file exists before attempting to import it, which prevents the script from running without the required onboarding data.</p>
<img src="JoinerScriptp2.png" alt="Joiner script part 2" width="900">

<p><b>Step 9:</b> Add the user creation logic to the Joiner script. This part of the script checks if a user already exists and then uses <b>New-ADUser</b> to create the account and populate the user details from the CSV file.</p>
<img src="JoinerScriptp3.png" alt="Joiner script part 3" width="900">

<p><b>Step 10:</b> Run the Joiner script and validate provisioning. After executing the script, the new users were created successfully and assigned to their proper department groups.</p>
<img src="Screenshot 2026-03-07 222956.png" alt="Joiner script execution success" width="900">

<p><b>Step 11:</b> Review the provisioning log file. The log file captured the successful user creation events and the group assignments performed by the Joiner script. This provides an audit trail for the onboarding process.</p>
<img src="JoinerUserlog.png" alt="Joiner user log" width="900">

<p><b>Step 12:</b> Validate the newly created accounts in Active Directory Users and Computers. After the script execution, the new user objects appeared in Active Directory.</p>
<img src="JoinerUserValidationActiveDirect.png" alt="Joiner validation in Active Directory" width="900">

<p><b>Step 13:</b> Verify the user group memberships. I confirmed that the users were placed into the proper security groups based on the department mapping logic written into the script.</p>
<img src="JoinerUserValidationActiveDirectp2.png" alt="Joiner group membership validation" width="900">

<p><b>Step 14:</b> Create the CSV file for the Leaver process. I then built a <b>leavers.csv</b> file that contained the usernames, ticket numbers, and reasons for offboarding users from the environment.</p>
<img src="leavercsv.png" alt="leavers csv" width="900">

<pre>
Username,Ticket,Reason
mross,REQ-2001,Termination
hspecy,REQ-2002,Voluntary resignation
</pre>

<p><b>Step 15:</b> Create the empty files needed for the Leaver process. I created both the <b>leavers.csv</b> file and the <b>Leaver-Users.ps1</b> script file inside the IAMLab directory before populating them with the required content.</p>
<img src="Createleaverscript1.png" alt="Create leaver script file" width="900">

<p><b>Step 16:</b> Build the Leaver script configuration. In PowerShell ISE I defined the CSV path, the log path, and the distinguished name of the <b>DisabledUsers</b> OU that would store terminated accounts.</p>
<img src="Createleaverscript2.png" alt="Leaver script configuration" width="900">

<p><b>Step 17:</b> Add validation to the Leaver script. This section checks that the log path exists and also confirms that the DisabledUsers OU is valid before the deprovisioning process runs.</p>
<img src="Createleaverscript3.png" alt="Leaver script validation" width="900">

<p><b>Step 18:</b> Add the deprovisioning logic to the Leaver script. In this section I used PowerShell to remove users from security groups, disable their accounts, update descriptions, and move them into the DisabledUsers OU.</p>
<img src="Createleaverscript4.png" alt="Leaver script deprovisioning logic" width="900">

<p><b>Step 19:</b> Review the full Leaver script in PowerShell ISE. The script automated the complete offboarding flow for all usernames found in the <b>leavers.csv</b> file.</p>
<img src="leaverscriptp1.png" alt="Leaver script in PowerShell ISE" width="900">

<p><b>Step 20:</b> Execute the Leaver script from PowerShell. Once the script was run, users listed in the CSV were processed and their accounts were offboarded from the environment.</p>
<img src="Screenshot 2026-03-07 225639.png" alt="Leaver script execution" width="900">

<p><b>Step 21:</b> Validate that the disabled users were moved into the DisabledUsers OU. This confirmed that the script successfully completed the quarantine step of the offboarding process.</p>
<img src="leavervalidation.png" alt="Disabled users OU validation" width="900">

<p><b>Step 22:</b> Validate final group membership after offboarding. I confirmed that the offboarded user was removed from all non-default groups and only retained the default Domain Users membership.</p>
<img src="leavervalidationp2.png" alt="Disabled user final membership validation" width="900">

<h2>Project Outcome</h2>
<p>
In this lab I successfully created a small Active Directory environment that demonstrates both the Joiner and Leaver sides of identity lifecycle management. The Joiner process automated user creation and security group assignment using a CSV and PowerShell script. The Leaver process automated offboarding by removing group access, disabling the account, updating the description, and moving the user to the DisabledUsers OU.
</p>

<h2>Skills Demonstrated</h2>
<ul>
  <li>Active Directory Administration</li>
  <li>IAM User Lifecycle Management</li>
  <li>PowerShell Scripting</li>
  <li>CSV Automation</li>
  <li>Windows Server Administration</li>
  <li>Group Based Access Control</li>
  <li>User Provisioning and Deprovisioning</li>
</ul>
