#!/bin/bash


###########################################################################################################################################################################
# variables
###########################################################################################################################################################################


#By default, set the user to see the processes of the 'current user'
#To change this to see all users, the user will call the relative function, 'process_view_menu_settings'
processes_display="currentuserprocesses"

#I have to make the 'global' variable that stores a file name - the file that contains the location of the current 'signal logs' file (my intention is that this file name is static)

#the concept of saving a persistent variable to hold a location of the signal log, was attained from stack overflow in which i reference
# Chepner, 2024, Stack Overflow, URL: https://stackoverflow.com/questions/12334495/bash-better-way-to-store-variable-between-runs
file_presaved_loglocation=stored_log_location.txt # (Chepner, 2024)

#global variable initially set to hold the way in which the process view is sorted, my assumption is by default sort is by PID
sort_method="pid"

###########################################################################################################################################################################
# functions
###########################################################################################################################################################################

#if the person running the code has this file in their directory then
#   set the text inside of this file, to the file location that contains all of the log signals (this should be a txt file)
#else
#   the user doesnt have the file in their directory, therefore I will make this file (on the assumption without a confirmation message)
#   then i will insert a default file location into the previous file, to store log signals (this file will be signal_log.txt, until changed)
check_userhas_presavedloglocation(){
if [ -f $file_presaved_loglocation ]; then
    file_with_logsignals=$(cat $file_presaved_loglocation)
else
    echo "signal_log.txt" > stored_log_location.txt
    file_with_logsignals=$(cat $file_presaved_loglocation)
fi
}

#this is a variable to flag whether the signal log is an existing file or new file, so it will know whether to append or overwrite the file
#this is only an initial call, so i dont append to a new file to create the file (I presume that is bad coding where implemented)
check_logsignals_fileexists_withincomputer(){
if [ -f $file_with_logsignals ]; then
    chosen_file="old"
else
    chosen_file="new"
fi
}


#prints all user processes
alluser_processes(){
    #print a context message to user
    echo -e "\n"
    echo "------------------------------ All user processes ------------------------------"
    echo -e "\n"

    ###ps aux###
    #command that gives "detailed information about all running processes"
    #lists the PID, Command/Name, CPU Time & other details
    #a - all users
    #u - user friendly
    #x - background processes
    ###
    ps aux --sort $sort_method 

    echo -e "\n" #-e means that the escape sequence is included, same as Programming One
    echo "--------------------------------------------------------------------------------"
    echo "--------------------------------------------------------------------------------"

}


#prints current user processes
currentuser_processes(){
    #print a context message to user
    echo -e "\n"
    echo "---------------------------- Current user processes --------------------------"
    echo -e "\n"

    ###ps aux###
    #command that gives "detailed information about only current user running processes"
    #lists the PID, Command/Name, CPU Time & other details
    #u - user friendly
    #x - background processes
    ps ux --sort $sort_method

    echo -e "\n"
    echo "------------------------------------------------------------------------------"
    echo "------------------------------------------------------------------------------"
}


#by default the user will see only 'current user processes' by method of the 'currentuser_process' function,
#if the user changes the default setting to see 'all user processes' using the 'process_view_menu_settings' function,
#then they will see 'all user' processes with the 'alluser_processes' function

#hence, the 'processes_display' variable controls the execution of either the 'alluser_processes' or 'currentuser_processes' function
display_processes() {
    if [ $processes_display == "currentuserprocesses" ]; then
        currentuser_processes
    elif [ $processes_display == "allprocesses" ]; then
        alluser_processes
    fi
}


#calling this function displays the main menu and requests an input from the user
main_menu() {
    #prompt to user the main menu
    echo -e "\n"
    echo "Listed below is the function menu...."
    echo "-> 1. Configure Process View Settings"
    echo "-> 2. Search User Processes"
    echo "-> 3. Send a Signal to a Process"
    echo "-> 4. View/Edit the Log for 'all processes that were sent a signal'"
    echo "-> 5. Quit"
    echo -e "\n"

    #prompt an input to the user to run a function
    read -p "Enter the relevant function number you wish to perform: " main_menu_input
}


#this function is called when the user selects '1' from the main menu
#this function prompts the alternative process view setting to the user and based on the users input will change the process view

