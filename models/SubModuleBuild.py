from sqlalchemy import Column, ForeignKey, String, Integer
from sqlalchemy.orm import relationship

from database import Base


class SubModuleBuild(Base):
    __tablename__ = 'submodule_builds'

    id = Column(Integer, primary_key=True, index=True)
    module = Column(String)
    build_time = Column(String)
    result = Column(String)
    module_build_id = Column(Integer, ForeignKey("module_builds.id"))

    parent = relationship("ModuleBuild", back_populates="submodules")
