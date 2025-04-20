#!/usr/bin/env bash
# Inspired by Kris Occhipinti's work on YouTube. Thank you!
# https://www.youtube.com/watch?v=io5lIfOdwDM
# GNU General Public License

# Terminal Control Abstraction Layer
declare -A term=(
    [hide_cursor]='\033[?25l'
    [show_cursor]='\033[?25h'
    [reset]='\033[0m'
    [move_to]='\033[%d;%dH'  # row, col
    [block]='█'
    [half_block]='▄'
    [ground]='▁'
)

# 256-color palette definitions
declare -A colors=(
    [black]=0       [red]=1        [green]=2      [yellow]=3
    [blue]=4        [magenta]=5    [cyan]=6       [white]=7
    [bright_black]=8 [bright_red]=9 [bright_green]=10
    [bright_yellow]=11 [bright_blue]=12 [bright_magenta]=13
    [bright_cyan]=14 [bright_white]=15
    [orange]=208    [purple]=93    [pink]=199
)

# Global constants
declare -ri GROUND_ROW=20
declare -ri MIN_WIDTH=6  # 2 left wall + 2 right wall + 2 interior

function set_color() {
    printf "\033[38;5;%dm" "${colors[$1]}"
}

function move_cursor() {
    printf "${term[move_to]}" "$1" "$2"
}

function draw_building() {
    local -i left_col=$1
    local -i width=$2
    local -i height=$3
    local color=${4:-blue}
    local window_color=${5:-yellow}

    # Ensure minimum width
    (( width >= MIN_WIDTH )) || width=$MIN_WIDTH
    local -i right_col=$((left_col + width - 1))
    local -i roof_row=$((GROUND_ROW - height))
    local -i interior_start=$((left_col + 2))
    local -i interior_end=$((right_col - 1))

    # Hide cursor and set color
    printf "%b" "${term[hide_cursor]}$(set_color "$color")"

    # Draw complete walls and interior in one pass per row
    for ((row = roof_row; row < GROUND_ROW; row++)); do
        # Left wall (exactly 2 solid blocks)
        move_cursor "$row" "$left_col"
        printf "%s%s" "${term[block]}" "${term[block]}"
        
        # Interior (full width between walls)
        for ((col = interior_start; col < interior_end; col++)); do
            printf "%s" "${term[block]}"
        done
        
        # Right wall (exactly 2 solid blocks)
        printf "%s%s" "${term[block]}" "${term[block]}"
    done

    # Add windows (only on odd rows)
    printf "%b" "$(set_color "$window_color")"
    for ((row = roof_row + 1; row < GROUND_ROW; row += 2)); do
        for ((col = interior_start; col < interior_end; col += 2)); do
            move_cursor "$row" "$col"
            printf "%s" "${term[half_block]}"
        done
    done

    # Draw ground shadow
    move_cursor "$GROUND_ROW" "$left_col"
    printf "%b" "$(set_color black)"
    for ((col = left_col; col <= right_col; col++)); do
        printf "%s" "${term[ground]}"
    done
}

function draw_city() {
    # Clear screen and hide cursor
    printf "%b" "${term[reset]}\033[2J${term[hide_cursor]}"

    # Draw perfectly aligned buildings
    draw_building 3 8 12 blue bright_white     # ██▄▄██
    draw_building 10 10 15 green yellow        # ██▄▄▄▄██
    draw_building 19 15 18 red bright_cyan     # ██▄▄▄▄▄▄██
    draw_building 32 8 14 purple orange        # ██▄▄██
    draw_building 39 13 16 cyan bright_red     # ██▄▄▄▄▄██

    # Draw continuous ground line
    printf "%b" "$(set_color white)"
    for ((col = 1; col <= 60; col++)); do
        move_cursor "$GROUND_ROW" "$col"
        printf "%s" "${term[ground]}"
    done

    # Reset and show cursor
    printf "%b" "${term[reset]}"
    move_cursor $((GROUND_ROW + 2)) 1
    printf "%b" "${term[show_cursor]}"
}

clear
# Run the cityscape
draw_city