#an option is also given to the user to go back to the main menu, where select of this function was a mistake and they dont want to change any settings
process_view_menu_settings() {
    #prompt to user this menu once they have selected the 'View User Processes' function
    echo -e "\n"
    echo "Select an option..."
    if [ $processes_display == "currentuserprocesses" ]; then
        echo "-> 1. Switch View to 'All User' Processes"
    elif [ $processes_display == "allprocesses" ]; then
        echo "-> 1. Switch View to 'Current User' processes"
    fi
    echo "-> 2. Change Process Sort Settings"
    echo "-> 3. Back to Home"
    echo -e "\n"
    read -p "Enter the relevant number: " processmenu_input
}

process_sort_menu_settings(){
    echo -e "\n"
    echo "Select an option..."
    echo "-> 1. Sort by User Name"
    echo "-> 2. Sort by PID"
    echo "-> 3. Sort by CPU Time"
    echo "-> 4. Sort by Process Status"
    echo "-> 5. Sort by Binary Name"
    echo -e "\n"
    read -p "Enter the relevant number: " processsort_input
}

#using the previous function's 'processmenu_input'
#the variable 'processes_display' will be set to the process view that the user selected (either current user or all user)
#the change in this variable will change the display of the process view to the user
change_process_view() {
    if [ $processes_display == "currentuserprocesses" ]; then
        processes_display="allprocesses"
    elif [ $processes_display == "allprocesses" ]; then
        processes_display="currentuserprocesses"
    fi
}

#if the user selects the option '2' from the main menu
#they will be prompted with this menu
#this menu is given prior to searching
#this menu allows the user to pick a relevant search method (binary or user)
#the input of the user (initialsearch_menu_input) is used to call the relevant search function (user_search or binary_search)
initial_search_menu(){
    echo -e "\n"
    echo "Select the way you would like to search process details..."
    echo "-> 1. Binary"
    echo "-> 2. User"
    echo -e "\n"
    read -p "Enter the relevant number: " initialsearch_menu_input
}


#when the user calls this function to search by user name
#they are prompted to input a username
#since veridian's usernames are numerical values ps -u returns no results
#hence, wrapping the user's input into a variable to read the numerical id and associate it with an 'ID' will allow me to use that variable for ps -u
#if that search only returns the header bar or less, then display to the user that no matches were found
#else
#   display search matches to user
user_search(){
    echo -e "\n"
    read -p "Enter a user's name to search for relative process details: " user_search_input
    echo -e "\n"
    echo "--------------------------- Resulting search processes ------------------------"
    echo -e "\n"

    numerical_username_adjusted=$user_search_input

    #my reference from the use of command 'id', as ps -u cannot work on a veridian numerical username came from a TA in the practical labs,
    #in turn the TA referenced that he realised it from our OS discord chat
    #my references associated from W3Schools as I took his guide and found my solution with W3Schools, https://www.geeksforgeeks.org/id-command-in-linux-with-examples/
    
    # W3Schools et al., 2024, URL: https://www.geeksforgeeks.org/id-command-in-linux-with-examples/ [accessed 01/11/2024]
    if [ $(ps -fu $(id -u $numerical_username_adjusted) | wc -l) -le 1 ]; then  # (W3Schools et al., 2024)
        echo "No matches were found!"
    else
        ps -fu $(id -u $numerical_username_adjusted) # (W3Schools et al., 2024)
    fi

    echo -e "\n"
    echo "------------------------------------------------------------------------------"
    echo "------------------------------------------------------------------------------"
}


#when the user calls this function to search by binary
#my assumption for this function is that they have to search the entire binary name with all content (i.e. grep -w)
#prompt the user for a binary to seach with
#using the binary input from the user, search all user processes for the exact input using grep -w

#if that search only returns the header bar or less, then display to the binary that no matches were found
#else
#   display search matches to user
binary_search(){
    echo -e "\n"
    read -p "Enter a binary name to search for relative process details (It is assumed you enter the full binary name): " binary_search_input
    echo -e "\n"
    echo "--------------------------- Resulting search processes ------------------------"
    echo -e "\n"

    if [ "$(ps aux | grep -x "$binary_search_input" | wc -l)" -le 1 ]; then
        echo "No matches were found!"
    else
        ps aux | grep -x $binary_search_input
    fi
    
    echo -e "\n"
    echo "------------------------------------------------------------------------------"
    echo "------------------------------------------------------------------------------"
}

