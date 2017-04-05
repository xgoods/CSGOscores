#!/bin/bash

#sort tmpGameResultsComma.txt | uniq -u

#start on parsing results.html
date=`date`
dateSplit=()
dateIndex=0
folderDateIndex=0
resultDate=()
resultDateIndex=0
gameFolderDate2=()
#date +%B' '%C' '%Y

start=`date +%s`

function getTmpMatchResults() {
    
    if [ -d ~/Desktop/csgostuff ]
    then
        :
    else
        mkdir ~/Desktop/csgostuff
    fi
    
    if [ -d ~/Desktop/csgostuff/games ]
    then
        :
    else
        mkdir ~/Desktop/csgostuff/games
    fi
    
    cd ~/Desktop/csgostuff
    echo 'program run '$date >> log.txt
    wget -qO results.html http://www.hltv.org/results/

    cat results.html | while read resultLine
    do
        echo $resultLine | grep '<div class="matchListDateBox"' | sed 's/<div class="matchListDateBox">.*,\ //g' | sed 's/<\/div>\ <div class="matchListBox"\ xmlns="http:\/\/www.w3.org\/1999\/html">//g' | sed 's/<br\/>//g'
        
        echo $resultLine | grep 'title="Match page"' | grep -o 'href="/match/[0-9]*-.*' | sed 's/href="//g' | sed 's/">Details<\/a><\/div> <\/div>//g' 
    done >> tmpmatchresults.txt
}

getTmpMatchResults

function getResultData() {
    while IFS='' read -r tmpResultLine
    do
        if [[ $tmpResultLine =~ `date +%B` || $tmpResultLine =~ `date --date="$(date +%Y-%m-%d) +1 month" +%B` || $tmpResultLine =~ `date --date="$(date +%Y-%m-%d) -1 month" +%B`  ]]
        then
            echo $tmpResultLine >> matchresults.txt
        else
           
        echo 'http://www.hltv.org'$tmpResultLine >> matchresults.txt
        fi
        
    done < tmpmatchresults.txt
}

getResultData

function getGames() {
    while OK='' read -r resultLine
    do
        if [[ $resultLine =~ `date +%B` || $resultLine =~ `date --date="$(date +%Y-%m-%d) +1 month" +%B` || $resultLine =~ `date --date="$(date +%Y-%m-%d) -1 month" +%B`  ]]
        then
            gameFolderDate=$(echo "$resultLine" | tr -d '[:space:]')
            
            gameFolderDate2[folderDateIndex]+=$gameFolderDate
            ((folderDateIndex++))
            if [ -d ~/Desktop/csgostuff/games/$gameFolderDate ]
            then
                :
            else
                mkdir ~/Desktop/csgostuff/games/$gameFolderDate
            fi
            
            gameFiles=~/Desktop/csgostuff/games/$gameFolderDate
        fi
        gameGet=$(echo $resultLine | grep '/match/[0-9]*')
        
        alreadyExists=$(echo $gameFiles/$gameGet | sed 's/http:\/\/www.hltv.org\/match\///g')
        
        if [ -e "$alreadyExists" ]
        then
            :
        else
            wget -qP $gameFiles $gameGet
        
        fi
        
    done < matchresults.txt
}


getGames

