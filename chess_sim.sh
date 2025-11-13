#!/bin/bash

#Benny Bitran
#208665000

#parse char into relevant column (file)
get_col_num() {
    case "$1" in
        a) echo 1 ;;
        b) echo 2 ;;
        c) echo 3 ;;
        d) echo 4 ;;
        e) echo 5 ;;
        f) echo 6 ;;
        g) echo 7 ;;
        h) echo 8 ;;
    esac
}

next_move() {
        move=($(echo "${parsed_moves[$move_count]}" | grep -o .))
        ######NORMAL MOVE######
        from_col=$(get_col_num "${move[0]}")    #parse char into relevant column (file)
        from_row=$((( 8 - ${move[1]} )))      #parse row to relevant row of the board (array)
        to_col=$(get_col_num "${move[2]}")
        to_row=$((( 8 - ${move[3]} ))) 
        line=(${board[$((from_row))]})  #hold the line to move FROM
        piece="${line[$((from_col))]}"  #save the piece

        #check if move is a *normal* capture
        dest_line=(${board[$((to_row))]}) 
        dest_piece="${dest_line[$((to_col))]}"
        if [ "$dest_piece" != "." ]
        then
            #save capture data
            moves_with_captures+=("$move_count")
            capture_data+=("${dest_piece}${to_col}${to_row}")
        fi      
        ######EN PASSANT######
        #check if a pawn made a diagonal move
        if { [ "$piece" = "p" ] || [ "$piece" = "P" ]; } && [ "$from_col" -ne "$to_col" ]
        then
            dest_line=(${board[$((to_row))]})  #hold the line
            dest_piece="${dest_line[$((to_col))]}"
            #check if the target landing was empty (meaning it was an en passant)
            if [ "$dest_piece" = "." ]
            then
                line[$((to_col))]="."
                board[$((from_row))]="${line[*]}"
                moves_with_captures+=("$move_count")   #FLAG THE MOVE NUMBER FOR BACKWARDING EN PASSANT
                if [ $((move_count % 2)) -eq 0 ]
                then
                    capture_data+=("p${to_col}${from_row}")
                else
                    capture_data+=("P${to_col}${from_row}")
                fi
            fi
        fi
        apply_to_board

        ######PROMOTION######
        #check if move was a promotion (5 chars in UCI is a promotion)
        if [ ${#move[@]} -eq 5 ]
        then
            piece="${move[4]}"
            if [ $((move_count % 2)) -eq 0 ]    #check if it was white (if yes - uppercase)
            then
                piece=${piece^^}
            fi
            #modify the line
            line=(${board[$((to_row))]})
            line[$((to_col))]="$piece"
            board[$((to_row))]="${line[*]}"
        fi

        ######CASTLING######
        if [ "$piece" = "k" ] || [ "$piece" = "K" ] 
        then
            #white kingside castle - move the rook
            if [ "${parsed_moves[$move_count]}" = "e1g1" ]
            then
                from_col=$(get_col_num 'h')
                from_row=7
                to_col=$(get_col_num 'f')
                to_row=7
                piece='R'
                apply_to_board
            
            #white queenside castle - move the rook
            elif [ "${parsed_moves[$move_count]}" = "e1c1" ]
            then
                from_col=$(get_col_num 'a')
                from_row=7
                to_col=$(get_col_num 'd')
                to_row=7
                piece='R'
                apply_to_board

            #black kingside castle - move the rook
            elif [ "${parsed_moves[$move_count]}" = "e8g8" ]
            then
                from_col=$(get_col_num 'h')
                from_row=0
                to_col=$(get_col_num 'f')
                to_row=0
                piece='r'
                apply_to_board

            #black queenside castle - move the rook
            elif [ "${parsed_moves[$move_count]}" = "e8c8" ]
            then
                from_col=$(get_col_num 'a')
                from_row=0
                to_col=$(get_col_num 'd')
                to_row=0
                piece='r'
                apply_to_board
            fi
        fi
        ((move_count++))
}

prev_move() {
        ((move_count--))
        move=($(echo "${parsed_moves[$move_count]}" | grep -o .))
        #get move values
        from_col=$(get_col_num "${move[2]}")    
        from_row=$((( 8 - ${move[3]} )))      #parse row to relevant row of the board (array)
        to_col=$(get_col_num "${move[0]}")
        to_row=$((( 8 - ${move[1]} ))) 
        line=(${board[$((from_row))]})  #hold the line
        piece="${line[$((from_col))]}"  #save the piece
        apply_to_board
        
        #check if piece restoration is needed and remove data from "stacks"
        if [ ${#moves_with_captures[@]} -gt 0 ] && [ "${moves_with_captures[-1]}" -eq "$move_count" ]
        then
            last_capture_data="${capture_data[-1]}"
            last_capture_data=($(echo "$last_capture_data" | grep -o .))
            piece="${last_capture_data[0]}"
            col="${last_capture_data[1]}"
            row="${last_capture_data[2]}"

            line=(${board[$row]})
            line[$col]="$piece"
            board[$row]="${line[*]}"

            unset 'moves_with_captures[-1]'
            unset 'capture_data[-1]'
        fi

        ######PROMOTION######
        #check if move was a promotion (5 chars in UCI is a promotion)
        if [ ${#move[@]} -eq 5 ]
        then
            piece="p"
            if [ $((move_count % 2)) -eq 0 ]     #check if it was white (if yes - uppercase)
            then
                piece=${piece^^}
            fi
            #modify the line
            line=(${board[$((to_row))]})
            line[$((to_col))]="$piece"
            board[$((to_row))]="${line[*]}"
        fi

        ######CASTLING######
        if [ "$piece" = "k" ] || [ "$piece" = "K" ] 
        then
            #white kingside castle - move the rook
            if [ "${parsed_moves[$move_count]}" = "e1g1" ]
            then
                from_col=$(get_col_num 'f')
                from_row=7
                to_col=$(get_col_num 'h')
                to_row=7
                piece='R'
                apply_to_board
            
            #white queenside castle - move the rook
            elif [ "${parsed_moves[$move_count]}" = "e1c1" ]
            then
                from_col=$(get_col_num 'd')
                from_row=7
                to_col=$(get_col_num 'a')
                to_row=7
                piece='R'
                apply_to_board

            #black kingside castle - move the rook
            elif [ "${parsed_moves[$move_count]}" = "e8g8" ]
            then
                from_col=$(get_col_num 'f')
                from_row=0
                to_col=$(get_col_num 'h')
                to_row=0
                piece='r'
                apply_to_board

            #black queenside castle - move the rook
            elif [ "${parsed_moves[$move_count]}" = "e8c8" ]
            then
                from_col=$(get_col_num 'd')
                from_row=0
                to_col=$(get_col_num 'a')
                to_row=0
                piece='r'
                apply_to_board
            fi
        fi
}

apply_to_board() {
        #modify origin line
        line[$((from_col))]="."
        board[$((from_row))]="${line[*]}"

        #modify target line
        line=(${board[$((to_row))]})
        line[$((to_col))]="$piece"
        board[$((to_row))]="${line[*]}"

}

reset_board() {
    board=(
    "8 r n b q k b n r 8" 
    "7 p p p p p p p p 7"
    "6 . . . . . . . . 6"
    "5 . . . . . . . . 5"
    "4 . . . . . . . . 4"
    "3 . . . . . . . . 3"
    "2 P P P P P P P P 2"
    "1 R N B Q K B N R 1") #7
    move_count=0
}

print_board() {
    echo Move "$move_count/${#parsed_moves[@]}" 
    echo "$files_line"  
    printf '%s\n' "${board[@]}"
    echo "$files_line"
}

###start###

files_line="  a b c d e f g h"
board=()
reset_board
move_count=0
moves_with_captures=() #this array will save all moves that a capture occured
capture_data=()        #this array will save the data about the corresponding capture

file="$1"
if [ ! -f "$file" ]; then
    echo "File does not exist: $file"
    exit 1
fi

i=1
rows=$(wc -l < "$file")
while [ $i -le $rows ]
do
    line=$(head -n $i "$file" | tail -n 1 | tr -d '\r')
    if [ -z "$(echo "$line" | tr -d '[:space:]')" ]; then
        empty_line=$i
        break
    fi
    i=$((i+1))
done
echo "Metadata from PGN file:"
head -n $((empty_line-1)) "$file" | tr -d '\r'
parsed_moves=($(python3 parse_moves.py "$(tail -n +$((empty_line+1)) "$1")"))
echo
print_board

while true
do
    #print menu
    echo -n "Press 'd' to move forward, 'a' to move back, 'w' to go to the start, 's' to go to the end, 'q' to quit:"
    read -r ans 
    echo
    #case: user pressed 'd'
    if [[ "$ans" == "d" ]]
    then
        if (( move_count >= ${#parsed_moves[@]} ))
        then
            echo No more moves available.
            continue
        fi

        next_move
        print_board

    #case: user pressed 'a'
    elif [[ "$ans" == "a" ]]
    then
        if (( move_count <= 0 ))
        then
            print_board
            continue
        fi

        prev_move
        print_board

    #go to start
    elif [[ "$ans" == "w" ]]
    then
        reset_board
        print_board

    #go to end
    elif [[ "$ans" == "s" ]]
    then
        #go from current move to last move
        for ((i=move_count; i<${#parsed_moves[@]}; i++))
        do
            next_move
        done
        print_board
        
    #exit program
    elif [[ "$ans" == "q" ]]
    then
        echo Exiting.
        echo End of game.
        break
    else
        echo "Invalid key pressed: $ans"
    fi
done
