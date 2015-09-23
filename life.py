import numpy as np

class Board(object):
    def __init__(self, size):
        self.board = np.zeros(size, int)
        self.board[3][2] = 1
        self.board[3][3] = 1
        self.board[3][4] = 1
        self.board[4][3] = 1

    def next(self):
        w, h = self.board.shape
        for (r, c) in np.nditer(self.board):
            print()
            print("Row: {}, Column: {}".format(r, c))

    neighbor_coordinates = [(-1,  1), (0,  1), (1,  1),
                            (-1,  0),          (1,  0),
                            (-1, -1), (0, -1), (1, -1)]
    def neighbors(self, row, column):
        width, height = self.board.shape
        count = 0
        for (column_mod, row_mod) in self.__class__.neighbor_coordinates:
            coords = (row + row_mod, column + column_mod)
            if coords[0] >= height or coords[1] >= width:
                continue
            if self.board[coords[0], coords[1]] == 1:
                count += 1
        return count

    def __iter__(self):
        while True:
            yield self.next()

    def __str__(self):
        b = bytearray()
        for row in self.board:
            for cell in row:
                # Append a "*" if the cell is alive, if not a space
                b.append(42 if cell == 1 else 32)
            # Append a newline
            b.append(10)
        return str(b, "utf-8")


if __name__ == "__main__":
