# Stonkflow Contracts

Единый источник protobuf-контрактов платформы **stonkflow**.

Репозиторий задает правила взаимодействия между микросервисами через Kafka:

- структура сообщений (protobuf)
- контроль совместимости (`buf breaking`)
- генерация стандартизованных Go DTO
- публикация `proto` как release-артефакта для внешних команд

## Для кого этот репозиторий

- Для команд, которые читают/пишут Kafka-топики внутри stonkflow.
- Для внешних интеграций, которым нужны `.proto` из релиза.
- Для Go-команд, которым нужны готовые DTO как библиотека.

## Что внутри

- `proto/` — исходные protobuf-контракты.
- `gen/` — сгенерированные Go DTO.
- `buf.yaml` — правила lint/breaking.
- `buf.gen.yaml` — правила генерации DTO.

## Карта контрактов (Topic -> Proto)

| Kafka Topic                                          | Proto file                                           |
|------------------------------------------------------|------------------------------------------------------|
| `session_<id>.<exchange>.<market>.command.order_add` | [order_add_command](./proto/order_add_command.proto) |
| `session_<id>.<exchange>.<market>.event.trade`       | [trade_event](./proto/trade_event.proto)             |
| `session_<id>.<exchange>.<market>.event.depth`       | [depth_event](./proto/depth_event.proto)             |
| `session_<id>.<exchange>.<market>.snapshot.order`    | [order_snapshot](./proto/order_snapshot.proto)       |
| `session_<id>.<exchange>.<market>.snapshot.position` | [position_snapshot](./proto/position_snapshot.proto) |
| `session_<id>.<exchange>.<market>.snapshot.balance`  | [balance_snapshot](./proto/balance_snapshot.proto)   |
| `cache_<id>.<exchange>.<market>.event.trade`         | [trade_event](./proto/trade_event.proto)             |
| `cache_<id>.<exchange>.<market>.event.depth`         | [depth_event](./proto/depth_event.proto)             |

При добавлении нового контракта обновляйте таблицу в том же PR.

## Использование как Go-библиотеки DTO

Официальный module path:

`github.com/stonkflow/contracts`

Подключение в Go-проект:

```bash
go get github.com/stonkflow/contracts@vX.Y.Z
```

Пример импорта DTO:

```go
import stonkflow "github.com/stonkflow/contracts/gen"
```

## Для внешних команд (не Go): через release artifact

На каждый релиз `vX.Y.Z` публикуется архив `proto-vX.Y.Z.tar.gz` в GitHub Release.

Скачать и распаковать:

```bash
VERSION=v1.2.3
curl -L -o "proto-${VERSION}.tar.gz" \
  "https://github.com/stonkflow/contracts/releases/download/${VERSION}/proto-${VERSION}.tar.gz"

mkdir -p /tmp/stonkflow-contracts
tar -xzf "proto-${VERSION}.tar.gz" -C /tmp/stonkflow-contracts
```

После распаковки `.proto` будут в `/tmp/stonkflow-contracts/proto/...`.

Пример генерации DTO для Python:

```bash
python -m grpc_tools.protoc \
  -I /tmp/stonkflow-contracts/proto \
  --python_out=. \
  /tmp/stonkflow-contracts/proto/trade_event.proto
```

Пример генерации DTO для Java:

```bash
protoc \
  -I /tmp/stonkflow-contracts/proto \
  --java_out=src/main/java \
  /tmp/stonkflow-contracts/proto/trade_event.proto
```

Сериализация/десериализация в любом языке выполняется стандартной protobuf-библиотекой для сгенерированных DTO.
