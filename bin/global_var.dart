/// Файл для глобальных переменных

List<List<String>> tableBody = []; //  табличка
List<String> tableRow = []; //  её строка

List<String> signs = []; //  массив для символов
List<String> resultStr = []; //  массив для результирующей строки
List<double> result = []; //  массив, в котором будет вычисляться результат

Map<String, int> priority = {
  //  словарь sприоритетов
  '~': 4, //  унарный минус
  '^': 3,
  '/': 2,
  '*': 2,
  '-': 1,
  '+': 1,
  '(': 0
};

final numRegex = RegExp(r'^[0-9]*$'); //  регулярное выражение для числа

String errorMsg = '';
int brackets = 0; //  счетчик скобок
bool dot = false;
String operator = ''; //  строка под символ
double lastValue = 0; //  переменная под последнее число
double right = 0; //  переменная под правый операнд
double left = 0; //  переменная под левый операнд
double resultValue = 0; //  результирующее значение
int i = 0; //  счетчик
int n = 0; //  номер строки
String mainEqu = ''; //  строка под уравнение
double? X = 0; //  икс
double? Xk = 0; //  коненчый икс
double? Y = 0; //  игрек
double? H = 0; //  шаг
int? eLimit = 0; //  погрешность
int? exit = 0; //  выход

void delimiter() =>
    print("\n===========================\n"); //  разделитель в консоли