from pathlib import Path
import csv
import random
import shutil

import cv2
import numpy as np


BASE_DIR = Path(__file__).resolve().parent.parent

CSV_ERROS = BASE_DIR / "scripts" / "results" / "avaliacao_classificacao" / "erros_classificacao.csv"
# se seu CSV estiver em outro lugar, ajuste acima

DATASET_BASE = BASE_DIR / "dataset" / "classification"
TRAIN_DIR = DATASET_BASE / "train"

OUTPUT_BASE = BASE_DIR / "dataset_reforco_classificacao"
OUTPUT_TRAIN_DIR = OUTPUT_BASE / "train"

AUGS_POR_IMAGEM = 6
SEED = 42

random.seed(SEED)
np.random.seed(SEED)


def garantir_pastas(classes: list[str]) -> None:
    OUTPUT_TRAIN_DIR.mkdir(parents=True, exist_ok=True)
    for classe in classes:
        (OUTPUT_TRAIN_DIR / classe).mkdir(parents=True, exist_ok=True)


def ler_csv_erros(csv_path: Path) -> list[dict]:
    if not csv_path.exists():
        raise FileNotFoundError(f"CSV de erros não encontrado: {csv_path}")

    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        return list(reader)


def ajustar_brilho_contraste(img: np.ndarray) -> np.ndarray:
    alpha = random.uniform(0.88, 1.12)  # contraste
    beta = random.randint(-18, 18)      # brilho
    out = cv2.convertScaleAbs(img, alpha=alpha, beta=beta)
    return out


def ajustar_hsv(img: np.ndarray) -> np.ndarray:
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV).astype(np.float32)

    hsv[..., 0] = np.clip(hsv[..., 0] + random.uniform(-4, 4), 0, 179)
    hsv[..., 1] = np.clip(hsv[..., 1] * random.uniform(0.88, 1.12), 0, 255)
    hsv[..., 2] = np.clip(hsv[..., 2] * random.uniform(0.88, 1.12), 0, 255)

    out = cv2.cvtColor(hsv.astype(np.uint8), cv2.COLOR_HSV2BGR)
    return out


def rotacionar_leve(img: np.ndarray) -> np.ndarray:
    h, w = img.shape[:2]
    angle = random.uniform(-8, 8)
    M = cv2.getRotationMatrix2D((w / 2, h / 2), angle, 1.0)
    out = cv2.warpAffine(
        img,
        M,
        (w, h),
        flags=cv2.INTER_LINEAR,
        borderMode=cv2.BORDER_REFLECT_101,
    )
    return out


def zoom_leve(img: np.ndarray) -> np.ndarray:
    h, w = img.shape[:2]
    scale = random.uniform(0.92, 1.08)

    new_w = int(w * scale)
    new_h = int(h * scale)

    resized = cv2.resize(img, (new_w, new_h), interpolation=cv2.INTER_LINEAR)

    if scale >= 1.0:
        start_x = (new_w - w) // 2
        start_y = (new_h - h) // 2
        out = resized[start_y:start_y + h, start_x:start_x + w]
    else:
        canvas = np.zeros_like(img)
        start_x = (w - new_w) // 2
        start_y = (h - new_h) // 2
        canvas[start_y:start_y + new_h, start_x:start_x + new_w] = resized
        out = canvas

    return out


def translacao_leve(img: np.ndarray) -> np.ndarray:
    h, w = img.shape[:2]
    tx = random.randint(-int(w * 0.06), int(w * 0.06))
    ty = random.randint(-int(h * 0.06), int(h * 0.06))

    M = np.float32([[1, 0, tx], [0, 1, ty]])
    out = cv2.warpAffine(
        img,
        M,
        (w, h),
        flags=cv2.INTER_LINEAR,
        borderMode=cv2.BORDER_REFLECT_101,
    )
    return out


def ruido_leve(img: np.ndarray) -> np.ndarray:
    noise = np.random.normal(0, 6, img.shape).astype(np.float32)
    out = img.astype(np.float32) + noise
    out = np.clip(out, 0, 255).astype(np.uint8)
    return out


def blur_leve(img: np.ndarray) -> np.ndarray:
    k = random.choice([0, 3])
    if k == 0:
        return img
    return cv2.GaussianBlur(img, (k, k), 0)