function getTmpGameResults() {
    for d in $date
    do
        dateSplit[dateIndex]+=$d
        ((dateIndex++))
    done
 
    case ${dateSplit[1]} in 
        "Mar") month="March";;
        "Apr") month="April";;
        "May") month="May";;
        "Jun") month="June";;
        "Jul") month="July";;
        "Aug") month="August";;
        "Sep") month="September";;
        "Oct") month="October";;
        "Nov") month="November";;
        "Dec") month="December";;
        "Jan") month="January";;
        "Feb") month="February";;
    esac
    
    gameCount=0
    finalDate='[0-9]*.* of '$month' '${dateSplit[5]}
    prevDate='[0-9]*.* of '`date --date="$(date +%Y-%m-%d) -1 month" +%B`' '${dateSplit[5]}
    nextDate='[0-9]*.* of '`date --date="$(date +%Y-%m-%d) +1 month" +%B`' '${dateSplit[5]}
    gameFolder=~/Desktop/csgostuff/games
    IFS=$'\n'
    
    for subd in ${gameFolderDate2[@]} 
    do 
        for f in $gameFolder/$subd/*
        do
            cat $f | while read gameLine
            do
                echo $gameLine | grep "$finalDate" | sed 's/<\/span>//g' | sed '/^$/d' >> tmpGameResults.txt
            
                echo $gameLine | grep "$prevDate" | sed 's/<\/span>//g' | sed '/^$/d' >> tmpGameResults.txt
            
                echo $gameLine | grep "$nextDate" | sed 's/<\/span>//g' | sed '/^$/d' >> tmpGameResults.txt
                
                echo $gameLine | egrep -o '([01]?[0-9]|2[0-3]):[0-5][0-9]    </span>' | sed 's/    <\/span>//g' >> tmpGameResults.txt
                
                echo $gameLine | grep -o 'href="/?pageid=[0-9]*&amp;teamid=[0-9]*">.* <' | sed 's/href="\/?pageid=[0-9]*&amp;teamid=[0-9]*">//g' | sed 's/<\/a><\/span> <//g' >> tmpGameResults.txt
    
                echo $gameLine | grep -o 'matchScore winningScore">[0-9]*' | sed 's/matchScore winningScore">//g' >> tmpGameResults.txt
         
                echo $gameLine| grep -o 'matchScore losingScore">[0-9]*' | sed 's/matchScore losingScore">//g' >> tmpGameResults.txt
         
                echo $gameLine | grep -o 'matchScore drawScore">[0-9]*' | sed 's/matchScore drawScore">//g' >> tmpGameResults.txt
         
                echo $gameLine | grep -o 'href="/?pageid=[0-9]*&amp;eventid=[0-9]*">.*</a></div>' | sed 's/href="\/?pageid=[0-9]*&amp;eventid=[0-9]*">//g' | sed 's/<\/a><\/div>//g' >> tmpGameResults.txt
         
                echo $gameLine | grep -o 'src="http://static.hltv.org//images/hotmatch/.*' | sed 's/src="http:\/\/static.hltv.org\/\/images\/hotmatch\///g' | sed 's/.png"\/><\/div>\      <div class="hotmatchbox" style="margin-top: -7px;font-size: 12px;width:270px;border-top:0;">//g' | sed 's/.png"\/><\/div>\    <div style="margin-top:3px;"><\/div>//g' >> tmpGameResults.txt
                
                echo $gameLine | grep -x '                  <span style="color: green">[0-9]*</span>:<span' | sed 's/<span\ style="color:\ green">//g' | sed 's/<\/span>:<span//g' >> tmpGameResults.txt 
             
                echo $gameLine | grep -x '            style="color: red">[0-9]*</span>' | sed 's/style="color:\ red">//g' | sed 's/<\/span>//g' | sed '/^$/d' >> tmpGameResults.txt
             
             
                echo $gameLine | grep -x '                  <span style="color: red">[0-9]*</span>:<span' | sed 's/<span\ style="color:\ red">//g' | sed 's/<\/span>:<span//g' >> tmpGameResults.txt
             
                echo $gameLine | grep -x '            style="color: green">[0-9]*</span>' | sed 's/style="color:\ green">//g' | sed 's/<\/span>//g' | sed '/^$/d' >> tmpGameResults.txt
             
            done
    
            echo 'Game Complete' >> tmpGameResults.txt 
            echo 'game '$gameCount' complete' >> log.txt && ((gameCount++))
        done
    done
}

getTmpGameResults

function getTmpGameResultsComma() {
    while read tmpGameResultsLine
    do
        if [[ ${#tmpGameResultsLine} -lt 500 ]]
        then
            printf '%s,' "$tmpGameResultsLine" | tr -d '[:space:]' >> tmpGameResultsComma.txt
        fi
        
        if [[ $tmpGameResultsLine =~ Game.*Complete ]]
        then
            echo "" >> tmpGameResultsComma.txt
        fi
     
    done < tmpGameResults.txt
}

getTmpGameResultsComma


touch GameResults.csv
function getMatchingGameResults() {
    
    while read tmpGameResultsCommaLine
    do
        if grep -Fxq $tmpGameResultsCommaLine GameResultsComma.txt
        then
            continue
        else
            echo $tmpGameResultsCommaLine >> GameResultsComma.txt
            echo $tmpGameResultsCommaLine >> GameResults.csv
        
        fi
        
    done < tmpGameResultsComma.txt
}

getMatchingGameResults

sort -rt ',' -k5 -k6 GameResults.csv -o GameResults.csv 
end=`date +%s`
rm matchresults.txt
rm tmpmatchresults.txt
rm tmpGameResultsComma.txt
rm tmpGameResults.txt
rm -rf $gameFolder/*
runtime='runtime='$(((end-start)/60)) 
echo $runtime' minutes' >> log.txt
echo "run complete" >> log.txt
notify-send 'Proccess Complete with'$runtime' minutes'