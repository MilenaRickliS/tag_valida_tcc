from pathlib import Path
import json
import csv
from collections import Counter

import numpy as np
import matplotlib.pyplot as plt

from ultralytics import YOLO
from sklearn.metrics import (
    confusion_matrix,
    classification_report,
    accuracy_score,
    precision_recall_fscore_support,
)



def avaliar_deteccao(
    model_path: str,
    data_yaml: str,
    split: str = "test",   
    imgsz: int = 640,
    conf: float = 0.25,
    iou: float = 0.60,
    save_dir: str = "results/avaliacao_deteccao",
) -> dict:
    model = YOLO(model_path)

    metrics = model.val(
        data=data_yaml,
        split=split,
        imgsz=imgsz,
        conf=conf,
        iou=iou,
        save=True,
        plots=True,
        project=save_dir,
        name="execucao",
    )

    resumo = {
        "model_path": model_path,
        "data_yaml": data_yaml,
        "split": split,
        "imgsz": imgsz,
        "conf": conf,
        "iou": iou,
        "metrics": {
            "precision": float(metrics.box.mp),
            "recall": float(metrics.box.mr),
            "mAP50": float(metrics.box.map50),
            "mAP50_95": float(metrics.box.map),
        },
        "save_dir": str(Path(save_dir) / "execucao"),
    }

    out_path = Path(save_dir) / "execucao" / "resumo_metricas.json"
    out_path.parent.mkdir(parents=True, exist_ok=True)

    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(resumo, f, ensure_ascii=False, indent=2)

    print("\n=== RESULTADO DETECÇÃO ===")
    print(f"Precision: {resumo['metrics']['precision']:.4f}")
    print(f"Recall:    {resumo['metrics']['recall']:.4f}")
    print(f"mAP50:     {resumo['metrics']['mAP50']:.4f}")
    print(f"mAP50-95:  {resumo['metrics']['mAP50_95']:.4f}")
    print(f"Arquivos salvos em: {resumo['save_dir']}")

    return resumo



