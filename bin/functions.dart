/// Основной файл вычислений
///
/// Используемые функции и процедуры:
/// requestValues - запрос начальных данных
/// solution - вычисление по выбранному методу
/// isItEqu - проверка на то, что у нас уравнение правильно введено
/// getNumber - чтение числа из строки
/// getResultValue - чтение массива resultStr и его вычисление
/// calcThis - вычисление каждого действия
/// printTable - вывод таблицы решения
/// getResultByEulerCauchy - вычисление методом Эйлера-Коши
/// getResultByEuler - вычисление методом Эйлера
/// amIWantToLeave - выход из программы

//  подключаемые библиотеки для работы и обращения к глобальным переменным
import 'dart:math';
import 'dart:io';
import 'global_var.dart';

//  пакет для работ с таблицами в консоли
import 'package:dolumns/dolumns.dart';

void requestValues() {
  resultStr = [
    'x',
    'y',
    '.',
    '/',
    '-',
    '+',
    '*',
    '^',
    '(',
    ')'
  ]; //  массив для результирующей строки

  //  блок ввода уравнения
  do {
    if (errorMsg.isEmpty) {
      print(
          '\nВведите уравнение вида: f(y,x)'); //  если до этого не было ошибок
    } else {
      print(
          '!!! В уравнении y\' = $mainEqu допущена ошибка ($errorMsg), проверьте уравнение и введите корректный вариант');
    }
    //  принимаем текст и форматируем его
    mainEqu = stdin.readLineSync()!;
    mainEqu = mainEqu.replaceAll(' ', '');
    mainEqu = mainEqu.toLowerCase();
  } while (!isItEqu(mainEqu));
  print("\nВводите десятичные числа через точку!\n");

  //  ввод переменных
  do {
    print('Введите начальное значение для Х = ');
    X = double.tryParse(stdin.readLineSync()!);
  } while (X == null);

  do {
    print('Введите конечное значение для Хk > X = ');
    Xk = double.tryParse(stdin.readLineSync()!);
  } while (Xk == null || Xk! <= X!);

  do {
    print('Введите начальное значение для Y>0 = ');
    Y = double.tryParse(stdin.readLineSync()!);
  } while (Y == null || Y! <= 0);

  do {
    print('Введите степень допустимой погрешности 0 < E < 8 = ');
    eLimit = int.tryParse(stdin.readLineSync()!);
  } while (eLimit == null || eLimit! <= 0 || eLimit! >= 8);

  do {
    print('Введите шаг H>0 = ');
    H = double.tryParse(stdin.readLineSync()!);
  } while (H == null || H! <= 0);
  delimiter();
  print("Ваше уравнение: y' = $mainEqu ;");
  print("X0 = $X, Y0 = $Y, X ∈ [$X ; $Xk], E = ${10}^(-${eLimit!}), H = $H ;");
  delimiter();
}

void solution() {
  //  локальные переменные:
  //  answer - выбор ответа
  int? answer;
  do {
    print('Выберите метод:\n1. Метод Эйлера\n2. Метод Эйлера-Коши');
    answer = int.tryParse(stdin.readLineSync()!);
  } while (answer != 1 && answer != 2 || answer == null);
  delimiter();

  n = 0;
  while (X! <= Xk!) {
    //  пока мы не выйдем за пределы отрезка
    switch (answer) {
      case 1: //  метод Эйлера
        tableBody.isEmpty //  если у нас таблица пуста,
            //  то мы добавляем шапку
            ? tableBody.add(['n', 'X(n)', 'Y(n)', 'Y\'(n)', 'ΔY(n)=Y\'(n)*h'])
            //  иначе вносим новую строку
            : getResultByEuler();
        break;
      case 2: //  метод Эйлера-Коши
        tableBody.isEmpty
            ? tableBody.add([
                'n',
                'X(n)',
                'Y(n)',
                'Y\'(n)',
                'ΔY(n)=Y\'(n)*h',
                'X(n+1)',
                'ỹ(n+1)',
                'ỹ\'(n+1)',
                'Δỹ(n+1)=ỹ\'(n+1)*h',
                'Δỹ(n)'
              ])
            : getResultByEulerCauchy();
        break;
    }
    n++; //  номер строки
  }
  printTable(tableBody); //  вывод таблицы
  tableBody.clear(); //  очищаем таблицу
  delimiter();
}

