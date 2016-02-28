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

  final Queue<List<int>> stack = new Queue();

  DivElement tree = new DivElement();

  String values = '';

  onGetArray() {
    tree = DOM.query("#tree");
    cells.clear();
    stack.clear();

    int size = int.parse(values);
    Random rnd = new Random();

    for(int i = 0; i< size; i++) {
      cells.add( pow(-1, i) * rnd.nextInt(100));
    }
    print("Yey Found: ");print(divideAndConquer(cells,0,size).toString());
    generateTree(size);
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
            print(E);
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




  int divideAndConquer(List<int> input, int leftIndex, int size) {
    if (size == 1) {
      return input.elementAt(leftIndex);
    }
    int middle = size ~/ 2;

    int maxLeftSum = divideAndConquer(input, leftIndex, middle);
    int maxRightSum = divideAndConquer(input, leftIndex + middle, size - middle);

    int maxLeftBorderSum = -10000, maxRightBorderSum = -10000;
    int sum = 0;

    List<int> level = new List(); // displ. purposes
    sum = 0;
    for (int i = middle; i < size; i++) {
      level.add(input.elementAt(i)); // displ. purposes
      sum += input.elementAt(i);
      maxRightBorderSum = max(sum, maxRightBorderSum);
      print(input.elementAt(i));
    }
    stack.addFirst(level);// displ. purposes

    level = new List(); // for displaying purposes we use here a new list
    for (int i = middle - 1; i >= 0; i--) {
      level.add(input.elementAt(i)); // displ. purposes
      sum += input.elementAt(i);
      maxLeftBorderSum = max(sum, maxLeftBorderSum);
      print(input.elementAt(i));
    }
    stack.addFirst(level);// displ. purposes

    int result = max(maxLeftSum, maxRightSum);
    result = max(result , maxLeftBorderSum + maxRightBorderSum);

    return result;
  }
}

