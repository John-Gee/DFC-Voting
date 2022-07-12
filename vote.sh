#!/usr/bin/bash

if [ -e vote.conf ]
then
  source vote.conf
fi

cfps="cfps/2207.txt"

if [ -z $owner ]
then
  owner=`/usr/bin/yad --entry --title "Owner" --text "Please input your owner address"`
fi

password=`/usr/bin/yad --text-align=center --text "Please input your password" --entry --hide-text`

if [ ! -z $password ]
then
  $defiPath/defi-cli -conf="$conf" walletpassphrase "$password" $timeout
  if [ 0 != $? ]
  then
    /usr/bin/yad --error --no-wrap --text "Wallet unlocking failed!"
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
    
    vote=`/usr/bin/yad --title "DFC Voter" --height=200 --list \
          --text "<big><a href='$cfpURL'>$cleanTitle</a></big>" \
          --column "Vote $i/$num" Yes Neutral No`
    echo "vote: $vote"
    if [ 0 == $? ]
    then
      vote=yes
    fi
    sign=`"$defiPath/defi-cli" -conf="$conf" signmessage "$owner" "$cfpId-$vote"`
    echo "defi-cli signmessage $owner $cfpId-$vote $sign" | xclip -selection c
  fi
  ((i++))
done < "$cfps"

"$defiPath/defi-cli" -conf="$conf" walletlock
