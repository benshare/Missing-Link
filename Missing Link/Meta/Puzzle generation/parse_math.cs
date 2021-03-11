// Notes
// Various levels of decomposition
// One approach is to do a sequence of simplifications--remove whitespace, then collapse
// multiplication/division, then handle addition/subtraction
// Can also use IndexOf instead of looping through characters.

// Important functions
// IndexOf
//	str.IndexOf(ch)
//	str.IndexOf(ch, start)
// Int casting
//	(int)
// Enum
//	enum Name { v1, v2 }
// Char to int
//	Char.GetNumericValue(ch)


using System;

class MainClass {
  enum Operator {
  	plus,
  	minus,
  	times,
  	divides
  }

  enum State {
  	waitingForNumber,
  	addingToNumber,
  	waitingForOperator
  }

  // Parse string containing only whitespace, numerals, and +-
  // Questions to deal with:
  //	- Is white space allowed in the middle of numerals?
  //	- Can negative numbers be added?
  //	- What happens if the first/last character is an operator?
  public static double ParseMath1(String equation) {
    int total = 0;
    string state = "waitingForNumber";
    bool currentOperatorIsPlus = true;
    string currentNumber = "";
    foreach (char ch in equation) {
      switch (state) {
        case "waitingForNumber": {
          if (ch == ' ') {
            continue;
          }
          int val = (int)Char.GetNumericValue(ch);
          if (val == -1) {
            Console.WriteLine("Unexpected operator--expected numeral.");
            return -1;
          }
          currentNumber += ch;
          state = "addingToNumber";
          break;
        }
        case "addingToNumber": {
          if (ch == ' ') {
            if (currentOperatorIsPlus) {
              int tmp;
              int.TryParse(currentNumber, out tmp);
              total += tmp;
            } else {
              int tmp;
              int.TryParse(currentNumber, out tmp);
              total -= tmp;
            }
            currentNumber = "";
            state = "waitingForOperator";
            continue;
          }
          int val = (int)Char.GetNumericValue(ch);
          if (val == -1) {
            if (ch == '+') {
              state = "waitingForNumber";
              currentOperatorIsPlus = true;
            } else {
              state = "waitingForNumber";
              currentOperatorIsPlus = false;
            }
          } else {
            currentNumber += ch;
          }
          break;
        }
        case "waitingForOperator": {
          if (ch == ' ') {
            continue;
          }
          int val = (int)Char.GetNumericValue(ch);
          if (val != -1) {
            Console.WriteLine("Unexpected numeral--expected operator.");
            return -1;
          }
          if (ch == '+') {
            state = "waitingForNumber";
            currentOperatorIsPlus = true;
          } else {
            state = "waitingForNumber";
            currentOperatorIsPlus = false;
          }
        }
        break;
      }
    }
    if (state == "waitingForNumber") {
      Console.WriteLine("Unexpected end of string--expected numeral.");
      return -1;
    }
    if (currentOperatorIsPlus) {
      int tmp;
      int.TryParse(currentNumber, out tmp);
      total += tmp;
    } else {
      int tmp;
      int.TryParse(currentNumber, out tmp);
      total -= tmp;
    }
    return total;
  }

