import 'package:angular2/angular2.dart';
import 'dart:collection';
import 'dart:html';
import 'dart:math';

@Component(selector: 'max_partial_sum', templateUrl: 'MaxPartialSum.html')
class MaxPartialSum {

  String result = "";

  List<int> cells = new List();
  List<List<int>> levels = new List();

  HashMap<int, DivElement> rows = new HashMap();

  DivElement tree = new DivElement();

  String values = '';

  onGetArray() {
    tree = DOM.query("#tree");
    tree.children.clear();
    DOM.clearNodes(tree);
    cells.clear();


    int size = int.parse(values);
    Random rnd = new Random();

    for(int i = 0; i < size; i++) {
      cells.add( pow(-1, i) * rnd.nextInt(100));
    }

    var rest =  1;
    var ticker = true;
    while (ticker) {
      rest = log(size)/log(2);
      print(rest);
      ticker = false;
      var splits = rest.toString().split('.');
      if (splits.length > 1) {
        String chunk = splits.elementAt(1);
        for (int i = 0 ; i < chunk.length; i++) {
          //print(chunk[i]);
          if (chunk[i] != "0") {
            rest = 1;
            size = size + 1;
            cells.add(0);
            ticker = true;
            break;
          }
        }
      }
    }

    for (int i = 0; i< size; i++) {
      rows[i + 1] = createRow();
    }



    DivElement row = new DivElement();
    row.className = "row";


    DivElement block  = new DivElement();
    block.className = "block";

    row.children.add(block);

    result = divideAndConquer(cells, 0, size).toString();



    rows.values.toList().reversed.forEach((D) {
      if (D.hasChildNodes()) {
        DOM.appendChild(tree, D);
      }
    });

  }


  void addCell(DivElement childNode, int number) {
    DivElement newCell = new DivElement();
    newCell.text = number.toString();
    newCell.className = "cell";
    childNode.children.add(newCell);
  }

  DivElement createRow() {
    var ele = new DivElement(); // container for bottom divs
    ele.className = "row";
    return ele;
  }

  DivElement createRightBlock() {
    return createBlock("left");
  }

  DivElement createLeftBlock() {
    return createBlock("right");
  }

  DivElement createSingleBlock() {
    return createBlock("none");
  }

  DivElement createBlock(String direction) {
    var ele = new DivElement(); // container for bottom divs
    ele.classes.add( "block");
    ele.classes.add( direction);
    return ele;
  }

  /**
   * Because we know how many rows we have from the beginning we create them and just add content
   */
  DivElement getCurrentRow(size) {
    var cur = rows[size];
    if (cur == null) {
      print("ACHTUNG ACHTUN!!"); print(size);
    }
    return cur;
  }

  int divideAndConquer(List<int> input, int leftIndex, int size) {
    // new DivElement which is new Level bottom level
    // add elements to the one which came from top
    // giv the bottom ones new ones
    //        [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] // 1 tree, i rows , j*i cells
    //    [ ] [ ] [ ] [ ]  |  [ ] [ ] [ ] [ ]
    //[ ] [ ] [ ] | [ ] [ ] [ ] | [ ] [ ] [ ] [ ]

    if (size == 1) {
      DivElement block = createSingleBlock(); // dsp
      addCell(block, input.elementAt(leftIndex)); // dsp
      getCurrentRow(1).children.add(block); // dsp
      return input.elementAt(leftIndex);
    }
    int middle = size ~/ 2;


    DivElement currentRow = getCurrentRow(size); // dsp
    DivElement container = createSingleBlock();// dsp
    DivElement leftBlock = createLeftBlock();// dsp
    DivElement rightBlock = createRightBlock();// dsp


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

    container.children.add(leftBlock);
    container.children.add(rightBlock);

    currentRow.children.add(container);

    int result = max(maxLeftSum, maxRightSum);
    result = max(result , maxLeftBorderSum + maxRightBorderSum);

    return result;
  }

}
