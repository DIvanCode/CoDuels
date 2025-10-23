# Taski

## Описание

- Хранение задач.
- Выдача информации по задаче пользователю для решения.
- Выдача файла задачи по запросу (например, условие / тесты).
- Выдача полного архива с задачей для тестирования.
- Проверка решения задачи, выдача вердикта тестирования.

## API

### Выдача рандомного id задачи

#### Запрос

`GET /task/random`

#### Ответ

Успех
```json
{
    "status": "OK",
    "task_id": "7d971f50363cf0aebbd87d971f50363cf0aebbd8"
}
```

Ошибка
```json
{
    "status": "Error",
    "error": "ошибка"
}
```

### Выдача информации по задаче пользователю

#### Запрос

`GET /task/{id}`

Пример:
- `GET /task/7d971f50363cf0aebbd87d971f50363cf0aebbd8`

#### Ответ

Успех
```json
{
    "status": "OK",
    "task": {
        "id": "7d971f50363cf0aebbd87d971f50363cf0aebbd8",
        "title": "A + B",
        "type": "write_code",
        "statement": "statement.md",
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

Ошибка
```json
{
    "status": "Error",
    "error": "ошибка"
}
```

### Выдача файла задачи

#### Запрос

`GET /task/{id}/{path}`

Примеры:
- `GET /task/7d971f50363cf0aebbd87d971f50363cf0aebbd8/statement.md`
- `GET /task/7d971f50363cf0aebbd87d971f50363cf0aebbd8/tests/01.in`

#### Ответ

`содержимое файла`

### Выдача архива с задачей

Происходит с использованием пакета [filestorage](filestorage.md).

### Запрос на тестирование решения пользователя

#### Запрос

`POST /test`
```json
{
    "task_id": "7d971f50363cf0aebbd87d971f50363cf0aebbd8",
    "solution_id": "1",
    "solution": "print(sum(map(int, input().split())))",
    "language": "Python"
}
```

#### Ответ

Успех
```json
{
    "status": "OK"
}
```

Ошибка
```json
{
    "status": "Error",
    "error": "ошибка"
}
```

### События обновления статуса тестирования решения

- Тестирование решения началось
```json
{
    "solution_id": "1",
    "type": "start"
}
```

- Тестирование решения завершилось
```json
{
    "solution_id": "1",
    "type": "finish",
    "verdict": "Accepted"
}
```

- Тестирование решения завершилось с ошибкой, нужно показать сообщение пользователю
```json
{
    "solution_id": "1",
    "type": "finish",
    "verdict": "Compilation Error",
    "message": "ошибка компиляции..."
}
```

- Тестирование решения завершилось с ошибкой (техническая ошибка)
```json
{
    "solution_id": "1",
    "type": "finish",
    "error": "ошибка"
}
```

- Тестирование решения в процессе:
```json
{
    "solution_id": "1",
    "type": "status",
    "message": "Test N passed"
}
```
