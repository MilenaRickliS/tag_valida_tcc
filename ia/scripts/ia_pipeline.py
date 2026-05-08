from pathlib import Path
from typing import Any, Dict, List
import json

import cv2
from ultralytics import YOLO
import unicodedata


class TagValidaPipeline:
    def __init__(
        self,
        detection_model_path: str,
        classification_model_path: str,
    ) -> None:
        self.detection_model_path = Path(detection_model_path)
        self.classification_model_path = Path(classification_model_path)

        if not self.detection_model_path.exists():
            raise FileNotFoundError(
                f"Modelo de detecção não encontrado: {self.detection_model_path.resolve()}"
            )

        if not self.classification_model_path.exists():
            raise FileNotFoundError(
                f"Modelo de classificação não encontrado: {self.classification_model_path.resolve()}"
            )

        self.detection_model = YOLO(str(self.detection_model_path))
        self.classification_model = YOLO(str(self.classification_model_path))

    def _cor_por_estado(self, estado: str) -> tuple[int, int, int]:
        """
        Retorna cor em BGR para OpenCV.
        """
        estado = estado.lower().strip()

        if estado == "bom":
            return (0, 180, 0)  # verde
        if estado == "alerta":
            return (0, 215, 255)  # amarelo
        if estado == "vencido":
            return (0, 0, 255)  # vermelho

        return (255, 255, 255)  # branco


    def analisar_imagem(
        self,
        image_path: str,
        output_dir: str = "results/pipeline",
        conf_det: float = 0.25,
        imgsz_det: int = 640,
        imgsz_cls: int = 224,
        salvar_crops: bool = True,
        salvar_json: bool = True,
    ) -> Dict[str, Any]:
        image_path = Path(image_path)

        if not image_path.exists():
            raise FileNotFoundError(f"Imagem não encontrada: {image_path.resolve()}")

        image = cv2.imread(str(image_path))
        if image is None:
            raise ValueError(f"Não foi possível abrir a imagem: {image_path.resolve()}")

        image_draw = image.copy()
        h, w = image.shape[:2]

        output_dir_path = Path(output_dir)
        output_dir_path.mkdir(parents=True, exist_ok=True)

        crops_dir = output_dir_path / "crops" / image_path.stem
        if salvar_crops:
            crops_dir.mkdir(parents=True, exist_ok=True)

    
        detect_results = self.detection_model.predict(
            source=str(image_path),
            conf=conf_det,
            imgsz=imgsz_det,
            verbose=False,
        )

        items: List[Dict[str, Any]] = []

        if not detect_results:
            output_image_path = output_dir_path / f"{image_path.stem}_resultado.jpg"
            cv2.imwrite(str(output_image_path), image_draw)

            resultado = {
                "imagem": str(image_path),
                "imagem_resultado": str(output_image_path),
                "quantidade_detectada": 0,
                "items": [],
            }

            if salvar_json:
                json_path = output_dir_path / f"{image_path.stem}_resultado.json"
                with open(json_path, "w", encoding="utf-8") as f:
                    json.dump(resultado, f, ensure_ascii=False, indent=2)

            return resultado

        result = detect_results[0]
        boxes = result.boxes
        det_names = result.names

        if boxes is None or len(boxes) == 0:
            output_image_path = output_dir_path / f"{image_path.stem}_resultado.jpg"
            cv2.imwrite(str(output_image_path), image_draw)

            resultado = {
                "imagem": str(image_path),
                "imagem_resultado": str(output_image_path),
                "quantidade_detectada": 0,
                "items": [],
            }

            if salvar_json:
                json_path = output_dir_path / f"{image_path.stem}_resultado.json"
                with open(json_path, "w", encoding="utf-8") as f:
                    json.dump(resultado, f, ensure_ascii=False, indent=2)

            return resultado

        for i, box in enumerate(boxes):
            cls_id = int(box.cls[0].item())
            det_confidence = float(box.conf[0].item())

            x1, y1, x2, y2 = box.xyxy[0].tolist()
            x1, y1, x2, y2 = map(int, [x1, y1, x2, y2])

            
            x1 = max(0, min(x1, w - 1))
            y1 = max(0, min(y1, h - 1))
            x2 = max(0, min(x2, w - 1))
            y2 = max(0, min(y2, h - 1))

            if x2 <= x1 or y2 <= y1:
                continue

            crop = image[y1:y2, x1:x2]
            if crop.size == 0:
                continue

           
            cls_results = self.classification_model.predict(
                source=crop,
                imgsz=imgsz_cls,
                verbose=False,
            )

            estado = "desconhecido"
            estado_confidence = 0.0

            if cls_results and cls_results[0].probs is not None:
                probs = cls_results[0].probs
                top1_id = int(probs.top1)
                top1_conf = float(probs.top1conf.item())

                if cls_results[0].names:
                    estado = cls_results[0].names[top1_id]
                else:
                    estado = str(top1_id)

                estado_confidence = top1_conf

                if estado_confidence < 0.85:
                    estado_original = estado
                    estado = "alerta"
                else:
                    estado_original = estado

            produto = det_names.get(cls_id, str(cls_id))
            cor = self._cor_por_estado(estado)

            crop_path = None
            if salvar_crops:
                crop_filename = f"{i+1:02d}_{produto}_{estado}.jpg"
                crop_path = crops_dir / crop_filename
                cv2.imwrite(str(crop_path), crop)

            item = {
                "id": i + 1,
                "produto": produto,
                "produto_conf": round(det_confidence * 100, 2),
                "estado": estado,
                "estado_conf": round(estado_confidence * 100, 2),
                "crop_path": str(crop_path) if crop_path else None,
                "bbox": {
                    "x1": x1,
                    "y1": y1,
                    "x2": x2,
                    "y2": y2,
                    "width": x2 - x1,
                    "height": y2 - y1,
                },
            }
            items.append(item)

            def remover_acentos(texto: str) -> str:
                return ''.join(
                    c for c in unicodedata.normalize('NFD', texto)
                    if unicodedata.category(c) != 'Mn'
                )

            texto = remover_acentos(f"{produto} - {estado}".upper())

            overlay = image_draw.copy()

         
            cv2.rectangle(
                overlay,
                (x1, y1),
                (x2, y2),
                cor,
                -1,
            )

            alpha = 0.12
            image_draw = cv2.addWeighted(overlay, alpha, image_draw, 1 - alpha, 0)

         
            cv2.rectangle(
                image_draw,
                (x1, y1),
                (x2, y2),
                cor,
                3,
                cv2.LINE_AA,
            )

          
            cv2.rectangle(
                image_draw,
                (x1 + 1, y1 + 1),
                (x2 - 1, y2 - 1),
                (255, 255, 255),
                1,
                cv2.LINE_AA,
            )

            
            font = cv2.FONT_HERSHEY_SIMPLEX
            font_scale = 0.58
            font_thickness = 2

            (text_w, text_h), baseline = cv2.getTextSize(
                texto,
                font,
                font_scale,
                font_thickness,
            )

            label_pad_x = 10
            label_pad_y = 8
            label_h = text_h + baseline + (label_pad_y * 2)
            label_w = text_w + (label_pad_x * 2)

            label_x1 = x1
            label_y2 = y1 - 8

        
            if label_y2 - label_h < 0:
                label_y2 = y1 + label_h + 8

            label_y1 = label_y2 - label_h
            label_x2 = label_x1 + label_w

        
            cv2.rectangle(
                image_draw,
                (label_x1 + 2, label_y1 + 2),
                (label_x2 + 2, label_y2 + 2),
                (0, 0, 0),
                -1,
            )

            cv2.rectangle(
                image_draw,
                (label_x1, label_y1),
                (label_x2, label_y2),
                cor,
                -1,
            )

           
            cv2.rectangle(
                image_draw,
                (label_x1, label_y1),
                (label_x2, label_y2),
                (255, 255, 255),
                1,
            )

       
            cv2.putText(
                image_draw,
                texto,
                (label_x1 + label_pad_x, label_y2 - label_pad_y),
                font,
                font_scale,
                (255, 255, 255),
                font_thickness,
                cv2.LINE_AA,
            )

        output_image_path = output_dir_path / f"{image_path.stem}_resultado.jpg"
        cv2.imwrite(str(output_image_path), image_draw)

        resultado = {
            "imagem": str(image_path),
            "imagem_resultado": str(output_image_path),
            "quantidade_detectada": len(items),
            "items": items,
        }

        if salvar_json:
            json_path = output_dir_path / f"{image_path.stem}_resultado.json"
            with open(json_path, "w", encoding="utf-8") as f:
                json.dump(resultado, f, ensure_ascii=False, indent=2)

        return resultado


