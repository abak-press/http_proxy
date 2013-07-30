# http_proxy

Это DSL для написания прокси сервера http запросов. Основан на [em-proxy](https://github.com/igrigorik/em-proxy)

## Установка

Добавляем следующие строчки в Gemfile:

    gem "http_proxy"

И вызываем команду:

    $ bundle

Или устанавливаем через команду gem:

    $ gem install http_proxy

## Использование

### Проксирование запросов

Необходимый минимум для проксирования запросов - выполнить роутинг запроса `route_to` в блоке `process`

Все соединения, для которых не был вызван метод `route_to` в блоке `process` будут закрыты

```ruby
require "http_proxy"

# Запуск прокси сервера на порту 8080
HttpProxy.start("0.0.0.0", 8080, debug: true) do |proxy|
  # Обработка пришедшего запроса
  proxy.process do
    # Отправить пришедший запрос на хост "192.168.1.1" и порт 9000
    proxy.route_to host: "192.168.1.1", port: 9000
  end
end
```

### Проксирование запросов между установленными бэкэндами

```ruby
require "http_proxy"

# Запуск прокси сервера на порту 8080
HttpProxy.start("0.0.0.0", 8080, debug: true) do |proxy|
  # Регистрирование одного бэкэнда на порту 8081
  # Бэкэнд одлжен быть запущен отдельно. Их может быть сколько угодно
  proxy.backend :one, host: "0.0.0.0", port: 8081
  
  # И еще одного бэкэнда на порту 8082
  proxy.backend :two, host: "0.0.0.0", port: 8082

  proxy.process do
    # Отправить пришедший запрос на бэкэнд :one
    proxy.route_to :one
  end
end
```

### Проксирования запросов с учетом пришедших заголовков

*В блок `process` заголовки передаются в raw формате, т.е простой строкой*

```ruby
require "http_proxy"

HttpProxy.start("0.0.0.0", 8080, debug: true) do |proxy|
  proxy.backend :one, host: "0.0.0.0", port: 8081

  proxy.process do |raw_headers|
    p raw_headers

    proxy.route_to :one
  end
end
```

*В блок `process` заголовки передаются в hash формате, ключи - строковые*

```ruby
require "http_proxy"

HttpProxy.start("0.0.0.0", 8080, debug: true) do |proxy|
  proxy.backend :one, host: "0.0.0.0", port: 8081

  proxy.process :headers do |headers|
    p headers
    
    proxy.route_to :one
  end
end
```

### Проксирование запросов с учетом пришедших заголовков и наличии указанного ключа в них

*В блок `process` передается значение, которое находится по указанному ключу или же закрывается соединение*

```ruby
require "http_proxy"

HttpProxy.start(host: "0.0.0.0", port: 3000, debug: false) do |proxy|
  proxy.backend :one, host: "0.0.0.0", port: 8081

  proxy.process :header, "Vines-User" do |header_key_value|
    p header_key_value
  
    proxy.route_to :one
  end
end
```

### Перезагрузка прокси сервера

Есть возможность назначить блок кода на сигнал `SUGHUP`

```ruby
require "http_proxy"

HttpProxy.on_reload do
  p "I'm a reloaded proxy"
end

HttpProxy.start(host: "0.0.0.0", port: 3000, debug: false) do |proxy|
  proxy.backend :one, host: "0.0.0.0", port: 8081

  proxy.process do
    proxy.route_to :one
  end
end
```

```bash
$ kill -HUP <process.pid>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
