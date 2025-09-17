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

ws://localhost:5001/ws?user_id=1

#### Сообщения от клиента

Присоединиться к дуэли
```json
{ "action": "join" }
```

Отправить решение
```json
{
    "action": "submit",
    "submission_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "solution": "print(sum(map(int, input().split())))",
    "language": "Python",
    "created_at": "2025-09-17T14:12:00Z"
}
```

#### Сообщения от сервера

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
    "submission_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "status": "queued",
    "created_at": "2025-09-17T14:05:00Z" 
}
```

Обновление вердикта посылки

Промежуточный результат тестирования
```json
{
    "type": "submisson_update",
    "submission_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "status": "running",
    "verdict": "Test #2 passed",
}
```

Финальный вердикт
```json
{
    "type": "submisson_update",
    "submission_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "status": "finished",
    "verdict": "Accepted", // Или "Wrong Answer on test #3", "Time Limit Exceeded", "Compilation Error"
}
```

Завершение дуэли
```json
{
    "type": "duel_finished",
    "duel_id": "123",
    "winner": "1", // Или "2", "draw"
}
```

### HTTP API

Получить информацию о дуэли
GET /api/duels/{duel_id}

```json
{
    "id": "123",
    "status": "in_progress",
    "task_id": "4cf94aac-ae47-459b-bb6a-459784fecc66",
    "starts_at": "2025-09-16T00:25:00Z",
    "deadline_at": "2025-09-16T00:55:00Z"
}
```

Получить список посылок игрока
GET /api/duels/{duel_id}/submissions

```json
[
    {
        "submission_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
        "status": "finished",
        "verdict": "Wring Answer on test #2",
        "created_at": "2025-09-17T14:05:00Z"
    },
    {
        "submission_id": "d9428888-1223-4e89-bcd7-891a2c3f4a5d",
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
    "solution": "print(sum(map(int, input().split())))",
    "language": "Python",
    "status": "finished",
    "verdict": "Accepted",
    "created_at": "2025-09-17T14:12:00Z"
}
```

## Схема данных
TODO
