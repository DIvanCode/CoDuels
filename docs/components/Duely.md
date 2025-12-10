# Duely

## Описание

- Единственная входная точка для пользователя.
- Хранение пользователей, рейтинга.
- Подбор соперника для дуэли.
- Управление дуэлями.
- Выдача id задачи для дуэли.
- Выдача информации про дуэль.
- Контроль за правилами и временем дуэли.
- Инициирование проверки решения.
- Хранение посылок участника дуэли.
- Получение вердикта.
- Завершение и формирование результата дуэли.
- Пересчёт рейтинга участников.
- Выдача истории дуэлей пользователя.

## Процессы

- Пользователь:
    - встаёт в очередь ожидания дуэли
    - выходит из очереди ожидания дуэли
    - отправляет посылку на тестирование
    - получает список своих посылок в дуэли
    - получает детальную информацию по посылке
    - получает историю своих дуэлей
    - получает одну из своих дуэлей
- Система:
    - определяет двух участников и начинает дуэль
    - получает обновление статуса либо вердикт тестирования посылки
    - заканчивает дуэль

## Интеграция

### Регистрация, аутентификация и авторизация

Регистрация и аутентификация происходят по связке никнейм + пароль.

При успешной аутентификации выдаётся связка токенов:
- короткоживуший многоразовый `AccessToken`
- долгоживущий одноразовый `RefreshToken`

Для авторизации запросов в Duely требуется использовать `AccessToken` (HTTP-заголовок `Authorization: Bearer {AccessToken}`).

При истечении времени жизни `AccessToken` необходимо обновить его с помощью `RefreshToken` и получить новую связку токенов.

### Флоу участия в дуэли

- Пользователь встаёт в очередь ожидания дуэли
    - фронтенд открывает SSE-подписку
- Пользователь выходит из очереди ожидания дуэли
    - фронтенд закрывает SSE-подписку
- Система определяет двух участников и начинает дуэль
    - бэкенд отправляет через SSE событие duel_started и id дуэли
    - фронтенд делает HTTP GET запрос дуэли
- Пользователь отправляет посылку на тестирование
    - фронтенд делает POST запрос на бэкенд и получает id посылки
    - фронтенд периодически делает GET запрос посылки (short polling)
- Система заканчивает дуэль
    - бэкенд отправляет через SSE событие duel_finished
    - фронтенд делает HTTP GET запрос дуэли

## API

### Регистрация

#### Запрос

`POST /users/register`
```json
{
    "nickname": "tourist",
    "password": "12345678_secret"
}
```

#### Ответ

Успех - в ответе статус 200.

Ошибка
```json
{
    "title": "ошибка",
    "detail": "детальная ошибка" // опционально
}
```

### Аутентификация

#### Запрос

`POST /users/login`
```json
{
    "nickname": "tourist",
    "password": "12345678_secret"
}
```

#### Ответ

Успех
```json
{
    "access_token": "{access_token}",
    "refresh_token": "{refresh_token}"
}
```

Ошибка
```json
{
    "title": "ошибка",
    "detail": "детальная ошибка" // опционально
}
```

### Обновление связки токенов

#### Запрос

`POST /users/refresh`
```json
    "refresh_token": "{refresh_token}"
```

#### Ответ

Успех
```json
{
    "access_token": "{access_token}",
    "refresh_token": "{refresh_token}"
}
```

Ошибка
```json
{
    "title": "ошибка",
    "detail": "детальная ошибка" // опционально
}
```

### Текущий пользователь

#### Запрос

`GET /users/iam`

#### Ответ

Успех
```json
{
    "id": 1,
    "nickname": "tourist",
    "rating": 3000
}
```

Ошибка
```json
{
    "title": "ошибка",
    "detail": "детальная ошибка" // опционально
}
```

### Информация о пользователе

#### Запрос

`GET /users/{userId}`

Пример:
- `GET /users/1`

#### Ответ

Успех
```json
{
    "id": 1,
    "nickname": "tourist",
    "rating": 3000
}
```