def flip_horizontal(img: np.ndarray) -> np.ndarray:
    if random.random() < 0.5:
        return cv2.flip(img, 1)
    return img


def pipeline_augmentacao(img: np.ndarray) -> np.ndarray:
    out = img.copy()

    operacoes = [
        ajustar_brilho_contraste,
        ajustar_hsv,
        rotacionar_leve,
        zoom_leve,
        translacao_leve,
        ruido_leve,
        blur_leve,
        flip_horizontal,
    ]

    random.shuffle(operacoes)

    qtd = random.randint(3, 5)
    for op in operacoes[:qtd]:
        out = op(out)

    return out


def copiar_originais_de_treino(classes: list[str]) -> int:
    total = 0
    for classe in classes:
        origem = TRAIN_DIR / classe
        destino = OUTPUT_TRAIN_DIR / classe

        if not origem.exists():
            print(f"⚠ Pasta não encontrada no treino original: {origem}")
            continue

        for ext in ("*.jpg", "*.jpeg", "*.png", "*.webp"):
            for img_path in origem.glob(ext):
                out_path = destino / img_path.name
                shutil.copy2(img_path, out_path)
                total += 1

    return total


def gerar_reforco_dos_erros(erros: list[dict]) -> tuple[int, int]:
    total_lidos = 0
    total_gerados = 0

    for erro in erros:
        img_path = Path(erro["imagem"])
        classe_real = erro["real"].strip()

        if not img_path.exists():
            print(f"⚠ Imagem do erro não encontrada: {img_path}")
            continue

        img = cv2.imread(str(img_path))
        if img is None:
            print(f"⚠ Não foi possível abrir: {img_path}")
            continue

        total_lidos += 1

        destino_classe = OUTPUT_TRAIN_DIR / classe_real
        destino_classe.mkdir(parents=True, exist_ok=True)

        stem = img_path.stem

        # copia original do erro
        original_out = destino_classe / f"{stem}_erro_original.jpg"
        cv2.imwrite(str(original_out), img)

        # gera augmentations
        for i in range(AUGS_POR_IMAGEM):
            aug = pipeline_augmentacao(img)
            out_path = destino_classe / f"{stem}_aug_{i+1:02d}.jpg"
            cv2.imwrite(str(out_path), aug)
            total_gerados += 1

    return total_lidos, total_gerados


def contar_imagens_por_classe(base_dir: Path) -> dict[str, int]:
    contagem = {}
    if not base_dir.exists():
        return contagem

    for pasta in sorted(base_dir.iterdir()):
        if pasta.is_dir():
            total = 0
            for ext in ("*.jpg", "*.jpeg", "*.png", "*.webp"):
                total += len(list(pasta.glob(ext)))
            contagem[pasta.name] = total
    return contagem


def main() -> None:
    print("=== PIPELINE DE MELHORIA AUTOMÁTICA - CLASSIFICAÇÃO ===")

    erros = ler_csv_erros(CSV_ERROS)
    classes = sorted({e["real"].strip() for e in erros})

    if not classes:
        print("❌ Nenhuma classe encontrada no CSV de erros.")
        return

    garantir_pastas(classes)

    print("\n1) Copiando dataset original de treino...")
    total_originais = copiar_originais_de_treino(classes)
    print(f"✔ {total_originais} imagens de treino copiadas.")

    print("\n2) Gerando reforço a partir dos erros...")
    total_lidos, total_gerados = gerar_reforco_dos_erros(erros)
    print(f"✔ {total_lidos} imagens de erro processadas.")
    print(f"✔ {total_gerados} imagens aumentadas geradas.")

    print("\n3) Resumo por classe:")
    resumo = contar_imagens_por_classe(OUTPUT_TRAIN_DIR)
    for classe, total in resumo.items():
        print(f" - {classe}: {total} imagem(ns)")

    print("\n4) Novo dataset pronto em:")
    print(OUTPUT_BASE)

    print("\nPróximo treino sugerido:")
    print(
        "yolo classify train "
        f"model={BASE_DIR / 'runs' / 'classify' / 'train' / 'weights' / 'best.pt'} "
        f"data={OUTPUT_BASE} "
        "epochs=40 imgsz=224"
    )


if __name__ == "__main__":
    main()