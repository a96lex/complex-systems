def read_input(filename=""):
    """
    Returns a list containing node pairs
    """
    try:
        with open(filename, "r") as f:
            data = f.read().split("\n")
    except Exception as e:
        print(e)
        return []

    clean_data = []
    for d in data:
        new_row = [int(x) for x in d.split(" ") if x != ""]
        if new_row != []:
            clean_data.append(new_row)

    return clean_data


def get_missing_nodes(clean_data=[]):
    """
    Assuming consecutive numbers, returns any missing node number from a list
    """
    num_list = []
    for x in range(len(clean_data)):
        for y in range(2):
            if clean_data[x][y] not in num_list:
                num_list.append(clean_data[x][y])

    num_list.sort()

    missing_nodes = []
    for i in range(1, num_list[-1] + 1):
        if i not in num_list:
            missing_nodes.append(i)
    return missing_nodes


def clean_input_file(filename="", clean_data=[], missing_nodes=[]):
    """
    Creates a file with a list of consecutive nodes, reducing the number of any node that
    is greater than any missing node
    """
    for i in range(len(missing_nodes)):
        for j in range(len(clean_data)):
            for x in range(2):
                if clean_data[j][x] > missing_nodes[i]:
                    clean_data[j][x] -= 1

        missing_nodes = [x - 1 for x in missing_nodes]

    f = open(f"new{filename}", "w")

    for data in clean_data:
        f.writelines(f"{data[0]} {data[1]}\n")
    f.close()

    return


if __name__ == "__main__":
    net_sizes = [1000, 5000, 10000, 50000]
    for i in range(len(net_sizes)):
        filename = f"nets/net{net_sizes[i]}.dat"
        clean_data = read_input(filename=filename)
        missing_nodes = get_missing_nodes(clean_data)
        if len(missing_nodes) > 0:
            clean_input_file(
                filename=filename, clean_data=clean_data, missing_nodes=missing_nodes
            )
