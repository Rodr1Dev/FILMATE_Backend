from datetime import datetime
from typing import Optional, List

from pydantic import BaseModel


class TransactionItem(BaseModel):
    id_reserva: int

    cliente: str
    pelicula: str
    sala: str

    monto_total: float

    estado_pago: str
    metodo_pago: Optional[str] = None

    fecha_compra: Optional[datetime] = None

    class Config:
        from_attributes = True


class TransactionMetrics(BaseModel):
    ventasMes: float
    ingresosTotales: float
    reembolsos: int
    ticketPromedio: float


class TransactionListResponse(BaseModel):
    data: List[TransactionItem]

    total: int
    page: int
    totalPages: int

    metricas: TransactionMetrics


class TicketDetail(BaseModel):
    id_boleto: int
    asiento: str
    precio_pagado: float
    estado_ingreso: str


class SnackDetail(BaseModel):
    producto: str
    cantidad: int
    subtotal: float
    class Config:
        from_attributes = True


class TransactionDetail(BaseModel):
    id_reserva: int

    cliente: str
    correo: str

    pelicula: str
    sala: str

    monto_subtotal: float
    descuento_aplicado: float
    monto_total: float

    estado_pago: str
    metodo_pago: Optional[str] = None
    transaccion_id: Optional[str] = None

    boletos: List[TicketDetail]
    snacks: List[SnackDetail]

    class Config:
        from_attributes = True


class ValidateQRSchema(BaseModel):
    codigo_qr: Optional[str] = None
    codigo: Optional[str] = None


class ValidateResponse(BaseModel):
    valido: bool
    estado: str
    detalle: Optional[dict] = None