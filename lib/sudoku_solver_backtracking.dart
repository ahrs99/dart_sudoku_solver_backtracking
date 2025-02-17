import 'dart:async';
import 'dart:io';

class SudokuSolver {
  SudokuSolver([this.animationDuration = const Duration(milliseconds: 50)]);

  final Duration animationDuration;

  final StreamController<List<List<int>>> streamController =
      StreamController<List<List<int>>>();

  Future<bool> solve(
    List<List<int>> grid, [
    int row = 0,
    int col = 0,
  ]) async {
    await Future<void>.delayed(animationDuration);

    streamController.add(clone(grid));

    if (row == grid.length) {
      return true;
    } else if (col == grid.length) {
      return solve(grid, row + 1);
    } else if (grid[row][col] != 0) {
      return solve(grid, row, col + 1);
    } else {
      for (int value = 1; value <= grid.length; value++) {
        if (_isValid(grid, row, col, value)) {
          grid[row][col] = value;

          if (await solve(grid, row, col + 1)) {
            return true;
          }

          grid[row][col] = 0;
        }
      }

      return false;
    }
  }

  static List<List<int>> clone(List<List<int>> grid) {
    final List<List<int>> copy = <List<int>>[];

    for (int i = 0; i < grid.length; i++) {
      copy.add(grid[i].toList());
    }

    return copy;
  }

  static void printGrid(List<List<int>> grid) {
    stdout.writeln('\x1B[2J\x1B[0;0H');

    for (int i = 0; i < grid.length; i++) {
      final StringBuffer row = StringBuffer();

      for (int j = 0; j < grid.length / 3; j++) {
        row.write('${grid[i][j]} ');
      }

      row.write('| ');

      for (int j = grid.length ~/ 3; j < grid.length / 3 * 2; j++) {
        row.write('${grid[i][j]} ');
      }

      row.write('| ');

      for (int j = grid.length ~/ 3 * 2; j < grid.length; j++) {
        row.write('${grid[i][j]} ');
      }

      if (i % 3 == 0 && i != 0) {
        stdout.writeln('------+-------+------');
      }

      stdout.writeln(row);
    }

    stdout.writeln();
  }

  bool _isValid(List<List<int>> grid, int row, int col, int value) {
    final bool notInRow = grid[row].every((int element) => element != value);
    final bool notInCol = grid.every((List<int> row) => row[col] != value);

    bool notInBox = true;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (grid[i + (row - row % 3)][j + (col - col % 3)] == value) {
          notInBox = false;
        }
      }
    }

    return notInRow && notInCol && notInBox;
  }

  void dispose() => streamController.close();
}
