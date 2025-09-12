# Exesh

## Описание

- Запуск списка шагов для тестирования задачи.
- Запуск кода пользователя на входных данных и выдача выходных данных.

## Компоненты

<img src="exesh_architecture.png" width="800px" alt="https://miro.com/app/board/uXjVJcoEORo=/">

Exesh состоит из двух компонентов:
- Coordinator - координация выполнения джоб
- Worker - выполнение джоб

### Coordinator

- Принимает запросы на запуск списка шагов тестирования.
- Распределяет джобы по worker'ам.
- Транслирует статусы выполнения шагов тестирования.

### Worker

- Получает от coordinator джобы.
- Выполняет команды, находящиеся в джобе.
- Сохраняет артефакт с выходными файлами джобы.

## Взаимодействие компонентов

### Выполнение графа джобов
```mermaid
sequenceDiagram
    participant Coordinator as coordinator
    participant Worker as worker
    participant OtherWorker as other worker

    ыCoordinator->>Coordinator: Скачать все необходимые исходники
    Coordinator->>Coordinator: Вычислить id каждого джоба

    loop Выполнение джоба
        Worker->>Coordinator: (heartbeat) Могу взять джоб
        Coordinator->>Worker: Джоб на исполнение

        Worker->>Coordinator: Скачать необходимые исходники
        Coordinator->>Worker: Архив с необходимыми исходниками

        Worker->>OtherWorker: Скачать артефакт другого джоба
        OtherWorker->>Worker: Архив с артефактом другого джоба

        Worker->>Worker: Выполнить джоб
        Worker->>Worker: Сохранить артефакты джоба

        Worker->>Coordinator: (heartbeat) Джоб выполнен
    end
```

## API
TODO

## Схема данных
TODO
