# TagVálida

### Sistema de Etiquetagem e Controle de Validade para Pequenas Empresas Alimentícias

> Projeto desenvolvido para auxiliar pequenas empresas alimentícias, especialmente panificadoras, no controle de validade, organização do estoque e rastreabilidade de produtos, com apoio de visão computacional.

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-Mobile%20App-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-Language-0175C2?style=for-the-badge&logo=dart&logoColor=white">
  <img alt="Firebase" src="https://img.shields.io/badge/Firebase-Backend-FFCA28?style=for-the-badge&logo=firebase&logoColor=black">
  <img alt="Python" src="https://img.shields.io/badge/Python-IA-3776AB?style=for-the-badge&logo=python&logoColor=white">
  <img alt="YOLOv8" src="https://img.shields.io/badge/YOLOv8-Visão%20Computacional-7B61FF?style=for-the-badge">
  <img alt="Status" src="https://img.shields.io/badge/Status-Em%20desenvolvimento-orange?style=for-the-badge">
</p>

---

## Sobre o projeto

O **TagVálida** é um sistema de etiquetagem criado para melhorar o controle de produtos alimentícios em pequenas empresas.

A proposta é:

* Reduzir desperdícios
* Melhorar o controle de validade
* Organizar o estoque
* Facilitar a rastreabilidade

Além do gerenciamento de etiquetas, o sistema integra um módulo de **Inteligência Artificial**, capaz de analisar imagens de alimentos para apoiar a identificação do seu estado de conservação.

<!-- ---

## Preview do projeto

<p align="center">
  <img src="assets/readme/tela1.png" width="250">
  <img src="assets/readme/tela2.png" width="250">
  <img src="assets/readme/tela3.png" width="250">
</p>

--- -->

## Principais funcionalidades

* Cadastro e autenticação de usuários
* Cadastro de categorias, setores e tipos de etiqueta
* Geração de etiquetas com validade automática
* Controle de estoque e movimentações
* Geração e leitura de QR Code
* Visualização de etiquetas:

  * Ativas
  * Em alerta
  * Vencidas
* Histórico completo de movimentações
* Relatórios gerenciais
* Exportação e impressão de etiquetas
* Configuração de impressoras
* Catálogo de alimentos com sinais de deterioração
* Módulo de IA para análise do estado do alimento

---

## Tecnologias utilizadas

### Aplicação principal

* Flutter
* Firebase 
* Sqflite

### Inteligência Artificial

* Python
* YOLOv8 (Ultralytics)
* PyTorch
* OpenCV

---

## Estrutura do projeto

```bash
tag_valida_tcc/
├── android/
├── assets/
├── ia/
│   ├── dataset/
│   │  └──  classification/
│   │       ├── test/ 
│   │       │       ├── alerta/
│   │       │       ├── bom/
│   │       │       └── vencido/
│   │       ├── train/ ...
│   │       └──  val/ ...
│   │  └──  detection/
│   │       ├── images/ 
│   │       │       ├── test/
│   │       │       ├── train/
│   │       │       └── val/
│   │       ├── labels/ ...
│   │       └── data.yaml
│   ├── scripts/
│   │       ├── api.py
│   │       └── ia_pipeline.py
│   ├── requirements.txt
│   └── ...
├── lib/
│   ├── data/
│   │   ├── local/
│   │       ├── mappers/
│   │       ├── outbox/
│   │       ├── repos/
│   │       └── app_db.dart
│   │   └── sync/
│   ├── models/
│   ├── providers/
│   ├── screens/
│   │   ├── ajuda/
│   │   ├── cadastro/
│   │   ├── catalogo_alimentos/
│   │   ├── categorias/
│   │   ├── configuracoes/
│   │   ├── configuracoes_impressora/
│   │   ├── criar_etiqueta/
│   │   ├── design_etiqueta/
│   │   ├── etiqueta_preview/
│   │   ├── etiquetas_ativas/
│   │   ├── etiquetas_diarias/
│   │   ├── etiquetas_finalizadas/
│   │   ├── historico/
│   │   ├── home/
│   │   ├── login/
│   │   ├── perfil/
│   │   ├── prever/
│   │   ├── relatorios/
│   │   ├── resultado_previsao/
│   │   ├── scanner_etiqueta/
│   │   ├── setores/
│   │   ├── tipo_etiqueta/
│   │   └── welcome.dart
│   ├── services/
│   ├── theme/
│   ├── utils/
│   ├── widgets/
│   └── main.dart
├── test/
├── web/
├── windows/
├── pubspec.yaml
└── README.md
```

---

## Configuração do ambiente de desenvolvimento

### Pré-requisitos

* Flutter SDK
* Dart SDK
* Android Studio ou VS Code
* Emulador ou dispositivo físico
* Projeto configurado no Firebase

### Passos iniciais

Clone o repositório:

```bash
git clone https://github.com/MilenaRickliS/tag_valida_tcc.git
```

Acesse a pasta do projeto:

```bash
cd tag_valida_tcc
```

Instale as dependências:

```bash
flutter pub get
```

Configure o Firebase:

* Adicione o arquivo `google-services.json` (Android)
* Configure o Firebase conforme a plataforma

---

## Como rodar o projeto localmente

```bash
flutter run
```

Verifique o ambiente:

```bash
flutter doctor
```

---

## Módulo de Inteligência Artificial

A pasta `ia/` contém o sistema de visão computacional.

### Configuração

```bash
cd ia
pip install -r requirements.txt
```

### Exemplo de treinamento

```bash
yolo classify train model=yolov8n-cls.pt data=dataset epochs=50 imgsz=224
```

---

## Diferenciais do projeto

* Foco em pequenas empresas alimentícias
* Integração entre gestão de etiquetas e visão computacional
* Aplicação prática com potencial real
* Projeto acadêmico com inovação tecnológica

---

## Possíveis melhorias futuras

* Melhorar a acurácia do modelo de IA
* Expandir o dataset
* Execução offline da IA no app
* Dashboard gerencial mais completo
* Controle por lote avançado
* Integração com dispositivos externos (IoT)

---

## Autora

**Milena Rickli Silvério Kriger**
Projeto desenvolvido como Trabalho de Conclusão de Curso em Engenharia de Software.

---

## Licença

Projeto desenvolvido para fins acadêmicos e de portifólio.