bool isItEqu(mainEqu) {
  //  Формальные параметры:
  //  mainEqu - строка текущего уравнения на проверку
  if (mainEqu == '') {
    //  ничего не ввели
    errorMsg = "Введите уравнение";
    return false;
  }

  if (!mainEqu.contains('x') || !mainEqu.contains('y')) {
    //  нет х или у
    errorMsg = "Отсутствие необходимых переменных";
    return false;
  }

  brackets = 0; //  счетчик скобок

  for (i = 0; i < mainEqu.length; i++) {
    //  пробег по всей строке
    if (!(resultStr.contains(mainEqu[i]) || numRegex.hasMatch(mainEqu[i]))) {
      //  нашли неизвестный символ (не число и не разрешенные знаки)
      errorMsg = "Неизвестные символы в формуле (${mainEqu[i]})";
      return false;
    }
    if (i != mainEqu.length - 1) {
      //  если мы не дошли до конца (иначе будет выход за пределы массива)
      if (priority
              .containsKey(mainEqu[i]) && //  если операторы идут друг за другом
          priority.containsKey(mainEqu[i + 1]) &&
          mainEqu[i + 1] != '(' &&
          mainEqu[i] != '(') {
        errorMsg = "Операторы идут друг за другом";
        return false;
      }
      if (mainEqu[i] == 'x' && mainEqu[i + 1] == 'x' ||
          mainEqu[i] == 'y' && mainEqu[i + 1] == 'y' ||
          mainEqu[i] == 'x' && mainEqu[i + 1] == 'y' ||
          mainEqu[i] == 'y' && mainEqu[i + 1] == 'x') {
        //  если переменные идут подряд
        errorMsg = "Переменные идут подряд";
        return false;
      }
      if (dot && mainEqu[i] == '.') {
        //  если повторяется точка в числе
        errorMsg = "Повторяется десятичная точка в числе";
        return false;
      }

      if (mainEqu[i + 1] == '0' && mainEqu[i] == '/') {
        //  явно делим на ноль
        errorMsg = "Явное деление на ноль";
        return false;
      }
      //  если мы встретили точку до этого и текущий символ не число
      //  то мы закончили читать число
      (dot && !numRegex.hasMatch(mainEqu[i])) ? dot = !dot : null;
    }
    //  если встретили точку, то ставим флажок
    mainEqu[i] == "." ? dot = !dot : null;

    //  ин- и де-крементируем количество скобок по открой и закрытой
    mainEqu[i] == "(" ? brackets++ : null;
    mainEqu[i] == ")" ? brackets-- : null;
  }

  if (brackets != 0) {
    //  если в конце счетчик не равен нулю, то мы ловим ошибку
    errorMsg = "Неравное количество скобок";
    return false;
  }
  resultStr.clear(); //  очищаем результирующую строку
  return true;
}

String getNumber(String str, int j) {
  //  Формальные параметры:
  //  str - часть всего уравнения
  //  j - текущая позиция символа в str
  //
  //  Локальные параметры:
  //  number - строка для итогового числа
  String number = "";

  //  начальное значение для счетчика не задается
  for (; j < str.length; j++) {
    if (numRegex.hasMatch(str[j]) || str[j] == '.') {
      //  если число
      number += str[j]; //  записываем число
    } else {
      break;
    }
  }
  i = j - 1; //  передвигаем курсор по строке
  return number; //  возвращаем число
}

void convertEqu(String mainEqu) {
  //  функция перевода строки в польскую нотацию

  //  чистим все массивы
  signs.clear(); //  знаки
  resultStr.clear(); //  строка
  result.clear(); //  вычисление
  i = 0;
  while (i < mainEqu.length) {
    if (mainEqu[i] == 'x') {
      resultStr.add(X!.toStringAsFixed(eLimit!)); //  вставляем сразу число
    }
    if (mainEqu[i] == 'y') {
      resultStr.add(Y!.toStringAsFixed(eLimit!)); //  вставляем сразу число
    }
    if (numRegex.hasMatch(mainEqu[i]) || mainEqu[i] == '.') {
      //  встретили число
      resultStr.add(getNumber(mainEqu, i));
    }
    if (mainEqu[i] == '(') {
      //  встретили открывающуюся скобку
      signs.add(mainEqu[i]);
    } else if (mainEqu[i] == ')') {
      //  встретили закрывающуюся скобку
      while (signs.last != '(' && signs.isNotEmpty) {
        //  вынимаем из массива знаков все знаки до открывающейся скобки
        resultStr.add(
            signs.removeLast()); //  одновременно удаляем знак и добавляем его
      }
      signs.removeLast(); //  удаляем эту скобку
    } else if (priority.containsKey(mainEqu[i])) {
      //  проверка на то, есть ли такой оператор
      operator = mainEqu[i];
      //  проверка на то, унарный ли это минус. Если да, то ставим "~"
      operator == '-' &&
              (i == 0 || (i > 1 && priority.containsKey(mainEqu[i - 1])))
          ? operator = '~'
          : null;

      while (
          //  проверяем приоритет действия, чтоб вытащить его в результирующую строку
          signs.isNotEmpty && (priority[signs.last]! >= priority[operator]!)) {
        resultStr.add(signs.removeLast());
      }

      signs.add(operator); //  добавляем оператор
    }

    i++;
  }

  for (var anyOperator in signs.reversed) {
    //  вытаскиваем все из стека знаков
    resultStr.add(anyOperator);
  }
  i = 0;
}

