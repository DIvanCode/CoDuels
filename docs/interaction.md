## Общие правила для всех вариантов:
1. submission_id — всегда генерирует сервер и хранится в базе. Фронт может использовать временный client_temp_id только для UX до подтверждения.
2. Результаты тестов сначала запичываются в БД, потом отправляются по каналу, чтобы гарантировать, что статус можно получить по REST, если даже уведомление потерялось
3. На reconnect клиент делает GET /api/duels/{duel_id} и GET /api/duels/{duel_id}/submissions и обновляет интерфейс по последнему состоянию


## WebSocket + HTTP
1. Подключение
Фронтэнд открывает канал
ws://localhost:5001/ws?user_id=1

2. Отправка решения
Фронт делает:
POST /api/duels/{duel_id}/submit
```json
{
    "solution": "print(sum(map(int, input().split())))",
    "language": "Python",
}
```

Ответ:
```json
{
    "submisson_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479"
}
```

3. Получение апдейтов
Сервер пушит через WS

Промежуточный результат тестирования
```json
{
    "type": "submisson_update",
    "submission_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "status": "Test #2 passed"
}
```

Финальный вердикт
```json
{
    "type": "submisson_verdict",
    "submission_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "verdict": "Accepted", // Или "Wrong Answer on test #3", "Time Limit Exceeded", "Compilation Error"
}
```

4. Потеря соединения
Если клиент отвалился, то WS закрывается
При реконнекте фронт:
1) Снова подключается к WS
2) Делает GET /api/duels/{duel_id} и GET /api/duels/{duel_id}/submissions
3) Сервер отдает все посылки с вердиктами
4) Фронт обновляет интерфейс по последнему состоянию и дальше слушает новые события


## Server-Sent Events + HTTP
1. Подключение
Фронт открывает поток
http://localhost:5001/sse?user_id=1

2. Отправка решения аналогично WS
POST /api/duels/{duel_id}/submit
```json
{
    "solution": "print(sum(map(int, input().split())))",
    "language": "Python",
}
```

Ответ:
```json
{
    "submisson_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479"
}
```

3. Получение апдейтов

event: "submisson_update"
data: {"submission_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479", "status": "Test #2 passed"}

event: "submisson_verdict"
data: {"submission_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479", "status": "Accepted"}

4. Переподключение
Браузер сам пытается переподключиться
Аналогично ws делает GET /api/duels/{duel_id} и GET /api/duels/{duel_id}/submissions
Дальше слушает новые события по SSE


## Long Polling
1. Отправка решения
Фронт делает POST (как обычно)

2. Апдейты
Для получения апдейтов фронт делает GET /api/updates?last_event_id=XY. Сервер либо сразу ответит, если есть новые события, либо держит соединение, пока что-то не появится. Если ответ пустой - фронт делает новый GET

3. Переподключение
Клиент повторно открывает long-poll запросы и делает snapshot GET

