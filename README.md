# HODLHODL test backend 

### pt.2 without admin panel and supported only `p2pkh` wallet address
bitcoin-ruby (master) does not support openssl3.0 because of that i used fork

### steps to run 
- `bundle install`
- `rackup config.ru`

or via Docker

- `docker compose build`
- `docker compose up`

### Consts for testing
```
PRIVATE_KEY 'cPZzpePWADM1DBj81zb6bBkbHzA1YxFCJfq499Pnrh2XvXZbbDZE'

SENDER_ADDRESS = 'mvpip5o5aM8kfjF9zga4MC4GVqx4nMbJUY'

RECIPIENT_ADDRESS = 'mi1HqBemjjE4DqM5fd94F5Nw2FhChmxs5C'
```