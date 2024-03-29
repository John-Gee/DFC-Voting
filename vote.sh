#!/usr/bin/bash

if [ -e vote.conf ]
then
  source vote.conf
fi

cfps="cfps/2208.txt"

if [ -z $owner ]
then
  owner=`yad --entry --title "Owner" --text "Please input your owner address"`
fi

password=`yad --text-align=center --text "Please input your password" --entry --hide-text`

if [ ! -z $password ]
then
  $defiPath/defi-cli -conf="$conf" walletpassphrase "$password" $timeout
  if [ 0 != $? ]
  then
    yad --error --no-wrap --text "Wallet unlocking failed!"
    exit 1
  fi
  password=""
fi

i=0
num=0
while read -r CFP
do
  if [ $i -eq 0 ]
  then
    num=$CFP
  else
    cfpId=`echo $CFP | cut -d\| -f1`
    cfpTitle=`echo $CFP | cut -d\| -f2`
    cfpURL=`echo $CFP | cut -d\| -f3`
    cleanTitle=`echo $cfpTitle | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g'`
    
    vote=$(yad --title "DFC Voter" --height=200 --list \
          --text "<big><a href='$cfpURL'>$cleanTitle</a></big>" \
          --column "Vote $i/$num" Yes Neutral No)
    rc=$?
    # first for cancel, second for Esc
    if [ 1 == $rc ] || [ 252 == $rc ]
    then
      echo "Exiting"
      break
    fi
    vote="${vote,,}"
    if [[ "$vote" == *"neutral"* ]]; then
      vote="neutral"
    elif [[ "$vote" == *"yes"* ]]; then
      vote="yes"
    elif [[ "$vote" == *"no"* ]]; then
      vote="no"
    else
      echo "Incorrect result for the vote"
      break
    fi
    sign=$("$defiPath/defi-cli" -conf="$conf" signmessage "$owner" "$cfpId-$vote")
    echo "defi-cli signmessage $owner $cfpId-$vote $sign"
    echo "defi-cli signmessage $owner $cfpId-$vote $sign" | xclip -selection c
  fi
  ((i++))
done < "$cfps"

"$defiPath/defi-cli" -conf="$conf" walletlock
