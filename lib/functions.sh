#!/bin/bash

# Workout Planner Functions

DATA="data/plan.csv"
DONE="data/done.csv"
LOG="logs/activity.log"

log() {
    mkdir -p logs
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "$LOG"
}

check_data() {
    if [ ! -f "$DATA" ]; then
        echo "Workout data file not found!"
        return 1
    fi
}

show_help() {
    echo "L85 WORKOUT PLANNER"
    echo "./main.sh"
    echo "./main.sh --help"
    echo "./main.sh --backup"
    echo "./main.sh --cron"
}

view_data() {
    check_data || return
    echo "===== WORKOUT DATA ====="
    cat -n "$DATA"
}

do_backup() {
    check_data || return
    mkdir -p backups
    backup_file="backups/data_$(date +%Y%m%d_%H%M%S).tar.gz"

    if tar -czf "$backup_file" data/; then
        echo "Backup created successfully!"
        du -h "$backup_file"
        log "Backup created"
    else
        echo "Backup failed!"
    fi
}

view_log() {
    if [ -f "$LOG" ]; then
        echo "===== ACTIVITY LOG ====="
        tail -n 15 "$LOG"
    else
        echo "No activity log found."
    fi
}

# Feature 1: Today's workout
feature_1() {
    check_data || return
    today=$(date +%A)

    echo "===== WORKOUT FOR $today ====="

    awk -F, -v day="$today" '
    NR>1 && $1==day {
        print "Exercise: " $2
        print "Sets: " $3
        print "Reps: " $4
        found=1
    }
    END {
        if (!found) print "No workout planned today."
    }' "$DATA"

    log "Viewed today's workout"
}

# Feature 2: Mark workout as done
feature_2() {
    check_data || return
    today=$(date +%F)
    day=$(date +%A)

    if ! grep -q "^${day}," "$DATA"; then
        echo "No workout planned for today!"
        return
    fi

    mkdir -p data

    if [ ! -f "$DONE" ]; then
        echo "day,completed_date" > "$DONE"
    fi

    if grep -q ",${today}$" "$DONE"; then
        echo "Today's workout is already marked as done!"
    else
        echo "$day,$today" >> "$DONE"
        echo "Workout marked as done!"
        log "Marked workout as done: $today"
    fi
}

# Feature 3: Weekly volume
feature_3() {
    check_data || return

    awk -F, '
    NR>1 && $3 ~ /^[0-9]+$/ && $4 ~ /^[0-9]+$/ {
        volume += $3 * $4
    }
    END {
        printf "Total weekly volume: %d\n", volume
    }' "$DATA"

    log "Calculated weekly volume"
}

# Feature 4: Completed workout streak
feature_4() {
    if [ ! -f "$DONE" ]; then
        echo "No completed workouts found."
        return
    fi

    current=$(date +%F)
    streak=0

    while grep -q ",${current}$" "$DONE"; do
        ((streak++))
        current=$(date -d "$current -1 day" +%F)
    done

    echo "Current workout streak: $streak day(s)"
    log "Checked workout streak"
}

# Feature 5: Add or remove exercise
feature_5() {
    check_data || return

    echo "1. Add Exercise"
    echo "2. Remove Exercise"

    read -p "Enter choice: " choice

    case "$choice" in
        1)
            read -p "Enter day: " day
            read -p "Enter exercise: " exercise
            read -p "Enter sets: " sets
            read -p "Enter reps: " reps

            if [[ -z "$day" || -z "$exercise" ||
                  ! "$sets" =~ ^[0-9]+$ ||
                  ! "$reps" =~ ^[0-9]+$ ||
                  "$day" == *,* || "$exercise" == *,* ]]; then
                echo "Invalid input!"
                return
            fi

            echo "$day,$exercise,$sets,$reps" >> "$DATA"
            echo "Exercise added successfully!"
            log "Added exercise: $exercise"
            ;;

        2)
            read -p "Enter exercise name to remove: " exercise

            if [ -z "$exercise" ]; then
                echo "Exercise name cannot be empty!"
                return
            fi

            if awk -F, -v ex="$exercise" '
                NR>1 && $2==ex {found=1}
                END {exit !found}
            ' "$DATA"; then

                awk -F, -v ex="$exercise" '
                    NR==1 || $2!=ex
                ' "$DATA" > data/temp.csv

                mv data/temp.csv "$DATA"
                echo "Exercise removed successfully!"
                log "Removed exercise: $exercise"
            else
                echo "Exercise not found!"
            fi
            ;;

        *)
            echo "Invalid choice!"
            ;;
    esac
}

# Cron task: Daily workout report
cron_task() {
    check_data || return

    mkdir -p reports
    today=$(date +%A)

    {
        echo "===== WORKOUT REPORT ====="
        echo "Date: $(date)"
        echo "Day: $today"
        echo

        awk -F, -v day="$today" '
        NR>1 && $1==day {
            print "Exercise: " $2
            print "Sets: " $3
            print "Reps: " $4
            found=1
        }
        END {
            if (!found) print "No workout planned today."
        }' "$DATA"

    } > reports/today_workout.txt

    echo "Daily workout report generated!"
    log "Daily report generated"
}

