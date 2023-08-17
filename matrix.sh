#!/bin/bash

# # Declare an empty array
# declare -a the_array=()

# # Input string to be split
# input_string="apple, banana, grape, orange"

# # Split the string by commas and populate the array
# IFS=', ' read -ra my_array <<< $input_string
# # IFS=',' read -ra elements <<< "${{ env.OTHER_LOCATIONS_TEST }}"

# # Print the elements of the array
# for element in "${my_array[@]}"; do
#   echo "$element"
#   the_array+=($element)
# done

# elementCount=${#the_array[@]}
# echo $the_array[0]
# echo $the_array[1]
# echo $the_array[2]
# echo $the_array[3]
# echo $elementCount

gcloud iam service-accounts keys create key-file.txt --iam-account=tf-service-account@ooloruntoba-playground.iam.gserviceaccount.com

gh secret set MYSECRET < key-file.txt --env myenvironment

gh auth login --with-token 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