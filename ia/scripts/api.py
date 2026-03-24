#uvicorn scripts.api:app --host 0.0.0.0 --port 8000

from pathlib import Path
from typing import Any, Dict
from uuid import uuid4
import shutil
import traceback
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware

from scripts.ia_pipeline import TagValidaPipeline

app = FastAPI(
    title="TagValida IA API",
    description="API para detecção de alimentos e classificação de validade",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = Path(__file__).resolve().parent.parent
UPLOAD_DIR = BASE_DIR / "uploads"
RESULTS_DIR = BASE_DIR / "results" / "api"

UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
RESULTS_DIR.mkdir(parents=True, exist_ok=True)

DETECTION_MODEL_PATH = BASE_DIR / "runs" / "detect" / "train2" / "weights" / "best.pt"
CLASSIFICATION_MODEL_PATH = BASE_DIR / "runs" / "classify" / "train3" / "weights" / "best.pt"

pipeline: TagValidaPipeline | None = None


def get_pipeline() -> TagValidaPipeline:
    global pipeline

    if pipeline is None:
        if not DETECTION_MODEL_PATH.exists():
            raise FileNotFoundError(
                f"Modelo de detecção não encontrado em: {DETECTION_MODEL_PATH}"
            )

        if not CLASSIFICATION_MODEL_PATH.exists():
            raise FileNotFoundError(
                f"Modelo de classificação não encontrado em: {CLASSIFICATION_MODEL_PATH}"
            )

        pipeline = TagValidaPipeline(
            detection_model_path=str(DETECTION_MODEL_PATH),
            classification_model_path=str(CLASSIFICATION_MODEL_PATH),
        )

    return pipeline


@app.get("/")
def root() -> Dict[str, Any]:
    return {
        "message": "API TagValida IA online",
        "status": "ok",
    }


@app.get("/health")
def health() -> Dict[str, Any]:
    return {
        "status": "ok",
        "detection_model_exists": DETECTION_MODEL_PATH.exists(),
        "classification_model_exists": CLASSIFICATION_MODEL_PATH.exists(),
    }


@app.post("/analisar")
@app.post("/analisar")
async def analisar_imagem(file: UploadFile = File(...)) -> Dict[str, Any]:
    try:
        print("1. Iniciando análise")

        if not file.filename:
            raise HTTPException(status_code=400, detail="Arquivo inválido.")

        ext = Path(file.filename).suffix.lower()
        print(f"2. Extensão recebida: {ext}")

        if ext not in [".jpg", ".jpeg", ".png", ".webp"]:
            raise HTTPException(
                status_code=400,
                detail="Formato não suportado. Envie JPG, JPEG, PNG ou WEBP.",
            )

        unique_name = f"{uuid4().hex}{ext}"
        image_path = UPLOAD_DIR / unique_name
        print(f"3. Salvando imagem em: {image_path}")

        with open(image_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        print("4. Carregando pipeline")
        tag_pipeline = get_pipeline()

        print("5. Executando analisar_imagem")
        resultado = tag_pipeline.analisar_imagem(
            image_path=str(image_path),
            output_dir=str(RESULTS_DIR),
            salvar_crops=True,
            salvar_json=True,
        )

        print("6. Análise concluída com sucesso")

        return {
            "success": True,
            "message": "Imagem analisada com sucesso.",
            "data": resultado,
        }

    except HTTPException:
        raise
    except FileNotFoundError as e:
        print("ERRO FileNotFoundError:")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
    except Exception as e:
        print("ERRO INTERNO NA ANALISE:")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Erro ao analisar imagem: {e}")