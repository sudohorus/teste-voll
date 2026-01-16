# Sistema de Troca de Mensagens

Este projeto é uma aplicação completa para troca de mensagens entre usuários, desenvolvida como parte de um desafio técnico. O sistema é composto por uma API RESTful em **Ruby on Rails** e um frontend reativo em **Vue.js**.

## Tecnologias Utilizadas

- **Backend:** Ruby on Rails
- **Frontend:** Vue.js

## Como Rodar o Projeto

A maneira mais simples de rodar a aplicação é utilizando o Docker Compose, que sobe tanto o backend quanto o frontend em containers configurados.

### Pré-requisitos

- Docker
- Docker Compose

### Passo a Passo

1. **Construa os containers:**

   ```bash
   docker-compose build
   ```
2. **Inicie a aplicação:**

   ```bash
   docker-compose up
   ```

## Documentação da API

### Autenticação

- **POST** `/api/v1/signup`: Criação de novo usuário.
- **POST** `/api/v1/login`: Autenticação de usuário (retorna o token JWT).

### Usuários

- **GET** `/api/v1/users`: Lista os usuários cadastrados.

### Mensagens

- **POST** `/api/v1/messages`: Envia uma nova mensagem.
- **GET** `/api/v1/messages/:id`: Exibe detalhes de um chat específico.

## Funcionalidades Implementadas

- **Autenticação JWT**: Sistema seguro de login e cadastro.
- **WebSockets (ActionCable)**: Suporte preparado para comunicação em tempo real.

---

*Desenvolvido para o Desafio Técnico Voll.*
