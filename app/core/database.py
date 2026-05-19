from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from dotenv import load_dotenv
import os
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME")

logger.info(f"🔗 Conectando a BD: {DB_USER}@{DB_HOST}:{DB_PORT}/{DB_NAME}")

DATABASE_URL = (
    f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}"
    f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

try:
    engine = create_engine(
        DATABASE_URL,
        echo=True
    )
    # Test de conexión
    with engine.connect() as conn:
        logger.info("✅ Conexión a BD exitosa")
except Exception as e:
    logger.error(f"❌ Error al conectar a BD: {e}")

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

Base = declarative_base()