from sqlalchemy import Column, String, Integer, DateTime
from sqlalchemy.orm import relationship

from database import Base


class ModuleBuild(Base):
    __tablename__ = 'module_builds'

    id = Column(Integer, primary_key=True, index=True)
    module = Column(String)
    build_time = Column(String)
    result = Column(String)
    finished_at = Column(DateTime(timezone=True))
    maven_opts = Column(String)
    uname = Column(String)
    uuid = Column(String)
    cpu = Column(String)
    mem = Column(Integer)

    # submodules = relationship("SubModuleBuild", backref="module")
    submodules = relationship("SubModuleBuild", back_populates="parent")
