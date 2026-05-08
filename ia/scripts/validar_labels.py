from pathlib import Path
import cv2


from pathlib import Path
import cv2

BASE_DIR = Path("../dataset/detection")

CLASS_NAMES = {
    0: "pao_frances",
    1: "pao_forma",
    2: "queijo_mussarela",
    3: "croissant",
    4: "morango",
    5: "ovo_teste",
}



def desenhar_bbox(image, label_path):
    h, w = image.shape[:2]

    with open(label_path, "r", encoding="utf-8") as f:
        linhas = f.readlines()

    for linha in linhas:
        partes = linha.strip().split()

        if len(partes) != 5:
            print(f"⚠ Label inválida: {label_path}")
            continue

        cls_id, xc, yc, bw, bh = partes

        cls_id = int(cls_id)
        xc, yc, bw, bh = map(float, [xc, yc, bw, bh])

        
        x1 = int((xc - bw / 2) * w)
        y1 = int((yc - bh / 2) * h)
        x2 = int((xc + bw / 2) * w)
        y2 = int((yc + bh / 2) * h)

        nome = CLASS_NAMES.get(cls_id, str(cls_id))

       
        cv2.rectangle(image, (x1, y1), (x2, y2), (0, 255, 0), 2)

        cv2.putText(
            image,
            nome,
            (x1, max(20, y1 - 10)),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.6,
            (0, 255, 0),
            2,
        )

    return image


def validar_dataset(split="train"):
    image_dir = BASE_DIR / "images" / split
    label_dir = BASE_DIR / "labels" / split

    imagens = list(image_dir.glob("*.*"))

    if not imagens:
        print(f"❌ Nenhuma imagem encontrada em {image_dir}")
        return

    print(f"\nValidando: {split}")
    print(f"Total de imagens: {len(imagens)}")
    print("ENTER/espaço: próxima | ESC: sair\n")

    cv2.namedWindow("Validacao YOLO", cv2.WINDOW_NORMAL)
    cv2.resizeWindow("Validacao YOLO", 1200, 800)

    for img_path in imagens:
        if img_path.suffix.lower() not in [".jpg", ".jpeg", ".png", ".webp"]:
            continue

        label_path = label_dir / f"{img_path.stem}.txt"

        image = cv2.imread(str(img_path))

        if image is None:
            print(f"❌ Erro ao abrir imagem: {img_path}")
            continue

        if not label_path.exists():
            print(f"⚠ Label não encontrada: {label_path}")
            continue

        image = desenhar_bbox(image, label_path)

        max_width = 1000
        h, w = image.shape[:2]

        if w > max_width:
            scale = max_width / w
            image = cv2.resize(image, (int(w * scale), int(h * scale)))

        cv2.imshow("Validacao YOLO", image)
        key = cv2.waitKey(0)

        if key == 27:
            break

    cv2.destroyAllWindows()


if __name__ == "__main__":
    validar_dataset("train")
    validar_dataset("val")
    validar_dataset("test")