  // Take a string representing an equation, multiply/divide in
  // place, then return the simplified equation.
  public static String collapseTimesAndDivides(String equation) {
  	String result = "";
    string state = "waitingForNumber";
    bool currentOperatorIsTimes = true;
    string previousNumber = "";
    string currentNumber = "";
    foreach (char ch in equation) {
      switch (state) {
        case "waitingForNumber": {
          if (ch == ' ') {
            continue;
          }
          int val = (int)Char.GetNumericValue(ch);
          if (val == -1) {
            Console.WriteLine("Unexpected operator--expected numeral.");
            return -1;
          }
          currentNumber += ch;
          state = "addingToNumber";
          break;
        }
        case "addingToNumber": {
          if (ch == ' ') {
            if (currentOperatorIsPlus) {
              int tmp;
              int.TryParse(currentNumber, out tmp);
              total += tmp;
            } else {
              int tmp;
              int.TryParse(currentNumber, out tmp);
              total -= tmp;
            }
            currentNumber = "";
            state = "waitingForOperator";
            continue;
          }
          int val = (int)Char.GetNumericValue(ch);
          if (val == -1) {
            if (ch == '+') {
              state = "waitingForNumber";
              currentOperatorIsPlus = true;
            } else {
              state = "waitingForNumber";
              currentOperatorIsPlus = false;
            }
          } else {
            currentNumber += ch;
          }
          break;
        }
        case "waitingForOperator": {
          if (ch == ' ') {
            continue;
          }
          int val = (int)Char.GetNumericValue(ch);
          if (val != -1) {
            Console.WriteLine("Unexpected numeral--expected operator.");
            return -1;
          }
          if (ch == '+') {
            state = "waitingForNumber";
            currentOperatorIsPlus = true;
          } else {
            state = "waitingForNumber";
            currentOperatorIsPlus = false;
          }
        }
        break;
      }
    }
    if (state == "waitingForNumber") {
      Console.WriteLine("Unexpected end of string--expected numeral.");
      return -1;
    }
    if (currentOperatorIsPlus) {
      int tmp;
      int.TryParse(currentNumber, out tmp);
      total += tmp;
    } else {
      int tmp;
      int.TryParse(currentNumber, out tmp);
      total -= tmp;
    }
    return total;

  }

  // Parse string containing only whitespace, numerals, and +-*/
  // Questions to deal with:
  //	- Is white space allowed in the middle of numerals?
  //	- Can negative numbers be added?
  //	- What happens if the first/last character is an operator?
  public static double ParseMath2(String equation) {
    int total = 0;
    State state = .waitingForNumber;
    Operator currentOperator;
    Operator previousOperator;
    string currentNumber = "";
    int previousNumber;
    foreach (char ch in equation) {
      switch (state) {
        case .waitingForNumber: {
          if (ch == ' ') {
            continue;
          }
          int val = (int)Char.GetNumericValue(ch);
          if (val == -1) {
            Console.WriteLine("Unexpected operator--expected numeral.");
            return -1;
          }
          currentNumber += ch;
          state = .addingToNumber;
          break;
        }
        case .addingToNumber: {
          if (ch == ' ') {
          	switch (currentOperator) {
          		case .plus: {
            		int tmp;
	            	int.TryParse(currentNumber, out tmp);
	            	total += tmp;
	            }
            } else {
              int tmp;
              int.TryParse(currentNumber, out tmp);
              total -= tmp;
            }
            currentNumber = "";
            state = "waitingForOperator";
            continue;
          }
          int val = (int)Char.GetNumericValue(ch);
          if (val == -1) {
            if (ch == '+') {
              state = "waitingForNumber";
              currentOperatorIsPlus = true;
            } else {
              state = "waitingForNumber";
              currentOperatorIsPlus = false;
            }
          } else {
            currentNumber += ch;
          }
          break;
        }
        case .waitingForOperator: {
          if (ch == ' ') {
            continue;
          }
          int val = (int)Char.GetNumericValue(ch);
          if (val != -1) {
            Console.WriteLine("Unexpected numeral--expected operator.");
            return -1;
          }
          if (ch == '+') {
            state = "waitingForNumber";
            currentOperatorIsPlus = true;
          } else {
            state = "waitingForNumber";
            currentOperatorIsPlus = false;
          }
        }
        break;
      }
    }
    if (state == "waitingForNumber") {
      Console.WriteLine("Unexpected end of string--expected numeral.");
      return -1;
    }
    if (currentOperatorIsPlus) {
      int tmp;
      int.TryParse(currentNumber, out tmp);
      total += tmp;
    } else {
      int tmp;
      int.TryParse(currentNumber, out tmp);
      total -= tmp;
    }
    return total;
  }

  

  public static void Main(string[] args) {
    Console.WriteLine(ParseMath1("1 + 23     - 4  "));
    Console.WriteLine(ParseMath1("1 + 23     - 4 + "));
    Console.WriteLine(ParseMath1("1 + 23 5    - 4  "));
    Console.WriteLine(ParseMath1("1 + 23   +  - 4  "));
    Console.WriteLine(ParseMath1("1 ++ 23     - 4  "));
  }
}