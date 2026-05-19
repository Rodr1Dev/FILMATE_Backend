from sqlalchemy import (
    Column,
    Integer,
    String,
    Text,
    Enum,
    DateTime
)

from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.core.database import Base

class Pelicula(Base):
    __tablename__ = "pelicula"

    id_pelicula = Column(
        Integer,
        primary_key=True
    )

    titulo = Column(
        String(150),
        nullable=False
    )

    sinopsis = Column(Text)

    duracion_minutos = Column(Integer)

    clasificacion_edad = Column(
        String(10)
    )

    url_poster = Column(
        String(255)
    )

    url_trailer = Column(
        String(255)
    )

    categoria_cartelera = Column(
        Enum(
            "Estreno",
            "Preventa",
            "Cartelera",
            "Proximamente",
            name="categoria_cartelera"
        ),
        default="Proximamente"
    )

    estado_registro = Column(
        Enum(
            "Activo",
            "Inactivo",
            name="estado_pelicula"
        ),
        default="Activo"
    )

    fecha_creacion = Column(
        DateTime,
        server_default=func.now()
    )

    generos = relationship(
        "PeliculaGenero",
        back_populates="pelicula"
    )

    actores = relationship(
        "PeliculaActor",
        back_populates="pelicula"
    )

    banners = relationship(
        "BannerHome",
        back_populates="pelicula"
    )

    funciones = relationship(
        "Funcion",
        back_populates="pelicula"
    )

    resenas = relationship(
        "Resena",
        back_populates="pelicula"
    )

    favoritos = relationship(
        "Favorito",
        back_populates="pelicula"
    )