def main() -> None:
    print("=== TAGVALIDA - PIPELINE IA ===")
    print("1 - Analisar imagem")

    opcao = input("Escolha uma opção: ").strip()

    if opcao != "1":
        print("Opção inválida.")
        return

    image_path = input("Digite o caminho da imagem: ").strip()

    detection_model_path = "runs/detect/train4/weights/best.pt"
    classification_model_path = "runs/classify/classificacao_refinada_sem_aug/weights/best.pt"

    pipeline = TagValidaPipeline(
        detection_model_path=detection_model_path,
        classification_model_path=classification_model_path,
    )

    resultado = pipeline.analisar_imagem(
        image_path=image_path,
        output_dir="results/pipeline",
        salvar_crops=True,
        salvar_json=True,
    )

    print("\n=== RESULTADO ===")
    print(f"Imagem analisada: {resultado['imagem']}")
    print(f"Imagem resultado: {resultado['imagem_resultado']}")
    print(f"Quantidade detectada: {resultado['quantidade_detectada']}")

    for item in resultado["items"]:
        print("\n----------------------------")
        print(f"ID: {item['id']}")
        print(f"Produto: {item['produto']}")
        print(f"Confiança produto: {item['produto_conf']}%")
        print(f"Estado: {item['estado']}")
        print(f"Confiança estado: {item['estado_conf']}%")
        print(f"Crop salvo em: {item['crop_path']}")
        print(f"Bounding box: {item['bbox']}")


if __name__ == "__main__":
    main()