Ошибка
```json
{
    "title": "ошибка",
    "detail": "детальная ошибка" // опционально
}
```

### Встать в очередь ожидания дуэли

Происходит запрос на создание SSE-подключения.

`GET /duels/connect`

#### События от бэкенда в SSE-подключение

- Дуэль началась
```json
event: DuelStarted
data:
{
    "duel_id": 1,
}
```

- Дуэль завершилась
```json
event: DuelFinished
data:
{
    "duel_id": 1
}
```

### Получить текущую дуэль пользователя

#### Запрос

`GET /duels/current`

#### Ответ

Успех
```json
{
    "id": 1,
    "status": "InProgress",
    "participants": [
        {
            "id": 1,
            "nickname": "tourist",
            "rating": 1500
        },
        {
            "id": 2,
            "nickname": "admin",
            "rating": 1500
        },
    ],
    "task_id": "7d971f50363cf0aebbd87d971f50363cf0aebbd8",
    "start_time": "2025-10-20T20:54:21.996464",
    "deadline_time": "2025-10-20T21:24:21.996464",
    "rating_changes": {
        "1": {
            "Win": 20,
            "Draw": 0,
            "Lose": -20
        },
        "2": {
            "Win": 20,
            "Draw": 0,
            "Lose": -20
        }
    }
}
```

Ошибка
```json
{
    "title": "ошибка",
    "detail": "детальная ошибка" // опционально
}
```

### Получить информацию о дуэли

#### Запрос

`GET /duels/{duel_id}`

Пример:
- `GET /duels/1`

#### Ответ

Успех
```json
// дуэль в процессе
{
    "id": 1,
    "status": "InProgress",
    "participants": [
        {
            "id": 1,
            "nickname": "tourist",
            "rating": 1500
        },
        {
            "id": 2,
            "nickname": "admin",
            "rating": 1500
        },
    ],
    "task_id": "7d971f50363cf0aebbd87d971f50363cf0aebbd8",
    "start_time": "2025-10-20T20:54:21.996464",
    "deadline_time": "2025-10-20T21:24:21.996464",
    "rating_changes": {
        "1": {
            "Win": 20,
            "Draw": 0,
            "Lose": -20
        },
        "2": {
            "Win": 20,
            "Draw": 0,
            "Lose": -20
        }
    }
}

// дуэль завершилась
{
    "id": 1,
    "status": "Finished",
    "participants": [
        {
            "id": 1,
            "nickname": "tourist",
            "rating": 1500
        },
        {
            "id": 2,
            "nickname": "admin",
            "rating": 1500
        },
    ],
    "task_id": "7d971f50363cf0aebbd87d971f50363cf0aebbd8",
    "start_time": "2025-10-20T20:54:21.996464",
    "deadline_time": "2025-10-20T21:24:21.996464",
    "winner_id": 1,
    "end_time": "2025-10-20T21:03:59.341261",
    "rating_changes": {
        "1": {
            "Win": 20,
            "Draw": 0,
            "Lose": -20
        },
        "2": {
            "Win": 20,
            "Draw": 0,
            "Lose": -20
        }
    }
}
```

Ошибка
```json
{
    "title": "ошибка",
    "detail": "детальная ошибка" // опционально
}
```

### История дуэлей пользователя

#### Запрос

`GET /duels?userId={userId}`

Пример:
- `GET /duels?userId=1`

#### Ответ

Успех
```json
[
    {
        "id": 1,
        "status": "Finished",
        "participants": [
            {
                "id": 1,
                "nickname": "tourist",
                "rating": 1500
            },
            {
                "id": 2,
                "nickname": "admin",
                "rating": 1500
            },
        ],
        "task_id": "7d971f50363cf0aebbd87d971f50363cf0aebbd8",
        "start_time": "2025-10-20T20:54:21.996464",
        "deadline_time": "2025-10-20T21:24:21.996464",
        "winner_id": 1,
        "end_time": "2025-10-20T21:03:59.341261",
        "rating_changes": {
            "1": {
                "Win": 20,
                "Draw": 0,
                "Lose": -20
            },
            "2": {
                "Win": 20,
                "Draw": 0,
                "Lose": -20
            }
        }
    }
]
```

