# Pyra — Monitoramento de Queimadas

MVP acadêmico desenvolvido para a **FIAP Global Solution 2026** que demonstra o monitoramento de focos de queimada no Brasil usando **dados de exemplo (mockados)**. O app roda sem nenhuma chave de API ou conta externa.

---

## Funcionalidades

| Tela | O que faz |
|------|-----------|
| **Mapa** | Exibe os focos mockados como marcadores coloridos por intensidade (FRP) sobre o mapa OpenStreetMap e mostra a posição do usuário. Regiões monitoradas aparecem como círculos azuis. |
| **Dashboard** | Gráfico de barras com focos por dia (últimos 7 dias), gráfico de pizza por bioma e ranking dos estados com mais focos. |
| **Alertas** | Lista de notificações geradas automaticamente quando um foco de exemplo entra no raio de uma região monitorada. |
| **Regiões** | Cadastro, edição e remoção de regiões de interesse com raio configurável (km). Três regiões de demo (Brasília, Belém, Manaus) são pré-carregadas no primeiro uso. |

---

## Tecnologias

- **Flutter 3.x** / Dart
- **flutter_map** + **latlong2** — mapa via OpenStreetMap (sem chave de API)
- **geolocator** — localização do dispositivo
- **provider** — gerência de estado
- **fl_chart** — gráficos de barras e pizza
- **shared_preferences** — persistência local de regiões e alertas
- **intl** — formatação de datas

---

## Dados

O app funciona **100% com dados mockados** — nenhuma chave de API ou conta externa é necessária.

Os 27 focos de exemplo distribuídos pelo Brasil estão centralizados em `lib/utils/mock_data.dart`. O arquivo contém um comentário deixando explícito que é a **camada de dados isolada**: para uma integração real com a **NASA FIRMS** ou o **INPE BDQueimadas**, basta substituir a lista `mockFocos` pelo retorno dos serviços `FirmsService` / `InpeService` — providers e telas não precisam mudar.

---

## Executar

```bash
git clone <repo>
cd pyra
flutter pub get
flutter run
```

Não é necessária nenhuma configuração adicional.

---

## Estrutura

```
lib/
├── main.dart                  # Ponto de entrada, providers e navegação
├── models/                    # Foco, Regiao, Alerta
├── providers/                 # FocosProvider, RegioesProvider, AlertasProvider
├── screens/                   # MapScreen, DashboardScreen, AlertsScreen, RegionsScreen
├── services/
│   ├── firms_service.dart     # Stub — camada preparada para NASA FIRMS
│   ├── inpe_service.dart      # Stub — camada preparada para INPE BDQueimadas
│   ├── location_service.dart  # GPS via geolocator
│   └── storage_service.dart   # SharedPreferences (regiões e alertas)
├── widgets/                   # EstadoVazio, StatCard, FiltroBottomSheet
└── utils/
    ├── mock_data.dart         # Focos e regiões de exemplo (camada de dados isolada)
    ├── geo_utils.dart         # Distância Haversine
    ├── helpers.dart           # Formatação de data e distância
    └── constants.dart         # Constantes do app
```

---

## Equipe

Projeto desenvolvido para FIAP — Global Solution 2026.

- **Nome** — RM XXXXX
- **Nome** — RM XXXXX
