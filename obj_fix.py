in_file = open('lamba_shuttle.mtl', 'r')

out_file = open('lambda_shuttle_new.mtl', 'w')

min_x = 100000
min_y = 100000
min_z = 100000
max_x = -100000
max_y = -100000
max_y = -100000

lines = in_file.readlines()

for line in lines:
    no_ret = line[:-1]
    split_line = no_ret.split(' ')
    if split_line[0] == 'v':
        if float(split_line[1]) < min_x:
            min_x = float(split_line[1])
        if float(split_line[2]) < min_y:
            min_y = float(split_line[2])
        if float(split_line[3]) < min_z:
            min_z = float(split_line[3])
        if float(split_line[1]) < min_x:
            min_x = float(split_line[1])
        if float(split_line[2]) < min_y:
            min_y = float(split_line[2])
        if float(split_line[3]) < min_z:
            min_z = float(split_line[3])

mid_x = (max_x + min_x)/2.0
mid_y = (max_y + min_y)/2.0
mix_z = (max_z + min_z)/2.0

for line in lines:
    no_ret = line[:-1]
    split_line = line.split(' ')
    if split_line[0] == 'v':
        output = "v "
        output += float(split_line[1]) - mid_x
        output += float(split_line[2]) - mid_y
        output += float(split_line[3]) - mid_z
    else:
        output += no_ret
    output += "\n"
    out_file.write(line)
