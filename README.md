# my-dc — Infraestrutura de Contêineres com Ansible

Projeto Ansible para orquestração de serviços Docker em ambiente on-premise. Gerencia o ciclo de vida completo (deploy, restart, remoção) de múltiplos serviços web, monitoramento e comunicação, todos atrás de um proxy reverso NGINX com SSL.

## Arquitetura

### Serviços Web (`d001`)
Serviços acessíveis via proxy reverso NGINX em `*.ccbv.local`.

| Serviço | Container | Domínio | Descrição |
| :--- | :--- | :--- | :--- |
| **NGINX** | `nginx-proxy` | `*.ccbv.local` | Gateway central, SSL/TLS termination |
| **BookStack** | `bookstack-app` | `wiki.ccbv.local` | Wiki e base de conhecimento |
| **Grafana** | `grafana-server` | `grafana.ccbv.local` | Dashboards e visualização de métricas |
| **Site1** | `site1-app` | `www.ccbv.local`, `ccbv.local` | Página principal |
| **Site2** | `site2-app` | `painel.ccbv.local` | Painel administrativo |
| **Novo SGA** | `novosga-novosga` | `novosga.ccbv.local`, `novosgap.ccbv.local` | Sistema de gerenciamento de atendimento (triagem + painel) |
| **Tatuscan** | `tatuscan-app` | `tatuscan.ccbv.local` | Monitoramento de rede |
| **Zabbix** | `zabbix` | `zabbix.ccbv.local` | Monitoramento de infraestrutura |

### Gerenciamento & Integração
Ferramentas de operação e integração de terceiros.

| Serviço | Container | Acesso | Descrição |
| :--- | :--- | :--- | :--- |
| **Portainer** | `portainer` | Portas 9000, 9443, 8000 | Interface web para gerenciamento de containers Docker |
| **Dockhand** | `dockhand` | Porta 3000 | Interface moderna de gerenciamento Docker com Git integration |
| **Waha** | `waha-app` | `waha.ccbv.local` | Gateway HTTP para WhatsApp (WAHA) |
| **Mosquitto** | `mosquitto-server` | — | Broker MQTT (portas 1883 e 8083/WebSocket) |
| **MiniDLNA** | `minidlna-server` | Porta 8200 | Servidor DLNA para streaming de mídia |

### Infraestrutura de Mineração (`V001`)
Serviços de processamento em background.

| Serviço | Container | Porta | Descrição |
| :--- | :--- | :--- | :--- |
| **XMRig Proxy** | `xmrig-proxy` | 3333 | Proxy para agregação de mineração |
| **XMRig** | `xmrig` | — | Worker de mineração |
| **Minefarm** | `minefarm` | 3544 | Gerenciamento de farm |

### Rede Docker
- **`{{ ansible_hostname }}-net`**: Rede externa criada pelo Ansible para comunicação entre contêineres web.

## Comandos de Gerenciamento

```bash
# Subir todos os serviços
make start

# Subir serviço específico
make start tags=novosga
make start tags=nginx

# Parar serviço específico
make stop tags=zabbix

# Reiniciar (stop + start)
make restart tags=novosga
make restart tags=nginx

# Grupos predefinidos
make start tags=d001   # Serviços web principais
make start tags=V001   # Mineração + Gerenciamento & Integração
```

Em ambientes com múltiplos hosts:
```bash
make start host=<servidor> tags=novosga
```

## Estrutura do Projeto

```
 ├── services.yml            # Playbook principal
 ├── Makefile                # Comandos simplificados
 ├── inventory/
 │   └── hosts               # Hosts (localhost/d001/v031/v032/taranis)
 ├── group_vars/
 │   └── all/
 │       ├── 00-global.yml   # Variáveis globais (timezone, SSL, logs)
 │       ├── vault.yml       # Credenciais (ansible-vault)
 │       └── <servico>.yml   # Um arquivo por serviço
 ├── examples/               # Arquivos de exemplo para configuração
 │   ├── inventory/
 │   │   └── hosts.example
 │   └── group_vars/
 │       └── all/
 │           ├── 00-global.example.yml
 │           ├── vault.example.yml
 │           └── <servico>.example.yml
 └── roles/                  # Definição de cada serviço
     ├── nginx/
     ├── bookstack/
     ├── grafana/
     ├── dockhand/
     ├── portainer/
     ├── waha/
     ├── novosga/
     ├── site1/
     ├── site2/
     ├── tatuscan/
     ├── zabbix/
      ├── mosquitto/
      ├── minefarm/
      ├── xmrig/
      ├── xmrig-proxy/
      └── minidlna/
```

## Tags Disponíveis

| Tag | Roles Incluídas |
| :--- | :--- |
| `d001` | nginx, bookstack, grafana, dockhand, site1, site2, novosga, tatuscan, zabbix |
| `V001` | minefarm, xmrig, xmrig-proxy, waha, portainer, mosquitto, minidlna |

## Segurança

Credenciais sensíveis estão em `group_vars/all/vault.yml` (protegido pelo .gitignore).

### Arquivos de Configuração

- **Arquivos reais** (`group_vars/all/`): Contêm valores sensíveis, NÃO versionados no Git
- **Arquivos de exemplo** (`examples/group_vars/all/`): Contêm templates documentados, versionados no Git

### Primeira Configuração

1. Copiar arquivos de exemplo:
   ```bash
   cp examples/inventory/hosts.example inventory/hosts
   cp examples/group_vars/all/*.yml group_vars/all/
   ```

2. Editar valores sensíveis em `group_vars/all/vault.yml`

3. (Opcional) Criptografar vault:
   ```bash
   ansible-vault encrypt group_vars/all/vault.yml
   ```

## Licença

Este projeto é licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## Pré-requisitos

- Ansible 2.16+
- Docker Engine & Docker Compose V2