Ошибка
```json
{
    "title": "ошибка",
    "detail": "детальная ошибка" // опционально
}
```

### Отправить решение на проверку

#### Запрос

`POST /duels/{duel_id}/submissions`

Пример:
- `POST /duels/1/submissions`
```json
{
    "solution": "print(sum(map(int, input().split())))",
    "language": "Python",
}
```

#### Ответ

Успех
```json
{
    "submission_id": 1
}
```

Ошибка
```json
{
    "title": "ошибка",
    "detail": "детальная ошибка" // опционально
}
```


### Список посылок пользователя в дуэли

#### Запрос

`GET /duels/{duel_id}/submissions`

Пример:
- `GET /duels/1/submissions`

#### Ответ

Успех
```json
[
    {
        "submission_id": 1,
        "status": "Queued",
        "language": "Python",
        "created_at": "2025-09-17T14:05:00Z",
        "is_upsolve": false
    },
    {
        "submission_id": 2,
        "status": "Running",
        "language": "Python",
        "created_at": "2025-09-17T14:12:00Z",
        "is_upsolve": false
    },
    {
        "submission_id": 3,
        "status": "Done",
        "verdict": "Accepted",
        "language": "Python",
        "created_at": "2025-09-17T14:12:00Z",
        "is_upsolve": false
    },
    {
        "submission_id": 4,
        "status": "Queued",
        "language": "Python",
        "created_at": "2025-09-17T14:55:00Z",
        "is_upsolve": true // посылка отправлена после конца дуэли => дорешка
    } 
]
```

Ошибка
```json
{
    "title": "ошибка",
    "detail": "детальная ошибка" // опционально
}
```

### Получить детальную информацию о посылке

#### Запрос

`GET /duels/{duel_id}/submissions/{submission_id}`

Пример:
- `GET /duels/1/submissions/1`

#### Ответ

Успех
```json
// тестирование не началось
{
    "submission_id": 1,
    "status": "Queued",
    "solution": "print(sum(map(int, input().split())))",
    "language": "Python",
    "created_at": "2025-09-17T14:05:00Z",
    "is_upsolve": false
}

// тестирование в процессе
{
    "submission_id": 1,
    "status": "Running",
    "solution": "print(sum(map(int, input().split())))",
    "language": "Python",
    "created_at": "2025-09-17T14:05:00Z",
    "is_upsolve": false
}

// тестирование в процессе и пользователю можно отобразить "message"
{
    "submission_id": 1,
    "status": "Running",
    "message": "Test 1 passed",
    "solution": "print(sum(map(int, input().split())))",
    "language": "Python",
    "created_at": "2025-09-17T14:05:00Z",
    "is_upsolve": false
}

// тестирование завершено
{
    "submission_id": 1,
    "status": "Done",
    "verdict": "Accepted",
    "solution": "print(sum(map(int, input().split())))",
    "language": "Python",
    "created_at": "2025-09-17T14:05:00Z",
    "is_upsolve": false
}

// тестирование завершено и пользователю можно отобразить "message"
{
    "submission_id": 1,
    "status": "Done",
    "verdict": "Compilation Error",
    "message": "ошибка...",
    "solution": "print(sum(map(int, input().split())))",
    "language": "Python",
    "created_at": "2025-09-17T14:05:00Z",
    "is_upsolve": false
}
```

Ошибка
```json
{
    "title": "ошибка",
    "detail": "детальная ошибка" // опционально
}
```

### Запуск кода на своих входных данных

#### Запрос
POST /runs

```json
{
    "code": "print(input()[::-1])",
    "language": "Python",
    "input": "hello"
}
```

#### Ответ
Успех
```json
{
  "run_id": 1,
  "code": "print(input()[::-1])",
  "language": "Python",
  "input": "hello",
  "status": "Queued",
  "output": null,
  "error": null
}
```

