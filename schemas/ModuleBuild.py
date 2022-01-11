from typing import List
from datetime import datetime
from uuid import UUID

from pydantic import BaseModel

from .SubModuleBuild import SubModuleBuild, SubModuleBuildResponse
from .BuildStatus import BuildStatus


class ModuleBuild(BaseModel):
    module: str
    build_time: str
    result: BuildStatus
    finished_at: datetime
    maven_opts: str
    uname: str
    uuid: UUID
    cpu: str
    mem: int
    submodules: List[SubModuleBuild]

    class Config:
        orm_mode = True


class ModuleBuildResponse(BaseModel):
    id: int
    module: str
    # build_time: str
    # result: BuildStatus
    # finished_at: str
    # maven_opts: str
    # uname: str
    # uuid: UUID
    # cpu: str
    # mem: int
    submodules: List[SubModuleBuildResponse]

    class Config:
        orm_mode = True
