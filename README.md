# vitis-vinifera

Vitis vinifera — [Виноград культурный](http://ru.wikipedia.org/wiki/%D0%92%D0%B8%D0%BD%D0%BE%D0%B3%D1%80%D0%B0%D0%B4_%D0%BA%D1%83%D0%BB%D1%8C%D1%82%D1%83%D1%80%D0%BD%D1%8B%D0%B9).

Позволяет проксировать http-bosh запросы на отдельные ноды vines кластера.

Прокси сервер ориентируется на заголовки http-запроса. По умолчанию он ищет ключ `Vines-User`. Если ключ не найден, то соединение просто закрывается.
Если ключ был найден, то по его значению осуществляется балансировка запроса.

Пример заголовка, который будет проксирован

```
109
GET / HTTP/1.1
User-Agent: test
Host: 127.0.0.1:3000
Vines-User: user@example.com
Connection: close

```

Если значение, которое было указано в ключе ни разу не проксировалось, то оно будет сохранено (зарегистрировано) в карту проксирования

```
  ...
  admin@example.com => node_23
  user@example.com  => node_1
  ...
```

Все последующие запросы с этим значением ключа будут направлены на ту ноду, в которую они отправлялись в первый раз.

По умолчанию, балансировка осуществляется путем подсчета количества зарегистрированных элементов на каждой ноде.
И в первую очередь, не зарегистрированные запросы будут отправляться на ту ноду, на которой меньше всего регистраций было сделано.

## Установка

Add this line to your application's Gemfile:

    gem "pruine"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pruine

## Использование

Прокси сервер с настройками по умолчанию

```ruby
require "pruine"

# Установка одной единственной ноды на порту 8081
Pruine.setup_nodes(
  one: {host: "0.0.0.0", port: 8081}
)

# Запуск прокси сервера на порту 8080
Pruine::Proxy.start("0.0.0.0", 8080, debug: true)
```

Прокси сервер с изменной настройкой redis сервера

```ruby
require "pruine"

# Установка трех нод на портах 8081, 8082 и 8083
Pruine.setup_nodes(
  one:   {host: "0.0.0.0", port: 8081},
  two:   {host: "0.0.0.0", port: 8082},
  three: {host: "0.0.0.0", port: 8083}
)

# Установка redis сервера на порту 6380
Pruine.setup_redis(
  host: "0.0.0.0", port: 6380
)

# Запуск прокси сервера на порту 8080
Pruine::Proxy.start("0.0.0.0", 8080, debug: true)
```

Прокси сервер с измененным балансировщиком.

Требования к балансировщику:
1. Должен быть метод класса/модуля `select`
2. Метод `select` должен возвращать массив из имени ноды и ее настроек `[:n1, {host: "0.0.0.0", port: 9292}]`

```ruby
require "pruine"

# Балансировщик с измененной логикой
module MyBalancer
  extend self

  def select(entry)
    node_uid = entry.length.odd? ? :one : :two

    [node_uid, Cluster.nodes[node_uid]]
  end
end

# Установка двух нод на портах 8081 и 8082
Pruine.setup_nodes(
  one: {host: "0.0.0.0", port: 8081},
  two: {host: "0.0.0.0", port: 8082}
)

# Установка своего балансировщика
Pruine.setup_balancer(MyBalancer)

Pruine::Proxy.start("0.0.0.0", 8080, debug: true)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