double calcThis(String someOperator, var left, var right) {
  //  функция вычисления каждого действия
  switch (someOperator) {
    case '+':
      return left + right;
    case '-':
      return left - right;
    case '*':
      return left * right;
    case '/':
      if (right == 0) {
        delimiter();
        print(
            "В процессе вычислений произошло деление на ноль. \nДальнейшее вычисление невозможно");
        delimiter();
        return 0;
      }
      return left / right;
    case '^':
      if (left == right && left == 0) {
        delimiter();
        print(
            "В процессе вычислений произошло возведение нуля в нулевую степень. \nДальнейшее вычисление невозможно");
        delimiter();
        return 0;
      }
      return pow(left, right).toDouble();
    default:
      return 0;
  }
}

void printTable(tableBody) {
  //  функция, принимающее тело таблицы для его строительства
  final columns = dolumnify(tableBody, //  устанавливаем тело
      columnSplitter: '  │  ', //  разделитель для столбиков
      headerIncluded: true, //  у нас будут заголовки для столбиков,
      headerSeparator:
          '─'); //  которые будут отделены от основной таблицы таким символом
  print(columns); //  выводим нащу табличку
}

void getResultValue() {
  //  функция, которая читает массив resultStr и вычисляет его
  for (int i = 0; i < resultStr.length; i++) {
    if (double.tryParse(resultStr[i]) != null) {
      //  если встретили число, то парсим его в массив
      result
          .add(double.parse(num.parse(resultStr[i]).toStringAsFixed(eLimit!)));
    } else if (priority.containsKey(resultStr[i])) {
      //  иначе встретили знак
      if (resultStr[i] == "~") {
        //  Проверяем, если стек пуст, то задаём нулевое значение, иначе - вытаскиваем из стека значение
        lastValue = result.isNotEmpty ? result.removeLast() : 0;
        result.add(calcThis('-', 0, lastValue)); //  считаем унарный минус
        continue; //  идем на следующий шаг
      }

      right = result.isNotEmpty ? result.removeLast() : 0; //  правый операнд
      left = result.isNotEmpty ? result.removeLast() : 0; //  левый операнд

      result.add(calcThis(resultStr[i], left, right)); //  вычисляем
    }
  }
  resultValue = double.parse(result.removeLast().toStringAsFixed(
      eLimit!)); //  в конце сохраняем в переменную результат вычислений
}

void getResultByEulerCauchy() {
  //  функция вычисления Методом Эйлера-Коши
  convertEqu(mainEqu);
  getResultValue(); //  посчитает промежуточную производную

  tableRow = [
    //  здесь работа со строкой в таблице, потому что происходят промежуточные вычисления
    n.toString(), //  этап
    X!.toStringAsFixed(
        H!.toString().substring(H!.toString().indexOf('.')).length -
            1), //  промежуточный Х
    Y!.toStringAsFixed(eLimit!), //  промежуточный У
    resultValue.toStringAsFixed(eLimit!), //  промежуточная производная
    (resultValue * H!).toStringAsFixed(eLimit!) //  промежуточная дельта
  ];

  Y = Y! + resultValue * H!; //  следующий У
  X = double.parse(X!.toStringAsFixed(eLimit!)) + H!; //  новый шаг
  tableRow = [...tableRow, X!.toString(), Y!.toStringAsFixed(eLimit!)];
  convertEqu(mainEqu); // снова посчитает уравнение

  getResultValue(); //  посчитает следующую промежуточную производную

  tableRow = [
    ...tableRow, //  к предыдущему массиву добавляем следующие значения:
    resultValue
        .toStringAsFixed(eLimit!), //  следующая промежуточная производная
    (resultValue * H!).toStringAsFixed(eLimit!), //  часть дельты
    (H! * (resultValue + double.parse(tableRow[3])) / 2)
        .toStringAsFixed(eLimit!) //  дельта
  ];

  Y = double.parse(tableRow[2]) + double.parse(tableRow[9]); //  новый У

  tableBody.add(tableRow); //  вставляем новую строчку
}

void getResultByEuler() {
  // функция вычисления методом Эйлера

  convertEqu(mainEqu);
  getResultValue(); //  посчитает промежуточную производную

  tableBody.add([
    //  работа с таблицей
    n.toString(), //  этап
    X!.toStringAsFixed(
        H!.toString().substring(H!.toString().indexOf('.')).length -
            1), //  промежуточный Х
    Y!.toStringAsFixed(eLimit!), //  промежуточный У
    resultValue.toStringAsFixed(eLimit!), //  промежуточная производная
    (resultValue * H!).toStringAsFixed(eLimit!) //  промежуточная дельта
  ]);
  Y = Y! + resultValue * H!; //  следующий У
  X = double.parse(X!.toStringAsFixed(eLimit!)) + H!; //  новый шаг
}

void amIWantToLeave() {
  //  функция, которая спрашивает, хотим ли мы выйти
  do {
    print("Выйти из программы? 1 - да, 0 - нет");
    exit = int.tryParse(stdin.readLineSync()!);
    delimiter();
  } while (exit != 1 && exit != 0 && exit == null);
}