#once search has been completed display a final menu to the user, to ask if they want to return to main menu or search again
#doing this instead of just showing a main menu, results in stopping the big main menu block from printing after a user's search results are returned
#hence it means the search results are lost by the user to the back of a large main menu
final_search_menu() {
    echo -e "\n"
    echo "Select an option..."
    echo "-> 1. Perform another search"
    echo "-> 2. Back to Home"
    echo -e "\n"
    read -p "Enter the relevant number: " searchmenu_input
}


#this function is called when the user selects '3' from the main menu

#remind the user of the current signal log that they will write to, once they perform one of the three selected signals
#prompt the user to select one of three signals
specify_a_signal() {
    echo -e "\n"
    echo "REMINDER: The signal log is currently being written to '"$file_with_logsignals"' "
    echo -e "\n"
    echo "Select the signal you would like to send..."
    echo "-> 1. SIGTERM (terminate a process, gracefully)"
    echo "-> 2. SIGSTOP (pause a process)"
    echo "-> 3. SIGCONT (resume a paused process)"
    echo "-> 4. SIGINT (interupt a process)"
    echo "-> 5. SIGHUP (kill controlling terminal)"
    echo "-> 6. SIGQUIT (terminate process, with core dump)"
    echo "-> 7. SIGKILL (force process termination, with no cleanup)"
    echo "-> 8. SIGALRM (indicate a timer has been expired)"
    echo "-> 9. SIGUSR1 (a user defined signal, that should be trapped in the relevant process)"
    echo "-> 10. SIGPIPE (indicate to a process that they are writing to a pipe without readers)"
    echo -e "\n"
    read -p "Enter the relevant number: " signalmenu_input
}


#after the user has selected a signal in which they want to send
#the user has to select a process in which they want to send the signal to
specify_a_process() {
    echo -e "\n"
    read -p "Enter the relevant processes PID: " process_for_signal_input
}


#based on the signal and process selected by the user
#send the relevant signal and process to the user using the kill command
#once the signal has been sent, if successfully achieved
#we will print a message saying successful
#we will then either append or overwrite the signal to the signal log file (i dont want to append to a new file, i want it to be a '>' if its a new file)
#else
#  the error will be notified to the user and it will not be written into the signal log
send_signal_to_process() {
    if [ $selectedsignal == "SIGTERM" ]; then
        kill -15 "$process_for_signal_input"
    elif [ $selectedsignal == "SIGSTOP" ]; then
        kill -19 "$process_for_signal_input"
    elif [ $selectedsignal == "SIGCONT" ]; then
        kill -18 "$process_for_signal_input"
    elif [ $selectedsignal == "SIGINT" ]; then
        kill -2 "$process_for_signal_input"
    elif [ $selectedsignal == "SIGHUP" ]; then
        kill -1 "$process_for_signal_input"
    elif [ $selectedsignal == "SIGQUIT" ]; then
        kill -3 "$process_for_signal_input"
    elif [ $selectedsignal == "SIGKILL" ]; then
        kill -9 "$process_for_signal_input"
    elif [ $selectedsignal == "SIGALRM" ]; then
        kill -14 "$process_for_signal_input"
    elif [ $selectedsignal == "SIGUSR1" ]; then
        kill -10 "$process_for_signal_input"
    elif [ $selectedsignal == "SIGPIPE" ]; then
        kill -13 "$process_for_signal_input"
    fi

    if [ $? -eq 0 ]; then
        echo -e "\n"
        echo "The signal" $selectedsignal "was successfully sent to the PID of" $process_for_signal_input
        if [ $chosen_file == "old" ]; then
            append_log_signal_to_file
        elif [ $chosen_file == "new" ]; then
            new_log_signal_to_file
            chosen_file="old"
        fi
    else
        echo -e "\n"
        echo "The signal" $selectedsignal "was unsuccessful"
    fi
}


#this user menu is displayed to the user to chose to go back to the main menu
#doing this instead of just showing a main menu, results in stopping the big main menu block from printing after a user's function results are returned
#hence it stops the results being lost by the user to the back of a large main menu
return_menu() {
    echo -e "\n"
    echo "Select an option..."
    echo "-> 1. Back to Home"
    echo -e "\n"
    read -p "Enter the relevant number: " return_input
}


