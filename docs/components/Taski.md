# Taski

## Описание

- Хранение задач.
- Выдача информации по задаче пользователю для решения.
- Выдача файла задачи по запросу (например, условие / тесты).
- Выдача полного архива с задачей для тестирования.
- Проверка решения задачи, выдача вердикта тестирования.

## API

### Выдача информации по задаче пользователю

Запрос GET /task/7d971f50363cf0aebbd87d971f50363cf0aebbd8

Ответ:
```json
{
    "status": "OK",
    "task": {
        "id": "7d971f50363cf0aebbd87d971f50363cf0aebbd8",
        "name": "A + B",
        "level": 1,
        "statement": "statement.tex",
        "tl": 1000,
        "ml": 256,
        "tests": [
            {
                "order": 1,
                "input": "tests/01.in",
                "output": "tests/01.out"
            }
        ]
    }
}
```

### Выдача файла задачи

Запрос GET /task/7d971f50363cf0aebbd87d971f50363cf0aebbd8/statement.tex

Ответ: файл statement.tex

### Выдача id рандомной задачи

Запрос GET /task/random

Ответ:
```json
{
    "status": "OK",
    "task_id": "7d971f50363cf0aebbd87d971f50363cf0aebbd8"
}
```

### Выдача архива с задачей

Происходит с использованием пакета [filestorage](filestorage.md).

### Запрос на тестирование решения пользователя

POST /test

```json
{
    "task_id": "7d971f50363cf0aebbd87d971f50363cf0aebbd8",
    "solution_id": "1",
    "solution": "print(sum(map(int, input().split())))",
    "language": "Python"
}
```

### События обновления статуса тестирования решения

Тестирование решения началось
```json
{
    "status": "OK",
    "solution_id": "1",
    "type": "start"
}
```

Тестирование решения завершилось
```json
{
    "submission_id": "1",
    "type": "finish",
    "verdict": "Accepted" // либо "<вердикт> on test #T", где <вердикт> = ["Time Limit", "Memory Limit", "Wrong Answer", "Runtime Error"]
}
```
Тестирование решения завершилось с ошибкой, нужно показать сообщение пользователю
```json
{
    "submission_id": "1",
    "type": "finish",
    "verdict": "Compilation Error",
    "message": "ошибка компиляции бла-бла-бла"
}
```
Тестирование решения завершилось с ошибкой (техническая ошибка)
```json
{
    "solution_id": "1",
    "type": "finish",
    "error": "ошибка"
}
```

Тестирование решения в процессе:
```json
{
    "solution_id": "1",
    "type": "status",
    "message": "Test #T passed successfully"
}
```
