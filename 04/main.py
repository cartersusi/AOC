TARGET = "MAS"

def readFileToMatrix(file_path):
    matrix = []
    with open(file_path, 'r') as file:
        for line in file:
            row = list(line.strip())
            matrix.append(row)
    return matrix

def printMatrix(matrix):
    for row in matrix:
        print(' '.join(row))

file_path = 'input'
matrix = readFileToMatrix(file_path)

res = 0
for i, row in enumerate(matrix):
    for j, col in enumerate(row):
        x = matrix[i][j]
        if x != TARGET[1]:
            continue

        top_left = matrix[i-1][j-1] if i > 0 and j > 0 else None
        bottom_right = matrix[i+1][j+1] if i < len(matrix)-1 and j < len(row)-1 else None
        
        bottom_left = matrix[i+1][j-1] if i < len(matrix)-1 and j > 0 else None
        top_right = matrix[i-1][j+1] if i > 0 and j < len(row)-1 else None
        if top_left == None or bottom_right == None or bottom_left == None or top_right == None:
            continue

        tmp = False
        if top_left == TARGET[0] and bottom_right == TARGET[2] or top_left == TARGET[2] and bottom_right == TARGET[0]:
            tmp = True
        if not tmp:
            continue

        tmp = False
        if bottom_left == TARGET[0] and top_right == TARGET[2] or bottom_left == TARGET[2] and top_right == TARGET[0]:
            tmp = True
        if not tmp:
            continue

        res += 1
        
print(res)
                
            
