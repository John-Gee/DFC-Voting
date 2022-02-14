#!/usr/bin/bash

if [ -e vote.conf ]
then
  source vote.conf
fi

user=`whoami`
conf="/home/$user/.defi/defi.conf"
cfps="cfps/2202.txt"

if [ -z $owner ]
then
  owner=`/usr/bin/zenity --entry --title "Owner" --text "Please input your owner address"`
fi

if [ -z $password ]
then
  password=`/usr/bin/zenity --password --title "Password" --text "Please input your password"`
fi

if [ ! -z $password ]
then
  $defiPath/defi-cli -conf="$conf" walletpassphrase "$password" 600
  password=""
fi

while read -r CFP
do
  cfpId=`echo $CFP | cut -d: -f1`
  cfpTitle=`echo $CFP | cut -d: -f2 | cut -d] -f1`
  cfpURL=`echo $CFP | cut -d] -f2`
  cleanTitle=`echo $cfpTitle | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'`
  
  vote=`/usr/bin/zenity --info --no-wrap --title "Vote" \
        --text "<big><a href=\"$cfpURL\">$cleanTitle</a></big>" \
        --ok-label yes \
        --extra-button no --extra-button neutral`
  if [ 0 == $? ]
  then
    vote=yes
  fi
  sign=`"$defiPath/defi-cli" -conf="$conf" signmessage "$owner" "$cfpId-$vote"`
  echo "defi-cli signmessage $owner $cfpId-$vote $sign" | xclip -selection c
done < "$cfps"

"$defiPath/defi-cli" -conf="$conf" walletlock
