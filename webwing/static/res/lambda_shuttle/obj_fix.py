in_file = open('lambda_shuttle.obj', 'r')

out_file = open('lambda_shuttle_new.obj', 'w+')

min_x = 100000
min_y = 100000
min_z = 100000
max_x = -100000
max_y = -100000
max_z = -100000

lines = in_file.readlines()

for line in lines:
    no_ret = line[:-1]
    split_line = no_ret.split(' ')
    if split_line[0] == "v":
        if float(split_line[1]) < min_x:
            min_x = float(split_line[1])
        if float(split_line[2]) < min_y:
            min_y = float(split_line[2])
        if float(split_line[3]) < min_z:
            min_z = float(split_line[3])
        if float(split_line[1]) > max_x:
            max_x = float(split_line[1])
        if float(split_line[2]) > max_y:
            max_y = float(split_line[2])
        if float(split_line[3]) > max_z:
            max_z = float(split_line[3])

mid_x = (max_x + min_x)/2.0
mid_y = (max_y + min_y)/2.0
mid_z = (max_z + min_z)/2.0

print "%s %s %s" % (mid_x, mid_y, mid_z)

i = 0
for line in lines:
    no_ret = line[:-1]
    split_line = no_ret.split(' ')
    output = ""
    if split_line[0] == "v":
        output += "v "
        output += str(float(split_line[1]) - mid_x) + " "
        output += str(float(split_line[2]) - mid_y) + " "
        output += str(float(split_line[3]) - mid_z) + " "
    else:
        output += no_ret
    output += "\n"
    if i <= 10:
        print output
    i +=  1
    out_file.write(output)
