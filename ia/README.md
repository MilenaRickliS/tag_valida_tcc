# IA de Previsão de Validade de Alimentos – TagValida

Sistema de **visão computacional baseado em YOLOv8** para detecção de alimentos e classificação do estado de conservação (**bom, alerta ou vencido**) a partir de imagens reais de produtos de panificação.

Este projeto faz parte do **TCC em Engenharia de Software**:
**“TagVálida: Desenvolvimento De Um Sistema De Etiquetagem com Visão Computacional Para Pequenas Empresas Alimentícias”**.

---

# Objetivo

Desenvolver um modelo de **Inteligência Artificial capaz de analisar visualmente alimentos** e indicar seu estado de conservação, auxiliando no controle de validade e na redução de desperdícios em panificadoras.

O sistema utiliza:

* **YOLOv8** para detectar o alimento na imagem
* **Modelo de classificação** para determinar o estado do alimento

Estados possíveis:

* ✅ **Bom**
* ⚠️ **Alerta**
* ❌ **Vencido**

---

# Arquitetura da IA

O sistema utiliza **duas etapas de visão computacional**:

### 1️⃣ Detecção do alimento

O modelo YOLO detecta qual alimento aparece na imagem e gera uma **bounding box**.

Classes detectadas:

* pão francês
* pão de forma
* croissant de presunto e queijo
* danesse de goiabada
* queijo mussarela
* ovo

### 2️⃣ Classificação do estado

Após detectar o alimento, o sistema **recorta a região detectada** e envia para um modelo de classificação que determina:

* bom
* alerta
* vencido

Fluxo:

Imagem → YOLO detecta alimento → recorte da região → classificador prevê estado

---

# Estrutura do Projeto

```
ia/
│
│
├── dataset/
│   ├── detection/
│   │   ├── images/
│   │   │   ├── train/
│   │   │   ├── val/
│   │   │   └── test/
│   │   ├── labels/
│   │   │   ├── train/
│   │   │   ├── val/
│   │   │   └── test/
│   │   └── data.yaml
│   │
│   └── classification/
│       ├── train/
│       │   ├── bom/
│       │   ├── alerta/
│       │   └── vencido/
│       ├── val/
│       │   ├── bom/
│       │   ├── alerta/
│       │   └── vencido/
│       └── test/
│           ├── bom/
│           ├── alerta/
│           └── vencido/
│
├── models/
│
├── scripts/
│   └── ia_detectar.py
│
├── results/
│
├── requirements.txt
│
└── README.md
```

---

# Dataset

O dataset foi coletado a partir de **imagens reais de produtos de panificação**.

Cada alimento possui imagens em três estados:

| Classe  | Descrição                                     |
| ------- | --------------------------------------------- |
| Bom     | Produto recém produzido ou dentro da validade |
| Alerta  | Produto próximo ao vencimento                 |
| Vencido | Produto com sinais visuais de deterioração    |

### Quantidade de imagens

Cada alimento possui aproximadamente:

* **128 imagens por estado**

Total por alimento:

384 imagens

Total aproximado do dataset:

**2304 imagens**

---

# Estrutura YOLO

Para a detecção, a estrutura segue o padrão YOLO:

```
data/detection/
│
├── images/
│   ├── train/
│   ├── val/
│   └── test/
│
├── labels/
│   ├── train/
│   ├── val/
│   └── test/
│
└── data.yaml
```

Exemplo de label YOLO:

```
0 0.512 0.487 0.420 0.380
```

Formato:

```
classe x_center y_center width height
```

Valores normalizados entre **0 e 1**.

---

# data.yaml

```
path: ./data/detection

train: images/train
val: images/val
test: images/test

nc: 6

names:
  0: pao_frances
  1: pao_forma
  2: croissant
  3: danesse_goiabada
  4: ovo_teste
  5: queijo_mussarela
```

---

# Treinamento

Instalar dependências:

```
pip install ultralytics
```

Treinar modelo de detecção:

```
yolo detect train data=data/detection/data.yaml model=yolov8n.pt epochs=100 imgsz=640
```

Treinar classificador:

```
yolo classify train model=yolov8n-cls.pt data=data/classification epochs=50 imgsz=224
```

---

# Resultados

Após o treinamento, os pesos do modelo ficam em:

```
runs/detect/train/weights/best.pt
```

Esse arquivo é o modelo final utilizado pelo sistema.

---

# Integração com o aplicativo

O modelo será utilizado no aplicativo **TagValida**, desenvolvido em **Flutter**, permitindo que o usuário:

1. Tire uma foto do alimento
2. O sistema detecte o produto
3. A IA classifique o estado do alimento

Exemplo de resultado exibido no aplicativo:

```
Produto: Pão francês
Estado: Alerta
Recomendação: Priorizar venda
```

---

# Tecnologias utilizadas

* Python
* YOLOv8 (Ultralytics)
* OpenCV
* PyTorch
* Flutter (integração no app)

---

# Possíveis melhorias futuras

* aumento do dataset
* uso de data augmentation
* treinamento com mais tipos de alimentos
* detecção em tempo real
* exportação para TensorFlow Lite para execução no dispositivo móvel

---

# Autor

Projeto desenvolvido por **Milena Rickli Silvério Kriger**
Engenharia de Software

TCC:
**TagVálida: Desenvolvimento De Um Sistema De Etiquetagem com Visão Computacional Para Pequenas Empresas Alimentícias**
