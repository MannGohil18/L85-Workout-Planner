
#!/bin/bash

# L85 Workout Planner
# Student: MAN GOHIL
# Roll: B11 | Division: H

cd "$(dirname "$0")" || exit 1
source lib/functions.sh

# Command line arguments
case "$1" in
    --help)
        show_help
        exit 0
        ;;
    --backup)
        do_backup
        exit 0
        ;;
    --cron)
        cron_task
        exit 0
        ;;
esac

# Main menu
while true
do
    echo
    echo "=================================="
    echo "       L85 WORKOUT PLANNER"
    echo "=================================="
    echo "1. Show Today's Workout"
    echo "2. Mark Workout as Done"
    echo "3. Calculate Weekly Volume"
    echo "4. Show Current Streak"
    echo "5. Add or Remove Exercise"
    echo "6. View Workout Data"
    echo "7. Backup Data"
    echo "8. View Activity Log"
    echo "0. Exit"
    echo "=================================="

    read -p "Enter your choice: " choice

    case "$choice" in
        1) feature_1 ;;
        2) feature_2 ;;
        3) feature_3 ;;
        4) feature_4 ;;
        5) feature_5 ;;
        6) view_data ;;
        7) do_backup ;;
        8) view_log ;;
        0)
            echo "Thank you for using Workout Planner!"
            break
            ;;
        *)
            echo "Invalid choice! Please try again."
            ;;
    esac
done

