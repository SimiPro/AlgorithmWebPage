// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/angular2.dart';
import 'dart:math';
import 'dart:collection';
import 'dart:html';

@Component(selector: 'my-app', templateUrl: 'app_component.html')
class AppComponent {

  List<int> cells = new List();
  List<List<int>> levels = new List();

  HashMap<int, DivElement> rows = new HashMap();

  final Queue<List<int>> stack = new Queue();
  final Queue<DivElement> row_stack = new Queue();

  DivElement tree = new DivElement();

  String values = '';

  onGetArray() {
    tree = DOM.query("#tree");
    DOM.clearNodes(tree);
    cells.clear();
    stack.clear();

    int size = int.parse(values);
    Random rnd = new Random();

    for(int i = 0; i< size; i++) {
      cells.add( pow(-1, i) * rnd.nextInt(100));
    }

    int currKey = size;
    while(currKey != 0) {
      var newRow = createRow();
      rows[currKey] = newRow;
      currKey = currKey ~/ 2;
    }

    DivElement row = new DivElement();
    row.className = "row";


    DivElement block  = new DivElement();
    block.className = "block";

    row.children.add(block);


    print("Result: ");print(divideAndConquer(cells, 0, size).toString());



  //  DOM.appendChild(tree, row);
    currKey = size;
    while(currKey != 0) {
      DOM.appendChild(tree, rows[currKey]);
      currKey = currKey ~/ 2;
    }

    //generateTree(size);
  }


  generateTree(int size) {
    int nextlevels = 2;

    for (int i = 0; i < stack.length; i++) {
      DivElement row = new DivElement();
      row.className = "array";

      for (int j = 0; j < nextlevels; j++) {
        var curr = stack.removeFirst();
        DivElement column = new DivElement();
        column.className = "column";
        row.append(column);
        curr.forEach((E) {
            DivElement cell = new DivElement();
            cell.text = E;
            cell.className = "cell";
            column.append(cell);
        });
        i++;
      }
      DOM.appendChild(tree, row);
      nextlevels = nextlevels * 2;
    }
  }



  void addCell(DivElement childNode, int number) {
    DivElement newCell = new DivElement();
    newCell.text = number.toString();
    newCell.className = "cell";
    childNode.children.add(newCell);
    //DOM.appendChild(childNode, newCell);
  }

  DivElement createRow() {
    var ele = new DivElement(); // container for bottom divs
    ele.className = "row";
    return ele;
  }

  DivElement createBlock() {
    var ele = new DivElement(); // container for bottom divs
    ele.className = "block";
    return ele;
  }

  /**
   * Because we know how many rows we have from the beginning we create them and just add content
   */
  DivElement getCurrentRow(size) {
    return rows[size];
  }

  int divideAndConquer(List<int> input, int leftIndex, int size) {
    // new DivElement which is new Level bottom level
    // add elements to the one which came from top
    // giv the bottom ones new ones
    //        [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] // 1 tree, i rows , j*i cells
    //    [ ] [ ] [ ] [ ]  |  [ ] [ ] [ ] [ ]
    //[ ] [ ] [ ] | [ ] [ ] [ ] | [ ] [ ] [ ] [ ]

    if (size == 1) {
      //DivElement block = createBlock();
      //addCell(block, input.elementAt(leftIndex)); // dsp
      //getCurrentRow(1).children.add(block);
      return input.elementAt(leftIndex);
    }
    int middle = size ~/ 2;


    DivElement currentRow = getCurrentRow(middle);
    DivElement leftBlock = createBlock();
    DivElement rightBlock = createBlock();

    int maxLeftSum = divideAndConquer(input, leftIndex, middle);
    int maxRightSum = divideAndConquer(input, leftIndex + middle, size - middle);

    int maxLeftBorderSum = -10000, maxRightBorderSum = -10000;
    int sum = 0;

    for (int i = middle; i < size; i++) {
      addCell(rightBlock, input.elementAt(i + leftIndex));
      sum += input.elementAt(i + leftIndex);
      maxRightBorderSum = max(sum, maxRightBorderSum);
    }

    sum = 0;
    for (int i = middle - 1; i >= 0; i--) {
      addCell(leftBlock, input.elementAt(i + leftIndex));
      sum += input.elementAt(i + leftIndex);
      maxLeftBorderSum = max(sum, maxLeftBorderSum);
    }

    currentRow.children.add(leftBlock);
    currentRow.children.add(rightBlock);

    int result = max(maxLeftSum, maxRightSum);
    result = max(result , maxLeftBorderSum + maxRightBorderSum);

    return result;
  }
}

