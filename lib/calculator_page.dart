import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = ''; // Stores the input expression
  String result = '0';    // Stores the calculation result
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = expression;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Button press handler
  void onPressed(String value) {
    setState(() {
      if (value == 'AC') {
        expression = '';
        result = '0';
      } else if (value == '=') {
        calculateResult();
        return;
      } else {
        expression += value;
      }

      _controller.text = expression;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  // Calculate result
  void calculateResult() {
    try {
      String exp = expression.replaceAll('x', '*').replaceAll('÷', '/');
      final parsed = _evaluate(exp);
      result = parsed.toString();
    } catch (e) {
      result = 'Error';
    }
  }

  // Evaluate expression
  double _evaluate(String exp) {
    List<String> tokens = _tokenize(exp);
    return _parseExpression(tokens);
  }

  // Tokenize input
  List<String> _tokenize(String input) {
    final regex = RegExp(r'(\d+\.?\d*|\+|\-|\*|\/)');
    return regex.allMatches(input).map((e) => e.group(0)!).toList();
  }

  // Left-to-right evaluation
  double _parseExpression(List<String> tokens) {
    double total = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      String op = tokens[i];
      double next = double.parse(tokens[i + 1]);
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

  // Build calculator button
  Widget buildButton(String text, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 22),
          ),
          onPressed: () => onPressed(text),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 22),
          ),
        ),
      ),
    );
  }

  // Build row of buttons
  Widget buildRow(List<String> values) {
    return Row(
      children: values.map((value) {
        Color color;
        if (value == 'AC') {
          color = Colors.red;
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
      appBar: AppBar(title: const Text("Arithmetic Calculator")),
      body: Column(
        children: [
          // Editable TextField
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

          // Result display
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                result,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const Divider(thickness: 1),

          // Buttons
          Expanded(
            child: Column(
              children: [
                buildRow(['7', '8', '9', '÷']),
                buildRow(['4', '5', '6', 'x']),
                buildRow(['1', '2', '3', '-']),
                buildRow(['AC', '0', '=', '+']),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
