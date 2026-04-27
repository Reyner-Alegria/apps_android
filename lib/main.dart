// Made by Reyner Carlos Silva Alegria
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculadoraCientificaApp());
}

class CalculadoraCientificaApp extends StatelessWidget {
  const CalculadoraCientificaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Científica',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CalculadoraCientificaPage(),
    );
  }
}

class CalculadoraCientificaPage extends StatefulWidget {
  const CalculadoraCientificaPage({super.key});

  @override
  State<CalculadoraCientificaPage> createState() => _CalculadoraCientificaPageState();
}

class _CalculadoraCientificaPageState extends State<CalculadoraCientificaPage> {
  static const Color numberColor = Color(0xFFD4D4D2);
  static const Color operatorColor = Color(0xFFFF9500);
  static const Color functionColor = Color(0xFF505050);

  String display = '0';
  String _expression = '';

  void clearAll() {
    setState(() {
      display = '0';
      _expression = '';
    });
  }

  void deleteLast() {
    setState(() {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
      display = _expression.isEmpty ? '0' : _expression;
    });
  }

  void appendValue(String value) {
    setState(() {
      if (_expression == '0' && value != '.') {
        _expression = value;
      } else {
        _expression += value;
      }
      display = _expression;
    });
  }

  void _applyUnary(String label) {
    setState(() {
      final value = double.tryParse(_expression) ?? 0.0;
      double result;
      switch (label) {
        case 'sin':
          result = sin(value * pi / 180);
          break;
        case 'cos':
          result = cos(value * pi / 180);
          break;
        case 'tan':
          result = tan(value * pi / 180);
          break;
        case '√':
          result = value < 0 ? double.nan : sqrt(value);
          break;
        case 'x²':
          result = value * value;
          break;
        case 'ln':
          result = value <= 0 ? double.nan : log(value);
          break;
        case 'log':
          result = value <= 0 ? double.nan : log(value) / ln10;
          break;
        default:
          result = value;
      }
      _expression = _formatResult(result);
      display = _expression;
    });
  }

  void evaluateExpression() {
    try {
      final expression = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('^', '**');
      final result = _calculate(expression);
      setState(() {
        _expression = _formatResult(result);
        display = _expression;
      });
    } catch (_) {
      setState(() {
        display = 'Erro';
        _expression = '';
      });
    }
  }

  double _calculate(String expression) {
    final parser = _ExpressionParser(expression);
    return parser.parse();
  }

