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

## API

### WebSocket API

#### Сообщения от клиента

Присоединиться к дуэли
```json
{ "action": "join" }
```

Отправить решение
```json
{
    "action": "submit",
    "submission_id": "1",
    "solution": "print(sum(map(int, input().split())))",
    "language": "Python",
    "created_at": "2025-09-17T14:12:00Z"
}
```

Запросить информацию о дуэли
```json
{ "action": "get_duel_info" }
```

#### Сообщения от сервера

Подтверждение подключения, выдается player_id
```json
{
    "type": "connected",
    "player_id": "1"  // или "2"
}
```

Игрок ожидает второго
```json
{
    "type": "waiting for opponent",
    "player_id": "1",
    "duel_id": "123"
}
```

Дуэль стартовала, выдан task_id
```json
{
    "type": "duel_started",
    "duel_id": "123",
    "task_id": "4cf94aac-ae47-459b-bb6a-459784fecc66",
    "starts_at": "2025-09-16T00:25:00Z",
    "deadline_at": "2025-09-16T00:55:00Z"
}
```

Подтверждение, что решение добавлено в очередь
```json
{
    "type": "submisson_received",
    "submission": {
        "submission_id": "88",
        "player_id": "1",
        "status": "queued",
        "created_at": "2025-09-17T14:05:00Z"
    }   
}
```

Обновление вердикта посылки
```json
{
    "type": "submisson_update",
    "submission": {
        "submission_id": "88",
        "player_id": "1",
        "status": "finished",
        "verdict": "Accepted", // Или "Wrong Answer on test #3", "Time Limit Exceeded"
        "created_at": "2025-09-17T14:05:00Z"
    }
}
```

Информация о дуэли (ответ на get_duel_info)
```json
{
    "type": "duel_info",
    "duel_id": "123",
    "status": "in_progress",
    "task_id": "4cf94aac-ae47-459b-bb6a-459784fecc66",
    "time_left": 1200
}
```

Завершение дуэли
```json
{
    "type": "duel_finished",
    "duel_id": "123",
    "winner": "1", // Или "2", "draw"
    "finished_at": "2025-09-17T14:17:00Z"
}
```


### HTTP API

Получить список посылок игрока
GET /api/duels/{duel_id}/submissions?player_id=1

```json
[
    {
        "submission_id": "123",
        "player_id": "1",
        "status": "finished",
        "verdict": "Wring Answer on test #2",
        "created_at": "2025-09-17T14:05:00Z"
    },
    {
        "submission_id": "144",
        "player_id": "1",
        "status": "finished",
        "verdict": "Accepted",
        "created_at": "2025-09-17T14:12:00Z"
    }
]
```

Получить посылку детально
GET /api/duels/{duel_id}/submissions/{submission_id}

```json
{
    "submission_id": "123",
    "player_id": "1",
    "solution": "print(sum(map(int, input().split())))",
    "language": "Python",
    "status": "finished",
    "verdict": "Accepted",
    "created_at": "2025-09-17T14:12:00Z"
}
```

## Схема данных
TODO
