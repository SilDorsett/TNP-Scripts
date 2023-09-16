# Read the input file
with open('/mnt/nationstates/new_foundings/new_foundings_list.tmp2', 'r') as input_file:
    nations = input_file.read().splitlines()

# Create an output file
with open('/mnt/nationstates/new_foundings/new_foundings_list.txt', 'w') as output_file:
    # Loop through the nations in groups of 8
    for i in range(0, len(nations), 8):
        group = nations[i:i+8]
        # Join the group with commas and add "+region:The North Pacific" at the end
        group_line = ','.join(group + ['+region:The North Pacific'])
        # Write the group line to the output file
        output_file.write(group_line + '\n')

print("Output file 'new_foundings_list.txt' created successfully.")