def avaliar_classificacao(
    model_path: str,
    dataset_dir: str,
    split: str = "test",  
    imgsz: int = 224,
    save_dir: str = "results/avaliacao_classificacao",
) -> dict:
    """
    Estrutura esperada:
    dataset/classification/test/
      bom/
      alerta/
      vencido/
    """

    model = YOLO(model_path)

    base = Path(dataset_dir) / split
    if not base.exists():
        raise FileNotFoundError(f"Pasta não encontrada: {base.resolve()}")

    class_names = sorted([p.name for p in base.iterdir() if p.is_dir()])
    if not class_names:
        raise ValueError(f"Nenhuma classe encontrada em: {base.resolve()}")

    y_true = []
    y_pred = []
    erros = []

    for class_name in class_names:
        class_dir = base / class_name
        imagens = []
        for ext in ("*.jpg", "*.jpeg", "*.png", "*.webp"):
            imagens.extend(class_dir.glob(ext))

        for img_path in imagens:
            results = model.predict(
                source=str(img_path),
                imgsz=imgsz,
                verbose=False,
            )

            pred_name = "desconhecido"
            pred_conf = 0.0

            if results and results[0].probs is not None:
                probs = results[0].probs
                top1_id = int(probs.top1)
                pred_conf = float(probs.top1conf.item())
                pred_name = results[0].names[top1_id]

            y_true.append(class_name)
            y_pred.append(pred_name)

            if pred_name != class_name:
                erros.append({
                    "imagem": str(img_path),
                    "real": class_name,
                    "predito": pred_name,
                    "confianca": round(pred_conf * 100, 2),
                })

    labels = sorted(list(set(class_names) | set(y_pred)))
    cm = confusion_matrix(y_true, y_pred, labels=labels)

    acc = accuracy_score(y_true, y_pred)
    precision_macro, recall_macro, f1_macro, _ = precision_recall_fscore_support(
        y_true,
        y_pred,
        labels=labels,
        average="macro",
        zero_division=0,
    )

    report = classification_report(
        y_true,
        y_pred,
        labels=labels,
        output_dict=True,
        zero_division=0,
    )

    out_dir = Path(save_dir)
    out_dir.mkdir(parents=True, exist_ok=True)


    plt.figure(figsize=(9, 7))
    plt.imshow(cm, interpolation="nearest")
    plt.title("Matriz de Confusão - Classificação")
    plt.colorbar()

    tick_marks = np.arange(len(labels))
    plt.xticks(tick_marks, labels, rotation=45, ha="right")
    plt.yticks(tick_marks, labels)

    thresh = cm.max() / 2 if cm.size else 0
    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            plt.text(
                j,
                i,
                format(cm[i, j], "d"),
                ha="center",
                va="center",
                color="white" if cm[i, j] > thresh else "black",
            )

    plt.ylabel("Classe real")
    plt.xlabel("Classe predita")
    plt.tight_layout()
    plt.savefig(out_dir / "confusion_matrix.png", dpi=220, bbox_inches="tight")
    plt.close()

   
    csv_path = out_dir / "erros_classificacao.csv"
    with open(csv_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=["imagem", "real", "predito", "confianca"],
        )
        writer.writeheader()
        writer.writerows(erros)

    
    confusoes = Counter()
    for real, pred in zip(y_true, y_pred):
        if real != pred:
            confusoes[(real, pred)] += 1

    ranking_confusoes = [
        {"real": real, "predito": pred, "quantidade": qtd}
        for (real, pred), qtd in confusoes.most_common()
    ]

   
    ranking_csv_path = out_dir / "ranking_confusoes.csv"
    with open(ranking_csv_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=["real", "predito", "quantidade"],
        )
        writer.writeheader()
        writer.writerows(ranking_confusoes)

    resumo = {
        "model_path": model_path,
        "dataset_dir": dataset_dir,
        "split": split,
        "classes": labels,
        "accuracy": round(float(acc), 6),
        "precision_macro": round(float(precision_macro), 6),
        "recall_macro": round(float(recall_macro), 6),
        "f1_macro": round(float(f1_macro), 6),
        "classification_report": report,
        "total_erros": len(erros),
        "ranking_confusoes": ranking_confusoes,
        "arquivos_gerados": {
            "confusion_matrix": str(out_dir / "confusion_matrix.png"),
            "resumo_json": str(out_dir / "resumo_classificacao.json"),
            "erros_csv": str(csv_path),
            "ranking_confusoes_csv": str(ranking_csv_path),
        },
    }

    with open(out_dir / "resumo_classificacao.json", "w", encoding="utf-8") as f:
        json.dump(resumo, f, ensure_ascii=False, indent=2)

    print("\n=== RESULTADO CLASSIFICAÇÃO ===")
    print(f"Acurácia:        {acc:.4f}")
    print(f"Precision macro: {precision_macro:.4f}")
    print(f"Recall macro:    {recall_macro:.4f}")
    print(f"F1 macro:        {f1_macro:.4f}")
    print(f"Total de erros:  {len(erros)}")
    print(f"Matriz salva em: {out_dir / 'confusion_matrix.png'}")
    print(f"CSV de erros:    {csv_path}")
    print(f"Ranking conf.:   {ranking_csv_path}")

    print("\n=== TOP CONFUSÕES ===")
    for item in ranking_confusoes[:10]:
        print(
            f"{item['real']} -> {item['predito']} : {item['quantidade']}"
        )

    return resumo



def main():
    print("=== AVALIAÇÃO DA IA TAGVALIDA ===")

   
    detection_model_path = "../runs/detect/train2/weights/best.pt"
    detection_data_yaml = "../dataset/detection/data.yaml"

    classification_model_path = "../runs/classify/train3/weights/best.pt"
    classification_dataset_dir = "../dataset/classification"

    try:
        avaliar_deteccao(
            model_path=detection_model_path,
            data_yaml=detection_data_yaml,
            split="test",   
            imgsz=640,
            conf=0.25,
            iou=0.60,
            save_dir="results/avaliacao_deteccao",
        )
    except Exception as e:
        print(f"\n[ERRO DETECÇÃO] {e}")

    try:
        avaliar_classificacao(
            model_path=classification_model_path,
            dataset_dir=classification_dataset_dir,
            split="test",   
            imgsz=224,
            save_dir="results/avaliacao_classificacao",
        )
    except Exception as e:
        print(f"\n[ERRO CLASSIFICAÇÃO] {e}")


if __name__ == "__main__":
    main()