#this function is called when the user selects '4' from the main menu
#the user is reminded of the current signal log location
#then they are prompted to chose a log file associated menu
initial_log_menu(){
    echo -e "\n"
    echo "REMINDER: The signal log is currently being written to '"$file_with_logsignals"' "
    echo -e "\n"
    echo "Select the option you would like perform..."
    echo "-> 1. View the log of 'all processes that were sent a signal'"
    echo "-> 2. Change the location of the log"
    echo "-> 3. Back to Home"
    echo -e "\n"
    read -p "Enter the relevant number: " initial_logmenu_input  
}


#where the user wants to view the current signal log, they call this function
#it will display the contents of the current signal log
#however.. if the signal log doesnt exist within the directory of the users computer
#it will display the error to the user
show_log() {
    echo -e "\n"
    echo "The log of all processes that were sent a signal is as follows..."
    echo -e "\n"

    echo "------------------------------------------------------------------------------"
    echo "------------------------------------------------------------------------------"
    echo -e "\n"

    if [ -f "$file_with_logsignals" ]; then
        cat "$file_with_logsignals"
    else
        echo "The file doesn't exist yet!"
    fi
    
    echo -e "\n"
    echo "------------------------------------------------------------------------------"
    echo "------------------------------------------------------------------------------"
}


#where the location of the signal log is changed, if the file already exists,
#this function is called to prompt to the user would they like to overwrite or append to existing file
existing_file_message(){
    echo -e "\n"
    echo "This file already exists"
    echo -e "\n"
    echo "Would you like to..."
    echo "-> 1. Append to existing log"
    echo "-> 2. Overwrite to existing log"
    echo -e "\n"
    read -p "Enter the relevant number: " existing_file_message_input
}


#calling this function will append the process signal to the intended file with log signals
append_log_signal_to_file() {
    echo "Process PID of" $process_for_signal_input "was sent the signal --> kill" $selectedsignal $process_for_signal_input >> $file_with_logsignals
}

#calling this function will overwrite the process signal to the intended file with log signals
new_log_signal_to_file() {
    echo "Process PID of" $process_for_signal_input "was sent the signal --> kill" $selectedsignal $process_for_signal_input > $file_with_logsignals
}


#calling this function from the the log file settings menu, will result in the user being able to change the log file location
#user is prompted for new file location
#if the location given included a directory, we have to check if both the directory and file exist in the first place
#if the directory doesnt exist then we display an error (i assume im not expected to make a new directory too! using mkdir)

#when the user enters either only a file location, we check if this file already exists
#if the file exists we have to prompt the user the 'existing file message' function (do you want to overwrite or append existing)
#based on the input by the user, the relevant function is called to act (append_existing_file or overwrite_existing_file)

#you will see i have a while true loop until the user inputs a correct input, if not an error will be displayed and the user will be asked to reprompt again

