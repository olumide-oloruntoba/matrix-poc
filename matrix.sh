#!/bin/bash

# Declare an empty array
declare -a the_array=()

# Input string to be split
input_string="apple, banana, grape, orange"

# Split the string by commas and populate the array
IFS=', ' read -r my_array <<< $input_string
# IFS=',' read -ra elements <<< "${{ env.OTHER_LOCATIONS_TEST }}"

# Print the elements of the array
for element in "${my_array[@]}"; do
  echo "$element"
  the_array+=($element)
done

elementCount=${#the_array[@]}
echo $the_array[0]
echo $the_array[1]
echo $the_array[2]
echo $the_array[3]
echo $elementCount