Ошибка
```json
{
    "title": "ошибка",
    "detail": "детальная ошибка" // опционально
}
```

### Получить детальную информацию о запуске
#### Запрос
GET /runs/{run_id}

#### Ответ
Успех
```json
// запуск не начался (ещё в очереди)
{
  "run_id": 1,
  "status": "Queued",
  "code": "print(input()[::-1])",
  "language": "Python",
  "input": "hello",
  "output": null,
  "error": null
}

// запуск в процессе
{
  "run_id": 1,
  "status": "Running",
  "code": "print(input()[::-1])",
  "language": "Python",
  "input": "hello",
  "output": null,
  "error": null
}

// запуск завершён успешно
{
  "run_id": 1,
  "status": "Done",
  "code": "print(input()[::-1])",
  "language": "Python",
  "input": "hello",
  "output": "olleh\n",
  "error": null
}

// запуск завершён с ошибкой выполнения
{
  "run_id": 1,
  "status": "Done",
  "code": "print(input()[::-1])",
  "language": "Python",
  "input": "hello",
  "output": "",
  "error": "RE"
}
```

Ошибка
```json
{
    "title": "ошибка",
    "detail": "детальная ошибка" // опционально
}
```


## Схема данных

### Users
| Поле          | Тип        | Описание                              |
|---------------|------------|---------------------------------------|
| Id            | serial PK  | id пользователя                       |
| Nickname      | text       | никнейм пользователя                  |
| PasswordHash  | text       | хеш пароля                            |
| PasswordSalt  | text       | соль пароля                           |
| RefreshToken  | text       | refresh token пользователя            |
| Rating        | int        | рейтинг пользователя                  |

### Duels
| Поле                   | Тип        | Описание                              |
|------------------------|------------|---------------------------------------|
| Id                     | serial PK  | id дуэли                              |
| TaskId                 | text       | id задачи (внешний, из Taski)         |
| User1Id                | int FK     | id первого участника                  |
| User2Id                | int FK     | id второго участника                  |
| Status                 | text       | статус дуэли                          |
| WinnerId               | int? FK    | id победителя (или NULL)              |
| StartTime              | timestamp  | время начала дуэли                    |
| DeadlineTime           | timestamp  | время автоматического окончания дуэли |
| EndTime                | timestamp? | время фактического окончания дуэли    |
| User1InitRating        | int        | начальный рейтинг первого участника   |
| User1FinalRating       | int?       | финальный рейтинг первого участника   |
| User2InitRating        | int        | начальный рейтинг второго участника   |
| User2FinalRating       | int?       | финальный рейтинг второго участника   |


### Submissions
| Поле        | Тип        | Описание                                |
|-------------|------------|-----------------------------------------|
| Id          | serial PK  | id посылки                              |
| DuelId      | int FK     | id дуэли                                |
| UserId      | int FK     | id пользователя                         |
| Code        | text       | код решения                             |
| Language    | text       | язык решения                            |
| SubmitTime  | timestamp  | время отправки                          |
| Status      | text       | статус тестирования                     |
| Verdict     | text       | вердикт тестирования                    |
| Message     | text       | сообщение для пользователя              |
| IsUpsolve   | bool       | индикатор дорешки                       |


### UserCodeRuns
| Поле       | Тип        | Описание                                   |
|------------|------------|--------------------------------------------|
| Id         | serial PK  | id запуска кода                            |
| UserId     | int FK     | id пользователя                            |
| Code       | text       | код решения                                |
| Language   | text       | язык решения                               |
| Input      | text       | пользовательские входные данные            |
| CreatedAt  | timestamp  | время создания запуска                     |
| Status     | int        | 0 = Queued, 1 = Running, 2 = Done          |
| Output     | text?      | вывод программы (stdout)                   |
| Error      | text?      | текст ошибки (stderr/compile error)        |
| ExecutionId| text?      | id выполнения в Exesh                      |
