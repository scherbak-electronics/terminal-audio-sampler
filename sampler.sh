#KEY_MAP
KEY_MAP[49]=0
KEY_MAP[50]=1
KEY_MAP[51]=2
KEY_MAP[52]=3
KEY_MAP[53]=4
KEY_MAP[54]=5
KEY_MAP[55]=6
KEY_MAP[56]=7
KEY_MAP[57]=8
KEY_MAP[48]=9
KEY_MAP[113]=10
KEY_MAP[119]=11
KEY_MAP[101]=12
KEY_MAP[114]=13
KEY_MAP[116]=14
KEY_MAP[121]=15
KEY_MAP[117]=16
KEY_MAP[105]=17
KEY_MAP[111]=18
KEY_MAP[112]=19
KEY_MAP[97]=20
KEY_MAP[115]=21
KEY_MAP[100]=22
KEY_MAP[102]=23
KEY_MAP[103]=24
KEY_MAP[104]=25
KEY_MAP[106]=26
KEY_MAP[107]=27
KEY_MAP[108]=28
KEY_MAP[122]=29
KEY_MAP[120]=30
KEY_MAP[99]=31
KEY_MAP[118]=32
KEY_MAP[98]=33
KEY_MAP[110]=34
KEY_MAP[109]=35
FILE_NAMES=()
while IFS=  read -r -d $'\0'; do
    FILE_NAMES+=("$REPLY")
done < <(find . -name "*.wav" -type f -print0)



#for i in "${ARR_OF_FILES[@]}"
#do
    #echo "from array .... $i"
#done
echo "Bash Sampler 0.1"
echo "CLI looping wave player powered by SoX"
echo "Scherbak Electronics © 2018"
echo "Found ${#FILE_NAMES[@]} files in current directory."



stty -echo -icanon time 0 min 0
PLAY_PROC=false
PLAYER_COMMAND=sox
PLAYER_OPTIONS="-d repeat 99999"
RUN_SAMPLER=true
LAST_KEY=false
PAGE_NUM=0
trap "RUN_SAMPLER=false" SIGINT
while $RUN_SAMPLER
do
    read -t 1 pressedkey
    
    if [[ "$pressedkey" == [a-z0-9] ]] ; then
        key_code=$(printf %u "'$pressedkey")
        key_num=${KEY_MAP[$key_code]}
        page_key_num=$((PAGE_NUM*36))
        file_index=$((key_num+page_key_num))
        if [[ ! -z ${FILE_NAMES[$file_index]} ]] ; then
            echo "${FILE_NAMES[$file_index]}"
            if [[ $PLAY_PROC == false ]] ; then
                $PLAYER_COMMAND "${FILE_NAMES[$file_index]}" $PLAYER_OPTIONS &
                PLAY_PROC=$!
            else
                kill $PLAY_PROC
                PLAY_PROC=false
                if [[ $LAST_KEY != $pressedkey ]] ; then
                    $PLAYER_COMMAND "${FILE_NAMES[$file_index]}" $PLAYER_OPTIONS &
                    PLAY_PROC=$!  
                fi
            fi    
        fi    
        LAST_KEY=$pressedkey
    fi

    if [[ "$pressedkey" == "-" ]] ; then
        if [[ $PAGE_NUM > 0 ]] ; then
            PAGE_NUM=$((PAGE_NUM-1))
            echo "Page $PAGE_NUM"
            if [[ $PLAY_PROC == false ]] ; then
                start_index=$((PAGE_NUM*36))
                end_index=$((start_index + 36))
                for (( c = $start_index; c <= $end_index; c++ ))
                do
                    if [[ ! -z ${FILE_NAMES[$c]} ]] ; then
                        echo "${FILE_NAMES[$c]}"
                    fi
                done
            fi
        fi
    fi
    if [[ "$pressedkey" == "=" ]] ; then
        PAGE_NUM=$((PAGE_NUM+1))
        echo "Page $PAGE_NUM"
        if [[ $PLAY_PROC == false ]] ; then
            start_index=$((PAGE_NUM*36))
            end_index=$((start_index + 36))
            for (( c = $start_index; c <= $end_index; c++ ))
            do
                if [[ ! -z ${FILE_NAMES[$c]} ]] ; then
                    echo "${FILE_NAMES[$c]}"
                fi
            done
        fi
    fi
    if [[ "$pressedkey" == "/" ]] ; then
        echo "STOP"
        if [[ $PLAY_PROC != false ]] ; then
            kill $PLAY_PROC
            PLAY_PROC=false
        fi
    fi
    sleep .05
done

reset
echo "end..."