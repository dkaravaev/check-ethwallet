# check-ethwallet
About:

This is the simple programm that helps you to check your account balance on your Ethereum Wallet. 

You need: 

0. Unix-based system with standard Unix utilities and BASH;

1. Ethereum CLI based on GoLang (geth);

2. gdialog (Installs automatically with make install).

Installation:

Just run: **make install** as a superuser.

Usage:

0. If you want to run CLI version of programm, you need to type in terminal command **balance** standalone or with options:

i. -a - get account table
ii. -i number  get account balance by index in account table.
iii. -h - help.
iiii. -e - check existance of Ethereum CLI.

1. If you want to run UI version in terminal you need to set **DISPLAY** shell variable to empty string and type in terminal **balance_ui**.

2. If you want to run GUI version just type in terminal **balance_ui**.


