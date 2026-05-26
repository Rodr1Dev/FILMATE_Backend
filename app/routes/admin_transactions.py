import logging

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Optional

from app.core.dependencies import get_db

from app.schemas.transaction import (
    TransactionListResponse,
    TransactionDetail,
    ValidateQRSchema,
    ValidateResponse
)

from app.repositories import transaction_repository

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api/ventas",
    tags=["ventas"]
)


@router.get(
    "/transacciones",
    response_model=TransactionListResponse
)
def list_transactions(
    estado: Optional[str] = None,
    buscar: Optional[str] = None,
    fecha: Optional[str] = None,
    tipo:  Optional[str] = None,
    page: int = 1,
    limit: int = 10,
    db: Session = Depends(get_db)
):

    return transaction_repository.list_transactions(
        db=db,
        estado=estado,
        buscar=buscar,
        fecha=fecha,
        page=page,
        limit=limit
    )


@router.get(
    "/transacciones/{reservation_id}",
    response_model=TransactionDetail,
    responses={
        404: {
            "description": "Transaction not found"
        },
        500: {
            "description": "Internal Server Error"
        }
    }
)
def get_transaction_detail(
    reservation_id: int,
    db: Session = Depends(get_db)
):

    logger.info(
        f"📥 GET /api/ventas/transacciones/{reservation_id}"
    )

    try:

        transaction = (
            transaction_repository.get_transaction_detail(
                db,
                reservation_id
            )
        )

        if not transaction:

            raise HTTPException(
                status_code=404,
                detail="Transaction not found"
            )

        return transaction

    except HTTPException:
        raise

    except Exception as e:

        logger.error(
            f"❌ Error GET /api/ventas/transacciones/{reservation_id}: {e}"
        )

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


@router.post(
    "/validar",
    response_model=ValidateResponse
)
def validate_ticket(
    payload: ValidateQRSchema,
    db: Session = Depends(get_db)
):

    return (
        transaction_repository
        .validate_ticket_or_transaction(
            db=db,
            codigo_qr=payload.codigo_qr,
            codigo=payload.codigo
        )
    )