  String _formatResult(double result) {
    if (result.isNaN) return 'Erro';
    if (result.isInfinite) return 'Erro';
    return result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 6)
        .replaceAll(RegExp(r'\.0+$'), '');
  }

  final List<String> history = [];
  String lastAnswer = '';

  void _addHistory(String expression, String result) {
    final entry = '$expression = $result';
    history.insert(0, entry);
    if (history.length > 5) history.removeLast();
  }

  void _appendConstant(String value) {
    setState(() {
      if (_expression == '0' && !value.contains('.')) {
        _expression = value;
      } else {
        _expression += value;
      }
      display = _expression;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora Científica'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Text(
                display,
                style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w500, color: Colors.black),
                maxLines: 2,
                textAlign: TextAlign.right,
              ),
            ),
          ),
          _buildHistorySection(theme),
          const SizedBox(height: 8),
          Expanded(flex: 2, child: _buildButtonGrid()),
        ],
      ),
    );
  }

  Widget _buildHistorySection(ThemeData theme) {
    return Container(
      height: 130,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Histórico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Expanded(
            child: history.isEmpty
                ? const Center(child: Text('Sem histórico'))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            final parts = entry.split(' = ');
                            _expression = parts.first;
                            display = _expression;
                          });
                        },
                        child: Container(
                          width: 220,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: theme.colorScheme.outline),
                          ),
                          child: Text(entry, style: const TextStyle(fontSize: 16)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonGrid() {
    final buttons = [
      ['C', 'DEL', 'π', 'e'],
      ['sin', 'cos', 'tan', '√'],
      ['ln', 'log', 'x²', 'ANS'],
      ['7', '8', '9', '÷'],
      ['4', '5', '6', '×'],
      ['1', '2', '3', '-'],
      ['0', '.', '(', ')'],
      ['^', '%', '+', '='],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        children: buttons.map((row) {
          return Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: row.map((label) {
                final color = _buttonColor(label);
                final foreground = (color == operatorColor || color == functionColor) ? Colors.white : Colors.black;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: foreground,
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: () => _onButtonPressed(label),
                      child: Text(label),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onButtonPressed(String label) {
    switch (label) {
      case 'C':
        clearAll();
        break;
      case 'DEL':
        deleteLast();
        break;
      case '=':
        evaluateExpression();
        break;
      case 'sin':
      case 'cos':
      case 'tan':
      case '√':
      case 'ln':
      case 'log':
      case 'x²':
        _applyUnary(label);
        break;
      case 'π':
        _appendConstant('3.141592653589');
        break;
      case 'e':
        _appendConstant('2.718281828459');
        break;
      case 'ANS':
        appendValue(lastAnswer.isEmpty ? '0' : lastAnswer);
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
      case '^':
      case '.':
      case '(':
      case ')':
      case '%':
        appendValue(label);
        break;
      default:
        appendValue(label);
        break;
    }
  }

  Color _buttonColor(String label) {
    if (['C', 'DEL'].contains(label)) return numberColor;
    if (['=', '+', '-', '×', '÷', '^', '%'].contains(label)) return operatorColor;
    if (['sin', 'cos', 'tan', '√', 'ln', 'log', 'x²', 'ANS', 'π', 'e'].contains(label)) return functionColor;
    return numberColor;
  }
}

class _ExpressionParser {
  final String expression;
  late String _expr;
  int _pos = -1;
  String _currentToken = '';

  _ExpressionParser(this.expression) {
    _expr = expression.replaceAll(' ', '');
  }

  double parse() {
    _nextToken();
    final value = _parseExpression();
    if (_currentToken.isNotEmpty) {
      throw FormatException('Unexpected token: $_currentToken');
    }
    return value;
  }

  void _nextToken() {
    if (_pos >= _expr.length - 1) {
      _currentToken = '';
      return;
    }
    _pos++;
    _currentToken = _expr[_pos];
    if (_currentToken == '*' && _pos + 1 < _expr.length && _expr[_pos + 1] == '*') {
      _pos++;
      _currentToken = '**';
    }
  }

  double _parseExpression() {
    var value = _parseTerm();
    while (_currentToken == '+' || _currentToken == '-') {
      final op = _currentToken;
      _nextToken();
      final right = _parseTerm();
      value = op == '+' ? value + right : value - right;
    }
    return value;
  }

  double _parseTerm() {
    var value = _parseFactor();
    while (_currentToken == '*' || _currentToken == '/' || _currentToken == '%') {
      final op = _currentToken;
      _nextToken();
      final right = _parseFactor();
      if (op == '*') {
        value *= right;
      } else if (op == '/') {
        value /= right;
      } else {
        value %= right;
      }
    }
    return value;
  }

  double _parseFactor() {
    var value = _parseBase();
    while (_currentToken == '**') {
      _nextToken();
      final exponent = _parseBase();
      value = pow(value, exponent).toDouble();
    }
    return value;
  }

  double _parseBase() {
    if (_currentToken == '+') {
      _nextToken();
      return _parseBase();
    }
    if (_currentToken == '-') {
      _nextToken();
      return -_parseBase();
    }
    if (_currentToken == '(') {
      _nextToken();
      final value = _parseExpression();
      if (_currentToken != ')') throw FormatException('Expected )');
      _nextToken();
      return value;
    }
    return _parseNumber();
  }

  double _parseNumber() {
    final start = _pos;
    while (_currentToken.isNotEmpty && (RegExp(r'[0-9.]').hasMatch(_currentToken))) {
      if (_pos >= _expr.length - 1) break;
      _nextToken();
    }
    final token = _expr.substring(start, _pos);
    final value = double.tryParse(token);
    if (value == null) throw FormatException('Número inválido: $token');
    _nextToken();
    return value;
  }
}
