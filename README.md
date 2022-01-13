# ExChangeRate

API para conversão de valores em diferentes moedas.

Usar a API em prod: https://ex-change-rate.gigalixirapp.com/swaggerui

Antes de testar chamadas com o SwaggerUI, selecionar o servidor de prod:

![selecionando servidor](https://i.ibb.co/f0gTKMn/swagger-ui-server-selection.png)

## Implementação

A API utiliza por baixo dos panos o serviço free de https://exchangeratesapi.io/

A API processa requisições de conversão entre moedas de forma assíncrona. O usuário não recebe uma resposta imediata e deve consultar o resultado de sua requisição no endpoint de listagem. 

Implementamos um cache agressivo na frente das chamadas pra API mãe porque o free tier só atualiza as taxas de conversão diariamente.

A aplicação é dividida entre o domínio web e interno (MVC padrão Phoenix).

O domínio interno é por sua vez dividido entre `commands` e `queries`, seguindo o padrão [Command Query Separation (CQS)](https://www.martinfowler.com/bliki/CommandQuerySeparation.html). Basicamente, `queries` são funções puras desprovidas de side-effects e os `commands` mudam o estado do sistema (inserindo ou atualizado entradas, processando jobs, etc.).

## Bibliotecas utilizadas

- Phoenix para API
- Ecto para validação e interação com o banco de dados
- Oban para processamento assíncrono de background jobs
- Tesla como cliente http
- Mentat para cache
- OpenApiSpex para documnetação da API
- Mox e Mock para mocks
- Money e Decimal para manipulação de valores monetários
- ExMachina para factories
- credo para lint
- Dialyxir para análise estática de código

## Documentação da API

A API expõe um SwaggerUI em `/swaggerui`.

## Rodando localmente

Dependências: 
- Elixir v1.13.1/OTP 24.2
- Docker
- Docker Compose

Rode:

```bash
docker-compose up -d # Inicia uma instância do Postgres
export ER_API_KEY=<SUA_API_KEY> # Exporta a variável de ambiente com sua chave da API
mix deps.get # Instala localmente as dependências
mix ecto.setup # Cria e migra o banco de dados
mix phx.server # Inicia o servidor
```
E navegue para [localhost:4000/swaggerui](http://localhost:4000/swaggerui)
