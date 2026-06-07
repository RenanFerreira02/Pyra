# Pyra 🔥 — Monitoramento de Queimadas

Aplicativo mobile Flutter para monitoramento de focos de queimada em tempo real, desenvolvido como projeto acadêmico para a **FIAP Global Solution**.

---

## Funcionalidades

| Tela | O que faz |
|------|-----------|
| **Mapa** | Exibe focos de calor como marcadores coloridos (intensidade) e a posição do usuário. Áreas monitoradas são desenhadas como círculos. |
| **Dashboard** | Gráfico de barras (focos por dia), pizza (por bioma) e ranking de estados. |
| **Alertas** | Lista de notificações geradas quando um foco entra no raio de uma região monitorada. |
| **Regiões** | Cadastro, edição e remoção de regiões de interesse com raio configurável. |

---

## Stack

- **Flutter 3.x** (Dart)
- **Firebase**: Firestore + Cloud Messaging
- **Google Maps Flutter**
- **NASA FIRMS** + **INPE BDQueimadas** (dados de queimadas)
- **OpenWeatherMap** (clima complementar)
- **Provider** (gerência de estado)
- **fl_chart** (gráficos)
- **flutter_dotenv** (variáveis de ambiente)

---

## Pré-requisitos

- Flutter SDK ≥ 3.5
- Dart SDK ≥ 3.5
- Conta Google para Google Maps SDK
- Projeto Firebase (Firestore + FCM habilitados)
- Chave NASA FIRMS (gratuita em https://firms.modaps.eosdis.nasa.gov/api/)

---

## Configuração

### 1. Clone e instale dependências

```bash
git clone <repo>
cd pyra
flutter pub get
```

### 2. Variáveis de ambiente

Copie o exemplo e preencha suas chaves:

```bash
cp .env.example .env
```

Edite `.env`:

```
FIRMS_API_KEY=sua_chave_nasa_firms
OPENWEATHER_API_KEY=sua_chave_openweather
GOOGLE_MAPS_API_KEY=sua_chave_google_maps
```

> **Nunca** commite o `.env` com chaves reais. O arquivo já está no `.gitignore`.

### 3. Firebase

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com).
2. Habilite **Cloud Firestore** e **Cloud Messaging**.
3. Adicione os apps Android e iOS:
   - Android: baixe `google-services.json` → `android/app/`
   - iOS: baixe `GoogleService-Info.plist` → `ios/Runner/`
4. Siga as instruções do [FlutterFire CLI](https://firebase.flutter.dev/docs/cli):
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

### 4. Google Maps SDK

- Ative **Maps SDK for Android** e **Maps SDK for iOS** no Google Cloud Console.
- Adicione a chave ao `AndroidManifest.xml` (já configurado via `${GOOGLE_MAPS_API_KEY}`).
- Para iOS, a chave já é injetada via `Info.plist`.

> **Sem as chaves configuradas**, o app funciona com **dados mockados** de focos cobrindo o Brasil.

---

## Executar

```bash
# Android
flutter run -d android

# iOS (Mac)
flutter run -d ios

# Com flavor de release
flutter build apk --release
flutter build ipa --release
```

---

## Estrutura do projeto

```
lib/
├── main.dart                  # Ponto de entrada, providers e navegação
├── models/
│   ├── foco.dart              # Foco de calor (satélite)
│   ├── regiao.dart            # Região monitorada pelo usuário
│   └── alerta.dart            # Alerta de proximidade
├── services/
│   ├── firms_service.dart     # NASA FIRMS API (+ mock)
│   ├── inpe_service.dart      # INPE BDQueimadas WFS
│   ├── weather_service.dart   # OpenWeatherMap
│   ├── firebase_service.dart  # Firestore + FCM + cache local
│   └── location_service.dart  # Geolocator
├── providers/
│   ├── focos_provider.dart    # Estado dos focos + filtros + estatísticas
│   ├── regioes_provider.dart  # CRUD de regiões
│   └── alertas_provider.dart  # Geração e leitura de alertas
├── screens/
│   ├── map_screen.dart        # Tela de mapa
│   ├── dashboard_screen.dart  # Dashboard com gráficos
│   ├── alerts_screen.dart     # Lista de alertas
│   └── regions_screen.dart    # Gerenciamento de regiões
├── widgets/
│   ├── estado_vazio_widget.dart
│   ├── stat_card_widget.dart
│   └── filtro_bottom_sheet.dart
└── utils/
    ├── constants.dart         # Endpoints, coleções Firestore, TTL de cache
    ├── geo_utils.dart         # Haversine (distância geográfica)
    └── helpers.dart           # Formatação de data/distância
```

---

## Fontes de dados

| Fonte | Tipo | Docs |
|-------|------|------|
| NASA FIRMS | REST CSV | https://firms.modaps.eosdis.nasa.gov/api/ |
| INPE BDQueimadas | WFS GeoJSON | https://queimadas.dgi.inpe.br |
| OpenWeatherMap | REST JSON | https://openweathermap.org/api |

---

## Regras de Firestore (exemplo)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /regioes/{id} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    match /focos/{id} {
      allow read: if true;
      allow write: if false; // somente Cloud Functions
    }
    match /alertas/{id} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## Equipe

Projeto desenvolvido para FIAP — Global Solution 2025.
