import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = ''; // Stores the current input expression
  String result = '0';    // Stores the calculation result
  TextEditingController _controller = TextEditingController(); // Controller for the TextField

  @override
  void initState() {
    super.initState();
    _controller.text = expression; // Initialize the TextField with empty expression
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose controller to free memory
    super.dispose();
  }

  // Handles all button presses
  void onPressed(String value) {
    setState(() {
      final selection = _controller.selection; // Current cursor position info
      final cursorPos = selection.baseOffset;  // Where the cursor is in the TextField

      if (value == 'AC') {
        // Clear everything
        expression = '';
        result = '0';
      } else if (value == '⌫') {
        // Backspace: remove one character before the cursor
        if (cursorPos > 0) {
          expression = expression.substring(0, cursorPos - 1) +
              expression.substring(cursorPos);
        }
      } else if (value == '=') {
        // When "=" is pressed, calculate the result
        calculateResult();
        return; // No need to update cursor
      } else {
        // Add the new value where the cursor is
        expression = expression.substring(0, cursorPos) +
            value +
            expression.substring(cursorPos);
      }

      // Update the TextField text
      _controller.text = expression;

      // Restore the cursor to correct position after change
      int newPos;
      if (value == '⌫') {
        newPos = (cursorPos - 1).clamp(0, _controller.text.length);
      } else if (value != 'AC' && value != '=') {
        newPos = (cursorPos + value.length).clamp(0, _controller.text.length);
      } else {
        newPos = cursorPos.clamp(0, _controller.text.length);
      }

      // Apply the new cursor position
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: newPos),
      );
    });
  }

  // Converts and evaluates the expression to get result
  void calculateResult() {
    try {
      // Replace symbols with actual math operators for parsing
      String exp = expression.replaceAll('x', '*').replaceAll('÷', '/');
      final parsed = _evaluate(exp);
      result = parsed.toString();
    } catch (e) {
      // If anything fails, show error
      result = 'Error';
    }
  }

  // Main evaluation logic
  double _evaluate(String exp) {
    List<String> tokens = _tokenize(exp); // Break expression into parts
    return _parseExpression(tokens); // Calculate from tokens
  }

  // Splits input into numbers and operators
  List<String> _tokenize(String input) {
    final regex = RegExp(r'(\d+\.?\d*|\+|\-|\*|\/)');
    return regex.allMatches(input).map((e) => e.group(0)!).toList();
  }

  // Loops left-to-right (no priority for * and / over + and -)
  double _parseExpression(List<String> tokens) {
    double total = double.parse(tokens[0]); // Start with first number
    for (int i = 1; i < tokens.length; i += 2) {
      String op = tokens[i]; // Operator (+, -, *, /)
      double next = double.parse(tokens[i + 1]); // Next number
      switch (op) {
        case '+':
          total += next;
          break;
        case '-':
          total -= next;
          break;
        case '*':
          total *= next;
          break;
        case '/':
          total /= next;
          break;
      }
    }
    return total;
  }

  // Creates a single calculator button
  Widget buildButton(String text, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 22),
          ),
          onPressed: () => onPressed(text), // Action when pressed
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 22),
          ),
        ),
      ),
    );
  }

  // Creates a row of buttons with appropriate colors
  Widget buildRow(List<String> values) {
    return Row(
      children: values.map((value) {
        Color color;
        if (value == 'AC') {
          color = Colors.red;
        } else if (value == '⌫') {
          color = Colors.indigo;
        } else if (value == '=') {
          color = Colors.orange;
        } else if (['+', '-', 'x', '÷'].contains(value)) {
          color = Colors.blue;
        } else {
          color = Colors.grey;
        }
        return buildButton(value, color);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("Arithmetic Calculator")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Input text field (shows current expression)
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _controller,
                onChanged: (val) {
                  setState(() {
                    expression = val;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Calculation',
                ),
                style: const TextStyle(fontSize: 24),
                keyboardType: TextInputType.text,
              ),
            ),
        
            // Shows calculation result
            Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  result,
                  style:
                      const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        
            const Divider(thickness: 1),
        
            // Calculator button layout
            Column(
              children: [
                buildRow(['7', '8', '9', '÷']),
                buildRow(['4', '5', '6', 'x']),
                buildRow(['1', '2', '3', '-']),
                buildRow(['AC', '⌫', '0', '+']),
                buildRow(['=']),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
