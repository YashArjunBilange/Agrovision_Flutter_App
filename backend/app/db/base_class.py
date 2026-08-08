import datetime
from sqlalchemy import Column, DateTime, Integer
from sqlalchemy.orm import declarative_base, declared_attr


class CustomBase:
    # Generate __tablename__ automatically in lowercase plural
    @declared_attr
    def __tablename__(cls) -> str:
        name = cls.__name__.lower()
        if name.endswith("y"):
            return name[:-1] + "ies"
        elif name.endswith("s"):
            return name + "es"
        return name + "s"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow, nullable=False)
    updated_at = Column(
        DateTime,
        default=datetime.datetime.utcnow,
        onupdate=datetime.datetime.utcnow,
        nullable=False,
    )


Base = declarative_base(cls=CustomBase)