# Reference to saving a persistent variable -- Chepner, 2024, Stack Overflow, URL: https://stackoverflow.com/questions/12334495/bash-better-way-to-store-variable-between-runs
change_log_location(){
    echo -e "\n"
    read -p "Specify the location of the log: " log_change_input
    
    if [[ "$log_change_input" == */* ]]; then
        #I learned 'Parameter Expansions' from our practical labs (lab 5 Solution cheatsheet that we were told to read!) - https://devhints.io/bash
        # Devhints et al., 2024, URL: https://devhints.io/bash [accessed 1/11/2024]
        file_part=${log_change_input##*/} # (devhints.io et al., 2024)
        directory_part=${log_change_input%/*} # (devhints.io et al., 2024)
        if [ -d $directory_part ]; then
            if [ -f $file_part ]; then
                existing_file_message
                while true; do
                    if [ $existing_file_message_input == "1" ]; then
                        chosen_file="old"
                        break
                    elif [ $existing_file_message_input == "2" ]; then
                        
                        #######
                        message_about_confirmation="overwrite the previous log file"

                        confirmation_message

                        while true; do
                            if [ $confirmation_input == "1" ]; then
                                continue_confirmation
                                break
                            elif [ $confirmation_input == "2" ]; then
                                abandon_confirmation
                                break
                            else
                                print_error
                            fi
                        done

                        if [ $break_systemchange == "yes" ]; then
                            break
                        fi
                        #######
                        chosen_file="new"
                        break
                    else
                        print_error
                    fi
                done
                file_with_logsignals="$log_change_input"
                echo $file_with_logsignals > $file_presaved_loglocation
            else
                chosen_file="new"
                file_with_logsignals="$log_change_input"
                echo $file_with_logsignals > $file_presaved_loglocation
            fi
        else
            echo -e "\n"
            echo "The directory" $directory_part "does not exist. Try Again!"
        fi
    else
        if [ -f "$log_change_input" ]; then
            existing_file_message
            while true; do
                if [ $existing_file_message_input == "1" ]; then
                    chosen_file="old"
                    break
                elif [ $existing_file_message_input == "2" ]; then

                    #######
                    message_about_confirmation="overwrite the previous log file"
                    confirmation_message

                    while true; do
                          if [ $confirmation_input == "1" ]; then
                            continue_confirmation
                            break
                        elif [ $confirmation_input == "2" ]; then
                            abandon_confirmation
                            break
                        else
                            print_error
                        fi
                    done

                    if [ $break_systemchange == "yes" ]; then
                        break
                    fi
                    #######

                    chosen_file="new"
                    break
                else
                   print_error
                fi
            done
            file_with_logsignals="$log_change_input"
            echo $file_with_logsignals > $file_presaved_loglocation
        else
            chosen_file="new"
            file_with_logsignals="$log_change_input"
            echo $file_with_logsignals > $file_presaved_loglocation
        fi
    fi
    
}


#this is just a message to let the user know that their input was recieved and they will return to main menu
back_to_home_message(){
    echo -e "\n"
    echo "Bringing you back to home menu..."
}


#print an error message to user
print_error() {
    echo -e "\n"
    echo "Error, invalid command!"
    echo "Try again"
}


#this function displays the confirmation choice to the user and asks for a return input
#this function will only be called when a system change is about to occur
confirmation_message(){
    echo -e "\n"
    echo "You are about to make a system change -" $message_about_confirmation
    echo -e "\n"
    echo "Can you confirm this choice?"
    echo "-> 1. Yes"
    echo "-> 2. No"
    echo -e "\n"
    read -p "Enter the relevant number: " confirmation_input
}


#this function is called when the user selected '1' from the confirmation_message function, as it continues with the system change
#using a variable that is either set to 'yes' or 'no', where the variable is 'yes' it will break from the current system change about to take place
continue_confirmation(){
    break_systemchange="no"
    echo -e "\n"
    echo "Continuing..."
    echo -e "\n"
}


#this function is called when the user selected '2' from the confirmation_message function, as it stops the system change
#using a variable that is either set to 'yes' or 'no', where the variable is 'yes' it will break from the current system change about to take place
abandon_confirmation(){
    break_systemchange="yes"
    echo -e "\n"
    echo "Abandoning..."
    echo -e "\n"
}

###########################################################################################################################################################################
# main code
###########################################################################################################################################################################


#prompt user with a hello and introduction
echo -e "\n"
echo "Welcome! This is your bash-based helper"

check_userhas_presavedloglocation

check_logsignals_fileexists_withincomputer

#the script will run continuously in a while loop
while true; do
    #this variable is used to flag whether the user wants to leave the system change function they are about to call, this is changed via the confirmation message
    break_systemchange="no"

    #message to user to tell them the script is displaying process information
    echo -e "\n"
    echo "Displaying your processes view..."

    #display user processes (settings within previous functions will declare whether its 'all user' or 'current user' processes)
    display_processes

    #prompt the menu to the user
    #the main menu will be prompted in a while true loop until the program is quit using option '5'
    main_menu

    #equal sign for string, -eq for integer
    #where the user selects to 'change process view settings', the 'process_view_menu_settings' function is called
    if [ $main_menu_input  == "1" ]; then
        
        #prompt the user to input a correct option from the 'process_view_menu_settings' function, if not they wont break out from a loop
        #a process view menu will be displayed to the user to change either the 'current' or 'all' user processes and the sorting of the processes by command name, pid, cpu time or process state
        while true; do
            process_view_menu_settings
            if [ $processmenu_input == "1" ]; then
                change_process_view
                break
            elif [ $processmenu_input == "2" ]; then
                while true; do
                    process_sort_menu_settings
                    if [ $processsort_input == "1" ]; then
                        sort_method="user"
                        break
                    elif [ $processsort_input == "2" ]; then
                        sort_method="pid"
                        break
                    elif [ $processsort_input == "3" ]; then
                        sort_method="time"
                        break
                    elif [ $processsort_input == "4" ]; then
                        sort_method="state"
                        break
                    elif [ $processsort_input == "5" ]; then
                        sort_method="command"
                        break
                    else
                        print_error
                    fi
                done
            elif [ $processmenu_input == "3" ]; then
                back_to_home_message
                break
            else
                print_error
            fi
        done

    #where the user selects to 'search processes', the 'initial_search_menu' function is called
    #from the initial_search_menu the user will be prompted in a loop to select, whether to search by binary or username
    elif [ $main_menu_input == "2" ]; then
        while true; do
            initial_search_menu
            if [ $initialsearch_menu_input == "1" ]; then
                binary_search
            elif [ $initialsearch_menu_input == "2" ]; then
                user_search
            else
                print_error
                continue
            fi

            #once the search has completed the user is given a final menu, to do another search or go back to main menu
            final_search_menu

            #based on the input of the final_search_menu the relevant action is achieved
            if [ $searchmenu_input == "1" ]; then
                continue
            elif [ $searchmenu_input == "2" ]; then
                back_to_home_message
                break
            else
                print_error
            fi
        done

    #where the user selects to 'send a signal to a process', the 'specify_a_signal' function is called
    #once a signal is specified then the signal will be set to be implemented
    elif [ $main_menu_input == "3" ]; then
            while true; do
                specify_a_signal
                if [ $signalmenu_input == "1" ]; then
                    selectedsignal="SIGTERM"
                    break
                elif [ $signalmenu_input == "2" ]; then
                    selectedsignal="SIGSTOP"
                    break
                elif [ $signalmenu_input == "3" ]; then
                    selectedsignal="SIGCONT"
                    break
                elif [ $signalmenu_input == "4" ]; then
                    selectedsignal="SIGINT"
                    break
                elif [ $signalmenu_input == "5" ]; then
                    selectedsignal="SIGHUP"
                    break
                elif [ $signalmenu_input == "6" ]; then
                    selectedsignal="SIGQUIT"
                    break
                elif [ $signalmenu_input == "7" ]; then
                    selectedsignal="SIGKILL"
                    break
                elif [ $signalmenu_input == "8" ]; then
                    selectedsignal="SIGALRM"
                    break
                elif [ $signalmenu_input == "9" ]; then
                    selectedsignal="SIGUSR1"
                    break
                elif [ $signalmenu_input == "10" ]; then
                    selectedsignal="SIGPIPE"
                    break
                else
                    print_error
                fi
            done
        
            #the user will be shown all processes again, just for convience
            display_processes

            #the process they want to send a signal to is requested
            specify_a_process

            #the message found within the 'confirmation_message' function is set
            message_about_confirmation="send a signal to a process"

            #the 'confirmation_message' is called to the user to prompt an answer
            confirmation_message

            #based on the confirmation message input, the user will either continue to send a signal to the process
            #or
            #user will break from sending the signal to a process
            while true; do
                if [ $confirmation_input == "1" ]; then
                    continue_confirmation
                    break
                elif [ $confirmation_input == "2" ]; then
                    abandon_confirmation
                    break
                else
                    print_error
                fi
            done

            #i use a variable to control the breaking from the outer loop that handles sending a process a signal,
            #as i cannot break from the inner loop, which is only a message confirmation loop
            if [ $break_systemchange == "yes" ]; then
                continue
            fi

            #function is called to actually send a signal to the process and its signal will be recorded in the signal log
            send_signal_to_process

            #as previously mentioned a return to home message will be displayed instead of just automatically printing a large main menu
            while true; do
                return_menu
                if [ $return_input == "1" ]; then
                    back_to_home_message
                    break
                else
                    print_error
                fi
            done

    #where the user selects to 'access the log settings', the 'initial_log_menu' function is called
    #from the initial_log_menu the user will be prompted in a loop to select an option/function, whether to show the signal log, change the signal log location or return back to the main menu
    elif [ $main_menu_input == "4" ]; then
        while true; do
            initial_log_menu
            if [ $initial_logmenu_input == "1" ]; then
                show_log
            elif [ $initial_logmenu_input == "2" ]; then
                change_log_location
            elif [ $initial_logmenu_input == "3" ]; then
                back_to_home_message
                break
            else
                print_error
            fi
        done

    #if the user chooses option '5' then the program will exit/end successfully
    elif [ $main_menu_input == "5" ]; then
        echo -e "\n"
        echo "Program has finished. Goodbye."
        exit 0

    #if the user doesnt enter a correct response to the main menu, an error will be printed to the user
    else
        print_error     
    fi
done

