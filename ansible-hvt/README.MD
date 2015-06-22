Clean (absolutely clean) Slate First Steps:

1) Create Ubuntu VMs with user: ubuntu -> add password (and rememebr it for later use)
2) Check bootstrap.ini -> still need to find a way to do this else where
3) run bootstrap.sh entering the ubuntu user's password
 a) it'll first ping and check it can ssh in with the password
 b) then it'll ask again for password (typically just enter for the sudo password)
 c) bootstrap playbook will then
   i) install the Gavin & Hvisage users
   ii) install the sudo and sshguard/fail2ban packages
   iii).. set the sudoers file
   iv)..... sshd config
 d) issue a reboot as the "normal" user (in my case that was/is hvisage with it's ssh keys already loaded and using sudo without password)
 e) lastly, doing a ping to check it worked