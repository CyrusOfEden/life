import copy
import time
import os

class Life(object):
    def __init__(self, seed=[], board=(14, 80)):
        if type(board) == tuple:
            self.board = [[False for _ in range(board[1])] for _ in range(board[0])]
            for (x, y) in seed:
                self.board[y][x] = True
        elif type(board) == list:
            self.board = board
        elif type(board) == str:
            return

    def next(self):
        """Get the next board"""
        board = copy.deepcopy(self.board)
        for row, items in enumerate(self.board):
            for column, _ in enumerate(items):
                board[row][column] = self.__next_cell_state(row, column)
        return Life(board=board)

    neighbor_coordinates = [
        (-1,  1), (0,  1), (1,  1),
        (-1,  0),          (1,  0),
        (-1, -1), (0, -1), (1, -1)
    ]
    def __next_cell_state(self, row_index, column_index):
        """Get the next cell state"""
        row_count = len(self.board)
        column_count = len(self.board[0])

        cell = self.board[row_index][column_index]
        neighbors = 0

        for (row_modifier, column_modifier) in self.__class__.neighbor_coordinates:
            row = row_index + row_modifier
            column = column_index + column_modifier

            if 0 < row < row_count and 0 < column < column_count:
                if self.board[row][column]:
                    neighbors += 1

        return (neighbors == 2 and cell) or neighbors == 3

    def display(self, period=200, generations=24):
        """Run the simulation"""
        gen = self
        delay = period / 1000
        for generation in self:
            os.system("clear")
            print(generation)
            generations -= 1
            if generations <= 0:
                break
            time.sleep(delay)
        return True

    def __iter__(self):
        generation = self
        while True:
            yield generation
            generation = generation.next()

    def __repr__(self):
        return "\n".join(
            ("".join("◉" if cell else " " for cell in row)) for row in self.board
        )

    def __str__(self):
        return repr(self)

if __name__ == "__main__":
    l = Life(seed=[(3,7), (3,6), (3,5), (4,5), (4,6), (2,5), (2,6)])
    l.display(generations=50)
